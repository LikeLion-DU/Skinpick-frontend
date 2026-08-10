import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/skin_analysis.dart';

part 'skin_dtos.freezed.dart';
part 'skin_dtos.g.dart';

@freezed
class SkinMetricsDto with _$SkinMetricsDto {
  const factory SkinMetricsDto({
    required int hydration,
    required int oil,
    required int redness,
    required int trouble,
    required int barrier,
  }) = _SkinMetricsDto;

  factory SkinMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$SkinMetricsDtoFromJson(json);
}

@freezed
class HighlightDto with _$HighlightDto {
  const factory HighlightDto({
    required String label,
    required String status,     // GOOD / WARN / CAUTION
  }) = _HighlightDto;

  factory HighlightDto.fromJson(Map<String, dynamic> json) =>
      _$HighlightDtoFromJson(json);
}

@freezed
class SkinTypeGapDto with _$SkinTypeGapDto {
  const factory SkinTypeGapDto({
    required String declared,
    required String observed,
    @Default(false) bool matched,
    @Default('') String message,
  }) = _SkinTypeGapDto;

  factory SkinTypeGapDto.fromJson(Map<String, dynamic> json) =>
      _$SkinTypeGapDtoFromJson(json);
}

@freezed
class SkinAnalysisDto with _$SkinAnalysisDto {
  const factory SkinAnalysisDto({
    required int skinAnalysisId,
    required int skinScore,
    required SkinMetricsDto metrics,
    @Default('') String summary,
    @Default(<HighlightDto>[]) List<HighlightDto> highlights,
    SkinTypeGapDto? skinTypeGap,        // 미선택이면 서버가 키를 생략한다
    required DateTime analyzedAt,
  }) = _SkinAnalysisDto;

  factory SkinAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$SkinAnalysisDtoFromJson(json);
}

extension SkinAnalysisDtoX on SkinAnalysisDto {
  SkinAnalysis toEntity() => SkinAnalysis(
        id: skinAnalysisId,
        skinScore: skinScore,
        metrics: SkinMetrics(
          hydration: metrics.hydration,
          oil: metrics.oil,
          redness: metrics.redness,
          trouble: metrics.trouble,
          barrier: metrics.barrier,
        ),
        summary: summary,
        highlights: highlights
            .map((h) => Highlight(
                  label: h.label,
                  status: HighlightStatus.fromJson(h.status),
                ))
            .toList(),
        skinTypeGap: skinTypeGap?.toEntity(),
        analyzedAt: analyzedAt,
      );
}

extension SkinTypeGapDtoX on SkinTypeGapDto {
  /// declared/observed 는 서버가 보낸 값이므로 null 이 될 수 없다.
  /// 그래도 알 수 없는 값이 오면 unknown 으로 흘려보내 앱이 죽지 않게 한다.
  SkinTypeGap toEntity() => SkinTypeGap(
        declared: SkinType.fromJson(declared) ?? SkinType.unknown,
        observed: SkinType.fromJson(observed) ?? SkinType.unknown,
        matched: matched,
        message: message,
      );
}
