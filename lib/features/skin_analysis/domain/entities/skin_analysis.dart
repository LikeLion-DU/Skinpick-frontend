import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_type.dart';

class SkinAnalysis {
  const SkinAnalysis({
    required this.id,
    required this.skinScore,
    required this.metrics,
    required this.summary,
    required this.highlights,
    this.skinTypeGap,
    required this.analyzedAt,
  });

  final int id;
  final int skinScore;
  final SkinMetrics metrics;
  final String summary;
  final List<Highlight> highlights;

  /// null = 사용자가 아직 피부 타입을 안 골랐다.
  /// 이 경우 S05 는 갭 카드 대신 "평소 본인 피부는?" 선택 칩을 띄운다.
  final SkinTypeGap? skinTypeGap;

  final DateTime analyzedAt;
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
