import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/food_traits.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/meal_type.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../../../shared/enums/skin_basis.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../domain/entities/plate_analysis.dart' as domain;
import '../../domain/entities/plate_history.dart' as domain;
import '../../domain/entities/skin_plate.dart' as domain;

part 'plate_dtos.freezed.dart';
part 'plate_dtos.g.dart';

@freezed
class NutritionDto with _$NutritionDto {
  const factory NutritionDto({
    @Default(0) int caloriesKcal,
    @Default(0) num proteinG,
    @Default(0) num fatG,
    @Default(0) num carbG,
    @Default(0) int sodiumMg,
    @Default(0) num sugarG,
  }) = _NutritionDto;

  factory NutritionDto.fromJson(Map<String, dynamic> json) =>
      _$NutritionDtoFromJson(json);
}

@freezed
class IngredientDto with _$IngredientDto {
  const factory IngredientDto({
    required String name,
    @Default('ETC') String tag,
  }) = _IngredientDto;

  factory IngredientDto.fromJson(Map<String, dynamic> json) =>
      _$IngredientDtoFromJson(json);
}

@freezed
class FoodAnalysisDto with _$FoodAnalysisDto {
  const factory FoodAnalysisDto({
    /// `POST /plates/analyze` 응답에는 없다. 저장 전이라 행이 없고, 서버는
    /// non_null 직렬화라 키 자체를 뺀다. required 로 두면 분석 응답이 파싱에서 죽는다.
    int? foodAnalysisId,
    required String foodName,
    String? foodCategory,
    @Default('ETC') String cookingMethod,
    @Default(false) bool spicy,

    /// 음식 특성 5종. **서버는 "모른다"를 null 이 아니라 `UNKNOWN`(foodGroup 은
    /// `ETC`) 문자열로 내려보낸다.** nullable 로 받아 null 체크만 하면 화면에
    /// UNKNOWN 이 그대로 뜬다 — 숨김은 [FoodGroup] 쪽 enum 이 맡는다.
    /// 기본값이 막는 것은 **옛 기록이 아니라 옛 서버 응답**이다. 저장된 옛 행에도
    /// 서버는 키를 UNKNOWN/ETC 로 채워 내리고(`plate_legacy_traits.json`), 이 키를
    /// 아예 안 만들던 것은 배포 경계에 남은 구 서버다(`plate_analyze.json`).
    @Default('ETC') String foodGroup,
    @Default('UNKNOWN') String portionSize,
    @Default('UNKNOWN') String spiciness,
    @Default('UNKNOWN') String oiliness,
    @Default('UNKNOWN') String processingLevel,
    @Default(<IngredientDto>[]) List<IngredientDto> ingredients,
    required NutritionDto nutrition,
  }) = _FoodAnalysisDto;

  factory FoodAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$FoodAnalysisDtoFromJson(json);
}

@freezed
class FeedbackDto with _$FeedbackDto {
  const factory FeedbackDto({
    required String message,

    /// 지금 피부 상태와 음식 특성을 잇는 설명. [message] 는 짧은 제목이고 이쪽이
    /// 그 아래 보조 문장이다. V8 이전 기록에는 키가 아예 없다.
    ///
    /// **[ActionDto] 에는 이 필드가 없다.** 행동 카드는 문구 자체가 설명이라
    /// 서버가 만들지 않는다 — 거기서 파싱을 시도하면 항상 비어 있다.
    String? reason,
    @Default(0) int scoreDelta,
    String? ruleCode,
  }) = _FeedbackDto;

  factory FeedbackDto.fromJson(Map<String, dynamic> json) =>
      _$FeedbackDtoFromJson(json);
}

@freezed
class ActionDto with _$ActionDto {
  const factory ActionDto({
    required String message,
    @Default(0) int expectedGain,
    String? ruleCode,
  }) = _ActionDto;

  factory ActionDto.fromJson(Map<String, dynamic> json) =>
      _$ActionDtoFromJson(json);
}

/// 서버가 good / caution / action 3개 배열로 나눠서 내려주므로
/// 앱은 타입 필터링 없이 3개 섹션에 바로 렌더링하면 된다.
@freezed
class FeedbackGroupDto with _$FeedbackGroupDto {
  const factory FeedbackGroupDto({
    @Default(<FeedbackDto>[]) List<FeedbackDto> good,
    @Default(<FeedbackDto>[]) List<FeedbackDto> caution,
    @Default(<ActionDto>[]) List<ActionDto> action,
  }) = _FeedbackGroupDto;

