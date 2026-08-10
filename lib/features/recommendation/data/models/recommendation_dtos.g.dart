// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendedFoodDtoImpl _$$RecommendedFoodDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendedFoodDtoImpl(
      foodName: json['foodName'] as String,
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$$RecommendedFoodDtoImplToJson(
        _$RecommendedFoodDtoImpl instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'reason': instance.reason,
    };

_$RecommendationDtoImpl _$$RecommendationDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationDtoImpl(
      skinAnalysisId: (json['skinAnalysisId'] as num).toInt(),
      recommend: (json['recommend'] as List<dynamic>?)
              ?.map(
                  (e) => RecommendedFoodDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RecommendedFoodDto>[],
      avoid: (json['avoid'] as List<dynamic>?)
              ?.map(
                  (e) => RecommendedFoodDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RecommendedFoodDto>[],
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$RecommendationDtoImplToJson(
        _$RecommendationDtoImpl instance) =>
    <String, dynamic>{
      'skinAnalysisId': instance.skinAnalysisId,
      'recommend': instance.recommend,
      'avoid': instance.avoid,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };
