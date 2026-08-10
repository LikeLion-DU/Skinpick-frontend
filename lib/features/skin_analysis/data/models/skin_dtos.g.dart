// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SkinMetricsDtoImpl _$$SkinMetricsDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinMetricsDtoImpl(
      hydration: (json['hydration'] as num).toInt(),
      oil: (json['oil'] as num).toInt(),
      redness: (json['redness'] as num).toInt(),
      trouble: (json['trouble'] as num).toInt(),
      barrier: (json['barrier'] as num).toInt(),
    );

Map<String, dynamic> _$$SkinMetricsDtoImplToJson(
        _$SkinMetricsDtoImpl instance) =>
    <String, dynamic>{
      'hydration': instance.hydration,
      'oil': instance.oil,
      'redness': instance.redness,
      'trouble': instance.trouble,
      'barrier': instance.barrier,
    };

_$HighlightDtoImpl _$$HighlightDtoImplFromJson(Map<String, dynamic> json) =>
    _$HighlightDtoImpl(
      label: json['label'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$HighlightDtoImplToJson(_$HighlightDtoImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'status': instance.status,
    };

_$SkinTypeGapDtoImpl _$$SkinTypeGapDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinTypeGapDtoImpl(
      declared: json['declared'] as String,
      observed: json['observed'] as String,
      matched: json['matched'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$$SkinTypeGapDtoImplToJson(
        _$SkinTypeGapDtoImpl instance) =>
    <String, dynamic>{
      'declared': instance.declared,
      'observed': instance.observed,
      'matched': instance.matched,
      'message': instance.message,
    };

_$SkinAnalysisDtoImpl _$$SkinAnalysisDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SkinAnalysisDtoImpl(
      skinAnalysisId: (json['skinAnalysisId'] as num).toInt(),
      skinScore: (json['skinScore'] as num).toInt(),
      metrics: SkinMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>),
      summary: json['summary'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => HighlightDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <HighlightDto>[],
      skinTypeGap: json['skinTypeGap'] == null
          ? null
          : SkinTypeGapDto.fromJson(
              json['skinTypeGap'] as Map<String, dynamic>),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$$SkinAnalysisDtoImplToJson(
        _$SkinAnalysisDtoImpl instance) =>
    <String, dynamic>{
      'skinAnalysisId': instance.skinAnalysisId,
      'skinScore': instance.skinScore,
      'metrics': instance.metrics,
      'summary': instance.summary,
      'highlights': instance.highlights,
      'skinTypeGap': instance.skinTypeGap,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };
