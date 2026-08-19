import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT를 기기 보안 저장소(iOS Keychain / Android Keystore)에 보관한다.
///
/// SharedPreferences를 쓰지 않는 이유: 평문으로 남는다.
/// 코드량 차이는 거의 없으므로 처음부터 안전한 쪽을 쓴다.
class TokenStorage {
  static const _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  const TokenStorage([
    this._storage = const FlutterSecureStorage(
      // **resetOnError 를 켜지 마라.** 이름과 달리 null 을 돌려주지 않는다 —
      // 안드로이드 플러그인은 예외를 만나면 secureStorage.deleteAll() 을 부른 뒤
      // `result.success("Data has been reset")` 로 답한다
      // (FlutterSecureStoragePlugin.java). 그 문자열이 그대로 토큰 자리에 앉아
      // `Authorization: Bearer Data has been reset` 이 나간다. write 도 같은
      // 처리라, 저장이 실패해도 성공으로 보이고 토큰은 어디에도 없다.
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ]);

  Future<void> save(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  /// **여기서 던지지 않는다.** 읽지 못한 토큰은 없는 토큰과 같게 다룬다.
  ///
  /// 부르는 곳이 셋이고(복원·요청 인터셉터·[hasToken]) 셋 다 예외를 받을 준비가
  /// 안 돼 있다. 특히 복원에서 새면 AuthState 가 초기값에 멈추고, 라우터가 그
  /// 상태를 스플래시로 고정해 재설치 말고는 빠져나갈 길이 없다. 인터셉터에서
  /// 새면 로그인 요청 자체가 실패해서 다시 로그인할 수도 없다.
  ///
  /// **지우지는 않는다.** iOS 는 기기 복원 직후 첫 잠금 해제 전까지 키체인이
  /// 막히는데, 그때 지우면 멀쩡한 세션이 날아간다. 값이 정말 깨진 경우는
  /// `resetOnError` 가 이미 정리하고, 그 밖의 경우는 다음 로그인이 덮어쓴다.
  Future<String?> read() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (error) {
      if (kDebugMode) debugPrint('토큰 읽기 실패 — 없는 것으로 다룬다: $error');
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _accessTokenKey);

  Future<bool> get hasToken async => (await read()) != null;
}
