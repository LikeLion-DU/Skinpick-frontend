import '../../../../shared/enums/insight_category.dart';

/// S10 개인화 인사이트. 문장·순서·변화량은 전부 서버가 만든 것을 그대로 싣는다.
///
/// 앱이 인과관계를 지어내지 않는다 — "수면 부족 때문에 트러블이 생겼어요" 같은
/// 문장은 서버가 이미 금지 규칙 아래에서 만들고 있다. 앱이 한 벌 더 만들면
/// 그 규칙이 두 곳으로 갈린다.
class SkinInsight {
  const SkinInsight({
    required this.skinAnalysisId,
    required this.summary,
    this.changes,
    required this.insights,
    required this.todayActions,
  });

  final int skinAnalysisId;
  final String summary;

  /// null = 직전 분석이 없다. 0 으로 채우면 "변화 없음"과 구분이 사라진다.
  final SkinInsightChanges? changes;

  /// 최대 3개. 배열 순서가 곧 우선순위다 — 앱이 다시 정렬하지 않는다.
  /// 비어 있는 것도 정상이다: 지표가 전부 양호하고 고민·나쁜 습관이 없는 경우다.
  final List<SkinInsightItem> insights;

  /// insights 와 같은 주제를 행동 관점으로 본 것이다. 길이도 순서도 항상 같다.
  final List<SkinTodayAction> todayActions;
}

/// 직전 분석 대비 증감. 부호 그대로다 — 방향 해석은 화면이 지표별로 한다.
class SkinInsightChanges {
  const SkinInsightChanges({
    required this.hydration,
    required this.oil,
    required this.redness,
    required this.trouble,
    required this.barrier,
    required this.skinScore,
  });

  final int hydration;
  final int oil;
  final int redness;
  final int trouble;
  final int barrier;
  final int skinScore;

  /// `SkinMetrics.toBars()` 의 key 로 델타를 찾는다.
  /// 두 리스트를 인덱스로 맞추면 지표 순서가 바뀌는 날 조용히 어긋난다.
  int? byKey(String key) => switch (key) {
        'hydration' => hydration,
        'oil' => oil,
        'redness' => redness,
        'trouble' => trouble,
        'barrier' => barrier,
        _ => null,
      };
}

class SkinInsightItem {
  const SkinInsightItem({
    required this.category,
    required this.title,
    required this.description,
  });

  /// null = 앱이 모르는 카테고리. 화면이 중립 아이콘을 쓴다.
  final InsightCategory? category;

  /// 카테고리별 고정 문구다. AI 가 쓰는 것은 description 뿐이다.
  final String title;
  final String description;
}

class SkinTodayAction {
  const SkinTodayAction({required this.category, required this.title});

  final InsightCategory? category;
  final String title;
}
