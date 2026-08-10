class DailyRecommendation {
  const DailyRecommendation({
    required this.skinAnalysisId,
    required this.recommend,
    required this.avoid,
    this.generatedAt,
  });

  final int skinAnalysisId;
  final List<RecommendedFood> recommend;
  final List<RecommendedFood> avoid;
  final DateTime? generatedAt;

  bool get isEmpty => recommend.isEmpty && avoid.isEmpty;
}

class RecommendedFood {
  const RecommendedFood({required this.foodName, required this.reason});

  final String foodName;
  final String reason;
}
