import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/widgets/app_widgets.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_loading_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 가입 직후 순서: 촬영 안내(S01d) → 촬영 → **프로필 설문** → 결과(S05).
///
/// 설문은 로딩 화면(S04) 위에 얹힌다. 분석은 촬영하는 순간 이미 시작되므로
/// (`skin_capture_page._start` 의 unawaited analyze) 5~8초 대기가 설문에 흡수되고,
/// 설문에서 나가도 밑에 로딩이 남아 그대로 결과로 이어진다 — 잃는 분석이 없다.
void main() {
  const designSize = Size(402, 874);

  const fresh = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
  );

  final analysis = SkinAnalysis(
    id: 101,
    skinScore: 58,
    metrics: const SkinMetrics(
      hydration: 38,
      oil: 52,
      redness: 64,
      trouble: 25,
      barrier: 78,
    ),
    summary: '건조와 홍조가 함께 보여요.',
    highlights: const [
      Highlight(label: '피부 장벽 양호', status: HighlightStatus.good),
    ],
    analyzedAt: DateTime(2026, 8, 16, 10, 30),
  );

  Widget loadingHost({
    required bool onboarding,
    AuthUser profile = fresh,
    SkinAnalysis? ready,
  }) =>
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(profile)),
          onboardingCaptureProvider.overrideWith((ref) => onboarding),
          skinAnalysisNotifierProvider.overrideWith(() => _StubAnalysis(ready)),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: GoRouter(
            initialLocation: Routes.skinLoading,
            routes: [
              GoRoute(
                path: Routes.skinLoading,
                builder: (_, __) => const SkinLoadingPage(),
              ),
              // 설문·결과 자체는 다른 테스트가 본다. 여기서 볼 것은 어디로 가는가다.
              GoRoute(
                path: Routes.onboardingProfile,
                builder: (_, __) => const Scaffold(body: Text('설문')),
              ),
              GoRoute(
                path: Routes.skinResult,
                builder: (_, __) => const Scaffold(body: Text('결과')),
              ),
            ],
          ),
        ),
      );

  // 로딩 화면은 분석을 기다리는 동안 애니메이션을 돌려 pumpAndSettle 이 끝나지
  // 않는다. 한 프레임(postFrame 콜백)과 라우트 전환 시간만 흘린다.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('온보딩이면 분석을 기다리는 동안 설문을 얹는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(loadingHost(onboarding: true));
    await settle(tester);

    expect(find.text('설문'), findsOneWidget);

    // 플래그를 소비했다. 안 끄면 두 번째 분석부터도 설문이 뜬다.
    final container = ProviderScope.containerOf(tester.element(find.text('설문')));
    expect(container.read(onboardingCaptureProvider), isFalse);
  });

  testWidgets('그냥 재분석하면 설문 없이 기다린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(loadingHost(onboarding: false));
    await settle(tester);

    expect(find.text('설문'), findsNothing);
    expect(find.byType(LoadingSteps), findsOneWidget);
  });

  testWidgets('촬영을 접었다가 프로필을 직접 설정한 사용자는 다시 묻지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    // 플래그는 켜져 있지만(촬영 안내에서 촬영하기를 눌렀다) 타입이 이미 있다.
    await tester.pumpWidget(loadingHost(
      onboarding: true,
      profile: const AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
        declaredSkinType: SkinType.dry,
      ),
    ));
    await settle(tester);

    expect(find.text('설문'), findsNothing);
  });

  testWidgets('설문을 쓰는 동안 분석이 끝나도 설문이 살아 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(loadingHost(onboarding: true));
    await settle(tester);
    expect(find.text('설문'), findsOneWidget);

    // pushReplacement 는 스택의 맨 위를 갈아치운다. 설문이 떠 있는 동안 부르면
    // 사용자가 쓰고 있던 설문이 통째로 사라진다.
    final container = ProviderScope.containerOf(tester.element(find.text('설문')));
    (container.read(skinAnalysisNotifierProvider.notifier) as _StubAnalysis)
        .land(analysis);
    await settle(tester);

    expect(find.text('설문'), findsOneWidget);
    expect(find.text('결과'), findsNothing);
  });

  testWidgets('설문을 닫으면 그동안 끝난 분석의 결과로 이어진다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(loadingHost(onboarding: true));
    await settle(tester);

    final container = ProviderScope.containerOf(tester.element(find.text('설문')));
    (container.read(skinAnalysisNotifierProvider.notifier) as _StubAnalysis)
        .land(analysis);
    await settle(tester);

    Navigator.of(tester.element(find.text('설문'))).pop();
    await settle(tester);

    // listen 은 이미 도착한 값에 반응하지 않는다. 로딩 화면이 돌아올 때 한 번
    // 직접 보지 않으면 사용자가 끝난 분석 앞에서 영원히 기다린다.
    expect(find.text('결과'), findsOneWidget);
  });

  testWidgets('들어올 때 분석이 이미 끝나 있으면 곧바로 결과로 간다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(loadingHost(onboarding: false, ready: analysis));
    await settle(tester);

    expect(find.text('결과'), findsOneWidget);
  });

  testWidgets('온보딩 모드 설문은 건너뛰기가 없고 촬영이 끝났다고 말한다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [authNotifierProvider.overrideWith(() => _StubAuth(fresh))],
      child: const MaterialApp(
        home: SkinTypePage(mode: ProfileFormMode.onboarding),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('사진 촬영이 끝났습니다'), findsOneWidget);
    // 출구는 건너뛰기가 아니라 타입의 "잘 모르겠어요"(UNKNOWN)와 뒤로가기다.
    expect(find.text('건너뛰기'), findsNothing);
  });

  testWidgets('촬영을 넘어간 사용자의 설문에는 건너뛰기가 남아 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [authNotifierProvider.overrideWith(() => _StubAuth(fresh))],
      child: const MaterialApp(home: SkinTypePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('건너뛰기'), findsOneWidget);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}

/// 서버 왕복 없이 분석 도착 시점만 테스트가 정한다.
class _StubAnalysis extends SkinAnalysisNotifier {
  _StubAnalysis(this.seed);

  final SkinAnalysis? seed;

  @override
  SkinAnalysisState build() =>
      SkinAnalysisState(analysis: AsyncData<SkinAnalysis?>(seed));

  /// 백그라운드로 돌던 분석이 지금 도착했다.
  void land(SkinAnalysis analysis) =>
      state = SkinAnalysisState(analysis: AsyncData<SkinAnalysis?>(analysis));
}
