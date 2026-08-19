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

_$ScoredItemDtoImpl _$$ScoredItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$ScoredItemDtoImpl(
      key: json['key'] as String,
      score: (json['score'] as num).toInt(),
      level: json['level'] as String? ?? '',
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$ScoredItemDtoImplToJson(_$ScoredItemDtoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'score': instance.score,
      'level': instance.level,
      'evidence': instance.evidence,
    };

_$SkinTypeDtoImpl _$$SkinTypeDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinTypeDtoImpl(
      primary: json['primary'] as String?,
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      label: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$$SkinTypeDtoImplToJson(_$SkinTypeDtoImpl instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'traits': instance.traits,
      'label': instance.label,
    };

_$SkinAgeDtoImpl _$$SkinAgeDtoImplFromJson(Map<String, dynamic> json) =>
    _$SkinAgeDtoImpl(
      estimatedSkinAge: (json['estimatedSkinAge'] as num).toInt(),
      axes: (json['axes'] as List<dynamic>?)
              ?.map((e) => ScoredItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ScoredItemDto>[],
      assessment: json['assessment'] as String? ?? '',
    );

Map<String, dynamic> _$$SkinAgeDtoImplToJson(_$SkinAgeDtoImpl instance) =>
    <String, dynamic>{
      'estimatedSkinAge': instance.estimatedSkinAge,
      'axes': instance.axes,
      'assessment': instance.assessment,
    };

_$CareFocusDtoImpl _$$CareFocusDtoImplFromJson(Map<String, dynamic> json) =>
    _$CareFocusDtoImpl(
      focus: json['focus'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$$CareFocusDtoImplToJson(_$CareFocusDtoImpl instance) =>
    <String, dynamic>{
      'focus': instance.focus,
      'label': instance.label,
    };

_$SkinAnalysisDtoImpl _$$SkinAnalysisDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SkinAnalysisDtoImpl(
      skinAnalysisId: (json['skinAnalysisId'] as num).toInt(),
      skinScore: (json['skinScore'] as num).toInt(),
      grade: json['grade'] as String?,
      metrics: SkinMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>),
      metricDetails: (json['metricDetails'] as List<dynamic>?)
              ?.map((e) => ScoredItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ScoredItemDto>[],
      skinType: json['skinType'] == null
          ? null
          : SkinTypeDto.fromJson(json['skinType'] as Map<String, dynamic>),
      skinAge: json['skinAge'] == null
          ? null
          : SkinAgeDto.fromJson(json['skinAge'] as Map<String, dynamic>),
      summary: json['summary'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => HighlightDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <HighlightDto>[],
      careFocus: (json['careFocus'] as List<dynamic>?)
              ?.map((e) => CareFocusDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CareFocusDto>[],
      careMessage: json['careMessage'] as String?,
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
      'grade': instance.grade,
      'metrics': instance.metrics,
      'metricDetails': instance.metricDetails,
      'skinType': instance.skinType,
      'skinAge': instance.skinAge,
      'summary': instance.summary,
      'highlights': instance.highlights,
      'careFocus': instance.careFocus,
      'careMessage': instance.careMessage,
      'skinTypeGap': instance.skinTypeGap,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };
