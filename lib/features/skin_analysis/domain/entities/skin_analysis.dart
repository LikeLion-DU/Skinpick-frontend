import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_type.dart';

class SkinAnalysis {
  const SkinAnalysis({
    required this.id,
    required this.skinScore,
    required this.metrics,
    this.metricDetails = const [],
    this.aiSkinType,
    this.skinAge,
    required this.summary,
    required this.highlights,
    this.skinTypeGap,
    required this.analyzedAt,
  });

  final int id;
  final int skinScore;
  final SkinMetrics metrics;

  /// [metrics] 와 같은 5개에 서버 등급과 관찰 근거를 붙인 것.
  /// 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
  final List<ScoredItem> metricDetails;

  /// AI 가 사진에서 읽은 피부 타입. null = 예전 분석이라 서버가 키를 생략했다.
  /// [skinTypeGap]`.observed`(규칙 도출)와는 다른 값이고, 갈릴 수 있다.
  final AiSkinType? aiSkinType;

  /// AI 추정 피부 나이. null = 예전 분석이거나 서버가 쓸 수 없다고 판단했다.
  /// 그 경우 카드를 통째로 숨긴다 — 빈 값으로 그리지 않는다.
  final SkinAge? skinAge;

  final String summary;
  final List<Highlight> highlights;

  /// null = 사용자가 아직 피부 타입을 안 골랐다.
  /// 이 경우 S05 는 갭 카드 대신 "평소 본인 피부는?" 선택 칩을 띄운다.
  final SkinTypeGap? skinTypeGap;

  final DateTime analyzedAt;
}

/// 점수 하나 + 관찰 근거. 피부 지표와 나이 축이 같이 쓴다.
///
/// 서버가 같이 주는 `level` 은 도메인까지 올리지 않는다. 화면 색은 `MetricBand` 가
/// 그리고 있어서 읽는 곳이 없는데, 원시 문자열로 들고 있으면 이 저장소가 정한
/// "wire enum 은 파서를 거친다" 규칙만 헐거워진다. 계약이 어긋나는지는 DTO 층의
/// 계약 테스트가 본다.
class ScoredItem {
  const ScoredItem({
    required this.key,
    required this.score,
    required this.evidence,
  });

  final String key;

  /// 서버가 준 원값. 방향을 뒤집지 않았으므로 바 길이는 이 값으로 그린다.
  final int score;

  final List<String> evidence;
}

/// AI 관찰 피부 타입. 화면 문구는 서버가 조합해 준 [label] 을 그대로 쓴다.
class AiSkinType {
  const AiSkinType({required this.primary, required this.label});

  /// 모르는 값이면 null. "미선택"과 섞이지 않도록 기본값을 두지 않는다.
  final SkinType? primary;

  /// "건성 · 민감 경향" 처럼 이미 조합된 문구. 비어 있을 수 있다.
  final String label;
}

/// AI 추정 피부 나이. 실제 나이가 아니라 사진 기반 외관 추정이다.
class SkinAge {
  const SkinAge({
    required this.estimatedSkinAge,
    required this.axes,
    required this.assessment,
  });

  final int estimatedSkinAge;

  /// 피부결·탄력·주름·톤·모공·색소·트러블 흔적 7개.
  /// 붉은기는 서버가 응답에서 뺀다 — 지표 쪽에 이미 있어 숫자가 둘이 되기 때문이다.
  final List<ScoredItem> axes;

  /// 왜 그 나이로 봤는지. 서버가 만든 문장이라 앱이 고치지 않는다.
  final String assessment;

  /// 서버가 이미 18~80 을 보장하지만 앱이 한 번 더 본다.
  /// 회귀가 나면 "AI 추정 피부 나이 0세" 가 확신에 찬 설명 옆에 그려진다.
  bool get isUsable => estimatedSkinAge >= 18 && estimatedSkinAge <= 80;
}

/// 자가 진단 ↔ 오늘 측정 비교. 서버가 계산해서 내려준다.
class SkinTypeGap {
  const SkinTypeGap({
    required this.declared,
    required this.observed,
    required this.matched,
    required this.message,
  });

  final SkinType declared;
  final SkinType observed;
  final bool matched;
  final String message;
}

class SkinMetrics {
  const SkinMetrics({
    required this.hydration,
    required this.oil,
    required this.redness,
    required this.trouble,
    required this.barrier,
  });

  final int hydration;
  final int oil;
  final int redness;
  final int trouble;
  final int barrier;

  /// 화면에서 5개 바를 그릴 때 쓰는 순서 고정 리스트.
  ///
  /// higherIsBetter가 반드시 필요하다 — hydration 30은 나쁘고 redness 30은 좋다.
  /// 이 정보 없이 게이지 색을 칠하면 홍조가 심할수록 초록으로 표시된다.
  List<({String key, String label, int value, bool higherIsBetter})> toBars() => [
        (key: 'hydration', label: '수분',   value: hydration, higherIsBetter: true),
        (key: 'oil',       label: '유분',   value: oil,       higherIsBetter: false),
        (key: 'redness',   label: '홍조',   value: redness,   higherIsBetter: false),
        (key: 'trouble',   label: '트러블', value: trouble,   higherIsBetter: false),
        (key: 'barrier',   label: '장벽',   value: barrier,   higherIsBetter: true),
      ];
}

class Highlight {
  const Highlight({required this.label, required this.status});

  final String label;
  final HighlightStatus status;
}
