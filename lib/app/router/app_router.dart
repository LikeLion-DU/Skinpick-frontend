import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/skin_profile_page.dart';
import '../../features/auth/presentation/pages/skin_type_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/recommendation/presentation/pages/recommendation_page.dart';
import '../../features/skin_plate/presentation/pages/plate_detail_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_capture_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_insight_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_loading_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_result_page.dart';
import '../../features/skin_plate/presentation/pages/food_capture_page.dart';
import '../../features/skin_plate/presentation/pages/plate_history_page.dart';
import '../../features/skin_plate/presentation/pages/plate_result_page.dart';
import '../../features/skin_plate/presentation/pages/weekly_report_page.dart';

/// 경로를 문자열 리터럴로 흩뿌리면 오타가 런타임까지 살아남는다.
class Routes {
  const Routes._();

  static const splash = '/splash';            // S00
  static const login = '/auth/login';         // S01
  static const signup = '/auth/signup';       // S01b
  static const skinType = '/onboarding/skin-type'; // S01c
  static const lifestyle = '/onboarding/lifestyle'; // 인사이트(S10) 진입 전 습관 입력
  // 촬영을 마치고 분석을 기다리는 동안(S04 위) 뜨는 프로필 설문. 같은 화면을
  // 건너뛰기 없는 모드로 쓴다 — 설문을 한 벌 더 만들면 둘 중 하나는 반드시 낡는다.
  static const onboardingProfile = '/onboarding/profile';
  static const home = '/home';                // S02
  // 가입 직후의 촬영 진입점. 화면은 `/skin/capture` 와 **같은** SkinCapturePage 다 —
  // 경로만 홈의 하위라 `go` 한 번으로 홈이 스택 바닥에 깔린다.
  static const onboardingCapture = '/home/skin-capture';
  static const skinCapture = '/skin/capture'; // S03
  static const skinLoading = '/skin/loading'; // S04
  static const skinResult = '/skin/result';   // S05
  static const foodCapture = '/plate/capture'; // S06
  static const plateResult = '/plate/result';  // S07
  static const recommendations = '/recommendations'; // S08
  static const plateHistory = '/plate/history'; // S09
  static const skinInsight = '/skin/insight'; // S10
  static const weeklyReport = '/plate/report'; // S11 — 주간 피부 식단 리포트
  static const skinProfile = '/profile';       // S12 — 나의 피부 프로필
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,

    /// 가드를 화면마다 넣지 않는다. 한 곳에서 처리하면 8~9일차에 화면을 급히
    /// 추가할 때 인증 체크를 잊는 사고가 구조적으로 불가능해진다. (PRD §10.5)
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final goingToAuth = location.startsWith('/auth');
      final atSplash = location == Routes.splash;

