import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/report/data/models/report_dtos.dart';
import 'package:skinplate/features/report/domain/entities/report.dart';
import 'package:skinplate/features/report/domain/repositories/report_repository.dart';
import 'package:skinplate/features/report/presentation/pages/report_page.dart';
import 'package:skinplate/features/report/presentation/widgets/daily_report_view.dart';
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
      // 서버는 1560.0 을 보낸다. 화면에는 "1,560" 이어야 한다 — 소수점 0 을
      // 그대로 쓰면 "1560.0kcal" 이 뜬다.
      expect(find.textContaining('1,560 / 2,000kcal'), findsOneWidget);
      expect(find.textContaining('5,550 / 2,000mg'), findsOneWidget);

      expect(find.text('여드름'), findsOneWidget);
      expect(find.text('74점'), findsOneWidget);
      // 다크서클은 서버가 보내지 않는다. 앱이 지어내지 않는다.
      expect(find.text('다크서클'), findsNothing);

      // 끼니 그룹은 앱이 만든다. 세 기록이 모두 점심이라 묶음이 하나다.
      expect(find.text('점심'), findsOneWidget);
      expect(find.text('돼지고기 김치찌개'), findsNWidgets(3));

      expect(find.text('AI 오늘의 한마디'), findsOneWidget);
      expect(find.text('나트륨 과다'), findsOneWidget);
      expect(find.text('단백질 충분'), findsOneWidget);
      expect(find.text('전체 기록 보기'), findsOneWidget);
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

    testWidgets('concerns 가 빈 배열이어도 화면이 깨지지 않는다', (tester) async {
      await pump(
        tester,
        host(
          _FakeReportRepository(daily: Success(daily('report_daily_empty'))),
          DailyReportView(date: DateTime(2026, 8, 17)),
        ),
      );

      // 앱이 점수를 지어내지 않는다. 왜 비었는지만 알린다.
      expect(find.textContaining('식단으로 볼 수 있는 피부 고민이 없어요'), findsOneWidget);
    });

    testWidgets('AI 문장이 없어도 점수와 영양은 그대로 뜬다', (tester) async {
      final report = daily('report_daily');
      final withoutAi = DailyReport(
        date: report.date,
        dailyScore: report.dailyScore,
        grade: report.grade,
        recordCount: report.recordCount,
        nutrition: report.nutrition,
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

      expect(find.text('이번 주 BEST'), findsOneWidget);
      expect(find.text('개선이 필요한 날'), findsOneWidget);
      expect(find.text('91'), findsOneWidget);
      expect(find.text('64'), findsOneWidget);

      // 변화량은 서버가 준 값 그대로다.
      expect(find.text('+8점'), findsOneWidget);
      expect(find.text('-3점'), findsOneWidget);

      // 문장 넷이 각자 라벨을 달고 한 카드 안에 들어간다.
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

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // 정확히 7일 앞선 구간을 조회해야 한다. 달력 뺄셈이라
      // Duration(days: 7) 이 아니다 — 서머타임에서 한 시간 어긋난다.
      final previous = firstRange!.to;
      expect(
        repository.lastRange!.to,
        DateTime(previous.year, previous.month, previous.day - 7),
      );

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

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      final previousWeek =
          tester.widget<Text>(find.textContaining(' - ')).data;

      await tester.tap(find.text('오늘의 리포트'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('주간 리포트'));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.textContaining(' - ')).data, previousWeek,
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
