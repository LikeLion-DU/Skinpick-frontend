import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/home/presentation/widgets/home_hero.dart';
import 'package:skinplate/features/home/presentation/widgets/today_records_card.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_history.dart';
import 'package:skinplate/shared/enums/meal_type.dart';
import 'package:skinplate/shared/enums/skin_level.dart';
import 'package:skinplate/shared/widgets/app_bottom_nav.dart';

/// 레이아웃이 실제로 그려지는지 본다.
///
/// 오버플로는 컴파일도 되고 테스트도 통과하지만 화면에는 노란 줄무늬로 나온다.
/// 위젯 테스트는 오버플로를 실패로 잡아 주므로, 시안 폭(402)에서 한 번 그려
/// 보는 것만으로 그 부류를 전부 걸러낸다.
void main() {
  /// 시안 프레임과 같은 크기. 이 폭에서 안 깨지는 것이 최소 조건이다.
  const designSize = Size(402, 874);

  Widget host(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: designSize,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.pagePadding),
              child: child,
            ),
          ),
        ),
      );

  testWidgets('히어로 — 기록이 없으면 점수 자리를 만들지 않고 말풍선을 띄운다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      // 기록이 없는 날은 서버가 점수도 목표도 보내지 않는다.
      const HomeHero(
        nickname: '스킨픽',
        score: null,
        grade: null,
        targetScore: null,
      ),
    ));

    // 확정 시안은 숫자 자리를 아예 비운다. 옛 시안의 `OO점` 은 0 점으로 읽힐
    // 자리를 막으려던 장치였는데, 자리를 없애는 편이 더 확실하다.
    expect(find.textContaining('스킨픽님의 식단을 찍어보세요'), findsOneWidget);
    expect(find.textContaining('목표'), findsNothing);
  });

  testWidgets('히어로 — 점수가 있으면 등급 배지와 목표가 함께 나온다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const HomeHero(
        nickname: '스킨픽',
        score: 72,
        // 서버가 매긴 등급이다. 앱은 72 를 보고 등급을 고르지 않는다.
        grade: SkinLevel.good,
        targetScore: 80,
      ),
    ));

    expect(find.text('72'), findsOneWidget);
    // GOOD 과 EXCELLENT 를 한 라벨로 접는 규칙만 앱 것이다(skin_level_test).
    expect(find.text('좋음'), findsOneWidget);
    expect(find.text('목표 80점'), findsOneWidget);
  });

  testWidgets('히어로 — 목표를 넘겨도 막대가 깨지지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      // 100 / 80 = 1.25. clamp 를 빼면 여기서 렌더가 죽는다.
      const HomeHero(
        nickname: '스킨픽',
        score: 100,
        grade: SkinLevel.excellent,
        targetScore: 80,
      ),
    ));

    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('기록 카드 — 비어 있으면 예시와 빈 슬롯을 보여준다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      TodayRecordsCard(
        items: const [],
        imageDirectory: null,
        onCapture: () {},
        onItemTap: (_) {},
        onSeeAll: () {},
      ),
    ));

    expect(find.text('기록을 함께 만들어가요!'), findsOneWidget);
    expect(find.text('ex)'), findsOneWidget);
  });

  testWidgets('기록 카드 — 끼니를 모르면 배지를 비우고 나머지는 그린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      TodayRecordsCard(
        items: [
          PlateHistoryItem(
            plateId: 1,
            foodName: '연어 샐러드',
            plateScore: 92,
            grade: SkinLevel.excellent,
            mealType: MealType.lunch,
            recordedAt: DateTime(2026, 8, 14, 12, 10),
          ),
          PlateHistoryItem(
            plateId: 2,
            // 서버가 앱이 모르는 끼니를 보낸 경우다. 줄이 사라지면 안 된다.
            foodName: '아주 긴 음식 이름이 들어와도 줄이 깨지지 않아야 한다 정말로',
            plateScore: 58,
            grade: SkinLevel.normal,
            mealType: null,
            recordedAt: DateTime(2026, 8, 14, 20, 10),
          ),
        ],
        imageDirectory: null,
        onCapture: () {},
        onItemTap: (_) {},
        onSeeAll: () {},
      ),
    ));

    expect(find.text('점심'), findsOneWidget);
    // 확정 시안은 홈 기록 줄에 숫자가 아니라 GOOD/BAD 라벨을 둔다. 92 는
    // GOOD(61~80 이상), 58 은 NORMAL 이라 BAD 다 — 경계는 SkinLevel 하나뿐이라
    // 리포트·기록 화면과 갈리지 않는다.
    expect(find.text('GOOD'), findsOneWidget);
    expect(find.text('BAD'), findsOneWidget);
  });

  testWidgets('하단 네비 — 솟은 촬영 버튼이 잘리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);

    var captured = 0;
    AppTab? selected;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          current: AppTab.home,
          onCapture: () => captured++,
          onTabSelected: (tab) => selected = tab,
        ),
      ),
    ));

    // 버튼이 막대 위로 19 솟아 있다. Clip.none 을 빼면 여기서 잘린다.
    final fab = find.byType(GestureDetector).last;
    await tester.tap(fab, warnIfMissed: false);
    expect(captured, 1);

    await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
    expect(selected, isNotNull);
  });
  // 시스템 글자 크기를 최대로 올린 기기. 히어로의 큰 숫자와 기록 줄의 GOOD/BAD
  // 라벨이 같은 줄에 있어서, 여기서 넘치면 홈 첫 화면이 노란 줄무늬로 열린다.
  testWidgets('글자 크기 2.0 — 히어로와 기록 카드가 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      Column(
        children: [
          const HomeHero(
            nickname: '스킨픽',
            score: 72,
            grade: SkinLevel.good,
            targetScore: 80,
          ),
          TodayRecordsCard(
            items: [
              PlateHistoryItem(
                plateId: 1,
                foodName: '아주 긴 음식 이름이 들어와도 줄이 깨지지 않아야 한다 정말로',
                plateScore: 92,
                grade: SkinLevel.excellent,
                mealType: MealType.lunch,
                recordedAt: DateTime(2026, 8, 14, 12, 10),
              ),
            ],
            imageDirectory: null,
            onCapture: () {},
            onItemTap: (_) {},
            onSeeAll: () {},
          ),
        ],
      ),
      textScale: 2.0,
    ));

    expect(tester.takeException(), isNull);
  });

}
