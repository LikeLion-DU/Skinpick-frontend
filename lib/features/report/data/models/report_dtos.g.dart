// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NutritionItemDtoImpl _$$NutritionItemDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$NutritionItemDtoImpl(
      nutrient: json['nutrient'] as String? ?? '',
      label: json['label'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      higherIsWorse: json['higherIsWorse'] as bool?,
    );

Map<String, dynamic> _$$NutritionItemDtoImplToJson(
        _$NutritionItemDtoImpl instance) =>
    <String, dynamic>{
      'nutrient': instance.nutrient,
      'label': instance.label,
      'unit': instance.unit,
      'amount': instance.amount,
      'target': instance.target,
      'percent': instance.percent,
      'status': instance.status,
      'higherIsWorse': instance.higherIsWorse,
    };

_$ConcernScoreDtoImpl _$$ConcernScoreDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ConcernScoreDtoImpl(
      concern: json['concern'] as String? ?? '',
      label: json['label'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      change: (json['changeFromFirstDay'] as num?)?.toInt(),
      message: json['message'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
    );

Map<String, dynamic> _$$ConcernScoreDtoImplToJson(
        _$ConcernScoreDtoImpl instance) =>
    <String, dynamic>{
      'concern': instance.concern,
      'label': instance.label,
      'score': instance.score,
      'status': instance.status,
      'changeFromFirstDay': instance.change,
      'message': instance.message,
      'tags': instance.tags,
    };

_$DayScoreDtoImpl _$$DayScoreDtoImplFromJson(Map<String, dynamic> json) =>
    _$DayScoreDtoImpl(
      date: DateTime.parse(json['date'] as String),
      dailyScore: (json['dailyScore'] as num?)?.toInt() ?? 0,
      grade: json['grade'] as String?,
      plateIds: (json['plateIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$$DayScoreDtoImplToJson(_$DayScoreDtoImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'dailyScore': instance.dailyScore,
      'grade': instance.grade,
      'plateIds': instance.plateIds,
    };

_$WeeklyCommentDtoImpl _$$WeeklyCommentDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyCommentDtoImpl(
      goodPoint: json['goodPoint'] as String?,
      improvePoint: json['improvePoint'] as String?,
      habit: json['habit'] as String?,
      nextWeek: json['nextWeek'] as String?,
    );

Map<String, dynamic> _$$WeeklyCommentDtoImplToJson(
        _$WeeklyCommentDtoImpl instance) =>
    <String, dynamic>{
      'goodPoint': instance.goodPoint,
      'improvePoint': instance.improvePoint,
      'habit': instance.habit,
      'nextWeek': instance.nextWeek,
    };

_$DailyReportDtoImpl _$$DailyReportDtoImplFromJson(Map<String, dynamic> json) =>
    _$DailyReportDtoImpl(
      date: DateTime.parse(json['date'] as String),
      dailyScore: (json['dailyScore'] as num?)?.toInt(),
      grade: json['grade'] as String?,
      recordCount: (json['recordCount'] as num?)?.toInt() ?? 0,
      nutrition: (json['nutrition'] as List<dynamic>?)
              ?.map((e) => NutritionItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NutritionItemDto>[],
      skinNutrients: (json['skinNutrients'] as List<dynamic>?)
              ?.map((e) => NutritionItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NutritionItemDto>[],
      concerns: (json['concerns'] as List<dynamic>?)
              ?.map((e) => ConcernScoreDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ConcernScoreDto>[],
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) =>
                  PlateHistoryItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PlateHistoryItemDto>[],
      aiComment: json['aiComment'] as String?,
      goodPoints: (json['goodPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      improvePoints: (json['improvePoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$DailyReportDtoImplToJson(
        _$DailyReportDtoImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'dailyScore': instance.dailyScore,
      'grade': instance.grade,
      'recordCount': instance.recordCount,
      'nutrition': instance.nutrition,
      'skinNutrients': instance.skinNutrients,
      'concerns': instance.concerns,
      'meals': instance.meals,
      'aiComment': instance.aiComment,
      'goodPoints': instance.goodPoints,
      'improvePoints': instance.improvePoints,
    };

_$WeeklyReportDtoImpl _$$WeeklyReportDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyReportDtoImpl(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      averageDailyScore: (json['averageDailyScore'] as num?)?.toInt(),
      grade: json['grade'] as String?,
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      recordedDays: (json['recordedDays'] as num?)?.toInt() ?? 0,
      recordCount: (json['recordCount'] as num?)?.toInt() ?? 0,
      dailyScores: (json['dailyScores'] as List<dynamic>?)
              ?.map((e) => DayScoreDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DayScoreDto>[],
      nutrition: (json['nutrition'] as List<dynamic>?)
              ?.map((e) => NutritionItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NutritionItemDto>[],
      concerns: (json['concerns'] as List<dynamic>?)
              ?.map((e) => ConcernScoreDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ConcernScoreDto>[],
      bestDay: json['bestDay'] == null
          ? null
          : DayScoreDto.fromJson(json['bestDay'] as Map<String, dynamic>),
      worstDay: json['worstDay'] == null
          ? null
          : DayScoreDto.fromJson(json['worstDay'] as Map<String, dynamic>),
      aiComment: json['aiComment'] == null
          ? null
          : WeeklyCommentDto.fromJson(
              json['aiComment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WeeklyReportDtoImplToJson(
        _$WeeklyReportDtoImpl instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'averageDailyScore': instance.averageDailyScore,
      'grade': instance.grade,
      'totalDays': instance.totalDays,
      'recordedDays': instance.recordedDays,
      'recordCount': instance.recordCount,
      'dailyScores': instance.dailyScores,
      'nutrition': instance.nutrition,
      'concerns': instance.concerns,
      'bestDay': instance.bestDay,
      'worstDay': instance.worstDay,
      'aiComment': instance.aiComment,
    };