  factory FeedbackGroupDto.fromJson(Map<String, dynamic> json) =>
      _$FeedbackGroupDtoFromJson(json);
}

/// `POST /plates/analyze` (200) 응답. **저장되지 않았다.**
///
/// [SkinPlateDto] 와 필드가 겹치지만 재사용하지 않는다 — plateId·createdAt 을
/// nullable 로 열어 두면 저장된 기록과 임시 결과가 같은 타입이 되고,
/// "이거 저장된 거였나" 를 필드 null 체크로 추측하게 된다.
@freezed
class PlateAnalysisDto with _$PlateAnalysisDto {
  const factory PlateAnalysisDto({
    required String analysisToken,
    required int skinAnalysisId,

    /// 어느 날 피부로 계산했는지. 신규 필드라 옛 응답에는 키가 없다.
    ///
    /// **분석(`/plates/analyze`)의 `TODAY` 는 오늘이고, 저장된 기록의 `TODAY` 는
    /// 그 기록을 저장한 날이다.** 서버가 저장 시점에 굳혀 두기 때문에 8/15 기록을
    /// 8/17 에 열어도 `TODAY` 가 온다 — 화면 문구가 갈리는 이유가 이것이다.
    String? skinBasis,
    DateTime? skinMeasuredAt,
    required int plateScore,

    /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
    /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
    String? grade,
    @Default(70) int baseScore,
    @Default('') String summary,
    required FoodAnalysisDto food,
    required FeedbackGroupDto feedbacks,
    @Default(<String>[]) List<String> appliedRules,
  }) = _PlateAnalysisDto;

  factory PlateAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$PlateAnalysisDtoFromJson(json);
}

/// `POST /plates/records` (201) · `GET /plates/{id}` 응답. 저장이 확정된 기록이다.
@freezed
class SkinPlateDto with _$SkinPlateDto {
  const factory SkinPlateDto({
    required int plateId,

    /// S07 에서 S08 추천으로 넘어갈 때 필요하다. 추천 조회가 이 값을 요구한다.
    /// 앱이 "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때 엉뚱한 날짜의
    /// 추천이 뜬다. 서버가 응답에 실어 준다.
    required int skinAnalysisId,

    /// 이 기록을 **저장한 날**의 피부인지. [PlateAnalysisDto.skinBasis] 참고 —
    /// 여기서의 `TODAY` 는 "오늘"이 아니라 "기록 당일"이다.
    String? skinBasis,
    DateTime? skinMeasuredAt,

    required int plateScore,

    /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
    /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
    String? grade,
    @Default(70) int baseScore,
    @Default('') String summary,
    required FoodAnalysisDto food,
    required FeedbackGroupDto feedbacks,
    @Default(<String>[]) List<String> appliedRules,

    /// "AI 맞춤 TIP". 생성 실패 시 서버가 키를 뺀다 — 그때 앱은 카드를 그리지
    /// 않는다. 룰 요약(summary)으로 메우지 마라. [PlateAnalysisDto] 에는 이 필드가
    /// 아예 없어서, 폴백을 두면 저장 전후로 같은 카드의 문장이 갈린다.
    String? aiTip,
    required DateTime createdAt,
  }) = _SkinPlateDto;

  factory SkinPlateDto.fromJson(Map<String, dynamic> json) =>
      _$SkinPlateDtoFromJson(json);
}

// ---------- DTO → Entity ----------

extension PlateAnalysisDtoX on PlateAnalysisDto {
  domain.PlateAnalysis toEntity() => domain.PlateAnalysis(
        analysisToken: analysisToken,
        skinAnalysisId: skinAnalysisId,
        skinBasis: SkinBasis.fromJson(skinBasis),
        skinMeasuredAt: skinMeasuredAt,
        plateScore: plateScore,
        grade: SkinLevel.fromJson(grade),
        baseScore: baseScore,
        summary: summary,
        food: food.toEntity(),
        good: feedbacks.good.map((f) => f.toEntity()).toList(),
        caution: feedbacks.caution.map((f) => f.toEntity()).toList(),
        actions: feedbacks.action.map((a) => a.toEntity()).toList(),
        appliedRules: appliedRules,
      );
}

extension SkinPlateDtoX on SkinPlateDto {
  domain.SkinPlate toEntity() => domain.SkinPlate(
        id: plateId,
        skinAnalysisId: skinAnalysisId,
        skinBasis: SkinBasis.fromJson(skinBasis),
        skinMeasuredAt: skinMeasuredAt,
        plateScore: plateScore,
        grade: SkinLevel.fromJson(grade),
        baseScore: baseScore,
        summary: summary,
        food: food.toEntity(),
        good: feedbacks.good.map((f) => f.toEntity()).toList(),
        caution: feedbacks.caution.map((f) => f.toEntity()).toList(),
        actions: feedbacks.action.map((a) => a.toEntity()).toList(),
        appliedRules: appliedRules,
        aiTip: aiTip,
        createdAt: createdAt,
      );
}

