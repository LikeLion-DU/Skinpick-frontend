import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/recommendation.dart';

/// 추천은 서버가 없으면 그 자리에서 만들어 준다(lazy 동기 생성).
/// 그래서 앱은 조회 한 번으로 끝나고, 미리 만들어 달라는 요청을 따로 보내지 않는다.
final recommendationProvider =
    FutureProvider.family<Result<DailyRecommendation>, int>(
  (ref, skinAnalysisId) =>
      ref.watch(recommendationRepositoryProvider).getBySkinAnalysis(skinAnalysisId),
);
