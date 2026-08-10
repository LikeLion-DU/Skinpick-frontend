import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/recommendation.dart';

part 'recommendation_dtos.freezed.dart';
part 'recommendation_dtos.g.dart';

@freezed
class RecommendedFoodDto with _$RecommendedFoodDto {
  const factory RecommendedFoodDto({
    required String foodName,
    @Default('') String reason,
  }) = _RecommendedFoodDto;

  factory RecommendedFoodDto.fromJson(Map<String, dynamic> json) =>
      _$RecommendedFoodDtoFromJson(json);
}

@freezed
class RecommendationDto with _$RecommendationDto {
  const factory RecommendationDto({
    required int skinAnalysisId,
    @Default(<RecommendedFoodDto>[]) List<RecommendedFoodDto> recommend,
    @Default(<RecommendedFoodDto>[]) List<RecommendedFoodDto> avoid,
    DateTime? generatedAt,
  }) = _RecommendationDto;

  factory RecommendationDto.fromJson(Map<String, dynamic> json) =>
      _$RecommendationDtoFromJson(json);
}

extension RecommendationDtoX on RecommendationDto {
  DailyRecommendation toEntity() => DailyRecommendation(
        skinAnalysisId: skinAnalysisId,
        recommend: recommend.map((r) => r.toEntity()).toList(),
        avoid: avoid.map((r) => r.toEntity()).toList(),
        generatedAt: generatedAt,
      );
}

extension RecommendedFoodDtoX on RecommendedFoodDto {
  RecommendedFood toEntity() =>
      RecommendedFood(foodName: foodName, reason: reason);
}
