import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/pages/onboarding_welcome_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';

/// 가입 직후 첫 화면(온보딩2). 나가는 길이 하나뿐이라 그 하나를 지킨다.
void main() {
  const designSize = Size(402, 874);

  /// 가입 직후 진입 경로. **실제 라우터 설정**을 세워 확인한다 — 촬영 화면이
  /// 카메라를 잡아 화면은 못 띄우지만, 경로 매칭은 빌더를 부르지 않는다.
  ///
  /// 두 가지를 본다.
  /// - 그 경로에 라우트가 **실제로 등록돼 있는가**. 상수만 고치고 라우트를 안
  ///   고치면 가입자가 "페이지 없음" 화면에 떨어지는데, signup 은 `go` 라 돌아올
  ///   길이 없다.
  /// - 매칭이 **홈을 깔고 그 위에 얹히는가**. 최상위로 옮기면 스택이 한 장뿐이라
  ///   방금 가입한 사용자가 뒤로가기를 누르는 순간 앱이 닫힌다.
  test('가입 직후 인사 경로는 홈을 깔고 그 위에 얹힌다', () {
    final container = ProviderContainer(
        overrides: [authNotifierProvider.overrideWith(_StubAuth.new)]);
    addTearDown(container.dispose);

    final matches = container
        .read(routerProvider)
        .configuration
        .findMatch(Uri.parse(Routes.onboardingWelcome))
        .matches
        .map((match) => match.matchedLocation)
        .toList();

    expect(matches, [Routes.home, Routes.onboardingWelcome]);
  });

  // 실제 촬영 화면은 카메라 하드웨어를 잡아 위젯 테스트로 띄울 수 없다. 여기서는
  // 도착지를 더미로 세우고 버튼이 그리로 가는지만 본다 — 경로가 실제 라우터에
  // 등록돼 있는지는 위 테스트가 지킨다.
  Widget host() => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: Routes.onboardingWelcome,
          routes: [
            GoRoute(
              path: Routes.onboardingWelcome,
              builder: (_, __) => const OnboardingWelcomePage(),
            ),
            GoRoute(
              path: Routes.onboardingCapture,
              builder: (_, __) => const Scaffold(body: Text('촬영 안내')),
            ),
          ],
        ),
      );

  testWidgets('시작하기를 누르면 촬영 안내로 간다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('저와 함께 피부고민을 해결해 보아요'), findsOneWidget);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('촬영 안내'), findsOneWidget);
  });

  testWidgets('작은 기기에서도 시작하기가 화면 안에 남는다', (tester) async {
    // 장식(300)이 들어 있어 스크롤이 없으면 버튼이 화면 밖으로 밀린다 —
    // 그러면 가입자가 첫 화면에서 갇힌다.
    await tester.binding.setSurfaceSize(const Size(320, 560));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('시작하기'), 100);
    expect(find.text('시작하기'), findsOneWidget);
  });
}

/// 라우터의 redirect 는 로그인 여부만 본다. 세션만 세워 주면 된다.
class _StubAuth extends AuthNotifier {
  @override
  AuthState build() => const Authenticated(AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
      ));
}
