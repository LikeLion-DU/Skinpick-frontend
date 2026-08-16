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

/// 가입 직후 순서를 뒤집었다: 촬영 안내(S01d) → 진단 → 결과 → 프로필 설문.
///
/// 설문은 결과 화면을 **덮는다**. 예전처럼 분석과 결과 사이에 끼우면 거기서 나간
/// 사용자가 방금 기다린 분석을 다시 볼 길이 없다 — 홈에 결과 진입점이 없다.
void main() {
  const designSize = Size(402, 874);

  Widget resultHost({required bool onboarding}) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_StubAuth.new),
          latestSkinAnalysisProvider
              .overrideWith((ref) => const Success<SkinAnalysis?>(null)),
          onboardingCaptureProvider.overrideWith((ref) => onboarding),
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

  testWidgets('온보딩 촬영으로 들어온 결과는 프로필 설문이 덮는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(resultHost(onboarding: true));
    // 분석이 비어 있어 결과 화면은 스피너를 돌린다 — pumpAndSettle 은 끝나지 않는다.
    // 한 프레임(postFrame 콜백)과 라우트 전환 시간만 흘린다.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('덮개'), findsOneWidget);

    // 플래그를 소비했다. 안 끄면 두 번째 분석부터도 설문이 덮인다.
    final container = ProviderScope.containerOf(tester.element(find.text('덮개')));
    expect(container.read(onboardingCaptureProvider), isFalse);
  });

  testWidgets('그냥 재분석한 결과는 덮지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(resultHost(onboarding: false));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('덮개'), findsNothing);
  });

  testWidgets('온보딩 모드 설문은 건너뛰기가 없고 촬영이 끝났다고 말한다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [authNotifierProvider.overrideWith(_StubAuth.new)],
      child: const MaterialApp(
        home: SkinTypePage(mode: ProfileFormMode.onboarding),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('사진 촬영이 끝났습니다'), findsOneWidget);
    // 출구는 건너뛰기가 아니라 타입의 "잘 모르겠어요"(UNKNOWN)와 뒤로가기다.
    expect(find.text('건너뛰기'), findsNothing);
  });

  testWidgets('홈에서 들어온 프로필 수정에는 건너뛰기가 남아 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [authNotifierProvider.overrideWith(_StubAuth.new)],
      child: const MaterialApp(home: SkinTypePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('건너뛰기'), findsOneWidget);
  });
}

class _StubAuth extends AuthNotifier {
  @override
  AuthState build() => const Authenticated(user);
}

const user = AuthUser(
  userId: 1,
  email: 'test@skinplate.app',
  nickname: '테스트유저',
);
