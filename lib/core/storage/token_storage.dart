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

  /// **던진다.** "토큰이 없다" 와 "토큰 저장소를 못 읽는다" 는 다른 사실이라
  /// 여기서 뭉개지 않는다. null 로 접으면 헤더 없이 나간 요청이 401 을 받고,
  /// 그 401 이 멀쩡한 세션을 지운다 — iOS 는 기기 복원 직후나 화면이 잠긴 동안
  /// 키체인이 막히는데, 분석 업로드(25~32초) 중에 화면을 잠그면 바로 그 상황이다.
  ///
  /// 못 읽었을 때 무엇을 할지는 부르는 쪽이 정한다. 복원은 로그인 화면으로
  /// 보내고(`AuthNotifier.restore`), 요청 인터셉터는 헤더 없이 보낸다
  /// (`AuthInterceptor`). 둘의 답이 다르기 때문에 여기서 정할 수 없다.
  Future<String?> read() => _storage.read(key: _accessTokenKey);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);

}
