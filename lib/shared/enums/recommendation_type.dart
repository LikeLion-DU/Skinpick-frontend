enum RecommendationType {
  recommend,
  avoid;

  static RecommendationType fromJson(String value) => switch (value) {
        'AVOID' => RecommendationType.avoid,
        _ => RecommendationType.recommend,
      };
}