extension FeedbackDtoX on FeedbackDto {
  domain.PlateFeedback toEntity() => domain.PlateFeedback(
        message: message,
        reason: reason,
        scoreDelta: scoreDelta,
        ruleCode: ruleCode,
      );
}

extension ActionDtoX on ActionDto {
  domain.PlateAction toEntity() => domain.PlateAction(
        message: message,
        expectedGain: expectedGain,
        ruleCode: ruleCode,
      );
}

extension FoodAnalysisDtoX on FoodAnalysisDto {
  domain.FoodAnalysis toEntity() => domain.FoodAnalysis(
        id: foodAnalysisId,
        foodName: foodName,
        foodCategory: foodCategory,
        cookingMethod: CookingMethod.fromJson(cookingMethod),
        spicy: spicy,
        foodGroup: FoodGroup.fromJson(foodGroup),
        portionSize: PortionSize.fromJson(portionSize),
        spiciness: Spiciness.fromJson(spiciness),
        oiliness: Oiliness.fromJson(oiliness),
        processingLevel: ProcessingLevel.fromJson(processingLevel),
        ingredients: ingredients
            .map((i) => domain.Ingredient(
                  name: i.name,
                  tag: IngredientTag.fromJson(i.tag),
                ))
            .toList(),
        nutrition: domain.Nutrition(
          caloriesKcal: nutrition.caloriesKcal,
          proteinG: nutrition.proteinG.toDouble(),
          fatG: nutrition.fatG.toDouble(),
          carbG: nutrition.carbG.toDouble(),
          sodiumMg: nutrition.sodiumMg,
          sugarG: nutrition.sugarG.toDouble(),
        ),
      );
}

// ---------- 히스토리 (S09) ----------

@freezed
class PlateHistoryItemDto with _$PlateHistoryItemDto {
  const factory PlateHistoryItemDto({
    required int plateId,
    required String foodName,
    @Default(0) int plateScore,

    /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱이 점수에서 다시 내면
    /// 경계표가 두 벌이 되고, 서버가 경계를 옮긴 날 한쪽만 따라간다.
    /// 모르는 값이면 null 이고 화면은 배지를 비운다.
    String? grade,

    /// 서버가 시각에서 파생해 보낸다. 모르는 값이면 화면이 배지를 비운다.
    String? mealType,
    required DateTime recordedAt,

    /// 이 끼니에서 눈에 띄는 항목 두세 개("나트륨" · "단백질").
    ///
    /// **서버가 고른다.** 앱이 고르려면 목록에 영양값 전체를 실어야 하고, 그러면
    /// "얼마부터 높은가"가 앱에도 한 벌 생긴다. 걸리는 항목이 없는 평범한 끼니는
    /// 빈 배열이고, 이 필드가 생기기 전 서버와 붙어도 기본값이 빈 배열이라 안전하다.
    @Default(<String>[]) List<String> highlightTags,
  }) = _PlateHistoryItemDto;

  factory PlateHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$PlateHistoryItemDtoFromJson(json);
}

@freezed
class PlateHistoryDayDto with _$PlateHistoryDayDto {
  const factory PlateHistoryDayDto({
    required DateTime date,

    /// **정상 응답에는 항상 온다.** 그날 얼굴을 안 찍었어도 서버가 그날 첫 기록의
    /// 채점 기준 분석 점수로 채운다(`PlateHistoryService`). 계약상 nullable 이라
    /// 그대로 열어 두는 것이지, 비는 날이 있어서가 아니다.
    int? skinScore,

    /// 그날 기록들의 평균. 서버가 계산해서 준다.
    ///
    /// 서버 쪽 타입이 primitive `int` 라 이 키는 생략될 수 없고, 기록이 하나도
    /// 없는 날은 `days` 에 아예 안 들어온다. nullable 은 방어다.
    ///
    /// **그래도 기본값을 두지 않는다.** 0 으로 떨어뜨리면 홈이 "0점 · 주의" 를
    /// 그리는데, 0점은 "아주 나쁘게 먹었다"로 읽힌다 — 아직 안 먹은 것과 다른
    /// 상태다. null 이어야 카드가 시안대로 `OO점` 으로 빠진다.
    int? plateScore,

    /// [plateScore] 의 등급. 서버가 매긴다 — 홈 히어로 배지가 이 값을 쓴다.
    String? grade,

    /// 시안의 "목표 80점". **값은 서버가 정한다** — 앱에 80 을 박지 않는다.
    /// 지금은 모두에게 같은 상수지만 사용자별 목표가 생기는 날 앱 배포가 필요해진다.
    /// 서버가 안 보내면 목표 막대를 그릴 근거가 없으므로 null 로 둔다.
    int? targetScore,

    /// "오늘의 AI 코멘트". 없으면 서버가 키를 빼고, 앱은 카드를 그리지 않는다.
    String? aiComment,
    @Default(<PlateHistoryItemDto>[]) List<PlateHistoryItemDto> plates,
  }) = _PlateHistoryDayDto;

