import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/unauthorized_signal.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../recommendation/presentation/providers/recommendation_provider.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import '../../../skin_plate/presentation/providers/plate_notifier.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/skin_profile.dart';

/// 전역 인증 상태. 라우터가 이 값만 보고 화면을 결정한다. (PRD §10.5)
sealed class AuthState {
  const AuthState();
}

/// 저장된 토큰을 확인하는 중. S00 스플래시가 떠 있다.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AuthUser user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated({this.expired = false});

  /// 토큰이 만료돼 밀려난 경우. 로그인 화면이 안내 문구를 띄운다.
  final bool expired;
}

/// 스플래시(S00) 최소 노출 시간. 토큰 확인은 수백 ms 라 브랜드 화면이
/// 깜빡이고 사라졌다 — 확인이 먼저 끝나도 이 시간은 채운다. 확인이 이보다
/// 길면 그만큼만 떠 있는다(합산이 아니다).
///
/// 프로바이더로 둔 이유는 테스트다. restore 를 기다리는 테스트가 실제 3초를
/// 기다리게 둘 수 없어 Duration.zero 로 덮는다.
final splashMinimumHoldProvider =
    Provider<Duration>((_) => const Duration(seconds: 3));

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 인터셉터가 이미 토큰을 지웠다. 여기서는 상태만 되돌린다.
    ref.listen(unauthorizedSignalProvider, (_, __) {
      // **만료는 "세션이 살아 있었는데 끊겼다" 일 때만이다.** 로그아웃은 토큰을
      // 지우고 `_clearSession()` 으로 화면별 프로바이더를 무효화하는데, 그때
      // 아직 살아 있는 홈이 곧바로 다시 조회한다. 토큰이 없으니 401 이고,
      // 그 401 이 방금 세운 `expired: false` 를 덮어써서 로그인 화면이 스스로
      // 나간 사용자에게 "로그인이 만료되었습니다" 를 띄웠다.
      //
      // 여기서 이르게 return 하지 않는다 — 그러면 안내 문구뿐 아니라 세션 정리도
      // 같이 건너뛴다. 정리는 언제나 하고, 문구만 갈라진다.
      final wasLoggedIn = state is Authenticated;

      _clearSession();

      // 정리를 끝낸 **뒤에** 갈라진다. 복원 중(AuthInitial)이라면 이 401 은
      // restore() 가 보낸 /auth/me 의 것이고, 전환은 restore() 가 최소 노출을
      // 채운 다음에 한다. 여기서 앞질러 쓰면 라우터가 상태 변화를 보고 스플래시를
      // 일찍 떠나, 만료 토큰으로 켰을 때만 브랜드 화면이 깜빡이고 사라진다.
      // 상태가 사라지지는 않는다 — restore() 가 같은 Unauthenticated 를 세운다.
      if (state is AuthInitial) return;

      state = Unauthenticated(expired: wasLoggedIn);
    });

    // build 중에 state 를 건드리지 않는다. 복원은 다음 마이크로태스크에서 시작한다.
    Future<void>.microtask(restore);
    return const AuthInitial();
  }

  /// 앱 시작 시 1회. 토큰이 살아 있으면 그대로 홈으로 들어간다.
  ///
  /// 상태 전환은 [splashMinimumHoldProvider] 만큼 미룬다 — 라우터가 이 상태만
  /// 보고 스플래시를 떠나므로, 여기서 기다리는 것이 곧 스플래시 노출 시간이다.
  /// 화면(SplashPage)에 타이머를 두지 않는 이유다: 전환 규칙이 두 곳에 생기면
  /// 어느 날 한쪽만 고쳐진다.
  Future<void> restore() async {
    final hold = ref.read(splashMinimumHoldProvider);
    // zero(테스트)면 타이머를 아예 만들지 않는다 — Duration.zero 도 Future.delayed
    // 는 Timer 라서, 마지막 pump 뒤에 만들어지면 !timersPending 에 걸린다.
    final minimumHold = hold == Duration.zero
        ? Future<void>.value()
        : Future<void>.delayed(hold);

    // 저장소를 못 읽으면 던진다. 여기서 새면 state 를 영영 못 써서 AuthState 가
    // 초기값에 멈추고, 라우터가 그 상태를 스플래시로 고정해 재설치 말고는
    // 빠져나갈 길이 없다 — 최소 노출 3초가 정상 동작이라 멈춘 것인지 기다리는
    // 것인지 화면만 봐서는 구분도 안 되고, restore 는 관측되지 않는
    // 마이크로태스크로 시작해서 예외가 아무 데도 안 남는다.
    //
    // **원인별로 막지 않고 여기서 한 번에 막는다.** 저장소든 프로바이더든
    // 무엇이 던지든 결과는 같다 — 세션을 세울 수 없으니 로그인으로 보낸다.
    // 만료로 세우지는 않는다. 기기 문제로 밀려난 사용자에게 "로그인이
    // 만료되었습니다" 라고 말하게 된다.
    AuthState resolved;
    try {
      resolved = await _resolveSession();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('세션 복원 실패 — 로그인으로 보낸다: $error\n$stackTrace');
      }
      resolved = const Unauthenticated();
    }

    await minimumHold;
    state = resolved;
  }

  Future<AuthState> _resolveSession() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      return const Unauthenticated();
    }

    final result = await ref.read(authRepositoryProvider).getMe();
    return result.when(
      success: Authenticated.new,
      // 만료·위조 토큰이면 조용히 로그인으로. 토큰은 UnauthorizedInterceptor 가
      // 지운다 — /auth/me 의 401 은 세션 사망이라 인터셉터의 정리 대상이다.
      // 여기서 또 지우지 않는다. 지우는 곳이 둘이면 한쪽만 따라가는 날이 온다.
      //
      // 만료 여부는 그대로 들고 간다. 이 경로가 곧 "만료 토큰으로 앱을 켰다" 라서,
      // 버리면 사용자가 아무 설명 없는 빈 로그인 폼 앞에 떨어진다 — 로그인 화면은
      // 이 플래그를 보고 "로그인이 만료되었습니다" 를 띄운다.
      failure: (failure) =>
          Unauthenticated(expired: failure is AuthFailure && failure.expired),
    );
  }

  /// 성공하면 null. 실패 사유는 화면이 그대로 문구로 쓴다.
  Future<Failure?> login({required String email, required String password}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final result = await ref.read(authRepositoryProvider).signup(
          email: email,
          password: password,
          nickname: nickname,
        );

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  /// 로그인 화면의 "테스트 1·2·3" 버튼. 슬롯 1은 발표 시연 전용이다.
  Future<Failure?> loginWithTestAccount({int slot = 1}) async {
    final result =
        await ref.read(authRepositoryProvider).loginWithTestAccount(slot: slot);

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  /// S01c 설문과 S05 인라인 칩 두 곳에서 부른다. 넘긴 필드만 바뀐다.
  /// 건너뛰기는 값을 안 넘기는 것이다 — UNKNOWN 을 대신 보내면
  /// "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  Future<Failure?> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) async {
    final result = await ref.read(authRepositoryProvider).updateProfile(
          declaredSkinType: declaredSkinType,
          skinConcerns: skinConcerns,
          sleepPattern: sleepPattern,
          stressLevel: stressLevel,
          exerciseHabit: exerciseHabit,
          waterIntake: waterIntake,
        );

    return result.when<Failure?>(
      success: (user) {
        state = Authenticated(user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    _clearSession();
    state = const Unauthenticated();
  }

  /// 화면별 프로바이더는 keep-alive 라 로그아웃해도 살아남는다. 그대로 두면 다음
  /// 계정이 로그인했을 때 이전 사용자의 얼굴·음식 사진(수 MB)과 점수가 화면에 남는다.
  ///
  /// 세션이 끝나는 길은 두 개다 — 사용자가 누른 로그아웃과 401(토큰 만료·무효).
  /// 둘 다 여기를 지나게 한다. 한쪽만 걸면 만료로 튕긴 경우에 그대로 남는다.
  ///
  /// ponytail: 디스크에 남은 기록 사진(`<documents>/plates/*.jpg`)은 지우지 않는다.
  /// 사진은 기록을 삭제할 때만 지운다(PlateImageStore.delete) — 로그아웃은 기록을
  /// 지우는 것이 아니라 세션을 끊는 것이라, 여기서 지우면 다시 로그인한 사용자의
  /// 히스토리에서 사진만 사라진다. 계정 전환이 잦아지면 사용자별 디렉터리로 나눈다.
  void _clearSession() {
    ref
      ..invalidate(plateNotifierProvider)
      ..invalidate(skinAnalysisNotifierProvider)
      ..invalidate(latestSkinAnalysisProvider)
      // 촬영 안내에서 켜 놓고 나가 버린 경우가 남는다. 그대로 두면 다음 계정의
      // 첫 분석 결과 위에 프로필 설문이 난데없이 덮인다.
      ..invalidate(onboardingCaptureProvider)
      // family 전체를 비운다. 이전 사용자의 피부 지표로 만든 추천 문구가 남는다.
      ..invalidate(recommendationProvider);
  }
}
