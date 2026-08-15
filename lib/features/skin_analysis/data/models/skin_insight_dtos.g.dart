// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_insight_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SkinInsightChangesDtoImpl _$$SkinInsightChangesDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SkinInsightChangesDtoImpl(
      hydration: (json['hydration'] as num).toInt(),
      oil: (json['oil'] as num).toInt(),
      redness: (json['redness'] as num).toInt(),
      trouble: (json['trouble'] as num).toInt(),
      barrier: (json['barrier'] as num).toInt(),
      skinScore: (json['skinScore'] as num).toInt(),
    );

Map<String, dynamic> _$$SkinInsightChangesDtoImplToJson(
        _$SkinInsightChangesDtoImpl instance) =>
    <String, dynamic>{
      'hydration': instance.hydration,
      'oil': instance.oil,
      'redness': instance.redness,
      'trouble': instance.trouble,
      'barrier': instance.barrier,
      'skinScore': instance.skinScore,
    };

_$SkinInsightItemDtoImpl _$$SkinInsightItemDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SkinInsightItemDtoImpl(
      category: json['category'] as String,
      priority: json['priority'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$SkinInsightItemDtoImplToJson(
        _$SkinInsightItemDtoImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'priority': instance.priority,
      'title': instance.title,
      'description': instance.description,
    };

_$SkinTodayActionDtoImpl _$$SkinTodayActionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SkinTodayActionDtoImpl(
      category: json['category'] as String,
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$$SkinTodayActionDtoImplToJson(
        _$SkinTodayActionDtoImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'title': instance.title,
    };

_$SkinInsightDtoImpl _$$SkinInsightDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinInsightDtoImpl(
      skinAnalysisId: (json['skinAnalysisId'] as num).toInt(),
      summary: json['summary'] as String? ?? '',
      changes: json['changes'] == null
          ? null
          : SkinInsightChangesDto.fromJson(
              json['changes'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>?)
              ?.map(
                  (e) => SkinInsightItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SkinInsightItemDto>[],
      todayActions: (json['todayActions'] as List<dynamic>?)
              ?.map(
                  (e) => SkinTodayActionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SkinTodayActionDto>[],
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$SkinInsightDtoImplToJson(
        _$SkinInsightDtoImpl instance) =>
    <String, dynamic>{
      'skinAnalysisId': instance.skinAnalysisId,
      'summary': instance.summary,
      'changes': instance.changes,
      'insights': instance.insights,
      'todayActions': instance.todayActions,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };
