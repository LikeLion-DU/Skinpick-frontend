import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/enums/skin_type.dart';

class SkinAnalysis {
  const SkinAnalysis({
    required this.id,
    required this.skinScore,
    this.grade,
    required this.metrics,
    this.metricDetails = const [],
    this.skinType,
    this.skinAge,
    required this.summary,
    required this.highlights,
    this.careFocus = const <CareFocus>[],
    this.careMessage,
    this.skinTypeGap,
    required this.analyzedAt,
  });

  final int id;
  final int skinScore;

  /// [skinScore] 의 등급. **서버가 매긴다.** 모르면 배지를 그리지 않는다.
  final SkinLevel? grade;

  final SkinMetrics metrics;

  /// [metrics] 와 같은 5개에 서버 등급과 관찰 근거를 붙인 것.
  /// 이 기능 이전에 저장된 분석이면 근거가 비어 있다(등급은 저장된 지표에서
  /// 서버가 계산하므로 옛 기록에도 온다).
  final List<ScoredItem> metricDetails;

  /// 지표 등급을 key 로 찾는다. 상태어를 그리는 화면이 셋이라 여기에 둔다 —
  /// 화면마다 metricDetails 를 다시 훑으면 한 곳이 빠진다.
  SkinLevel? levelOf(String metricKey) {
    for (final detail in metricDetails) {
      if (detail.key == metricKey) return detail.level;
    }
    return null;
  }

  /// 오늘의 피부 타입 + 상태. `primary` 는 [skinTypeGap]`.observed` 와 항상 같은 값이다 —
  /// 둘 다 서버가 같은 규칙으로 낸다. null 이면 화면이 자가 신고 타입으로 떨어진다.
  final ObservedSkinType? skinType;

  /// AI 추정 피부 나이. null = 예전 분석이거나 서버가 쓸 수 없다고 판단했다.
  /// 그 경우 카드를 통째로 숨긴다 — 빈 값으로 그리지 않는다.
  final SkinAge? skinAge;

  final String summary;
  final List<Highlight> highlights;

  /// "지금 피부가 필요로 하는 관리" 축. 서버가 지표에서 규칙으로 낸다 —
  /// 앱이 지표를 보고 축을 고르지 않는다(그러면 기준이 두 곳에 생긴다).
  final List<CareFocus> careFocus;

  /// 위 축들의 권고 문단. **[summary] 와 다른 것을 말한다** — summary 는 AI 가
  /// 사진에서 관찰한 것이고 이쪽은 그 관찰에서 나오는 식단 방향이다.
  final String? careMessage;

  /// null = 사용자가 아직 피부 타입을 안 골랐다.
  /// 이 경우 S05 는 갭 카드 대신 "평소 본인 피부는?" 선택 칩을 띄운다.
  final SkinTypeGap? skinTypeGap;

  final DateTime analyzedAt;
}

/// 관리 축 하나. 서버 enum 이름과 라벨을 함께 들고 있다 — 화면은 라벨만 그린다.
class CareFocus {
  const CareFocus({required this.focus, required this.label});

  /// 서버 enum 이름(`HYDRATION` 등). 화면은 **키로만** 쓴다.
  final String focus;

  final String label;
}

/// 점수 하나 + 등급 + 관찰 근거. 피부 지표와 나이 축이 같이 쓴다.
class ScoredItem {
  const ScoredItem({
    required this.key,
    required this.score,
    this.level,
    required this.evidence,
  });

  final String key;

  /// 서버가 준 원값. 방향을 뒤집지 않았으므로 바 길이는 이 값으로 그린다.
  final int score;

  /// 서버가 **방향을 맞춰** 매긴 등급. 홍조 80 도 수분 20 도 나쁜 쪽이라 둘 다
  /// CAUTION 계열로 온다 — 화면은 이것을 [MetricBand] 로 접어 상태어를 만든다.
  final SkinLevel? level;

  final List<String> evidence;
}

/// 오늘 관찰된 피부 타입 + 상태. 화면 문구는 서버가 조합해 준 [label] 을 그대로 쓴다.
class ObservedSkinType {
  const ObservedSkinType({required this.primary, required this.label});

  /// 모르는 값이면 null. "미선택"과 섞이지 않도록 기본값을 두지 않는다.
  final SkinType? primary;

  /// "건성 · 붉은기" · "복합성 · 수분 부족(수부지)" 처럼 타입과 상태가 이미 조합된 문구.
  /// 비어 있을 수 있다. **뒤에 아무것도 이어 붙이지 않는다** — 괄호로 끝나는 문구가
  /// 있어서 "…(수부지) 피부" 로 깨진다.
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
