import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/meal_type.dart';
import '../../../../shared/enums/nutrient_status.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../skin_plate/data/models/plate_dtos.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';
import '../../domain/entities/report.dart' as domain;

part 'report_dtos.freezed.dart';
part 'report_dtos.g.dart';

/// `GET /reports/daily` · `GET /reports/weekly` 계약.
///
/// 서버는 `default-property-inclusion: non_null` 이라 **값이 없는 필드는 키 자체가
/// 사라진다.** 서버가 생략할 수 있는 필드에 `required` 를 쓰면 그 응답에서 파싱이
/// 죽는다 — 기록이 하나도 없는 날이 바로 그 경우다.
///
/// 이 파일을 고쳤으면 반드시
/// `dart run build_runner build --delete-conflicting-outputs` 를 돌린다.

/// 영양 밸런스 막대 하나.
@freezed
class NutritionItemDto with _$NutritionItemDto {
  const factory NutritionItemDto({
    /// 서버 enum 이름. 화면은 키로만 쓰고 표시는 [label] 로 한다.
    @Default('') String nutrient,
    @Default('') String label,
    @Default('') String unit,

    /// 서버가 `BigDecimal` 로 낸다. `1820.5` 도 `1820` 도 오므로 **num 이어야 한다** —
    /// double 로 두면 정수로 온 날 캐스팅 예외로 리포트 전체가 실패한다.
    @Default(0) num amount,
    @Default(0) int target,
    @Default(0) int percent,

    /// `LOW` · `NORMAL` · `HIGH`. 모르는 값은 화면에서 회색이 된다.
    String? status,
    @Default(false) bool higherIsWorse,
  }) = _NutritionItemDto;

  factory NutritionItemDto.fromJson(Map<String, dynamic> json) =>
      _$NutritionItemDtoFromJson(json);
}

/// 고민 하나의 식단 점수.
@freezed
class ConcernScoreDto with _$ConcernScoreDto {
  const factory ConcernScoreDto({
    @Default('') String concern,
    @Default('') String label,
    @Default(0) int score,
    String? status,

    /// 기간 첫 기록일 대비 변화. **서버 필드명은 `changeFromFirstDay` 다** —
    /// `change` 로 읽으면 파싱이 조용히 null 이 되고, 화면은 "변화량이 아직
    /// 없는 주"와 구분하지 못한 채 영영 증감을 안 그린다. 예외도 경고도 없다.
    ///
    /// **일일 응답에는 이 키가 없다.** 주간도 기록일이 하루뿐이면 없다.
    @JsonKey(name: 'changeFromFirstDay') int? change,

    /// 이 고민에 관해 가장 크게 움직인 룰의 이유 문장. **서버가 저장해 둔 문장을
    /// 그대로 고른 것이라 앱이 짓지 않는다.**
    ///
    /// V8 이전 기록이거나 걸린 룰이 없으면 키가 빠진다. 주간 응답에도 없다 —
    /// 한 끼를 설명하는 문장이 기간 평균 옆에 붙으면 한 주를 설명하는 것처럼 읽힌다.
    String? message,

    /// 같은 근거의 짧은 라벨들("나트륨 과다"). 최대 2개. 없으면 빈 배열이다.
    @Default(<String>[]) List<String> tags,
  }) = _ConcernScoreDto;

  factory ConcernScoreDto.fromJson(Map<String, dynamic> json) =>
      _$ConcernScoreDtoFromJson(json);
}

/// 하루의 대표 점수. 주간 추이 · BEST DAY · WORST DAY 가 같은 모양을 쓴다.
@freezed
class DayScoreDto with _$DayScoreDto {
  const factory DayScoreDto({
    required DateTime date,
    @Default(0) int dailyScore,
    String? grade,

    /// 그날 기록의 id. **BEST/WORST 카드에만 온다** — 추이 그래프 7칸에는 키가 없다.
    /// 앱은 이 id 로 로컬 사진(`plates/{plateId}.jpg`)을 찾는다(PRD §9.6).
    @Default(<int>[]) List<int> plateIds,
  }) = _DayScoreDto;

  factory DayScoreDto.fromJson(Map<String, dynamic> json) =>
      _$DayScoreDtoFromJson(json);
}

/// 주간 AI 문장 넷. 생성에 실패하면 이 객체 자체의 키가 빠진다.
@freezed
class WeeklyCommentDto with _$WeeklyCommentDto {
  const factory WeeklyCommentDto({
    String? goodPoint,
    String? improvePoint,
    String? habit,
    String? nextWeek,
  }) = _WeeklyCommentDto;

  factory WeeklyCommentDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyCommentDtoFromJson(json);
}

