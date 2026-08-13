import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/skin_type_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/recommendation/presentation/pages/recommendation_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_capture_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_loading_page.dart';
import '../../features/skin_analysis/presentation/pages/skin_result_page.dart';
import '../../features/skin_plate/presentation/pages/food_capture_page.dart';
import '../../features/skin_plate/presentation/pages/plate_result_page.dart';

/// 경로를 문자열 리터럴로 흩뿌리면 오타가 런타임까지 살아남는다.
class Routes {
  const Routes._();

  static const splash = '/splash';            // S00
  static const login = '/auth/login';         // S01
  static const signup = '/auth/signup';       // S01b
  static const skinType = '/onboarding/skin-type'; // S01c
  static const home = '/home';                // S02
  static const skinCapture = '/skin/capture'; // S03
  static const skinLoading = '/skin/loading'; // S04
  static const skinResult = '/skin/result';   // S05
  static const foodCapture = '/plate/capture'; // S06
  static const plateResult = '/plate/result';  // S07
  static const recommendations = '/recommendations'; // S08
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
      GoRoute(path: Routes.home, builder: (_, __) => const HomePage()),
      GoRoute(path: Routes.skinCapture, builder: (_, __) => const SkinCapturePage()),
      GoRoute(path: Routes.skinLoading, builder: (_, __) => const SkinLoadingPage()),
      GoRoute(path: Routes.skinResult, builder: (_, __) => const SkinResultPage()),
      GoRoute(path: Routes.foodCapture, builder: (_, __) => const FoodCapturePage()),
      GoRoute(path: Routes.plateResult, builder: (_, __) => const PlateResultPage()),
      GoRoute(
        path: '${Routes.recommendations}/:skinAnalysisId',
        builder: (_, state) => RecommendationPage(
          skinAnalysisId: int.parse(state.pathParameters['skinAnalysisId']!),
        ),
      ),
    ],
  );
});

/// AuthState 가 바뀌면 go_router 가 redirect 를 다시 평가하게 한다.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
