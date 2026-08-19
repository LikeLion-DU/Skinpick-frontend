import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/home/presentation/pages/home_page.dart';
import 'package:skinplate/features/report/presentation/pages/report_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_history_provider.dart';
import 'package:skinplate/shared/enums/skin_type.dart';
import 'package:skinplate/shared/widgets/app_bottom_nav.dart';

/// 하단 네비 개편이 실제로 반영됐는지.
///
/// 기록은 **사라진 것이 아니라 자리를 옮겼다.** 네비에서 빠지고 홈 "오늘의 기록"
/// 카드의 제목 줄(화살표)로 들어간다. 확정 시안이 별도 텍스트 버튼을 없애고
/// 카드 헤더 자체를 눌리게 만들었다.
void main() {
  const designSize = Size(402, 874);

  testWidgets('하단 네비의 세 번째 자리는 리포트다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);

    AppTab? selected;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          current: AppTab.home,
          onCapture: () {},
          onTabSelected: (tab) => selected = tab,
        ),
      ),
    ));

    // 오른쪽 탭. 아이콘은 그대로 쓰되 뜻만 리포트로 바뀌었다.
    await tester.tap(find.byType(GestureDetector).at(1), warnIfMissed: false);
    expect(selected, AppTab.report);
  });

  testWidgets('기록 화면 경로는 그대로 살아 있다', (tester) async {
    // 네비에서 뺀 것이지 기능을 지운 것이 아니다. 상수가 사라지면
    // 홈 "오늘의 기록" 카드의 화살표가 컴파일되지 않는다.
    expect(Routes.plateHistory, '/plate/history');
    expect(Routes.report, '/report');
  });

  testWidgets('리포트 화면 — 오늘의 리포트가 기본 선택이고 월간을 붙일 수 있다', (tester) async {
    // 탭이 목록이라 월간은 한 줄만 늘리면 된다. 각 탭의 내용은 report_test 가 본다.
    expect(ReportTab.values.first, ReportTab.daily);
    expect(ReportTab.values.map((tab) => tab.label).toList(),
        ['오늘의 리포트', '주간 리포트']);
  });

  testWidgets('홈 — 하단 네비는 리포트로, 기록은 카드 제목 줄로 간다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);

    final container = ProviderContainer(overrides: [
      // 홈이 실제로 보는 것만 채운다. 나머지는 기본 구현이 서버를 부르지 않는다.
      latestSkinAnalysisProvider.overrideWith((ref) async => const Success(null)),
      plateHistoryProvider.overrideWith((ref) async => const Success([])),
      plateImageDirectoryProvider.overrideWith((ref) async => null),
    ]);
    addTearDown(container.dispose);

    container.read(authNotifierProvider.notifier).state = const Authenticated(
      AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
        declaredSkinType: SkinType.oily,
      ),
    );

    final router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(path: Routes.home, builder: (_, __) => const HomePage()),
        GoRoute(path: Routes.report, builder: (_, __) => const Text('리포트 화면')),
        GoRoute(
            path: Routes.plateHistory, builder: (_, __) => const Text('기록 화면')),
        GoRoute(path: Routes.foodCapture, builder: (_, __) => const Text('촬영')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    // 기록으로 가는 문이 홈에 남아 있어야 한다. 네비에서 뺐으므로 이게 유일하다.
    // 시안에서 텍스트 버튼이 사라지고 카드 제목 줄 전체가 눌린다 — 제목을
    // 눌러 이동하지 않으면 저장된 기록에 닿을 방법이 없어진다.
    expect(find.text('오늘의 기록'), findsOneWidget);
    await tester.tap(find.text('오늘의 기록'));
    await tester.pumpAndSettle();
    expect(find.text('기록 화면'), findsOneWidget);

    router.go(Routes.home);
    await tester.pumpAndSettle();

    // 하단 네비의 오른쪽 자리는 이제 리포트다.
    tester
        .widget<AppBottomNav>(find.byType(AppBottomNav))
        .onTabSelected(AppTab.report);
    await tester.pumpAndSettle();
    expect(find.text('리포트 화면'), findsOneWidget);
  });
}
