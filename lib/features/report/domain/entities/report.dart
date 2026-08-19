/// 리포트 화면이 쓰는 형태. **숫자는 전부 서버가 센 값 그대로다** —
/// 여기서 평균을 내거나 등급을 매기는 코드는 한 줄도 없다.
///
/// 일일과 주간이 한 파일에 있는 것은 두 화면이 같은 조각([NutritionItem]·
/// [ConcernScore])을 공유하기 때문이다. 나누면 그 조각이 어느 쪽에 속하는지가
/// 애매해지고, 결국 두 벌이 생긴다.
library;

import '../../../../core/utils/kst_date.dart';
import '../../../../shared/enums/meal_type.dart';
import '../../../../shared/enums/nutrient_status.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';

/// 영양 밸런스 막대 하나.
///
/// **기준값도 라벨도 단위도 서버가 보낸다.** 앱에 영양 상수를 두면 서버가 기준을
/// 조정할 때마다 앱 배포가 필요해진다.
class NutritionItem {
  const NutritionItem({
    required this.nutrient,
    required this.label,
    required this.unit,
    required this.amount,
    required this.target,
    required this.percent,
    required this.status,
    required this.higherIsWorse,
  });

  /// 서버 enum 이름(`CALORIES` 등). 화면은 이것을 **키로만** 쓰고 표시는
  /// [label] 로 한다 — 앱이 항목 목록을 알면 서버가 항목을 늘려도 안 그린다.
  final String nutrient;

  final String label;
  final String unit;

  /// 하루 합계(주간이면 기록일 하루 평균).
  final double amount;

  final int target;

  /// 기준 대비 비율(%). 100 을 넘을 수 있다 — 막대를 그릴 때 잘라야 한다.
  final int percent;

  /// 모르는 값이면 null. 그때는 색을 입히지 않고 회색으로 둔다.
  final NutrientStatus? status;

  /// 초과가 문제인 항목이면 true. 단백질만 부족이 문제다.
  final bool higherIsWorse;

  /// 경고색으로 칠할지. 서버가 준 위치와 방향을 조합할 뿐이다.
  bool get isWarning =>
      status?.isWarning(higherIsWorse: higherIsWorse) ?? false;
}

/// 자가 신고 피부 고민 하나에 대한 식단 점수.
///
/// "여드름이 62점"이 아니라 **"여드름 관점에서 본 식단이 62점"** 이다.
/// 식단으로 설명할 수 없는 고민(다크서클)은 서버가 아예 보내지 않는다.
class ConcernScore {
  const ConcernScore({
    required this.concern,
    required this.label,
    required this.score,
    required this.status,
    required this.change,
    this.message,
    this.tags = const <String>[],
  });

  /// 서버 enum 이름(`ACNE` 등). 표시는 [label] 로 한다.
  final String concern;

  final String label;
  final int score;

  /// 모르는 값이면 null. 배지를 비운다.
  final SkinLevel? status;

  /// 기간 첫 기록일 대비 변화. **일일에는 항상 없고**, 주간도 기록일이
  /// 하루뿐이면 없다. 없을 때 앱이 계산하지 않는다 — 비교할 기준이 없다.
  final int? change;

  /// 이 고민에 관해 가장 크게 움직인 룰의 이유 문장. 서버가 저장해 둔 문장이라
  /// 앱이 짓지 않는다. V8 이전 기록·주간 응답에는 없다.
  final String? message;

  /// 같은 근거의 짧은 라벨들. 비어 있으면 칩 줄을 그리지 않는다.
  final List<String> tags;
}

/// 하루의 대표 점수 한 줄. 주간 추이 · BEST DAY · WORST DAY 가 같은 모양을 쓴다.
///
/// **기록이 없는 날은 아예 만들어지지 않는다.** 0 점짜리 점을 끼워 넣으면
/// 그래프도 평균도 거짓이 된다.
class DayScore {
  const DayScore({
    required this.date,
    required this.dailyScore,
    required this.grade,
    this.plateIds = const <int>[],
  });

  final DateTime date;
  final int dailyScore;
  final SkinLevel? grade;

  /// 그날 기록의 id. **BEST/WORST 에만 채워진다** — 추이 그래프의 점에는 없다.
  /// 앱은 이 id 로 로컬 사진을 찾는다(서버에 이미지가 없다 · PRD §9.6).
  final List<int> plateIds;
}

/// 주간 AI 문장 넷. 숫자가 없는 것이 의도다 —
/// 평균도 BEST DAY 도 서버가 이미 정했고 AI 는 그 결과를 설명하기만 한다.
class WeeklyComment {
  const WeeklyComment({
    required this.goodPoint,
    required this.improvePoint,
    required this.habit,
    required this.nextWeek,
  });

  final String? goodPoint;
  final String? improvePoint;
  final String? habit;
  final String? nextWeek;

  /// 생성에 실패하면 응답에서 키가 통째로 빠진다. 네 칸이 모두 비어 있으면
  /// 카드를 그리지 않는다 — 빈 카드는 "로딩 중"으로 읽힌다.
  bool get isEmpty =>
      (goodPoint ?? improvePoint ?? habit ?? nextWeek) == null;
}

