import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_dtos.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._remote);

  final ReportRemoteDataSource _remote;

  @override
  Future<Result<DailyReport>> daily({DateTime? date}) =>
      callApi(() async => (await _remote.daily(date: date)).toEntity());

  @override
  Future<Result<WeeklyReport>> weekly({DateTime? from, DateTime? to}) =>
      callApi(() async => (await _remote.weekly(from: from, to: to)).toEntity());
}