  factory PlateHistoryDayDto.fromJson(Map<String, dynamic> json) =>
      _$PlateHistoryDayDtoFromJson(json);
}

@freezed
class PlateHistoryDto with _$PlateHistoryDto {
  const factory PlateHistoryDto({
    @Default(<PlateHistoryDayDto>[]) List<PlateHistoryDayDto> days,
  }) = _PlateHistoryDto;

  factory PlateHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$PlateHistoryDtoFromJson(json);
}

extension PlateHistoryDtoX on PlateHistoryDto {
  /// 끼니 순서를 **여기서** 정한다. 화면마다 뒤집으면 한 곳을 빠뜨리고,
  /// 실제로 홈은 저녁→아침, 기록은 아침→저녁으로 같은 날을 반대로 그렸다.
  /// 서버가 최신순으로 준다는 전제에 기대지 않고 기록 시각으로 세운다.
  List<domain.PlateHistoryDay> toEntity() => days
      .map((day) => domain.PlateHistoryDay(
            date: day.date,
            skinScore: day.skinScore,
            plateScore: day.plateScore,
            grade: SkinLevel.fromJson(day.grade),
            targetScore: day.targetScore,
            aiComment: day.aiComment,
            plates: day.plates
                .map((item) => domain.PlateHistoryItem(
                      plateId: item.plateId,
                      foodName: item.foodName,
                      plateScore: item.plateScore,
                      grade: SkinLevel.fromJson(item.grade),
                      mealType: MealType.fromJson(item.mealType),
                      recordedAt: item.recordedAt,
                      highlightTags: item.highlightTags,
                    ))
                .toList()
              ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)),
          ))
      .toList();
}

/// 두 엔드포인트가 이 DTO 하나를 공유한다.
///
///   POST /plates/simulate           저장 전 — 본문에 analysisToken
///   POST /plates/{plateId}/simulate 저장 후 — 경로에 plateId
///
/// 앞쪽 응답에는 `plateId` 가 없다(저장된 게 없으니 돌려줄 id 도 없다). 뒤쪽에는
/// 있지만 앱이 읽지 않는다 — 요청할 때 이미 알고 있던 값이다. nullable 필드로
/// 열어 두는 대신 아예 받지 않는다. 안 읽는 값에 "언제 null 인가" 주석이 붙는 게
/// 더 나쁘다.
@freezed
class PlateSimulationDto with _$PlateSimulationDto {
  const factory PlateSimulationDto({
    required int beforeScore,
    required int afterScore,
    @Default(<String>[]) List<String> appliedActions,
    @Default(<String>[]) List<String> removedRules,
    @Default('') String summary,
  }) = _PlateSimulationDto;

  factory PlateSimulationDto.fromJson(Map<String, dynamic> json) =>
      _$PlateSimulationDtoFromJson(json);
}

extension PlateSimulationDtoX on PlateSimulationDto {
  domain.PlateSimulation toEntity() => domain.PlateSimulation(
        beforeScore: beforeScore,
        afterScore: afterScore,
        appliedActions: appliedActions
            .map(PlateActionCode.fromJson)
            .whereType<PlateActionCode>()   // 모르는 액션은 조용히 버린다
            .toList(),
        removedRules: removedRules,
        summary: summary,
      );
}

// `GET /reports?period=WEEK` 의 PlateReportDto 는 지웠다. 주간 화면이
// `GET /reports/weekly` 로 옮겨 가면서 이 응답을 읽는 곳이 없어졌다 —
// 두 엔드포인트의 "이번 주 평균"은 정의가 다르므로(끼니 평균 vs 일 평균의
// 평균) 둘을 함께 두면 화면마다 다른 숫자가 뜬다. 리포트 DTO 는
// `features/report/data/models/report_dtos.dart` 에 있다.
