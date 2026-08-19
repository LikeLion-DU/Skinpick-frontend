import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_level.dart';
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

/// 점수 하나 + 등급 + 관찰 근거. 서버에서 피부 지표 5개와 나이 축 7개가
/// 같은 모양으로 온다.
///
/// `level` 은 서버가 **방향을 맞춰** 계산한 5단계다(홍조는 100-점수로 뒤집은 뒤 매긴다).
/// 화면의 상태어는 이것을 접어서 만든다 — 앱에 지표 경계표를 두지 않는다.
@freezed
class ScoredItemDto with _$ScoredItemDto {
  const factory ScoredItemDto({
    required String key,
    required int score,
    /// 이 필드가 없던 서버와 붙으면 빈 문자열이고, 그러면 상태어 자리가 빈다.
    @Default('') String level,
    @Default(<String>[]) List<String> evidence,
  }) = _ScoredItemDto;

  factory ScoredItemDto.fromJson(Map<String, dynamic> json) =>
      _$ScoredItemDtoFromJson(json);
}

/// 오늘의 피부 타입과 상태. 서버가 지표에서 규칙으로 낸다.
///
/// [primary] 는 `skinTypeGap.observed` 와 **항상 같은 값**이다. 예전에는 이 필드가
/// AI 관찰값이라 둘이 갈릴 수 있었고, 그래서 S05 는 제목에 규칙값을·칩에 AI 값을
/// 그리며 한 화면에서 타입 두 개를 들고 있었다. 서버가 판정을 한쪽으로 모으면서
/// 그 구조가 없어졌다.
///
/// `traits` 를 enum 으로 올리지 않는다. 화면에 그리는 것은 서버가 조합해 준 [label]
/// 이고("건성 · 붉은기"), 앱이 상태를 따로 그리기 시작하면 조합 규칙이 두 곳에 생긴다.
/// 그래서 서버가 상태 값 이름을 바꿔도 이 모델은 깨지지 않는다.
@freezed
class SkinTypeDto with _$SkinTypeDto {
  const factory SkinTypeDto({
    String? primary,
    @Default(<String>[]) List<String> traits,
    @Default('') String label,
  }) = _SkinTypeDto;

  factory SkinTypeDto.fromJson(Map<String, dynamic> json) =>
      _$SkinTypeDtoFromJson(json);
}

/// AI 추정 피부 나이. 실제 나이가 아니라 사진 기반 외관 추정이다.
///
/// 서버가 쓸 수 없다고 판단하면(축이 모자라거나 나이가 18~80 밖) 키 자체를 생략한다.
/// 그래서 이 DTO 가 오면 값은 이미 믿을 수 있는 상태다.
@freezed
class SkinAgeDto with _$SkinAgeDto {
  const factory SkinAgeDto({
    required int estimatedSkinAge,
    @Default(<ScoredItemDto>[]) List<ScoredItemDto> axes,
    @Default('') String assessment,
  }) = _SkinAgeDto;

  factory SkinAgeDto.fromJson(Map<String, dynamic> json) =>
      _$SkinAgeDtoFromJson(json);
}

/// 관리 축 하나. 서버가 지표에서 규칙으로 낸다 — AI 문장이 아니다.
///
/// enum 이름과 라벨이 함께 온다. 화면은 [focus] 를 키로만 쓰고 표시는 [label] 로
/// 한다 — 그래야 서버가 축을 늘리거나 문구를 다듬을 때 앱을 고치지 않는다.
@freezed
class CareFocusDto with _$CareFocusDto {
  const factory CareFocusDto({
    @Default('') String focus,
    @Default('') String label,
  }) = _CareFocusDto;

  factory CareFocusDto.fromJson(Map<String, dynamic> json) =>
      _$CareFocusDtoFromJson(json);
}

@freezed
class SkinAnalysisDto with _$SkinAnalysisDto {
  const factory SkinAnalysisDto({
    required int skinAnalysisId,
    required int skinScore,

    /// [skinScore] 의 등급. **서버가 매긴다** — 앱에 경계표를 두지 않는다.
    /// 이 필드가 생기기 전 서버와 붙으면 null 이고, 그때는 배지를 안 그린다.
    String? grade,
    required SkinMetricsDto metrics,
    // 같은 5개에 등급과 근거를 붙인 것. 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
    @Default(<ScoredItemDto>[]) List<ScoredItemDto> metricDetails,
    // 지표에서 규칙으로 도출한다 — 예전 분석에도 온다. 서버가 못 낼 이유가 없어졌지만
    // 널 허용은 유지한다. 계약이 바뀌었다고 옛 기록을 여는 순간 앱이 멎어서는 안 된다.
    SkinTypeDto? skinType,
    SkinAgeDto? skinAge,                // 예전 분석이면 서버가 키를 생략한다
    @Default('') String summary,
    @Default(<HighlightDto>[]) List<HighlightDto> highlights,

    /// "지금 피부가 필요로 하는 관리" 축. 지표에서 규칙으로 도출하므로 **예전
    /// 분석에도 온다**(highlights 와 같은 성격이다). 최소 하나는 오지만, 이 필드가
    /// 생기기 전 서버와 붙어도 기본값이 빈 배열이라 화면이 칩 줄만 안 그린다.
    @Default(<CareFocusDto>[]) List<CareFocusDto> careFocus,

    /// 위 축들의 권고를 이어 붙인 문단. **AI 문장이 아니다** — [summary](AI 가
    /// 관찰한 것)와 다른 것을 말한다. 없으면 화면이 summary 로 떨어진다.
    String? careMessage,
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
        grade: SkinLevel.fromJson(grade),
        metrics: SkinMetrics(
          hydration: metrics.hydration,
          oil: metrics.oil,
          redness: metrics.redness,
          trouble: metrics.trouble,
          barrier: metrics.barrier,
        ),
        metricDetails: metricDetails.map((d) => d.toEntity()).toList(),
        skinType: skinType?.toEntity(),
        skinAge: skinAge?.toEntity(),
        summary: summary,
        highlights: highlights
            .map((h) => Highlight(
                  label: h.label,
                  status: HighlightStatus.fromJson(h.status),
                ))
            .toList(),
        careFocus: careFocus
            .map((item) => CareFocus(focus: item.focus, label: item.label))
            .toList(),
        careMessage: careMessage,
        skinTypeGap: skinTypeGap?.toEntity(),
        analyzedAt: analyzedAt,
      );
}

extension ScoredItemDtoX on ScoredItemDto {
  ScoredItem toEntity() => ScoredItem(
        key: key,
        score: score,
        level: SkinLevel.fromJson(level),
        evidence: evidence,
      );
}

extension SkinTypeDtoX on SkinTypeDto {
  /// primary 는 모르는 값이면 null 로 흘려보낸다 — SkinType 의 기존 규칙과 같다.
  /// label 이 비어 있으면 화면이 기존 문구로 떨어진다.
  ObservedSkinType toEntity() =>
      ObservedSkinType(primary: SkinType.fromJson(primary), label: label);
}

extension SkinAgeDtoX on SkinAgeDto {
  SkinAge toEntity() => SkinAge(
        estimatedSkinAge: estimatedSkinAge,
        axes: axes.map((a) => a.toEntity()).toList(),
        assessment: assessment,
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
