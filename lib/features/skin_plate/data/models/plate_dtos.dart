import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/plate_action_code.dart';
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
    required int foodAnalysisId,
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

@freezed
class SkinPlateDto with _$SkinPlateDto {
  const factory SkinPlateDto({
    required int plateId,
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

extension SkinPlateDtoX on SkinPlateDto {
  domain.SkinPlate toEntity() => domain.SkinPlate(
        id: plateId,
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

@freezed
class PlateSimulationDto with _$PlateSimulationDto {
  const factory PlateSimulationDto({
    required int plateId,
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
        plateId: plateId,
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