/// `GET /reports/daily?date=`
@freezed
class DailyReportDto with _$DailyReportDto {
  const factory DailyReportDto({
    required DateTime date,

    /// 기록이 없는 날은 키가 없다. **0 을 기본값으로 두면 화면이 "0점"을 그린다** —
    /// 0 점은 "아주 나쁘게 먹었다"이고 이건 "아직 안 찍었다"다.
    int? dailyScore,
    String? grade,
    @Default(0) int recordCount,
    @Default(<NutritionItemDto>[]) List<NutritionItemDto> nutrition,

    /// 피부 영양 포인트 3종(비타민C·오메가3·아연). **영양 밸런스와 다른 배열이다** —
    /// 시안이 다른 카드로 그리고, 측정 가능 여부도 다르다(표준 음식표에 매칭된
    /// 끼니에서만 값이 나오므로 `status` 가 없을 수 있다).
    ///
    /// [NutritionItemDto] 와 같은 모양이라 화면도 같은 위젯을 쓴다.
    @Default(<NutritionItemDto>[]) List<NutritionItemDto> skinNutrients,
    @Default(<ConcernScoreDto>[]) List<ConcernScoreDto> concerns,

    /// 히스토리와 **같은 DTO** 다. 서버가 하나로 내려주므로 앱도 하나로 받는다.
    @Default(<PlateHistoryItemDto>[]) List<PlateHistoryItemDto> meals,
    String? aiComment,
    @Default(<String>[]) List<String> goodPoints,
    @Default(<String>[]) List<String> improvePoints,
  }) = _DailyReportDto;

  factory DailyReportDto.fromJson(Map<String, dynamic> json) =>
      _$DailyReportDtoFromJson(json);
}

/// `GET /reports/weekly?from=&to=`
@freezed
class WeeklyReportDto with _$WeeklyReportDto {
  const factory WeeklyReportDto({
    required DateTime from,
    required DateTime to,
    int? averageDailyScore,
    String? grade,
    @Default(0) int totalDays,
    @Default(0) int recordedDays,
    @Default(0) int recordCount,

    /// 기록이 있는 날만 들어 있다. 없는 날은 아예 항목이 없다.
    @Default(<DayScoreDto>[]) List<DayScoreDto> dailyScores,
    @Default(<NutritionItemDto>[]) List<NutritionItemDto> nutrition,
    @Default(<ConcernScoreDto>[]) List<ConcernScoreDto> concerns,
    DayScoreDto? bestDay,
    DayScoreDto? worstDay,
    WeeklyCommentDto? aiComment,
  }) = _WeeklyReportDto;

  factory WeeklyReportDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportDtoFromJson(json);
}

// ---------- 매핑 ----------

extension NutritionItemDtoX on NutritionItemDto {
  domain.NutritionItem toEntity() => domain.NutritionItem(
        nutrient: nutrient,
        label: label,
        unit: unit,
        // num 으로 받아 여기서 한 번만 double 로 만든다.
        amount: amount.toDouble(),
        target: target,
        percent: percent,
        status: NutrientStatus.fromJson(status),
        higherIsWorse: higherIsWorse,
      );
}

extension ConcernScoreDtoX on ConcernScoreDto {
  domain.ConcernScore toEntity() => domain.ConcernScore(
        concern: concern,
        label: label,
        score: score,
        status: SkinLevel.fromJson(status),
        change: change,
        message: message,
        tags: tags,
      );
}

extension DayScoreDtoX on DayScoreDto {
  domain.DayScore toEntity() => domain.DayScore(
        date: date,
        dailyScore: dailyScore,
        grade: SkinLevel.fromJson(grade),
        plateIds: plateIds,
      );
}

extension WeeklyCommentDtoX on WeeklyCommentDto {
  domain.WeeklyComment toEntity() => domain.WeeklyComment(
        goodPoint: goodPoint,
        improvePoint: improvePoint,
        habit: habit,
        nextWeek: nextWeek,
      );
}

extension DailyReportDtoX on DailyReportDto {
  domain.DailyReport toEntity() => domain.DailyReport(
        date: date,
        dailyScore: dailyScore,
        grade: SkinLevel.fromJson(grade),
        recordCount: recordCount,
        nutrition: nutrition.map((item) => item.toEntity()).toList(),
        skinNutrients: skinNutrients.map((item) => item.toEntity()).toList(),
        concerns: concerns.map((item) => item.toEntity()).toList(),
        // 끼니 순서를 여기서 세운다. 화면마다 정렬하면 한 곳을 빠뜨리고,
        // 같은 날이 홈과 리포트에서 반대로 그려진다. (히스토리 매퍼와 같은 규칙)
        meals: meals
            .map((meal) => PlateHistoryItem(
                  plateId: meal.plateId,
                  foodName: meal.foodName,
                  plateScore: meal.plateScore,
                  grade: SkinLevel.fromJson(meal.grade),
                  mealType: MealType.fromJson(meal.mealType),
                  recordedAt: meal.recordedAt,
                  highlightTags: meal.highlightTags,
                ))
            .toList()
          ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)),
        aiComment: aiComment,
        goodPoints: goodPoints,
        improvePoints: improvePoints,
      );
}

extension WeeklyReportDtoX on WeeklyReportDto {
  domain.WeeklyReport toEntity() => domain.WeeklyReport(
        from: from,
        to: to,
        averageDailyScore: averageDailyScore,
        grade: SkinLevel.fromJson(grade),
        totalDays: totalDays,
        recordedDays: recordedDays,
        recordCount: recordCount,
        dailyScores: dailyScores.map((score) => score.toEntity()).toList(),
        nutrition: nutrition.map((item) => item.toEntity()).toList(),
        concerns: concerns.map((item) => item.toEntity()).toList(),
        bestDay: bestDay?.toEntity(),
        worstDay: worstDay?.toEntity(),
        aiComment: aiComment?.toEntity(),
      );
}
