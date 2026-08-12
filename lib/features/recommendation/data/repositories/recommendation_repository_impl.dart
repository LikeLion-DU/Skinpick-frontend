import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';
import '../models/recommendation_dtos.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(this._remote);

  final RecommendationRemoteDataSource _remote;

  @override
  Future<Result<DailyRecommendation>> getBySkinAnalysis(int skinAnalysisId) =>
      callApi(() async =>
          (await _remote.getBySkinAnalysis(skinAnalysisId)).toEntity());
}
