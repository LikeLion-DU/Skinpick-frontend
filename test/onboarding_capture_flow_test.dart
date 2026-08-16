import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_result_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 가입 직후 순서를 뒤집었다: 촬영 안내(S01d) → 진단 → 결과(S05) → 프로필 설문.
///
/// 설문은 결과 화면을 **덮는다**. 예전처럼 분석과 결과 사이에 끼우면 거기서 나간
/// 사용자가 방금 기다린 분석을 다시 볼 길이 없다 — 홈에 결과 진입점이 없다.
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

  Widget resultHost({
    required bool onboarding,
    AuthUser profile = fresh,
    SkinAnalysisNotifier Function()? analysisNotifier,
  }) =>
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(profile)),
          latestSkinAnalysisProvider
              .overrideWith((ref) => const Success<SkinAnalysis?>(null)),
          onboardingCaptureProvider.overrideWith((ref) => onboarding),
          if (analysisNotifier != null)
            skinAnalysisNotifierProvider.overrideWith(analysisNotifier),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: GoRouter(
            initialLocation: Routes.skinResult,
            routes: [
              GoRoute(
                path: Routes.skinResult,
                builder: (_, __) => const SkinResultPage(),
              ),
              // 설문 자체는 다른 테스트가 본다. 여기서 확인할 것은 덮였는가다.
              GoRoute(
                path: Routes.onboardingProfile,
                builder: (_, __) => const Scaffold(body: Text('덮개')),
              ),
            ],
          ),
        ),
      );

  // 분석이 비어 있으면 결과 화면이 스피너를 돌려 pumpAndSettle 이 끝나지 않는다.
  // 한 프레임(postFrame 콜백)과 라우트 전환 시간만 흘린다.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('온보딩 촬영으로 들어온 결과는 프로필 설문이 덮는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(resultHost(onboarding: true));
    await settle(tester);

    expect(find.text('덮개'), findsOneWidget);

    // 플래그를 소비했다. 안 끄면 두 번째 분석부터도 설문이 덮인다.
    final container = ProviderScope.containerOf(tester.element(find.text('덮개')));
    expect(container.read(onboardingCaptureProvider), isFalse);
  });

  testWidgets('그냥 재분석한 결과는 덮지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(resultHost(onboarding: false));
    await settle(tester);

    expect(find.text('덮개'), findsNothing);
  });

  testWidgets('촬영을 접었다가 프로필을 직접 설정한 사용자는 덮지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    // 플래그는 켜져 있지만(촬영 안내에서 촬영하기를 눌렀다) 타입이 이미 있다.
    await tester.pumpWidget(resultHost(
      onboarding: true,
      profile: const AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
        declaredSkinType: SkinType.dry,
      ),
    ));
    await settle(tester);

    expect(find.text('덮개'), findsNothing);
  });

  testWidgets('설문을 닫으면 결과를 다시 받는다', (tester) async {
    final spy = _SpyAnalysis(analysis);

    await tester.binding.setSurfaceSize(designSize);
    await tester
        .pumpWidget(resultHost(onboarding: true, analysisNotifier: () => spy));
    await settle(tester);
    expect(find.text('덮개'), findsOneWidget);

    Navigator.of(tester.element(find.text('덮개'))).pop();
    await settle(tester);

    // 갭 문장은 서버가 만든다. 다시 안 받으면 같은 질문을 던지는 인라인 칩이
    // 그 자리에 다시 뜨고, 카드 제목이 측정값 대신 자가 신고값으로 떨어진다.
    expect(spy.refreshCalls, 1);
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

/// 다시 받기가 실제로 불렸는지만 센다. 서버 왕복은 이 테스트의 관심사가 아니다.
class _SpyAnalysis extends SkinAnalysisNotifier {
  _SpyAnalysis(this.seed);

  final SkinAnalysis seed;
  int refreshCalls = 0;

  @override
  SkinAnalysisState build() =>
      SkinAnalysisState(analysis: AsyncData<SkinAnalysis?>(seed));

  @override
  Future<void> refresh(int id) async => refreshCalls++;
}
