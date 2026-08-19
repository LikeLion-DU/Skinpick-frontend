import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/auth/presentation/pages/onboarding_welcome_page.dart';

/// 가입 직후 첫 화면(온보딩2). 여기서 나가는 길이 하나뿐이라 그 하나를 지킨다 —
/// 이 버튼이 엉뚱한 곳으로 가면 가입자가 촬영을 영영 시작하지 못한다.
void main() {
  const designSize = Size(402, 874);

  Widget host() => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: Routes.onboardingWelcome,
          routes: [
            GoRoute(
              path: Routes.onboardingWelcome,
              builder: (_, __) => const OnboardingWelcomePage(),
            ),
            // 촬영 화면 자체는 다른 테스트가 본다. 여기서 볼 것은 어디로 가는가다.
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