/// `GET /reports/daily?date=` 응답. 한 번의 호출로 화면이 완성된다.
class DailyReport {
  const DailyReport({
    required this.date,
    required this.dailyScore,
    required this.grade,
    required this.recordCount,
    required this.nutrition,
    required this.skinNutrients,
    required this.concerns,
    required this.meals,
    required this.aiComment,
    required this.goodPoints,
    required this.improvePoints,
  });

  final DateTime date;

  /// 그날 기록들의 평균. **기록이 없으면 null 이다** — 0 이 아니다.
  final int? dailyScore;

  final SkinLevel? grade;
  final int recordCount;
  final List<NutritionItem> nutrition;

  /// 피부 영양 포인트 3종. 영양 밸런스와 **다른 카드**에 그린다.
  ///
  /// 표준 음식표에 매칭된 끼니에서만 값이 나오므로 `status` 가 null 일 수 있다 —
  /// 그때 화면은 "알 수 없음"으로 그린다. 0 을 "부족"으로 읽으면 안 된다.
  final List<NutritionItem> skinNutrients;

  /// 사용자가 고른 고민 중 식단으로 설명할 수 있는 것만. 없으면 빈 목록이다.
  final List<ConcernScore> concerns;

  /// 히스토리와 같은 모양이라 같은 엔티티를 쓴다. 사진은 서버에 없고
  /// 앱이 기록할 때 남긴 로컬 파일을 `plateId` 로 찾는다. (PRD §9.6)
  final List<PlateHistoryItem> meals;

  /// 기록을 저장할 때 서버가 만들어 둔 문장. 리포트를 열 때 새로 만들지 않는다.
  final String? aiComment;

  final List<String> goodPoints;
  final List<String> improvePoints;

  bool get isEmpty => recordCount == 0;

  /// 끼니별 묶음. **서버는 평평한 목록으로 주고 그룹은 화면이 만든다.**
  /// 순서는 `MealType` 선언 순서(아침→점심→저녁)이고, 끼니를 모르는 기록은 맨 뒤다.
  List<MapEntry<MealType?, List<PlateHistoryItem>>> get byMealType {
    final groups = <MealType?, List<PlateHistoryItem>>{};
    for (final meal in meals) {
      groups.putIfAbsent(meal.mealType, () => []).add(meal);
    }

    return [
      for (final type in MealType.values)
        if (groups[type] != null) MapEntry(type, groups[type]!),
      if (groups[null] != null) MapEntry(null, groups[null]!),
    ];
  }
}

/// `GET /reports/weekly?from=&to=` 응답.
///
/// 기간만 넓히면 그대로 월간이 된다 — 그래서 이름과 달리 "7일"을 가정하는
/// 필드가 없다. 화면이 7칸 축을 그리는 근거는 [from]~[to] 폭이다.
class WeeklyReport {
  const WeeklyReport({
    required this.from,
    required this.to,
    required this.averageDailyScore,
    required this.grade,
    required this.totalDays,
    required this.recordedDays,
    required this.recordCount,
    required this.dailyScores,
    required this.nutrition,
    required this.concerns,
    required this.bestDay,
    required this.worstDay,
    required this.aiComment,
  });

  final DateTime from;
  final DateTime to;

  /// **기록이 있는 날만** 평균한 값이다. 안 찍은 날을 0 으로 세면 성실하게
  /// 기록할수록 점수가 낮아진다. 기록이 하나도 없으면 null.
  final int? averageDailyScore;

  final SkinLevel? grade;

  /// 조회 기간의 달력일 수.
  final int totalDays;

  /// 그중 기록이 하나라도 있는 날 수. 평균의 분모다.
  final int recordedDays;

  /// 기간 전체의 기록(끼니) 수.
  final int recordCount;

  /// 날짜 오름차순. **기록이 없는 날은 들어 있지 않다.**
  final List<DayScore> dailyScores;

  /// 기록이 있는 날의 **하루 평균**이다. 합계가 아니다.
  final List<NutritionItem> nutrition;

  final List<ConcernScore> concerns;

  /// 동점 처리까지 서버가 정한 결과다. 앱이 다시 고르지 않는다.
  final DayScore? bestDay;
  final DayScore? worstDay;

  /// 생성에 실패하면 null 이다. **나머지 리포트는 그대로 보여야 한다.**
  final WeeklyComment? aiComment;

  bool get isEmpty => recordedDays == 0;

  /// [from] 부터 [to] 까지 하루씩. 그래프의 가로축이다.
  ///
  /// **[totalDays] 를 세지 않고 두 날짜를 직접 훑는다.** 서버가 그 키를 빠뜨리면
  /// 축이 0칸이 되어 그래프가 통째로 사라지는데, 그건 "기록이 없는 주"와
  /// 화면에서 구분되지 않는다.
  ///
  /// 달력 덧셈이어야 한다 — `Duration(days: n)` 은 정확히 24n 시간이라
  /// 서머타임이 있는 시간대의 기기에서 하루가 밀린다.
  List<DateTime> get axis {
    final days = <DateTime>[];
    for (var date = DateTime(from.year, from.month, from.day);
        !date.isAfter(to);
        date = addDays(date, 1)) {
      days.add(date);
    }
    return days;
  }

  /// 그 날짜의 점수. 기록이 없는 날은 null 이고 화면은 점을 찍지 않는다.
  DayScore? scoreOn(DateTime date) {
    for (final score in dailyScores) {
      if (score.date.year == date.year &&
          score.date.month == date.month &&
          score.date.day == date.day) {
        return score;
      }
    }
    return null;
  }
}
