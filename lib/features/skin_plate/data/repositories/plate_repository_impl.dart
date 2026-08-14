import 'dart:typed_data';

import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../domain/entities/plate_analysis.dart';
import '../../domain/entities/skin_plate.dart';
import '../../domain/repositories/plate_repository.dart';
import '../datasources/plate_remote_datasource.dart';
import '../models/plate_dtos.dart';

class PlateRepositoryImpl implements PlateRepository {
  const PlateRepositoryImpl(this._remote);

  final PlateRemoteDataSource _remote;

  @override
  Future<Result<PlateAnalysis>> analyze(Uint8List image, {int? skinAnalysisId}) =>
      callApi(() async =>
          (await _remote.analyze(image, skinAnalysisId: skinAnalysisId)).toEntity());

  @override
  Future<Result<SkinPlate>> saveRecord(String analysisToken) =>
      callApi(() async => (await _remote.saveRecord(analysisToken)).toEntity());

  @override
  Future<Result<SkinPlate>> getById(int id) =>
      callApi(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Result<PlateSimulation>> simulateAnalysis(
          String analysisToken, List<PlateActionCode> actions) =>
      callApi(() async =>
          (await _remote.simulateAnalysis(analysisToken, actions)).toEntity());

  @override
  Future<Result<PlateSimulation>> simulate(int plateId, List<PlateActionCode> actions) =>
      callApi(() async => (await _remote.simulate(plateId, actions)).toEntity());
}
