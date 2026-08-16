import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_history.dart';
import 'package:skinplate/features/skin_plate/domain/entities/weekly_report.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/weekly_report_page.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/weekly_report_provider.dart';
import 'package:skinplate/shared/enums/meal_type.dart';

/// 주간 리포트에서 앱이 직접 만드는 값은 둘뿐이다 — **지난주 평균**과 **음식 TOP**.
/// 이번 주 평균·기록 수는 서버가 센 것을 그대로 쓴다.
///
/// 그 둘이 틀리면 증상이 조용하다. 화면은 멀쩡히 뜨고 숫자만 틀린다.
void main() {
  const designSize = Size(402, 874);

  /// 이번 주 = 8/10~8/16, 지난주 = 8/3~8/9.
  final thisWeekFrom = DateTime(2026, 8, 10);
  final thisWeekTo = DateTime(2026, 8, 16);

  PlateHistoryItem meal(String foodName, int score, DateTime at) =>
      PlateHistoryItem(
        plateId: score + at.day,
        foodName: foodName,
        plateScore: score,
        mealType: MealType.lunch,
        recordedAt: at,
      );

  PlateHistoryDay dayOf(DateTime date, List<PlateHistoryItem> plates) =>
      PlateHistoryDay(
        date: date,
        skinScore: null,
        plateScore: null,
        targetScore: 80,
        plates: plates,
      );

  PlateReport reportOf({int? average, int count = 0}) => PlateReport(
        from: thisWeekFrom,
        to: thisWeekTo,
        averageScore: average,
        recordCount: count,
      );

  group('집계', () {
    test('경계는 서버가 준 from 이다 — 그 앞이 지난주다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 80, count: 2),
        days: [
          // 지난주: 60, 70 → 평균 65
          dayOf(DateTime(2026, 8, 9), [meal('라면', 60, DateTime(2026, 8, 9))]),
          dayOf(DateTime(2026, 8, 3), [meal('국밥', 70, DateTime(2026, 8, 3))]),
          // 이번 주 — 경계일(8/10)은 이번 주에 들어간다
          dayOf(DateTime(2026, 8, 10), [meal('샐러드', 90, DateTime(2026, 8, 10))]),
        ],
      );

      expect(week.lastWeekAverage, 65);
      expect(week.averageScore, 80, reason: '이번 주 평균은 서버 값 그대로다');
      expect(week.scoreDelta, 15);
    });

    test('평균 반올림이 서버(Math.round)와 같다', () {
      // 60 + 61 = 121 / 2 = 60.5 → 61
      final week = WeeklyReport.assemble(
        report: reportOf(average: 70, count: 1),
        days: [
          dayOf(DateTime(2026, 8, 5), [
            meal('국밥', 60, DateTime(2026, 8, 5)),
            meal('덮밥', 61, DateTime(2026, 8, 5)),
          ]),
        ],
      );

      expect(week.lastWeekAverage, 61);
    });

    test('지난주 기록이 없으면 비교하지 않는다 — 0 으로 빼면 첫 주에 +78 이 뜬다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 78, count: 1),
        days: [
          dayOf(DateTime(2026, 8, 12), [meal('샐러드', 78, DateTime(2026, 8, 12))]),
        ],
      );

      expect(week.lastWeekAverage, isNull);
      expect(week.scoreDelta, isNull);
    });

    test('이번 주 기록이 0건이어도 지난주 평균 때문에 delta 가 생기지 않는다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(count: 0), // averageScore 없음 = 서버가 키를 뺀 상태
        days: [
          dayOf(DateTime(2026, 8, 5), [meal('국밥', 70, DateTime(2026, 8, 5))]),
        ],
      );

      expect(week.isEmpty, isTrue);
      expect(week.scoreDelta, isNull);
    });
  });

  group('음식 TOP', () {
    test('같은 음식은 한 줄로 합친다 — 잘 맞은 쪽은 최고점이 대표다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 85, count: 3),
        days: [
          dayOf(thisWeekFrom, [
            meal('샐러드', 88, DateTime(2026, 8, 10)),
            meal('샐러드', 92, DateTime(2026, 8, 11)),
            meal('연어덮밥', 84, DateTime(2026, 8, 12)),
          ]),
        ],
      );

      expect(week.bestFoods.map((food) => food.foodName), ['샐러드', '연어덮밥']);
      expect(week.bestFoods.first.plateScore, 92);
    });

    test('주의 쪽은 같은 음식의 최저점이 대표다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 50, count: 2),
        days: [
          dayOf(thisWeekFrom, [
            meal('라면', 55, DateTime(2026, 8, 10)),
            meal('라면', 48, DateTime(2026, 8, 11)),
          ]),
        ],
      );

      expect(week.cautionFoods.single.plateScore, 48);
    });

    test('보통(60~74) 구간은 어느 쪽에도 넣지 않는다', () {
      // ScoreGrade 경계: 75 이상 좋음, 60 이상 보통, 그 아래 주의.
      final week = WeeklyReport.assemble(
        report: reportOf(average: 68, count: 3),
        days: [
          dayOf(thisWeekFrom, [
            meal('비빔밥', 74, DateTime(2026, 8, 10)),
            meal('국수', 60, DateTime(2026, 8, 11)),
            meal('토스트', 59, DateTime(2026, 8, 12)),
          ]),
        ],
      );

      expect(week.bestFoods, isEmpty);
      expect(week.cautionFoods.map((food) => food.foodName), ['토스트']);
    });

    test('각각 최대 3개까지만 세운다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 90, count: 5),
        days: [
          dayOf(thisWeekFrom, [
            for (var index = 0; index < 5; index++)
              meal('음식$index', 80 + index, DateTime(2026, 8, 10 + index)),
          ]),
        ],
      );

      expect(week.bestFoods, hasLength(3));
      expect(week.bestFoods.first.plateScore, 84, reason: '높은 점수부터다');
    });

    test('지난주에 먹은 것은 이번 주 TOP 에 섞이지 않는다', () {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 80, count: 1),
        days: [
          dayOf(DateTime(2026, 8, 5), [meal('지난주샐러드', 99, DateTime(2026, 8, 5))]),
          dayOf(thisWeekFrom, [meal('이번주샐러드', 80, DateTime(2026, 8, 10))]),
        ],
      );

      expect(week.bestFoods.single.foodName, '이번주샐러드');
    });
  });

  group('화면', () {
    Widget host(WeeklyReport week) => ProviderScope(
          overrides: [
            weeklyReportProvider.overrideWith((ref) async => Success(week)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const WeeklyReportPage(),
          ),
        );

    testWidgets('시안 폭에서 넘치지 않고 서버 숫자를 그대로 그린다', (tester) async {
      final week = WeeklyReport.assemble(
        report: reportOf(average: 78, count: 18),
        days: [
          dayOf(DateTime(2026, 8, 5), [meal('국밥', 72, DateTime(2026, 8, 5))]),
          dayOf(thisWeekFrom, [
            meal('샐러드', 92, DateTime(2026, 8, 10)),
            meal('아주아주긴이름의음식이라도점수를밀어내지않아야한다', 48,
                DateTime(2026, 8, 11)),
          ]),
        ],
      );

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(week));
      await tester.pumpAndSettle();

      expect(find.text('78'), findsOneWidget);
      expect(find.text('이번 주 18회 기록했어요'), findsOneWidget);
      expect(find.text('지난주 대비 +6점'), findsOneWidget);
      expect(find.text('92점'), findsOneWidget);
    });

    testWidgets('기록이 없는 주에는 빈 안내만 남는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(
        WeeklyReport.assemble(report: reportOf(), days: const []),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('아직 기록이 없어요'), findsOneWidget);
      expect(find.text('이번 주 잘 맞았던 음식'), findsNothing);
    });
  });
}