      return switch (auth) {
        AuthInitial() => atSplash ? null : Routes.splash,
        Unauthenticated() => goingToAuth ? null : Routes.login,
        // 피부 타입 선택(S01c)은 이미 로그인한 뒤에 거치는 화면이라
        // /auth 가 아니라 /onboarding 아래에 둔다. /auth 에 두면 이 분기가
        // 가입 직후 사용자를 곧바로 홈으로 밀어내 S01c 를 영영 못 본다.
        Authenticated() => (goingToAuth || atSplash) ? Routes.home : null,
      };
    },
    routes: <RouteBase>[
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.signup, builder: (_, __) => const SignupPage()),
      GoRoute(path: Routes.skinType, builder: (_, __) => const SkinTypePage()),
      // 인사이트가 습관을 받으러 보내는 화면. 같은 화면을 습관 전용 모드로 쓴다 —
      // 습관 UI 를 한 벌 더 만들면 둘 중 하나는 반드시 낡는다.
      GoRoute(
        path: Routes.lifestyle,
        builder: (_, __) =>
            const SkinTypePage(mode: ProfileFormMode.lifestyle),
      ),
      GoRoute(
        path: Routes.onboardingProfile,
        builder: (_, __) =>
            const SkinTypePage(mode: ProfileFormMode.onboarding),
      ),
      // 가입 직후 촬영을 홈의 **하위**에 둔다. `go` 한 번으로 홈 위에 얹혀서,
      // 촬영을 거쳐 결과(S05)까지 갔을 때 스택이 [홈, 결과]가 된다 — 홈에서
      // 촬영을 시작한 경우와 같은 모양이라 뒤로가기가 홈으로 간다. 최상위에
      // 두면 스택 바닥이 카메라라 결과에서 나갈 곳이 없다.
      //
      // 페이지는 아래 `/skin/capture` 와 같은 것을 쓴다. 안내 화면은 그 페이지가
      // 이미 갖고 있다(`_introView`) — 따로 만들면 가입자가 같은 안내를 두 번 본다.
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const HomePage(),
        routes: <RouteBase>[
          // 하위 경로를 리터럴로 적지 않는다. 상수와 따로 놀면 상수만 바꿨을 때
          // analyze 도 테스트도 통과한 채로 가입자가 "페이지 없음" 화면에 떨어진다
          // — signup 은 `go` 라 돌아올 길도 없다. 여기서 잘라 쓰면 어긋날 수 없다.
          GoRoute(
            path: Routes.onboardingCapture.substring(Routes.home.length + 1),
            builder: (_, __) => const SkinCapturePage(onboarding: true),
          ),
        ],
      ),
      GoRoute(path: Routes.skinCapture, builder: (_, __) => const SkinCapturePage()),
      GoRoute(path: Routes.skinLoading, builder: (_, __) => const SkinLoadingPage()),
      GoRoute(path: Routes.skinResult, builder: (_, __) => const SkinResultPage()),
      GoRoute(path: Routes.foodCapture, builder: (_, __) => const FoodCapturePage()),
      GoRoute(path: Routes.plateResult, builder: (_, __) => const PlateResultPage()),
      // 저장된 기록 열람. 분석 직후 화면과 경로 접두어를 공유하지만 페이지는
      // 다르다 — S07 은 저장 생명주기를 쥔 Notifier 위에 있고 여기는 id 조회다.
      GoRoute(
        path: '${Routes.plateResult}/:plateId',
        builder: (_, state) => PlateDetailPage(
          plateId: int.parse(state.pathParameters['plateId']!),
        ),
      ),
      GoRoute(path: Routes.plateHistory, builder: (_, __) => const PlateHistoryPage()),
      GoRoute(path: Routes.weeklyReport, builder: (_, __) => const WeeklyReportPage()),
      GoRoute(path: Routes.skinProfile, builder: (_, __) => const SkinProfilePage()),
      GoRoute(
        path: '${Routes.recommendations}/:skinAnalysisId',
        builder: (_, state) => RecommendationPage(
          skinAnalysisId: int.parse(state.pathParameters['skinAnalysisId']!),
        ),
      ),
      GoRoute(
        path: '${Routes.skinInsight}/:skinAnalysisId',
        builder: (_, state) => SkinInsightPage(
          skinAnalysisId: int.parse(state.pathParameters['skinAnalysisId']!),
        ),
      ),
    ],
  );
});

/// AuthState 의 **종류**가 바뀌면 go_router 가 redirect 를 다시 평가하게 한다.
///
/// 값이 바뀔 때마다 알리면 안 된다. redirect 는 로그인 여부만 보므로 프로필 저장처럼
/// `Authenticated` 안의 값만 달라진 경우엔 어차피 같은 답을 내는데, 알리는 것만으로
/// go_router 가 라우트를 다시 세워 그 순간 열려 있던 화면이 통째로 새로 만들어진다.
///
/// 실제로 났던 증상: 프로필 설문에서 저장을 누르면 서버에는 잘 들어가는데 화면이
/// 닫히지 않고 설문이 처음부터 다시 떴다. 저장 직후 상태가 바뀌며 이 화면이
/// 헐리는 바람에, 뒤이어 실행될 "닫고 돌아가기"가 영영 실행되지 않았다.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        if (previous.runtimeType != next.runtimeType) notifyListeners();
      },
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
