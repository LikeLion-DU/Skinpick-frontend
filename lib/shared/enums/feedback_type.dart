enum FeedbackType {
  good, // 좋은 점
  caution, // 주의사항
  action; // 추천 행동 — 화면에서 가장 강조되는 카드

  static FeedbackType fromJson(String value) => switch (value) {
        'GOOD' => FeedbackType.good,
        'CAUTION' => FeedbackType.caution,
        'ACTION' => FeedbackType.action,
        _ => FeedbackType.caution,
      };
}
