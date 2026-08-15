import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/recommendation/data/datasources/recommendation_remote_datasource.dart';
import '../../features/recommendation/data/repositories/recommendation_repository_impl.dart';
import '../../features/recommendation/domain/repositories/recommendation_repository.dart';
import '../../features/skin_analysis/data/datasources/skin_remote_datasource.dart';
import '../../features/skin_analysis/data/repositories/skin_repository_impl.dart';
import '../../features/skin_analysis/domain/entities/skin_insight.dart';
import '../../features/skin_analysis/domain/repositories/skin_repository.dart';
import '../../features/skin_plate/data/datasources/plate_remote_datasource.dart';
import '../../features/skin_plate/data/repositories/plate_repository_impl.dart';
import '../../features/skin_plate/domain/repositories/plate_repository.dart';
import '../network/dio_client.dart';
import '../network/unauthorized_signal.dart';
import '../result/result.dart';
import '../storage/token_storage.dart';

/// 전역 배선. 화면은 Repository 인터페이스만 알고 구현체는 여기서만 등장한다.
///
/// riverpod_generator 를 쓰지 않는다 — 프로바이더 선언 20줄을 위해 생성 코드를
/// 한 벌 더 커밋하고 build_runner 를 한 번 더 돌려야 하는 값이 없다.
/// DTO 는 freezed 가 필요해서 쓰지만 여기는 아니다.

final tokenStorageProvider = Provider<TokenStorage>((ref) => const TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final client = DioClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    // 인터셉터가 토큰을 지운 뒤 이 신호를 쏘고, AuthNotifier 가 받아 상태를 되돌린다.
    onUnauthorized: () => ref.read(unauthorizedSignalProvider.notifier).fire(),
  );
  return client.dio;
});

// ---------- auth ----------

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(
      AuthRemoteDataSource(ref.watch(dioProvider)),
      ref.watch(tokenStorageProvider),
    ));

// ---------- skin_analysis ----------

final skinRepositoryProvider = Provider<SkinRepository>(
  (ref) => SkinRepositoryImpl(SkinRemoteDataSource(ref.watch(dioProvider))),
);

/// S10 개인화 인사이트. 화면 rebuild 로 다시 부르지 않는다.
///
/// autoDispose 라도 안전하다 — 두 번째 조회는 서버가 저장해 둔 인사이트를 그대로
/// 돌려주므로 AI 를 다시 부르지 않는다. 다룰 주제가 없어 저장되지 않은 경우만
/// 매번 만들어지는데, 그 경로는 AI 호출 자체가 없어서 빠르다.
///
/// 재시도는 `ref.invalidate(skinInsightProvider(id))` 다. 서버가 실패한 인사이트를
/// 저장하지 않으므로 같은 GET 이 그대로 재시도가 된다.
final skinInsightProvider =
    FutureProvider.autoDispose.family<Result<SkinInsight>, int>(
  (ref, skinAnalysisId) =>
      ref.watch(skinRepositoryProvider).getInsight(skinAnalysisId),
);

// ---------- skin_plate ----------

final plateRepositoryProvider = Provider<PlateRepository>(
  (ref) => PlateRepositoryImpl(PlateRemoteDataSource(ref.watch(dioProvider))),
);

// ---------- recommendation ----------

final recommendationRepositoryProvider = Provider<RecommendationRepository>(
  (ref) => RecommendationRepositoryImpl(
    RecommendationRemoteDataSource(ref.watch(dioProvider)),
  ),
);
