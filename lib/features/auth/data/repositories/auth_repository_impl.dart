import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_dtos.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  /// 토큰 저장을 Repository 안에서 끝낸다.
  /// Notifier 가 저장까지 맡으면 로그인 경로 3개(가입·로그인·테스트)마다
  /// 저장을 잊을 자리가 생긴다.
  @override
  Future<Result<AuthSession>> signup({
    required String email,
    required String password,
    required String nickname,
  }) =>
      callApi(() async {
        final response = await _remote.signup(SignupRequestDto(
          email: email,
          password: password,
          nickname: nickname,
        ));
        await _tokenStorage.save(response.accessToken);
        return response.toEntity();
      });

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) =>
      callApi(() async {
        final response = await _remote.login(
          LoginRequestDto(email: email, password: password),
        );
        await _tokenStorage.save(response.accessToken);
        return response.toEntity();
      });

  @override
  Future<Result<AuthSession>> loginWithTestAccount({int slot = 1}) =>
      callApi(() async {
        final response = await _remote.testLogin(slot);
        await _tokenStorage.save(response.accessToken);
        return response.toEntity();
      });

  @override
  Future<Result<AuthUser>> getMe() =>
      callApi(() async => (await _remote.me()).toEntity());

  @override
  Future<Result<AuthUser>> updateSkinType(SkinType skinType) =>
      callApi(() async => (await _remote.updateSkinType(skinType)).toEntity());

  /// 서버는 상태를 갖지 않으므로 로컬 토큰 삭제가 곧 로그아웃이다.
  @override
  Future<void> logout() => _tokenStorage.clear();
}
