import '../../../../shared/enums/score_grade.dart';
import 'plate_history.dart';

/// `GET /reports?period=WEEK` 응답 그대로. **서버가 센 값이다.**
///
/// 평균을 앱에서 다시 내지 않는다 — 반올림이 조금만 달라도 홈 카드와 리포트
/// 화면에 서로 다른 "이번 주 평균"이 뜬다.
class PlateReport {
  const PlateReport({
    required this.from,
    required this.to,
    required this.averageScore,
    required this.recordCount,
  });

  /// 서버 기준 이번 주. `lastDays(7)` 이라 **오늘을 포함한 7일**이다
  /// (달력 주가 아니다 — 월요일에 리셋되지 않는다).
  final DateTime from;
  final DateTime to;

  /// 기록이 0건이면 null. 0 점이 아니다.
  final int? averageScore;

  final int recordCount;
}

/// 주간 피부 식단 리포트 — 화면이 쓰는 형태.
///
/// 서버가 센 이번 주([PlateReport])에, 저장된 기록에서 뽑은 두 가지를 얹는다:
/// **지난주 평균**과 **음식 TOP**. 둘 다 서버에 없는 값이라 앱이 만들지만,
/// 만드는 것은 *집계*지 점수가 아니다 — 개별 점수는 전부 서버가 매겨 저장한
/// `plateScore` 를 그대로 쓴다.
class WeeklyReport {
  const WeeklyReport({
    required this.from,
    required this.to,
    required this.averageScore,
    required this.recordCount,
    required this.lastWeekAverage,
    required this.bestFoods,
    required this.cautionFoods,
  });

  final DateTime from;
  final DateTime to;
  final int? averageScore;
  final int recordCount;

  /// 직전 7일 평균. 그 기간에 기록이 없으면 null 이고 화면은 비교를 숨긴다.
  final int? lastWeekAverage;

  /// 지난주 대비. 한쪽이라도 비면 null 이다 — 없는 주를 0 으로 놓고 빼면
  /// 첫 주에 "+78" 이 뜬다.
  int? get scoreDelta => (averageScore == null || lastWeekAverage == null)
      ? null
      : averageScore! - lastWeekAverage!;

  /// 이번 주 잘 맞았던 음식 / 주의가 필요했던 음식. 각각 최대 3개.
  final List<PlateHistoryItem> bestFoods;
  final List<PlateHistoryItem> cautionFoods;

  bool get isEmpty => recordCount == 0;

  static const _topCount = 3;

  /// [days] 는 지난주 시작일부터 이번 주 끝까지 14일치여야 한다.
  /// [report] 의 `from` 을 경계로 두 구간을 가른다 — 앱이 날짜를 다시 계산하면
  /// 기기 시간대가 KST 와 어긋나는 순간 하루가 밀린다.
  static WeeklyReport assemble({
    required PlateReport report,
    required List<PlateHistoryDay> days,
  }) {
    final thisWeek = <PlateHistoryItem>[];
    final lastWeek = <PlateHistoryItem>[];

    for (final day in days) {
      (day.date.isBefore(report.from) ? lastWeek : thisWeek).addAll(day.plates);
    }

    return WeeklyReport(
      from: report.from,
      to: report.to,
      averageScore: report.averageScore,
      recordCount: report.recordCount,
      lastWeekAverage: _average(lastWeek),
      bestFoods: _pick(thisWeek, ScoreGrade.good, best: true),
      cautionFoods: _pick(thisWeek, ScoreGrade.caution, best: false),
    );
  }

  /// 서버 `ReportService.averageScore` 와 같은 식이다 —
  /// 끼니 단위 산술평균을 반올림하고, 0건이면 null.
  static int? _average(List<PlateHistoryItem> items) {
    if (items.isEmpty) return null;

    final total = items.fold<int>(0, (sum, item) => sum + item.plateScore);
    return (total / items.length).round();
  }

  /// 같은 음식을 여러 번 먹었으면 한 줄로 합친다. 합치지 않으면 "샐러드 92 ·
  /// 샐러드 88" 처럼 같은 이름이 TOP 을 채워 다양성이 사라진다.
  /// 잘 맞았던 쪽은 그 음식의 **최고점**, 주의 쪽은 **최저점**을 대표로 세운다.
  ///
  /// 등급 경계는 [ScoreGrade] 를 그대로 쓴다. 여기서 임계값을 새로 만들면
  /// 기록 카드의 배지와 리포트의 분류가 따로 놀게 된다.
  static List<PlateHistoryItem> _pick(
    List<PlateHistoryItem> items,
    ScoreGrade grade, {
    required bool best,
  }) {
    final representatives = <String, PlateHistoryItem>{};

    for (final item in items) {
      if (ScoreGrade.fromScore(item.plateScore) != grade) continue;

      final kept = representatives[item.foodName];
      if (kept == null ||
          (best
              ? item.plateScore > kept.plateScore
              : item.plateScore < kept.plateScore)) {
        representatives[item.foodName] = item;
      }
    }

    final picked = representatives.values.toList()
      ..sort((a, b) {
        final byScore = best
            ? b.plateScore.compareTo(a.plateScore)
            : a.plateScore.compareTo(b.plateScore);
        // 동점이면 최근에 먹은 것이 위다. 정렬이 흔들리면 새로고침마다
        // 순서가 바뀌어 사용자가 목록을 못 믿는다.
        return byScore != 0 ? byScore : b.recordedAt.compareTo(a.recordedAt);
      });

    return picked.take(_topCount).toList();
  }
}
