import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/skin_profile.dart';
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
        return _sessionWithProfile(response);
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
        return _sessionWithProfile(response);
      });

  @override
  Future<Result<AuthSession>> loginWithTestAccount({int slot = 1}) =>
      callApi(() async {
        final response = await _remote.testLogin(slot);
        return _sessionWithProfile(response);
      });

  /// 토큰을 저장한 뒤 `/auth/me` 로 프로필을 마저 받아 세션을 만든다.
  ///
  /// 로그인 응답(`AuthResponse`)은 id·이메일·닉네임뿐이다. 프로필은 `/auth/me` 만
  /// 준다. 이걸 안 부르면 로그인으로 시작한 세션은 앱을 껐다 켜기 전까지 고민·습관이
  /// 빈 사용자로 남고, 그 상태에서 설문에 들어가면 빈 화면이 뜬다 — 거기서 제출하면
  /// 서버가 고민 컬렉션을 통째로 갈아 끼우므로 안 고른 고민이 영구히 지워진다.
  ///
  /// 저장이 먼저다. 인터셉터가 토큰을 붙여야 `/auth/me` 가 401 을 안 맞는다.
  Future<AuthSession> _sessionWithProfile(AuthResponseDto response) async {
    await _tokenStorage.save(response.accessToken);
    return AuthSession(
      accessToken: response.accessToken,
      expiresIn: response.expiresIn,
      user: (await _remote.me()).toEntity(),
    );
  }

  @override
  Future<Result<AuthUser>> getMe() =>
      callApi(() async => (await _remote.me()).toEntity());

  @override
  Future<Result<AuthUser>> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) =>
      callApi(() async => (await _remote.updateProfile(
            declaredSkinType: declaredSkinType,
            skinConcerns: skinConcerns,
            sleepPattern: sleepPattern,
            stressLevel: stressLevel,
            exerciseHabit: exerciseHabit,
            waterIntake: waterIntake,
          ))
              .toEntity());

  /// 서버는 상태를 갖지 않으므로 로컬 토큰 삭제가 곧 로그아웃이다.
  @override
  Future<void> logout() => _tokenStorage.clear();
}
