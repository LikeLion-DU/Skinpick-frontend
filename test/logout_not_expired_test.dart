import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/network/unauthorized_signal.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/shared/enums/skin_type.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';

/// 스스로 로그아웃한 사용자에게 "로그인이 만료되었습니다" 라고 말하면 안 된다.
///
/// 로그아웃은 토큰을 지우고 화면별 프로바이더를 무효화하는데, 그때 아직 살아
/// 있는 홈이 곧바로 다시 조회한다. 토큰이 없으니 401 이고, 그 401 이 방금 세운
/// 상태를 덮어써서 로그인 화면에 만료 안내가 떴다. (2026-08-17 에뮬레이터 QA)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
  );

  // 저장된 토큰이 있어야 restore() 가 세션을 세운다.
  setUp(() => FlutterSecureStorage.setMockInitialValues(
      <String, String>{'access_token': 'jwt'}));

  ProviderContainer container() {
    final made = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_StubRepository(user)),
      // 스플래시 최소 노출(실기기 3초)을 끈다 — settled() 는 500ms 만 기다린다.
      splashMinimumHoldProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(made.dispose);
    return made;
  }

  /// restore() 는 마이크로태스크로 시작해 보안 저장소를 읽는다. 한 프레임으로는
  /// 안 끝나므로 상태가 실제로 바뀔 때까지 기다린다.
  Future<void> settled(ProviderContainer made) async {
    for (var i = 0; i < 50; i++) {
      if (made.read(authNotifierProvider) is! AuthInitial) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('로그아웃 뒤에 도착한 401 은 만료로 읽지 않는다', () async {
    final made = container();
    made.listen(authNotifierProvider, (_, __) {});

    await settled(made);
    expect(made.read(authNotifierProvider), isA<Authenticated>());

    await made.read(authNotifierProvider.notifier).logout();

    // 무효화된 프로바이더가 토큰 없이 보낸 요청의 401 이 뒤늦게 도착한다.
    made.read(unauthorizedSignalProvider.notifier).fire();

    final state = made.read(authNotifierProvider);
    expect(state, isA<Unauthenticated>());
    expect((state as Unauthenticated).expired, isFalse);
  });

  test('세션이 살아 있을 때 온 401 은 그대로 만료다', () async {
    final made = container();
    made.listen(authNotifierProvider, (_, __) {});

    await settled(made);
    expect(made.read(authNotifierProvider), isA<Authenticated>());

    made.read(unauthorizedSignalProvider.notifier).fire();

    final state = made.read(authNotifierProvider);
    expect(state, isA<Unauthenticated>());
    expect((state as Unauthenticated).expired, isTrue);
  });
}

/// 저장된 토큰이 살아 있는 사용자. 로그아웃은 토큰 삭제뿐이라 여기선 no-op 이다.
class _StubRepository implements AuthRepository {
  _StubRepository(this.user);

  final AuthUser user;

  @override
  Future<Result<AuthUser>> getMe() async => Success(user);

  @override
  Future<void> logout() async {}

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthSession>> loginWithTestAccount({int slot = 1}) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthSession>> signup({
    required String email,
    required String password,
    required String nickname,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthUser>> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) =>
      throw UnimplementedError();
}
