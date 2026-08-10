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
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ]);

  Future<void> save(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> read() => _storage.read(key: _accessTokenKey);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);

  Future<bool> get hasToken async => (await read()) != null;
}
