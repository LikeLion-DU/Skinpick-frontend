import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/utils/kst_date.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/report/data/models/report_dtos.dart';
import 'package:skinplate/features/report/domain/entities/report.dart';
import 'package:skinplate/features/report/domain/repositories/report_repository.dart';
import 'package:skinplate/features/report/presentation/pages/report_page.dart';
import 'package:skinplate/features/report/presentation/widgets/daily_report_view.dart';
import 'package:skinplate/features/report/presentation/widgets/report_widgets.dart';
import 'package:skinplate/features/report/presentation/widgets/weekly_report_view.dart';

/// 리포트 두 탭의 화면 동작.
///
/// 데이터는 `test/fixtures` 의 응답을 그대로 파싱해서 만든다 — 손으로 엔티티를
/// 조립하면 "내가 상상한 서버"를 검증하게 되고, 계약 테스트와 두 벌이 된다.
void main() {
  /// 폭은 시안 프레임(402)이고 높이만 크게 잡는다.
  ///
  /// 리포트는 한 화면보다 길어서 실제 높이로 그리면 아래쪽 카드가 ListView 에
  /// 아예 만들어지지 않아 찾을 수 없다. **폭은 그대로 두는 것이 중요하다** —
  /// 오버플로는 가로에서 나고, 위젯 테스트는 그것을 실패로 잡아 준다.
  const designSize = Size(402, 2600);

  Map<String, dynamic> data(String name) {
    final body = jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  DailyReport daily(String fixture) =>
      DailyReportDto.fromJson(data(fixture)).toEntity();

  WeeklyReport weekly(String fixture) =>
      WeeklyReportDto.fromJson(data(fixture)).toEntity();

  Widget host(_FakeReportRepository repository, Widget child) => ProviderScope(
        overrides: [reportRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: child),
        ),
      );

  Future<void> pump(WidgetTester tester, Widget widget) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  // ---------- 오늘의 리포트 ----------

  group('오늘의 리포트', () {
    testWidgets('정상 응답 — 점수·등급·영양·고민·끼니·AI 가 한 화면에 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(daily('report_daily'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      expect(find.text('60'), findsOneWidget);
      // 서버가 NORMAL 을 줬고 앱은 그것을 3단계 어휘로 옮긴다.
      expect(find.text('보통'), findsWidgets);
      expect(find.text('오늘 3개 기록했어요'), findsOneWidget);

      // 영양 항목을 앱이 고르지 않는다. 서버가 준 6개가 그대로 나온다.
      expect(find.text('칼로리'), findsOneWidget);
      expect(find.text('나트륨'), findsOneWidget);
      // 일일은 3열 타일이라 절대량이 들어갈 자리가 없다(85px 칸). 서버가 준
      // 비율을 그린다 — 절대량은 주간 줄에 그대로 있고 그쪽 테스트가 본다.
      expect(find.text('78%'), findsOneWidget);   // 칼로리 1560/2000
      expect(find.text('278%'), findsOneWidget);  // 나트륨 5550/2000
      // 방향이 반대인 항목에 "과다"를 쓰지 않는다 — 단백질 HIGH 는 충분이다.
      expect(find.text('충분'), findsOneWidget);
      expect(find.text('과다'), findsWidgets);

      expect(find.text('여드름'), findsOneWidget);
      expect(find.text('74점'), findsOneWidget);
      // 다크서클은 서버가 보내지 않는다. 앱이 지어내지 않는다.
      expect(find.text('다크서클'), findsNothing);

      // 시안이 끼니 라벨을 그룹 머리글에서 줄 안으로 옮겼다. 세 기록이 모두
      // 점심이라 라벨이 세 번 나온다 — 줄만 보고 어느 끼니인지 알 수 있다.
      expect(find.text('점심'), findsNWidgets(3));
      expect(find.text('돼지고기 김치찌개'), findsNWidgets(3));

      expect(find.text('AI 오늘의 한마디'), findsOneWidget);
      // 같은 문구가 식단 포인트 칩과 고민 근거 태그에 함께 나온다. 서버가 두
      // 자리에 같은 근거를 실어 보내기 때문이고, 앱이 지어낸 중복이 아니다.
      expect(find.text('나트륨 과다'), findsWidgets);
      expect(find.text('단백질 충분'), findsOneWidget);
      expect(find.text('전체 기록 보기'), findsOneWidget);
    });

    testWidgets('피부 영양 포인트는 영양 밸런스와 다른 카드로 온다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(daily('report_daily'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      expect(find.text('피부 영양 포인트'), findsOneWidget);
      expect(find.text('비타민C'), findsOneWidget);
      expect(find.text('오메가3'), findsOneWidget);
      expect(find.text('아연'), findsOneWidget);

      // 비타민C 45/100 → LOW · higherIsWorse=false → "부족"
      expect(find.text('45%'), findsOneWidget);
      // 표준 음식표에 매칭된 끼니가 없으면 status 키가 없다. 0 을 "부족"이라고
      // 단정하지 않고 모른다고 말해야 한다.
      expect(find.text('알 수 없음'), findsOneWidget);
    });

    testWidgets('고민 카드에 서버가 준 이유 문장과 근거 태그가 함께 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(daily('report_daily'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      // 문장·태그 모두 서버가 저장된 룰 reason 에서 고른 것이다. 앱이 짓지 않는다.
      expect(find.text('당류가 높은 음식 섭취가 다소 많았어요.'), findsOneWidget);
      expect(find.text('당류 과다'), findsOneWidget);
      expect(find.text('항산화 식품 양호'), findsOneWidget);
    });

    testWidgets('기록이 없는 날 — 0점이 아니라 OO점이고 빈 안내가 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(daily('report_daily_empty'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      // 0 점은 "아주 나쁘게 먹었다"로 읽힌다. 아직 안 찍은 것과 다르다.
      expect(find.text('OO'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      expect(find.text('아직 오늘 기록이 없어요'), findsOneWidget);
      expect(find.text('오늘 기록된 음식이 없어요'), findsOneWidget);
      expect(find.text('기록이 없어 영양을 계산할 수 없어요'), findsOneWidget);
    });

    testWidgets('기록은 있는데 고민이 비면 골라 보라고 안내한다', (tester) async {
      // 고민을 안 골랐거나, 고른 고민이 전부 식단으로 설명할 수 없는 것(다크서클)
      // 이다. 서버는 둘을 같은 빈 배열로 주므로 앱이 원인을 하나로 단정하지 않는다.
      final report = daily('report_daily');
      final withoutConcerns = DailyReport(
        date: report.date,
        dailyScore: report.dailyScore,
        grade: report.grade,
        recordCount: report.recordCount,
        nutrition: report.nutrition,
        skinNutrients: report.skinNutrients,
        concerns: const [],
        meals: report.meals,
        aiComment: report.aiComment,
        goodPoints: report.goodPoints,
        improvePoints: report.improvePoints,
      );

      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(withoutConcerns)),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      // 앱이 점수를 지어내지 않는다. 왜 비었는지만 알린다.
      expect(find.textContaining('식단으로 볼 수 있는 피부 고민이 없어요'), findsOneWidget);
      // 기록은 있으니 점수·영양은 그대로 있다.
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('고민 상태가 색이 아니라 글자로도 뜬다 — 스크린리더가 읽는다', (tester) async {
      // 없애면 등급이 카드 바탕색에만 남는데, 그 바탕은 셋 다 흰색에 가까워
      // 서로 구분되지 않고 스크린리더는 색을 못 읽는다.
      final report = daily('report_daily');
      expect(report.concerns, isNotEmpty, reason: '픽스처에 고민이 없으면 아무것도 못 본다');
      // status 가 전부 null 이면 아래 루프가 통째로 비어 아무것도 검증하지 않는다.
      expect(report.concerns.any((concern) => concern.status != null), isTrue,
          reason: '픽스처의 등급이 전부 null 이면 이 테스트는 빈 껍데기다');

      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(report)),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      for (final concern in report.concerns) {
        final status = concern.status;
        if (status == null) continue;
        expect(
          // **고민 카드 안으로 좁힌다.** 화면 전체에서 찾으면 점수 카드가 그린
          // '보통' 이 대신 잡혀서, 칩을 비-좋음 등급에서 전부 없애도 통과한다.
          find.descendant(
            of: find.byType(ConcernList),
            matching: find.text(status.label),
          ),
          findsWidgets,
          reason: '${concern.label} 의 등급이 글자로 없다 — 색만 남으면 아무도 못 읽는다',
        );
      }
    });

    testWidgets('상태를 스크린리더가 한 번만 읽는다', (tester) async {
      final handle = tester.ensureSemantics();
      final report = daily('report_daily');
      final graded =
          report.concerns.where((concern) => concern.status != null).toList();
      expect(graded, isNotEmpty);

      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(report)),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      // excludeSemantics 가 없으면 안쪽 Text 노드가 합쳐져 "상태 보통\n보통" 이
      // 된다 — 같은 말을 두 번 읽는다.
      for (final label in graded.map((c) => c.status!.label).toSet()) {
        expect(find.bySemanticsLabel('상태 $label'), findsWidgets);
        expect(
          find.bySemanticsLabel('상태 $label\n$label'),
          findsNothing,
          reason: '등급이 두 번 읽힌다',
        );
      }

      handle.dispose();
    });

    testWidgets('주간 탭에서도 상태 칩이 산다 — 변화량까지 든 좁은 줄이다', (tester) async {
      // 같은 ConcernList 를 주간이 다시 쓴다. 그쪽 줄에는 변화량 라벨이 더 붙어
      // 가장 빡빡한 배치라, 여기서만 접히는 회귀가 나올 수 있다.
      final report = weekly('report_weekly');
      final graded =
          report.concerns.where((concern) => concern.status != null).toList();
      expect(graded, isNotEmpty);

      await pump(
        tester,
        host(
          _FakeReportRepository(weekly: Success(report)),
          const WeeklyReportView(),
        ),
      );

      for (final concern in graded) {
        expect(
          find.descendant(
            of: find.byType(ConcernList),
            matching: find.text(concern.status!.label),
          ),
          findsWidgets,
          reason: '주간 ${concern.label} 의 등급이 글자로 없다',
        );
      }
    });

    testWidgets('AI 문장이 없어도 점수와 영양은 그대로 뜬다', (tester) async {
      final report = daily('report_daily');
      final withoutAi = DailyReport(
        date: report.date,
        dailyScore: report.dailyScore,
        grade: report.grade,
        recordCount: report.recordCount,
        nutrition: report.nutrition,
        skinNutrients: report.skinNutrients,
        concerns: report.concerns,
        meals: report.meals,
        aiComment: null,
        goodPoints: report.goodPoints,
        improvePoints: report.improvePoints,
      );

      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(withoutAi)),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      expect(find.text('AI 오늘의 한마디'), findsNothing);
      expect(find.textContaining('AI 한마디는 아직 준비되지 않았어요'), findsOneWidget);
      // 나머지는 살아 있어야 한다.
      expect(find.text('60'), findsOneWidget);
      expect(find.text('칼로리'), findsOneWidget);
    });

    testWidgets('API 오류 — 화면이 깨지지 않고 다시 시도가 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(
            daily: const FailureResult(NetworkFailure()),
          ),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      expect(find.text('다시 시도'), findsOneWidget);
    });
  });

  // ---------- 주간 리포트 ----------

  group('주간 리포트', () {
    testWidgets('여러 날 기록 — 평균·기록일수·BEST/WORST·변화량이 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(
              weekly: Success(weekly('report_weekly_multiday'))),
          const WeeklyReportView(),
        ),
      );

      expect(find.text('76'), findsOneWidget);
      // 분모가 7이 아니라 기록한 5일이라는 것이 화면에 보여야 한다.
      expect(find.textContaining('7일 중 5일 기록'), findsOneWidget);

      // 서버는 1560.0 을 보낸다. 화면에는 "1,560" 이어야 한다 — 소수점 0 을
      // 그대로 쓰면 "1560.0kcal" 이 뜬다.
      expect(find.textContaining('1,560 / 2,000kcal'), findsOneWidget);
      expect(find.textContaining('5,550 / 2,000mg'), findsOneWidget);

      expect(find.text('이번 주 BEST'), findsOneWidget);
      expect(find.text('개선이 필요한 날'), findsOneWidget);
      // 막대 그래프가 칸마다 점수를 적으므로 BEST/WORST 점수와 겹친다.
      expect(find.text('91'), findsWidgets);
      expect(find.text('64'), findsWidgets);

      // 변화량은 서버가 준 값 그대로다.
      expect(find.text('+8점'), findsOneWidget);
      expect(find.text('-3점'), findsOneWidget);

      // 문장 넷이 각자 라벨을 달고 한 카드 안에 들어간다.
      // BEST/WORST 카드는 서버가 준 plateIds 로 그날 사진을 찾는다. 테스트 환경에는
      // 로컬 파일이 없으므로 자리를 비우지 않고 대체 아이콘이 뜬다.
      expect(find.byIcon(Icons.restaurant), findsWidgets);

      expect(find.text('AI 주간 분석'), findsOneWidget);
      expect(find.text('잘한 점'), findsOneWidget);
      expect(find.text('개선할 점'), findsOneWidget);
      expect(find.text('이번 주 습관'), findsOneWidget);
      expect(find.text('다음 주 제안'), findsOneWidget);
    });

    testWidgets('일부 날짜만 기록된 주 — 그래프가 0점을 그리지 않는다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(
              weekly: Success(weekly('report_weekly_multiday'))),
          const WeeklyReportView(),
        ),
      );

      // 8/13·8/16 은 기록이 없다. 점수 라벨이 CustomPainter 로 그려지므로
      // 위젯 트리에는 없고, 엔티티 수준에서 빈 날이 유지되는지를 본다.
      final report = weekly('report_weekly_multiday');
      expect(report.axis.length, 7);
      expect(report.scoreOn(DateTime(2026, 8, 13)), isNull);
      expect(report.dailyScores.every((score) => score.dailyScore > 0), isTrue);

      // 요일 축은 7칸 모두 그려진다 — 빈 날도 자리를 지킨다.
      for (final label in ['월', '화', '수', '목', '금', '토', '일']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('기록이 없는 주 — 평균이 OO 이고 그래프 자리에 안내가 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(weekly: Success(weekly('report_weekly_empty'))),
          const WeeklyReportView(),
        ),
      );

      expect(find.text('OO'), findsOneWidget);
      expect(find.text('이번 주에는 아직 기록이 없어요'), findsOneWidget);
      expect(find.text('이번 주에는 기록한 날이 없어요'), findsOneWidget);
      // BEST/WORST 는 서버가 안 주므로 카드째 없다.
      expect(find.text('이번 주 BEST'), findsNothing);
    });

    testWidgets('AI 만 실패해도 숫자·그래프·BEST DAY 는 정상으로 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(weekly: Success(weekly('report_weekly_no_ai'))),
          const WeeklyReportView(),
        ),
      );

      expect(find.text('AI 주간 분석'), findsNothing);
      expect(find.textContaining('AI 주간 분석을 가져오지 못했어요'), findsOneWidget);

      // 문장만 빠지고 숫자·영양·BEST DAY 는 그대로 떠 있어야 한다.
      expect(find.text('60'), findsWidgets);
      expect(find.text('이번 주 BEST'), findsOneWidget);
      expect(find.text('칼로리'), findsOneWidget);
    });

    testWidgets('이전 주로 이동한다 — 다음 주는 이번 주에서 잠겨 있다', (tester) async {
      final repository = _FakeReportRepository(
          weekly: Success(weekly('report_weekly_multiday')));

      await pump(tester, host(repository, const WeeklyReportView()));

      // 미래는 서버가 막지 않고 빈 리포트를 준다. 앱이 잠가야 한다.
      final forward = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );
      expect(forward.onPressed, isNull);

      final firstRange = repository.lastRange;
      expect(firstRange, isNotNull);

      // 이번 주는 월요일에서 시작하고 **오늘에서 끊긴다.** 일요일까지 보내면
      // 아직 오지도 않은 날이 AI 프롬프트의 "N일 중 M일 기록"에 들어간다.
      expect(firstRange!.from.weekday, DateTime.monday);
      expect(firstRange.to.isAfter(todayKst()), isFalse);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // 주의 기준점은 **시작일**이다. 끝은 이번 주만 오늘에서 잘리므로
      // 7일 간격이 아니다 — 요일에 따라 3일 차이도 나고 0일 차이도 난다.
      //
      // 정확히 7일 앞선 월요일이어야 한다. 달력 뺄셈이라 Duration(days: 7) 이
      // 아니다 — 서머타임에서 한 시간 어긋난다.
      final previousFrom = firstRange.from;
      expect(
        repository.lastRange!.from,
        DateTime(previousFrom.year, previousFrom.month, previousFrom.day - 7),
      );

      // 지나간 주는 일요일까지 다 왔으므로 월~일 이레가 통째로 온다.
      final past = repository.lastRange!;
      expect(past.from.weekday, DateTime.monday);
      expect(past.to, DateTime(past.from.year, past.from.month, past.from.day + 6));

      // 이제 다음 주로 돌아갈 수 있다.
      final forwardAgain = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );
      expect(forwardAgain.onPressed, isNotNull);
    });

    testWidgets('탭을 넘겼다 돌아와도 보고 있던 주가 유지된다', (tester) async {
      // TabBarView 는 화면 밖 자식을 버린다. 살려 두지 않으면 이 State 가 새로
      // 만들어져 보고 있던 주가 이번 주로 되돌아가고, autoDispose 프로바이더도
      // 함께 버려져 최대 27초짜리 AI 생성이 다시 돈다.
      final repository = _FakeReportRepository(
        daily: Success(daily('report_daily')),
        weekly: Success(weekly('report_weekly_multiday')),
      );

      await pump(
        tester,
        ProviderScope(
          overrides: [reportRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: ReportPage()),
        ),
      );

      await tester.tap(find.text('주간 리포트'));
      await tester.pumpAndSettle();

      // 두 탭이 다 살아 있으므로(그게 이 테스트의 요점이다) 화살표를 주간
      // 화면 안으로 좁혀서 찾는다. 좁히지 않으면 일일 탭의 날짜 화살표까지
      // 잡혀 tap 이 "여럿 찾음"으로 죽는다.
      final weeklyBack = find.descendant(
        of: find.byType(WeeklyReportView),
        matching: find.byIcon(Icons.chevron_left),
      );
      final weeklyRange = find.descendant(
        of: find.byType(WeeklyReportView),
        matching: find.textContaining(' ~ '),
      );

      await tester.tap(weeklyBack);
      await tester.pumpAndSettle();
      final previousWeek = tester.widget<Text>(weeklyRange).data;

      await tester.tap(find.text('오늘의 리포트'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('주간 리포트'));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(weeklyRange).data, previousWeek,
          reason: '탭을 넘겼다 오면 이번 주로 되돌아가면 안 된다');
    });

    testWidgets('불러오는 중에는 주 이동 화살표가 잠긴다', (tester) async {
      // 27초짜리 조회 위에서 화살표를 연타하면 매번 다른 기간이라 요청이
      // 그만큼 새로 나가고, Dio 는 앞선 요청을 취소하지 않는다 —
      // 사용자는 한 번 넘겼다고 생각하는데 서버는 AI 를 다섯 번 돌린다.
      final repository = _FakeReportRepository(
        weekly: Success(weekly('report_weekly')),
        pending: true,
      );

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(repository, const WeeklyReportView()));
      await tester.pump(); // 로딩 상태에서 멈춘다

      for (final icon in [Icons.chevron_left, Icons.chevron_right]) {
        final button = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(icon),
            matching: find.byType(IconButton),
          ),
        );
        expect(button.onPressed, isNull, reason: '$icon 이 잠겨 있어야 한다');
      }

      repository.release();
      await tester.pumpAndSettle();
    });

    testWidgets('API 오류 — 다시 시도가 뜬다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(
            weekly: const FailureResult(NetworkFailure()),
          ),
          const WeeklyReportView(),
        ),
      );

      expect(find.text('다시 시도'), findsOneWidget);
    });
  });

  /// 실서버 응답 원문을 그대로 파싱해서 화면까지 올린다.
  ///
  /// 계약 테스트는 "키가 값으로 올라오는가" 까지만 본다. 그 값이 위젯으로 그려지는지는
  /// 별개다 — 파싱은 됐는데 화면이 조건을 잘못 걸어 안 그리는 경우를 여기서 잡는다.
  testWidgets('실서버 일일 응답이 화면까지 올라온다 — 피부 영양·고민 문장·등급',
      (tester) async {
    await pump(
      tester,
      host(
        _FakeReportRepository(daily: Success(daily('report_daily_live'))),
        DailyReportView(date: DateTime(2026, 8, 17)),
      ),
    );

    // 피부 영양 포인트 3종. 서버가 준 라벨 그대로다.
    expect(find.text('비타민C'), findsOneWidget);
    expect(find.text('오메가3'), findsOneWidget);
    expect(find.text('아연'), findsOneWidget);
    // 표준 음식표에 매칭된 끼니가 없어 비타민C·아연은 못 잰 상태로 왔다.
    // "부족" 이 아니라 "알 수 없음" 이어야 한다.
    expect(find.text('알 수 없음'), findsNWidgets(2));

    // 고민 문장과 태그. 앱이 짓지 않은 서버 문장이다.
    expect(find.text('발효식품이 포함돼 있어요. 꾸준히 챙기면 도움이 될 수 있어요.'),
        findsOneWidget);
    // 같은 근거가 두 고민에 걸려서 칩도 둘이다(여드름·부기). 서버가 고민마다
    // 따로 골라 주기 때문이고, 앱이 합치지 않는다.
    expect(find.text('발효식품 포함'), findsWidgets);

    // 끼니 줄에는 서버 등급 라벨만 있다. **주요영양 칩은 여기 없다** — 시안이
    // 리포트의 "오늘 먹은 음식" 은 사진·이름·라벨 세 개로만 두고, 칩은 기록
    // 화면(S09)의 카드에 둔다. 그쪽은 plate_delete_test 가 본다.
    expect(find.text('BAD'), findsWidgets);
    expect(find.text('돼지고기 김치찌개'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('평균 배너 — 기본 크기에서 점수 글자가 시안(40)을 지킨다', (tester) async {
    // 오른쪽 묶음을 flex 로 감싸면 왼쪽 문장과 폭을 나눠 가져서, 어느 쪽으로
    // 기울여도 시안이 깨진다(문장이 두 줄로 접히거나 40px 숫자가 29.7 로 줄었다).
    // 지금은 flex 를 쓰지 않고 배율 상한만 둔다.
    await pump(
      tester,
      host(
        _FakeReportRepository(weekly: Success(weekly('report_weekly_live'))),
        const WeeklyReportView(),
      ),
    );

    // 실서버 캡처의 평균은 60 이다. 같은 숫자가 추이 그래프에도 있으므로 배너
    // 안에서 찾는다.
    final score = tester.getSize(find.descendant(
      of: find.byType(ReportCard).first,
      matching: find.text('60'),
    ).first);
    expect(score.height, closeTo(40, 6), reason: '점수 글자 높이');
  });

  testWidgets('네 끼 넘는 날은 남은 개수를 적는다 — 말없이 자르지 않는다', (tester) async {
    // 실서버 응답의 BEST DAY 가 5끼다. 썸네일 칸은 셋이라 둘이 남는다.
    await pump(
      tester,
      host(
        _FakeReportRepository(weekly: Success(weekly('report_weekly_live'))),
        const WeeklyReportView(),
      ),
    );

    // BEST 와 WORST 가 같은 날이라(기록일 하루) 두 카드에 같이 뜬다.
    expect(find.text('+2'), findsNWidgets(2));
  });

  /// 에뮬레이터 QA(2026-08-19)에서 잡힌 것. 오늘 기록이 없는 날 고민 카드가
  /// "프로필에서 고민을 골라 보세요" 라고 했는데, 테스트 계정은 이미 고민을 셋
  /// 골라 둔 상태였다 — 원인을 잘못 짚으면 사용자가 시키는 대로 해도 화면이 그대로다.
  testWidgets('기록이 없는 날 고민 카드는 프로필 탓을 하지 않는다', (tester) async {
    await pump(
      tester,
      host(
        _FakeReportRepository(daily: Success(daily('report_daily_empty'))),
        DailyReportView(date: DateTime(2026, 8, 19)),
      ),
    );

    expect(find.text('기록이 없어 고민별 점수를 낼 수 없어요'), findsOneWidget);
    expect(find.textContaining('프로필에서 고민을 골라'), findsNothing);
  });

  // ---------- 시스템 글자 크기 ----------

  /// 접근성 설정을 최대로 올린 기기. **가로 오버플로는 여기서만 드러난다** —
  /// 세로는 길어지면 스크롤이 되지만 가로는 잘린다. 이번에 늘어난 카드(피부 영양
  /// 포인트 3열 · 고민 태그 칩 · BEST/WORST 썸네일 3칸)가 전부 가로로 나뉜 칸이라
  /// 두 탭을 각각 한 번 그려 본다.
  group('글자 크기 2.0', () {
    Widget scaled(Widget child) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: child,
        );

    testWidgets('오늘의 리포트 — 넘치지 않는다', (tester) async {
      await pump(
        tester,
        scaled(host(
          _FakeReportRepository(daily: Success(daily('report_daily'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        )),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('100점짜리 날이 있어도 그래프가 넘치지 않는다', (tester) async {
      // 눈금판 높이가 고정이라 라벨이 커지면 100 점 막대가 판을 넘긴다.
      final report = weekly('report_weekly_multiday');
      final maxed = WeeklyReport(
        from: report.from,
        to: report.to,
        averageDailyScore: 100,
        grade: report.grade,
        totalDays: report.totalDays,
        recordedDays: report.recordedDays,
        recordCount: report.recordCount,
        dailyScores: [
          for (final day in report.dailyScores)
            DayScore(
              date: day.date,
              dailyScore: 100,
              grade: day.grade,
              plateIds: day.plateIds,
            ),
        ],
        nutrition: report.nutrition,
        concerns: report.concerns,
        bestDay: report.bestDay,
        worstDay: report.worstDay,
        aiComment: report.aiComment,
      );

      await pump(
        tester,
        scaled(host(
          _FakeReportRepository(weekly: Success(maxed)),
          const WeeklyReportView(),
        )),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('주간 리포트 — 썸네일 줄도 넘치지 않는다', (tester) async {
      await pump(
        tester,
        scaled(host(
          _FakeReportRepository(weekly: Success(weekly('report_weekly_multiday'))),
          const WeeklyReportView(),
        )),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

/// 화면만 보기 위한 가짜 저장소. 프로바이더 배선은 그대로 탄다.
class _FakeReportRepository implements ReportRepository {
  _FakeReportRepository({
    Result<DailyReport>? daily,
    Result<WeeklyReport>? weekly,
    bool pending = false,
  })  : _daily = daily,
        _weekly = weekly,
        _gate = pending ? Completer<void>() : null;

  final Result<DailyReport>? _daily;
  final Result<WeeklyReport>? _weekly;

  /// 응답을 붙잡아 두는 문. 로딩 상태를 그대로 세워 두고 화면을 본다.
  final Completer<void>? _gate;

  void release() => _gate?.complete();

  /// 마지막으로 조회한 구간. 주 이동이 실제로 다른 구간을 부르는지 본다.
  ({DateTime from, DateTime to})? lastRange;

  @override
  Future<Result<DailyReport>> daily({DateTime? date}) async =>
      _daily ?? (throw UnimplementedError());

  @override
  Future<Result<WeeklyReport>> weekly({DateTime? from, DateTime? to}) async {
    if (from != null && to != null) lastRange = (from: from, to: to);
    await _gate?.future;
    return _weekly ?? (throw UnimplementedError());
  }
}
