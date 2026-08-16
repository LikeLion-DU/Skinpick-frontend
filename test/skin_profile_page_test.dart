import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_profile_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';

/// 피부 프로필은 **음식 개인화의 기준을 확인하는 화면**이다.
/// 여기서 새로 계산하는 값이 없어야 하고, 미설정이 빈칸으로 새면 안 된다.
void main() {
  const designSize = Size(402, 874);

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

  const user = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '두잉',
    skinConcerns: {SkinConcern.darkCircle},
    sleepPattern: SleepPattern.lacking,
    // 스트레스·운동·물은 일부러 비운다 — 미설정이 어떻게 보이는지가 요점이다.
  );

  Widget host({SkinAnalysis? latest}) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(user)),
          latestSkinAnalysisProvider.overrideWith((ref) async => Success(latest)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SkinProfilePage(),
        ),
      );

  testWidgets('최근 분석의 지표 5개를 전부 펴고 시안 폭에서 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: analysis));
    await tester.pumpAndSettle();

    // 결과 화면(S05)은 4개만 보여주지만 여기는 채점 기준을 확인하는 곳이라
    // 트러블이 빠지면 근거가 하나 사라진다.
    for (final label in ['수분', '유분', '홍조', '트러블', '장벽']) {
      expect(find.text(label), findsOneWidget, reason: '$label 지표가 없다');
    }
    expect(find.text('2026. 8. 16'), findsOneWidget);
    expect(find.text('다크서클'), findsOneWidget);
  });

  testWidgets('미설정 습관은 빈칸이 아니라 미설정으로 적는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: analysis));
    await tester.pumpAndSettle();

    expect(find.text('부족해요'), findsOneWidget); // 수면
    expect(find.text('미설정'), findsNWidgets(3)); // 스트레스·운동·물 섭취
  });

  testWidgets('불러오기에 실패하면 기록이 없다고 말하지 않는다', (tester) async {
    // 실패와 "정말 없음"을 같이 다루면, 분석을 해 둔 사용자가 오프라인으로 열었을 때
    // 앱이 없는 사실을 단정한다. 그것도 재시도할 방법 없이.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => _StubAuth(user)),
        latestSkinAnalysisProvider.overrideWith(
            (ref) async => const FailureResult(NetworkFailure())),
      ],
      child: const MaterialApp(home: SkinProfilePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('아직 피부 분석 기록이 없어요'), findsNothing);
    expect(find.text('피부 분석을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('분석이 없으면 인사이트 버튼을 그리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // 인사이트는 분석 하나를 기준으로 만들어진다. 눌러서 빈 화면을 보는 것보다
    // 버튼이 없는 편이 낫다.
    expect(find.text('개인화 피부 인사이트 보기'), findsNothing);
    expect(find.text('피부 분석하기'), findsOneWidget);
    expect(find.textContaining('아직 피부 분석 기록이 없어요'), findsOneWidget);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
