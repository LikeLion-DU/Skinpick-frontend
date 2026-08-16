import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';

/// 촬영 화면이 결과 아래에 남아 있으면 안 된다.
///
/// 예전에는 촬영 → 결과를 `push` 로 쌓아서, 결과에서 뒤로 가면 카메라가 되살아났다.
/// 사용자는 "촬영 이전 화면"으로 나가려던 것이지 다시 찍으려던 게 아니다.
/// 카메라는 [다시 촬영] 을 명시적으로 골랐을 때만 떠야 한다.
///
/// 실제 촬영 화면은 카메라 하드웨어를 잡으므로 위젯 테스트로 띄울 수 없다.
/// 여기서는 같은 전이 방식(push / pushReplacement)을 쓰는 라우터로 스택만 검증한다.
void main() {
  /// 이동 뒤 남아 있는 라우트 경로들.
  List<String> stackOf(GoRouter router) => router
      .routerDelegate.currentConfiguration.matches
      .map((match) => match.matchedLocation)
      .toList();

  GoRouter build() => GoRouter(
        initialLocation: Routes.home,
        routes: [
          for (final path in [
            Routes.home,
            Routes.skinCapture,
            Routes.skinLoading,
            Routes.skinResult,
            Routes.foodCapture,
            Routes.plateResult,
          ])
            GoRoute(path: path, builder: (_, __) => Text(path)),
        ],
      );

  Future<void> pump(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('촬영 전 뒤로가기 — 촬영 이전 화면으로 돌아간다', (tester) async {
    final router = build();
    await pump(tester, router);

    // 홈에서 카메라로 들어가는 것은 push 다. 아직 찍지 않았으니 되돌아갈 자리가 있어야 한다.
    router.push(Routes.foodCapture);
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home, Routes.foodCapture]);

    router.pop();
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home]);
  });

  testWidgets('음식: 촬영 → 결과 → 뒤로가기 — 카메라가 되살아나지 않는다', (tester) async {
    final router = build();
    await pump(tester, router);

    router.push(Routes.foodCapture);
    await tester.pumpAndSettle();

    // 찍은 뒤에는 교체다. 이 한 줄이 이 테스트의 전부다.
    router.pushReplacement(Routes.plateResult);
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home, Routes.plateResult]);
    expect(stackOf(router), isNot(contains(Routes.foodCapture)));

    router.pop();
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home]);
  });

  testWidgets('음식: 결과 → 다시 촬영 → 카메라가 뜬다', (tester) async {
    final router = build();
    await pump(tester, router);

    router.push(Routes.foodCapture);
    router.pushReplacement(Routes.plateResult);
    await tester.pumpAndSettle();

    // 명시적으로 고른 경우에만 카메라가 돌아온다.
    router.pushReplacement(Routes.foodCapture);
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home, Routes.foodCapture]);
  });

  testWidgets('음식: 다시 촬영 → 촬영 → 결과 → 뒤로가기 — 스택이 불어나지 않는다', (tester) async {
    final router = build();
    await pump(tester, router);

    router.push(Routes.foodCapture);
    router.pushReplacement(Routes.plateResult);
    router.pushReplacement(Routes.foodCapture);
    router.pushReplacement(Routes.plateResult);
    await tester.pumpAndSettle();

    // 재촬영을 반복해도 홈 위에 한 장만 쌓인다. push 였다면 여기가 4장이다.
    expect(stackOf(router), [Routes.home, Routes.plateResult]);

    router.pop();
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home]);
  });

  testWidgets('피부: 촬영 → 로딩 → 결과 → 뒤로가기 — 카메라도 로딩도 남지 않는다', (tester) async {
    final router = build();
    await pump(tester, router);

    router.push(Routes.skinCapture);
    router.pushReplacement(Routes.skinLoading);
    router.pushReplacement(Routes.skinResult);
    await tester.pumpAndSettle();

    expect(stackOf(router), [Routes.home, Routes.skinResult]);

    router.pop();
    await tester.pumpAndSettle();
    expect(stackOf(router), [Routes.home]);
  });

  testWidgets('피부: 첫 사용자는 결과 앞에 생활 습관 단계가 낀다', (tester) async {
    final router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        for (final path in [
          Routes.home,
          Routes.skinCapture,
          Routes.skinLoading,
          Routes.lifestyle,
          Routes.skinResult,
        ])
          GoRoute(path: path, builder: (_, __) => Text(path)),
      ],
    );
    await pump(tester, router);

    router.push(Routes.skinCapture);
    router.pushReplacement(Routes.skinLoading);
    router.pushReplacement(Routes.lifestyle);
    router.pushReplacement(Routes.skinResult);
    await tester.pumpAndSettle();

    // 강제 단계도 교체라 결과에서 뒤로 가면 습관 화면으로 되돌아가지 않는다.
    expect(stackOf(router), [Routes.home, Routes.skinResult]);
  });
}
