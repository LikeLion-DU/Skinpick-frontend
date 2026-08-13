// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NutritionDtoImpl _$$NutritionDtoImplFromJson(Map<String, dynamic> json) =>
    _$NutritionDtoImpl(
      caloriesKcal: (json['caloriesKcal'] as num?)?.toInt() ?? 0,
      proteinG: json['proteinG'] as num? ?? 0,
      fatG: json['fatG'] as num? ?? 0,
      carbG: json['carbG'] as num? ?? 0,
      sodiumMg: (json['sodiumMg'] as num?)?.toInt() ?? 0,
      sugarG: json['sugarG'] as num? ?? 0,
    );

Map<String, dynamic> _$$NutritionDtoImplToJson(_$NutritionDtoImpl instance) =>
    <String, dynamic>{
      'caloriesKcal': instance.caloriesKcal,
      'proteinG': instance.proteinG,
      'fatG': instance.fatG,
      'carbG': instance.carbG,
      'sodiumMg': instance.sodiumMg,
      'sugarG': instance.sugarG,
    };

_$IngredientDtoImpl _$$IngredientDtoImplFromJson(Map<String, dynamic> json) =>
    _$IngredientDtoImpl(
      name: json['name'] as String,
      tag: json['tag'] as String? ?? 'ETC',
    );

Map<String, dynamic> _$$IngredientDtoImplToJson(_$IngredientDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tag': instance.tag,
    };

_$FoodAnalysisDtoImpl _$$FoodAnalysisDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$FoodAnalysisDtoImpl(
      foodAnalysisId: (json['foodAnalysisId'] as num).toInt(),
      foodName: json['foodName'] as String,
      foodCategory: json['foodCategory'] as String?,
      cookingMethod: json['cookingMethod'] as String? ?? 'ETC',
      spicy: json['spicy'] as bool? ?? false,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <IngredientDto>[],
      nutrition:
          NutritionDto.fromJson(json['nutrition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FoodAnalysisDtoImplToJson(
        _$FoodAnalysisDtoImpl instance) =>
    <String, dynamic>{
      'foodAnalysisId': instance.foodAnalysisId,
      'foodName': instance.foodName,
      'foodCategory': instance.foodCategory,
      'cookingMethod': instance.cookingMethod,
      'spicy': instance.spicy,
      'ingredients': instance.ingredients,
      'nutrition': instance.nutrition,
    };

_$FeedbackDtoImpl _$$FeedbackDtoImplFromJson(Map<String, dynamic> json) =>
    _$FeedbackDtoImpl(
      message: json['message'] as String,
      scoreDelta: (json['scoreDelta'] as num?)?.toInt() ?? 0,
      ruleCode: json['ruleCode'] as String?,
    );

Map<String, dynamic> _$$FeedbackDtoImplToJson(_$FeedbackDtoImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'scoreDelta': instance.scoreDelta,
      'ruleCode': instance.ruleCode,
    };

_$ActionDtoImpl _$$ActionDtoImplFromJson(Map<String, dynamic> json) =>
    _$ActionDtoImpl(
      message: json['message'] as String,
      expectedGain: (json['expectedGain'] as num?)?.toInt() ?? 0,
      ruleCode: json['ruleCode'] as String?,
    );

Map<String, dynamic> _$$ActionDtoImplToJson(_$ActionDtoImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'expectedGain': instance.expectedGain,
      'ruleCode': instance.ruleCode,
    };

_$FeedbackGroupDtoImpl _$$FeedbackGroupDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$FeedbackGroupDtoImpl(
      good: (json['good'] as List<dynamic>?)
              ?.map((e) => FeedbackDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FeedbackDto>[],
      caution: (json['caution'] as List<dynamic>?)
              ?.map((e) => FeedbackDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FeedbackDto>[],
      action: (json['action'] as List<dynamic>?)
              ?.map((e) => ActionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ActionDto>[],
    );

Map<String, dynamic> _$$FeedbackGroupDtoImplToJson(
        _$FeedbackGroupDtoImpl instance) =>
    <String, dynamic>{
      'good': instance.good,
      'caution': instance.caution,
      'action': instance.action,
    };

_$SkinPlateDtoImpl _$$SkinPlateDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinPlateDtoImpl(
      plateId: (json['plateId'] as num).toInt(),
      skinAnalysisId: (json['skinAnalysisId'] as num).toInt(),
      plateScore: (json['plateScore'] as num).toInt(),
      baseScore: (json['baseScore'] as num?)?.toInt() ?? 70,
      summary: json['summary'] as String? ?? '',
      food: FoodAnalysisDto.fromJson(json['food'] as Map<String, dynamic>),
      feedbacks:
          FeedbackGroupDto.fromJson(json['feedbacks'] as Map<String, dynamic>),
      appliedRules: (json['appliedRules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SkinPlateDtoImplToJson(_$SkinPlateDtoImpl instance) =>
    <String, dynamic>{
      'plateId': instance.plateId,
      'skinAnalysisId': instance.skinAnalysisId,
      'plateScore': instance.plateScore,
      'baseScore': instance.baseScore,
      'summary': instance.summary,
      'food': instance.food,
      'feedbacks': instance.feedbacks,
      'appliedRules': instance.appliedRules,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$PlateSimulationDtoImpl _$$PlateSimulationDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$PlateSimulationDtoImpl(
      plateId: (json['plateId'] as num).toInt(),
      beforeScore: (json['beforeScore'] as num).toInt(),
      afterScore: (json['afterScore'] as num).toInt(),
      appliedActions: (json['appliedActions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      removedRules: (json['removedRules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      summary: json['summary'] as String? ?? '',
    );

Map<String, dynamic> _$$PlateSimulationDtoImplToJson(
        _$PlateSimulationDtoImpl instance) =>
    <String, dynamic>{
      'plateId': instance.plateId,
      'beforeScore': instance.beforeScore,
      'afterScore': instance.afterScore,
      'appliedActions': instance.appliedActions,
      'removedRules': instance.removedRules,
      'summary': instance.summary,
    };
