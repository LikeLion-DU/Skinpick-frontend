import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_score_card.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_summary_cards.dart';

/// 분석 결과 화면의 카드들이 시안 폭(402)에서 실제로 그려지는지 본다.
/// 오버플로는 컴파일도 통과하고 화면에서만 노란 줄무늬로 나온다 — 여기서 잡는다.
void main() {
  const designSize = Size(402, 874);

  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
            child: Center(child: child),
          ),
        ),
      );

  testWidgets('점수 카드 — 58점은 주의 배지, 기준 문구가 함께 나온다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateScoreCard(score: 58, basisLabel: '민감성 피부 기준'),
    ));

    expect(find.text('58'), findsOneWidget);
    expect(find.text('주의'), findsOneWidget);
    expect(find.text('민감성 피부 기준'), findsOneWidget);
  });

  testWidgets('점수 카드 — 기준을 모르면 지어내지 않고 비운다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateScoreCard(score: 92, basisLabel: null),
    ));

    expect(find.text('92'), findsOneWidget);
    expect(find.textContaining('기준'), findsNothing);
  });

  testWidgets('분석 요약 — GOOD·BAD 항목이 서버 문장 그대로 나온다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateSummaryCard(
        good: [PlateFeedback(message: '단백질 충분', scoreDelta: 5, ruleCode: 'R01')],
        caution: [
          PlateFeedback(message: '나트륨 과다', scoreDelta: -8, ruleCode: 'R04'),
        ],
      ),
    ));

    expect(find.text('GOOD'), findsOneWidget);
    expect(find.text('BAD'), findsOneWidget);
    expect(find.text('단백질 충분'), findsOneWidget);
    expect(find.text('나트륨 과다'), findsOneWidget);
    // 시안이 숫자를 지웠다 — 델타가 화면에 새어 나오면 안 된다.
    expect(find.textContaining('-8'), findsNothing);
  });

  testWidgets('분석 요약 — 둘 다 비어도 침묵하지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateSummaryCard(good: [], caution: []),
    ));

    expect(find.textContaining('무난한 식사'), findsOneWidget);
  });

  testWidgets('영양 타일 — 네 칸이 시안 폭에 들어가고 천 단위 쉼표가 붙는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const NutrientTiles(
        caloriesKcal: 500,
        sodiumMg: 1280,
        sugarG: 28,
        fatG: 14,
      ),
    ));

    expect(find.text('500 kcal'), findsOneWidget);
    expect(find.text('1,280 mg'), findsOneWidget); // 쉼표가 핵심이다
    expect(find.text('28 g'), findsOneWidget);
    expect(find.text('14 g'), findsOneWidget);
  });
}
