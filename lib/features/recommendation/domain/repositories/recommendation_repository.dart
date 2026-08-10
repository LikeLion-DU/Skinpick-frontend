import '../../../../core/result/result.dart';
import '../entities/recommendation.dart';

abstract interface class RecommendationRepository {
  Future<Result<DailyRecommendation>> getBySkinAnalysis(int skinAnalysisId);
}
