import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/home/presentation/widgets/daily_score_card.dart';
import 'package:skinplate/features/home/presentation/widgets/today_records_card.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_history.dart';
import 'package:skinplate/shared/enums/meal_type.dart';
import 'package:skinplate/shared/widgets/app_bottom_nav.dart';

/// 레이아웃이 실제로 그려지는지 본다.
///
/// 오버플로는 컴파일도 되고 테스트도 통과하지만 화면에는 노란 줄무늬로 나온다.
/// 위젯 테스트는 오버플로를 실패로 잡아 주므로, 시안 폭(402)에서 한 번 그려
/// 보는 것만으로 그 부류를 전부 걸러낸다.
void main() {
  /// 시안 프레임과 같은 크기. 이 폭에서 안 깨지는 것이 최소 조건이다.
  const designSize = Size(402, 874);

  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: designSize),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.pagePadding),
              child: child,
            ),
          ),
        ),
      );

  testWidgets('점수 카드 — 기록이 없으면 0점이 아니라 OO점이다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const DailyScoreCard(nickname: '스킨픽', score: null, targetScore: 80),
    ));

    // 0 점은 "아주 나쁘게 먹었다"로 읽힌다. 아직 안 먹은 것과는 다르다.
    expect(find.text('OO'), findsOneWidget);
    expect(find.textContaining('스킨픽님의 식단을 찍어보세요'), findsOneWidget);
  });

  testWidgets('점수 카드 — 점수가 있으면 등급 배지와 목표가 함께 나온다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      const DailyScoreCard(nickname: '스킨픽', score: 72, targetScore: 80),
    ));

    expect(find.text('72'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget); // 72 는 보통 구간이다
    expect(find.text('목표 80점'), findsOneWidget);
  });

  testWidgets('점수 카드 — 목표를 넘겨도 막대가 깨지지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      // 100 / 80 = 1.25. clamp 를 빼면 여기서 렌더가 죽는다.
      const DailyScoreCard(nickname: '스킨픽', score: 100, targetScore: 80),
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
            mealType: MealType.lunch,
            recordedAt: DateTime(2026, 8, 14, 12, 10),
          ),
          PlateHistoryItem(
            plateId: 2,
            // 서버가 앱이 모르는 끼니를 보낸 경우다. 줄이 사라지면 안 된다.
            foodName: '아주 긴 음식 이름이 들어와도 줄이 깨지지 않아야 한다 정말로',
            plateScore: 58,
            mealType: null,
            recordedAt: DateTime(2026, 8, 14, 20, 10),
          ),
        ],
        imageDirectory: null,
        onCapture: () {},
        onItemTap: (_) {},
      ),
    ));

    expect(find.text('점심'), findsOneWidget);
    expect(find.text('92점'), findsOneWidget);
    expect(find.text('58점'), findsOneWidget);
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
}
