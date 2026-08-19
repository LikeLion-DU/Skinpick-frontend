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
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // 키스토어가 리셋되면(기기 초기화·백업 복원·일부 OEM 업데이트) 저장된
        // 값을 못 풀어 read 가 예외를 던진다. 이 옵션이 켜져 있으면 라이브러리가
        // 못 푸는 값을 지우고 null 을 돌려준다 — 앱이 스스로 빠져나온다.
        resetOnError: true,
      ),
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
