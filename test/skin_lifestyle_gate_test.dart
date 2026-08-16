import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/shared/enums/skin_type.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_loading_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';

/// 생활 습관 게이트가 **어디에 서 있는가**.
///
/// 예전에는 분석과 결과 사이(S04b)에 서 있었다. 그 근거는 "인사이트가 습관 없이
/// 굳는다" 였는데, 인사이트는 분석 시점이 아니라 사용자가 S10 에 들어갈 때 서버가
/// 처음 만든다(`GET /skin-insights` 가 get-or-create). 그래서 게이트를 S10 으로
/// 옮겼다.
///
/// 여기서는 옮긴 자리의 **앞쪽 절반**을 지킨다 — 습관이 비어 있어도 피부 분석
/// 결과까지는 그냥 볼 수 있어야 한다. 뒤쪽 절반(S10 이 조회 전에 막는가)은
/// `skin_insight_widgets_test.dart` 가 지킨다.
void main() {
  final analysis = SkinAnalysisDto.fromJson(
    (jsonDecode(File('test/fixtures/skin_latest.json').readAsStringSync())
        as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  ).toEntity();

  /// 습관 네 칸이 전부 비어 있다 — 옛 정책이라면 여기서 막혔을 사용자다.
  const emptyLifestyle = AuthUser(
    userId: 1,
    email: 'fresh@skinplate.app',
    nickname: '새사용자',
    declaredSkinType: SkinType.oily,
  );

  GoRouter buildRouter() => GoRouter(
        initialLocation: Routes.skinLoading,
        routes: [
          GoRoute(
              path: Routes.skinLoading,
              builder: (_, __) => const SkinLoadingPage()),
          GoRoute(
              path: Routes.skinResult, builder: (_, __) => const Text('결과')),
          GoRoute(
              path: Routes.lifestyle, builder: (_, __) => const Text('생활습관')),
        ],
      );

  String locationOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.path;

  testWidgets('습관이 비어 있어도 분석이 끝나면 결과로 간다', (tester) async {
    final container = ProviderContainer(overrides: [
      authNotifierProvider.overrideWith(() => _StubAuth(emptyLifestyle)),
      skinAnalysisNotifierProvider.overrideWith(_StubAnalysis.new),
    ]);
    addTearDown(container.dispose);

    final router = buildRouter();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    // 로딩 화면의 단계 안내가 계속 돌아 pumpAndSettle 은 끝나지 않는다.
    await tester.pump(const Duration(milliseconds: 100));

    expect(locationOf(router), Routes.skinLoading);

    // 서버 응답이 도착했다.
    (container.read(skinAnalysisNotifierProvider.notifier) as _StubAnalysis)
        .deliver(analysis);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(locationOf(router), Routes.skinResult,
        reason: '습관이 비었다고 결과를 막으면, 5~8초 기다린 분석을 다시 볼 길이 없다');
    expect(locationOf(router), isNot(Routes.lifestyle));
  });

  testWidgets('습관을 다 채운 사용자도 같은 길로 간다', (tester) async {
    final container = ProviderContainer(overrides: [
      authNotifierProvider.overrideWith(() => _StubAuth(const AuthUser(
            userId: 2,
            email: 'done@skinplate.app',
            nickname: '완료유저',
            declaredSkinType: SkinType.oily,
            sleepPattern: SleepPattern.enough,
            stressLevel: StressLevel.low,
            exerciseHabit: ExerciseHabit.frequent,
            waterIntake: WaterIntake.enough,
          ))),
      skinAnalysisNotifierProvider.overrideWith(_StubAnalysis.new),
    ]);
    addTearDown(container.dispose);

    final router = buildRouter();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    (container.read(skinAnalysisNotifierProvider.notifier) as _StubAnalysis)
        .deliver(analysis);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(locationOf(router), Routes.skinResult);
  });
}

/// 로딩 상태로 시작해 [deliver] 로 결과를 밀어 넣는다. 화면이 `ref.listen` 으로
/// 전이를 잡으므로 **값이 바뀌어야** 한다 — 처음부터 결과를 들고 있으면 안 된다.
class _StubAnalysis extends SkinAnalysisNotifier {
  @override
  SkinAnalysisState build() =>
      const SkinAnalysisState(analysis: AsyncLoading<SkinAnalysis?>());

  void deliver(SkinAnalysis analysis) =>
      state = SkinAnalysisState(analysis: AsyncData<SkinAnalysis?>(analysis));
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this._user);

  final AuthUser _user;

  @override
  AuthState build() => Authenticated(_user);
}
