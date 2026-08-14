import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/plate_action_code.dart';
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
    required int plateScore,
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

    required int plateScore,
    @Default(70) int baseScore,
    @Default('') String summary,
    required FoodAnalysisDto food,
    required FeedbackGroupDto feedbacks,
    @Default(<String>[]) List<String> appliedRules,
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
        plateScore: plateScore,
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
        plateScore: plateScore,
        baseScore: baseScore,
        summary: summary,
        food: food.toEntity(),
        good: feedbacks.good.map((f) => f.toEntity()).toList(),
        caution: feedbacks.caution.map((f) => f.toEntity()).toList(),
        actions: feedbacks.action.map((a) => a.toEntity()).toList(),
        appliedRules: appliedRules,
        createdAt: createdAt,
      );
}

extension FeedbackDtoX on FeedbackDto {
  domain.PlateFeedback toEntity() => domain.PlateFeedback(
        message: message,
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
    required DateTime recordedAt,
  }) = _PlateHistoryItemDto;

  factory PlateHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$PlateHistoryItemDtoFromJson(json);
}

@freezed
class PlateHistoryDayDto with _$PlateHistoryDayDto {
  const factory PlateHistoryDayDto({
    required DateTime date,

    /// 그날 피부 분석이 없으면 서버가 키를 뺀다. required 로 두면 파싱이 죽는다.
    int? skinScore,
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
  List<domain.PlateHistoryDay> toEntity() => days
      .map((day) => domain.PlateHistoryDay(
            date: day.date,
            skinScore: day.skinScore,
            plates: day.plates
                .map((item) => domain.PlateHistoryItem(
                      plateId: item.plateId,
                      foodName: item.foodName,
                      plateScore: item.plateScore,
                      recordedAt: item.recordedAt,
                    ))
                .toList(),
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
