import 'package:dio/dio.dart';

import '../../../../core/network/api_call.dart';
import '../models/recommendation_dtos.dart';

class RecommendationRemoteDataSource {
  const RecommendationRemoteDataSource(this._dio);

  final Dio _dio;

  /// 추천이 아직 없으면 서버가 그 자리에서 만들어 준다(lazy 동기 생성).
  /// 그래서 앱은 "없으면 만들어 달라"는 요청을 따로 보내지 않는다.
  Future<RecommendationDto> getBySkinAnalysis(int skinAnalysisId) async {
    final response = await _dio.get<dynamic>(
      '/recommendations',
      queryParameters: <String, dynamic>{'skinAnalysisId': skinAnalysisId},
    );
    return RecommendationDto.fromJson(requireEnvelopeData(response));
  }
}
