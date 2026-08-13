import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/entities/skin_photo_set.dart';
import '../../domain/repositories/skin_repository.dart';
import '../datasources/skin_remote_datasource.dart';
import '../models/skin_dtos.dart';

class SkinRepositoryImpl implements SkinRepository {
  const SkinRepositoryImpl(this._remote);

  final SkinRemoteDataSource _remote;

  @override
  Future<Result<SkinAnalysis>> analyze(SkinPhotoSet photos) =>
      callApi(() async => (await _remote.analyze(photos)).toEntity());

  @override
  Future<Result<SkinAnalysis?>> getLatest() =>
      callApi(() async => (await _remote.getLatest())?.toEntity());

  @override
  Future<Result<SkinAnalysis>> getById(int id) =>
      callApi(() async => (await _remote.getById(id)).toEntity());
}
