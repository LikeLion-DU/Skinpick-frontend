import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/report/data/models/report_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_result_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_score_card.dart';
import 'package:skinplate/shared/enums/metric_band.dart';
import 'package:skinplate/shared/enums/nutrient_status.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 이번에 서버가 새로 주기 시작한 필드들의 앱 쪽 계약.
///
/// **키가 없는 응답에서도 앱이 죽지 않아야 한다.** 새 필드가 붙기 전 서버와 붙을
/// 수도 있고(배포 순서), 예전에 저장된 기록은 애초에 그 값을 만들 수 없다.
/// 그래서 파싱 테스트와 화면 테스트를 함께 둔다.
void main() {
  const designSize = Size(402, 874);

  Map<String, dynamic> data(String name) =>
      (jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  // ─────────────────────── 파싱 (① ② ③ ④ ⑥) ───────────────────────

  group('파싱', () {
    test('skinNutrients — 재지 못한 항목은 status 가 null 이라 "부족"이 아니다', () {
      final report = DailyReportDto.fromJson(data('report_daily')).toEntity();

      expect(report.nutrition, hasLength(6));
      expect(report.skinNutrients, hasLength(3));

      final zinc = report.skinNutrients
          .firstWhere((item) => item.nutrient == 'ZINC');
      expect(zinc.status, isNull);
      // 0 을 "부족"으로 읽으면 안 된다 — isWarning 은 status 가 없으면 false 다.
      expect(zinc.isWarning, isFalse);

      final vitaminC = report.skinNutrients
          .firstWhere((item) => item.nutrient == 'VITAMIN_C');
      expect(vitaminC.status, NutrientStatus.low);
      // higherIsWorse=false 이므로 LOW 는 경고다.
      expect(vitaminC.isWarning, isTrue);
    });

    test('오메가3 는 단위가 "회" 다 — 앱이 g 으로 읽지 않는다', () {
      final report = DailyReportDto.fromJson(data('report_daily')).toEntity();
      final omega3 =
          report.skinNutrients.firstWhere((item) => item.nutrient == 'OMEGA3');

      expect(omega3.unit, '회');
      expect(omega3.target, 1);
    });

    test('고민 문장·태그를 그대로 받는다 — 앱이 조합하지 않는다', () {
      final report = DailyReportDto.fromJson(data('report_daily')).toEntity();
      final acne =
          report.concerns.firstWhere((item) => item.concern == 'ACNE');

      expect(acne.message, '당류가 높은 음식 섭취가 다소 많았어요.');
      expect(acne.tags, ['당류 과다', '튀김 조리']);
    });

    test('기록 카드 태그를 그대로 받는다', () {
      final report = DailyReportDto.fromJson(data('report_daily')).toEntity();

      expect(report.meals.first.highlightTags, isNotEmpty);
      expect(report.meals.map((meal) => meal.highlightTags).expand((t) => t),
          contains('나트륨'));
    });

    test('BEST/WORST 에만 plateIds 가 있고 추이 칸에는 없다', () {
      final weekly =
          WeeklyReportDto.fromJson(data('report_weekly_multiday')).toEntity();

      expect(weekly.bestDay!.plateIds, [41, 42, 43]);
      expect(weekly.worstDay!.plateIds, [51]);
      // 그래프 칸은 서버가 키를 생략한다 → 기본값 빈 배열.
      expect(weekly.dailyScores, everyElement(
          predicate<dynamic>((score) => score.plateIds.isEmpty)));
    });

    test('careFocus·careMessage 를 그대로 받는다', () {
      final analysis = SkinAnalysisDto.fromJson(data('skin_latest')).toEntity();

      expect(analysis.careFocus.map((item) => item.focus),
          ['HYDRATION', 'ANTIOXIDANT']);
      expect(analysis.careFocus.map((item) => item.label),
          ['수분·장벽', '항산화']);
      expect(analysis.careMessage, contains('수분 유지에 도움이 되는 식습관'));
    });
  });

  // ─────────────────────── 하위 호환 ───────────────────────

  group('새 필드가 없는 응답', () {
    test('일일 리포트 — skinNutrients·message·tags 키가 없어도 파싱된다', () {
      final json = Map<String, dynamic>.from(data('report_daily'))
        ..remove('skinNutrients');
      for (final concern in (json['concerns'] as List)
          .cast<Map<String, dynamic>>()) {
        concern.remove('message');
        concern.remove('tags');
      }
      for (final meal in (json['meals'] as List).cast<Map<String, dynamic>>()) {
        meal.remove('highlightTags');
      }

      final report = DailyReportDto.fromJson(json).toEntity();

      expect(report.skinNutrients, isEmpty);
      expect(report.concerns.first.message, isNull);
      expect(report.concerns.first.tags, isEmpty);
      expect(report.meals.first.highlightTags, isEmpty);
      // 기존 값은 그대로 온다.
      expect(report.dailyScore, 60);
      expect(report.nutrition, hasLength(6));
    });

    test('주간 리포트 — plateIds 가 없어도 BEST/WORST 는 그려진다', () {
      // report_weekly.json 은 새 필드를 넣지 않은 옛 응답 그대로 두었다.
      final weekly =
          WeeklyReportDto.fromJson(data('report_weekly')).toEntity();

      expect(weekly.bestDay, isNotNull);
      expect(weekly.bestDay!.plateIds, isEmpty);
      expect(weekly.averageDailyScore, 60);
    });

    test('피부 분석 — careFocus·careMessage 키가 없어도 파싱된다', () {
      final json = Map<String, dynamic>.from(data('skin_latest'))
        ..remove('careFocus')
        ..remove('careMessage');

      final analysis = SkinAnalysisDto.fromJson(json).toEntity();

      expect(analysis.careFocus, isEmpty);
      expect(analysis.careMessage, isNull);
      // 요약과 하이라이트는 그대로다 — 화면이 그쪽으로 떨어진다.
      expect(analysis.summary, isNotEmpty);
      expect(analysis.highlights, isNotEmpty);
    });

    test('등급 키가 없으면 배지만 사라진다 — 앱이 점수에서 다시 매기지 않는다', () {
      final json = Map<String, dynamic>.from(data('plate_history'))
        ..remove('grade');
      for (final day in (json['days'] as List).cast<Map<String, dynamic>>()) {
        day.remove('grade');
        for (final plate
            in (day['plates'] as List).cast<Map<String, dynamic>>()) {
          plate.remove('grade');
        }
      }

      final days = PlateHistoryDto.fromJson(json).toEntity();

      expect(days.first.grade, isNull);
      expect(days.first.plates.first.grade, isNull);
      // 점수는 그대로 온다 — 사라지는 것은 등급 라벨뿐이다.
      expect(days.first.plates.first.plateScore, isNotNull);
    });

    testWidgets('등급을 모르면 점수 카드가 배지 없이 숫자만 그린다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: PlateScoreCard(score: 58, grade: null)),
      ));

      expect(find.text('58'), findsOneWidget);
      // 58 을 보고 '보통'이라고 앱이 말하면 그게 두 번째 경계표다.
      expect(find.text('보통'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    test('목표 점수 키가 없으면 null 이다 — 앱이 80 을 만들지 않는다', () {
      final json = Map<String, dynamic>.from(data('plate_history'));
      for (final day in (json['days'] as List).cast<Map<String, dynamic>>()) {
        day.remove('targetScore');
      }

      final days = PlateHistoryDto.fromJson(json).toEntity();

      // 목표는 서버가 정한다. 기본값 80 을 두면 사용자별 목표가 생기는 날
      // 앱이 조용히 옛 목표를 그린다.
      expect(days.first.targetScore, isNull);
      // 점수는 그대로다 — 사라지는 것은 목표 막대뿐이다.
      expect(days.first.plateScore, isNotNull);
    });

    test('지표 등급이 없으면 상태어만 사라진다 — 앱이 60/40 표를 다시 만들지 않는다', () {
      final json = Map<String, dynamic>.from(data('skin_latest'));
      for (final detail
          in (json['metricDetails'] as List).cast<Map<String, dynamic>>()) {
        detail.remove('level');
      }

      final analysis = SkinAnalysisDto.fromJson(json).toEntity();

      expect(analysis.levelOf('hydration'), isNull);
      expect(MetricBand.of(null, higherIsBetterMetric: true), isNull);
      // 값과 근거는 그대로다 — 막대는 계속 그려진다.
      expect(analysis.metricDetails.first.score, isNonZero);
      expect(analysis.metrics.hydration, isNonZero);
    });

    test('히스토리 — highlightTags 가 없어도 파싱된다', () {
      final json = Map<String, dynamic>.from(data('plate_history'));
      for (final day in (json['days'] as List).cast<Map<String, dynamic>>()) {
        for (final plate
            in (day['plates'] as List).cast<Map<String, dynamic>>()) {
          plate.remove('highlightTags');
        }
      }

      final history = PlateHistoryDto.fromJson(json);

      expect(history.days.first.plates.first.highlightTags, isEmpty);
    });
  });

  // ─────────────────────── 화면 (⑥ ⑦) ───────────────────────

  group('화면', () {
    const user = AuthUser(
      userId: 1,
      email: 'test@skinplate.app',
      nickname: '테스트유저',
    );

    Widget skinResult(Map<String, dynamic> json) {
      final analysis = SkinAnalysisDto.fromJson(json).toEntity();

      return ProviderScope(
        overrides: [
          latestSkinAnalysisProvider
              .overrideWith((ref) async => Success(analysis)),
          authNotifierProvider.overrideWith(() => _StubAuth(user)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SkinResultPage(),
        ),
      );
    }

    testWidgets('관리 축 칩과 권고 문단이 서버 값으로 뜬다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(skinResult(data('skin_latest')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('지금 피부가 필요로 하는 관리'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('수분·장벽'), findsOneWidget);
      expect(find.text('항산화'), findsOneWidget);
      expect(find.textContaining('수분 유지에 도움이 되는 식습관'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('careMessage 가 없으면 관찰 요약으로 떨어진다 — 앱이 문장을 짓지 않는다',
        (tester) async {
      final json = Map<String, dynamic>.from(data('skin_latest'))
        ..remove('careFocus')
        ..remove('careMessage');

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(skinResult(json));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('지금 피부가 필요로 하는 관리'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // 서버 summary 다. 앱이 지은 문장이 아니다.
      expect(find.text('피부 장벽은 양호하지만 건조하고 홍조가 관찰됩니다.'), findsOneWidget);
      expect(find.text('수분·장벽'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('실서버 피부 응답이 화면까지 올라온다 — 관리 축·문단·지표 상태어',
        (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(skinResult(data('skin_latest_live')));
      await tester.pumpAndSettle();

      // 서버가 지표마다 매긴 등급이 상태어로 올라온다. 수분 CAUTION 은 낮아서
      // 나쁜 쪽이라 "부족", 홍조 CAUTION 은 높아서 나쁜 쪽이라 "주의"다.
      expect(find.text('부족'), findsOneWidget);
      expect(find.text('주의'), findsOneWidget);
      expect(find.text('보통'), findsOneWidget);
      expect(find.text('좋음'), findsNWidgets(2));

      await tester.scrollUntilVisible(
        find.text('지금 피부가 필요로 하는 관리'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('수분·장벽'), findsOneWidget);
      expect(find.text('항산화'), findsOneWidget);
      expect(find.textContaining('수분 유지에 도움이 되는 식습관'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('프로필 설정에 수부지 칸이 있고 서버 enum 이름으로 저장된다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(ProviderScope(
        overrides: [authNotifierProvider.overrideWith(() => _StubAuth(user))],
        child: MaterialApp(theme: AppTheme.light, home: const SkinTypePage()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('수부지'), findsOneWidget);
      // 서버 `SkinType.selectable()` 과 같은 순서·같은 wire 이름이어야 한다.
      expect(SkinType.selectable.map((type) => type.wire).toList(), [
        'DRY',
        'OILY',
        'COMBINATION',
        'SENSITIVE',
        'DEHYDRATED_OILY',
        'UNKNOWN',
      ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('수부지에도 글리프와 설명이 있다 — 빈 칸으로 남지 않는다', (tester) async {
      expect(SkinType.dehydratedOily.glyph,
          'assets/icons/skin_type_dehydrated_oily.png');
      expect(SkinType.dehydratedOily.description, isNotNull);
      expect(File(SkinType.dehydratedOily.glyph).existsSync(), isTrue);
    });
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
