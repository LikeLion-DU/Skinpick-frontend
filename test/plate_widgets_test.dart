import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_score_card.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_summary_cards.dart';
import 'package:skinplate/shared/enums/cooking_method.dart';
import 'package:skinplate/shared/enums/food_traits.dart';
import 'package:skinplate/shared/enums/skin_basis.dart';

/// 칩으로 나가는 두 값 말고는 화면에 안 쓰이므로 고정해 둔다.
/// [PortionSize] 는 파싱만 하고 안 그리지만, "안 그린다"를 검증하려면 넣을 수 있어야 한다.
FoodAnalysis _food({
  Spiciness spiciness = Spiciness.unknown,
  Oiliness oiliness = Oiliness.unknown,
  PortionSize portionSize = PortionSize.unknown,
}) =>
    FoodAnalysis(
      foodName: '돼지고기 김치찌개',
      foodCategory: '한식/찌개',
      cookingMethod: CookingMethod.boiled,
      spicy: true,
      spiciness: spiciness,
      oiliness: oiliness,
      portionSize: portionSize,
      ingredients: const [],
      nutrition: const Nutrition(
        caloriesKcal: 520,
        proteinG: 28.5,
        fatG: 24,
        carbG: 32,
        sodiumMg: 1850,
        sugarG: 6.2,
      ),
    );

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

  testWidgets('점수 카드 — 58점은 보통 배지', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(const PlateScoreCard(score: 58)));

    expect(find.text('58'), findsOneWidget);
    // 서버 기준으로 41~60 이 NORMAL 이다. 앱이 쓰던 75/60 경계에서는
    // '주의'였지만, 등급표는 이제 서버 것 하나뿐이다.
    expect(find.text('보통'), findsOneWidget);
  });

  testWidgets('점수 카드 — 채점 기준 문구를 여기서 만들지 않는다', (tester) async {
    // 자가신고 피부 타입을 기준으로 쓰던 자리다. "잘 모르겠어요 피부 기준" 이
    // 그대로 떴다 — 음식 판정은 실제 측정 지표로 하므로 이 카드는 기준을
    // 말하지 않는다. 기준은 [SkinBasisLine] 한 곳이다.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(const PlateScoreCard(score: 92)));

    expect(find.text('92'), findsOneWidget);
    expect(find.textContaining('기준'), findsNothing);
    expect(find.textContaining('피부 기준'), findsNothing);
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

  testWidgets('판정 이유 — 제목 아래 설명이 한 줄 더 붙는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateSummaryCard(
        good: [],
        caution: [
          PlateFeedback(
            message: '매운맛 자극',
            reason: '지금 붉은기가 높은 상태에서 매운 재료가 들어 있어 부담이 될 수 있어요.',
            scoreDelta: -12,
            ruleCode: 'R02',
          ),
        ],
      ),
    ));

    expect(find.text('매운맛 자극'), findsOneWidget);
    expect(find.textContaining('붉은기가 높은 상태'), findsOneWidget);
  });

  testWidgets('판정 이유 — V8 이전 기록은 제목만 그리고 빈 줄을 남기지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const PlateSummaryCard(
        good: [PlateFeedback(message: '단백질 충분', scoreDelta: 6, ruleCode: 'R05')],
        caution: [],
      ),
    ));

    expect(find.text('단백질 충분'), findsOneWidget);
    // 카드 안의 Text 는 'GOOD' 과 제목 둘뿐이어야 한다. 설명 자리에 빈 Text 를
    // 남기면 줄 간격만큼 카드에 구멍이 생긴다.
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('피부 기준 — 분석 직후의 TODAY 는 "오늘"이다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const SkinBasisLine(basis: SkinBasis.today, measuredAt: null),
    ));

    expect(find.text('오늘 피부 상태 기준'), findsOneWidget);
  });

  testWidgets('피부 기준 — 저장된 기록의 TODAY 는 "기록 당일"이다', (tester) async {
    // 서버가 저장한 날로 굳혀 주므로 8/15 기록을 8/17 에 열어도 TODAY 가 온다.
    // 두 화면이 같은 값에서 다른 문구를 써야 하는 이유가 이것이다.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const SkinBasisLine(
        basis: SkinBasis.today,
        measuredAt: null,
        pastRecord: true,
      ),
    ));

    expect(find.text('기록 당일 피부 상태 기준'), findsOneWidget);
    expect(find.text('오늘 피부 상태 기준'), findsNothing);
  });

  testWidgets('피부 기준 — RECENT 는 측정일을 함께 보여준다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      SkinBasisLine(
        basis: SkinBasis.recent,
        measuredAt: DateTime(2026, 8, 15),
      ),
    ));

    expect(find.text('최근 피부 상태 기준 · 8/15'), findsOneWidget);
  });

  testWidgets('피부 기준 — 옛 응답에는 필드가 없다. 지어내지 않고 비운다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const SkinBasisLine(basis: null, measuredAt: null),
    ));

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('음식 특성 — 아는 것만 칩으로 나오고 UNKNOWN 은 빠진다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      FoodTraitChips(
        food: _food(
          spiciness: Spiciness.hot,
          oiliness: Oiliness.unknown, // 서버가 확신 못 한 항목
          portionSize: PortionSize.large,
        ),
      ),
    ));

    expect(find.text('매운 정도 · 많이 매움'), findsOneWidget);
    expect(find.textContaining('기름기'), findsNothing);
    expect(find.textContaining('UNKNOWN'), findsNothing);

    // **섭취량은 파싱만 하고 화면에는 안 낸다.** LARGE 를 넣어도 칩이 없어야 한다 —
    // 척도를 정의한 기준이 없는 AI 관찰값이라, 얹으면 사용자가 자기 식사량의
    // 근거로 읽는다. 서버의 저장·리포트 환산은 그대로다.
    expect(find.textContaining('섭취량'), findsNothing);
    expect(find.textContaining('많이 드'), findsNothing);
  });

  testWidgets('음식 특성 — 서버 경고와 맞부딪히는 값은 안 그린다', (tester) async {
    // 서버 R02 는 spiciness 가 아니라 표준 테이블의 spicy·CAPSAICIN 태그로 발동하고
    // (룰 주석: "NONE(캡사이신으로만 발동)은 1.0"), R07 은 조리법이 FRIED 이기만
    // 해도 발동한다. 그래서 "안 매움"·"담백" 칩이 바로 아래 "매운맛 자극"·"튀김
    // 조리" 경고와 한 화면에 같이 뜬다 — 앱이 자기 말을 뒤집는 자리다.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      Column(children: [
        FoodTraitChips(
          food: _food(
            spiciness: Spiciness.none,
            oiliness: Oiliness.low,
            portionSize: PortionSize.small,
          ),
        ),
        const PlateSummaryCard(
          good: [],
          caution: [
            PlateFeedback(message: '매운맛 자극', scoreDelta: -12, ruleCode: 'R02'),
            PlateFeedback(message: '튀김 조리', scoreDelta: -6, ruleCode: 'R07'),
          ],
        ),
      ]),
    ));

    expect(find.textContaining('안 매움'), findsNothing);
    expect(find.textContaining('담백'), findsNothing);
    // 그린 칩이 하나도 없으니 영역째 사라진다 — 경고 카드만 남는다.
    expect(find.text('매운맛 자극'), findsOneWidget);
    expect(find.text('튀김 조리'), findsOneWidget);
  });

  testWidgets('음식 특성 — 둘 다 모르면 영역째 사라진다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(FoodTraitChips(food: _food())));

    // 빈 칩 두 개보다 없는 편이 낫다.
    expect(find.byType(Text), findsNothing);
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
