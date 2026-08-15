import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/insight_category.dart';
import '../../domain/entities/skin_insight.dart';

part 'skin_insight_dtos.freezed.dart';
part 'skin_insight_dtos.g.dart';

@freezed
class SkinInsightChangesDto with _$SkinInsightChangesDto {
  const factory SkinInsightChangesDto({
    required int hydration,
    required int oil,
    required int redness,
    required int trouble,
    required int barrier,
    required int skinScore,
  }) = _SkinInsightChangesDto;

  factory SkinInsightChangesDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightChangesDtoFromJson(json);
}

@freezed
class SkinInsightItemDto with _$SkinInsightItemDto {
  const factory SkinInsightItemDto({
    required String category,
    /// HIGH / MEDIUM / LOW. 배열 순서에서 파생된 값이라 앱이 쓰지 않는다 —
    /// 받아만 두고 엔티티로 넘기지 않는다. 넘기면 언젠가 이걸로 정렬하는 코드가 생긴다.
    @Default('') String priority,
    @Default('') String title,
    @Default('') String description,
  }) = _SkinInsightItemDto;

  factory SkinInsightItemDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightItemDtoFromJson(json);
}

@freezed
class SkinTodayActionDto with _$SkinTodayActionDto {
  const factory SkinTodayActionDto({
    required String category,
    @Default('') String title,
  }) = _SkinTodayActionDto;

  factory SkinTodayActionDto.fromJson(Map<String, dynamic> json) =>
      _$SkinTodayActionDtoFromJson(json);
}

@freezed
class SkinInsightDto with _$SkinInsightDto {
  const factory SkinInsightDto({
    required int skinAnalysisId,
    @Default('') String summary,

    /// 직전 분석이 없으면 서버가 키를 통째로 지운다.
    SkinInsightChangesDto? changes,

    /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이고, 서버는 이 경우를 저장하지 않는다.
    @Default(<SkinInsightItemDto>[]) List<SkinInsightItemDto> insights,
    @Default(<SkinTodayActionDto>[]) List<SkinTodayActionDto> todayActions,
    DateTime? generatedAt,
  }) = _SkinInsightDto;

  factory SkinInsightDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightDtoFromJson(json);
}

extension SkinInsightDtoX on SkinInsightDto {
  SkinInsight toEntity() => SkinInsight(
        skinAnalysisId: skinAnalysisId,
        summary: summary,
        changes: changes?.toEntity(),
        insights: insights
            .map((item) => SkinInsightItem(
                  category: InsightCategory.fromJson(item.category),
                  title: item.title,
                  description: item.description,
                ))
            .toList(),
        todayActions: todayActions
            .map((action) => SkinTodayAction(
                  category: InsightCategory.fromJson(action.category),
                  title: action.title,
                ))
            .toList(),
      );
}

extension SkinInsightChangesDtoX on SkinInsightChangesDto {
  SkinInsightChanges toEntity() => SkinInsightChanges(
        hydration: hydration,
        oil: oil,
        redness: redness,
        trouble: trouble,
        barrier: barrier,
        skinScore: skinScore,
      );
}
