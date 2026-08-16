import 'dart:typed_data';

import '../../../../core/network/api_call.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../domain/entities/plate_analysis.dart';
import '../../domain/entities/plate_history.dart';
import '../../domain/entities/skin_plate.dart';
import '../../domain/entities/weekly_report.dart';
import '../../domain/repositories/plate_repository.dart';
import '../datasources/plate_image_store.dart';
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

  /// 서버가 먼저다. 사진을 먼저 지우면 서버 삭제가 실패했을 때 기록은 남고
  /// 사진만 사라진 상태가 된다 — 히스토리에 깨진 칸이 생긴다.
  @override
  Future<Result<void>> deleteRecord(int plateId) => callApi(() async {
        await _remote.delete(plateId);
        await PlateImageStore.delete(plateId);
      });

  @override
  Future<Result<List<PlateHistoryDay>>> history(DateTime from, DateTime to) =>
      callApi(() async => (await _remote.history(from, to)).toEntity());

  /// 두 번 부른다. 서버 `/reports` 는 이번 주 하나만 세어 주고, 지난주 비교와
  /// 음식 TOP 은 저장된 기록에서 뽑아야 한다.
  ///
  /// 조회 구간을 앱이 계산하지 않는다 — 서버가 준 `from` 에서 7일을 빼는 것이
  /// 두 구간을 정확히 붙이는 유일한 방법이다. 기기 시계로 오늘을 다시 세면
  /// 자정 무렵이나 KST 가 아닌 기기에서 하루가 어긋난다.
  @override
  Future<Result<WeeklyReport>> weeklyReport() => callApi(() async {
        final report = (await _remote.weeklyReport()).toEntity();

        // 달력 뺄셈이어야 한다. `Duration(days: 7)` 은 정확히 168시간이라, 서머타임이
        // 있는 시간대의 기기에서 그 구간에 전환이 끼면 자정 −168h 가 전날 23시로
        // 떨어지고 조회가 하루 일찍 시작된다 — 지난주가 8일이 되어 평균이 어긋난다.
        final lastWeekFrom = DateTime(
            report.from.year, report.from.month, report.from.day - 7);

        // 기록 조회가 실패해도 이미 받은 리포트는 버리지 않는다. 카드가 크게
        // 보여주는 평균·기록 수는 위에서 이미 왔고, 기록이 필요한 것은 지난주
        // 비교와 음식 TOP 뿐이다 — 그 셋은 없으면 화면이 알아서 접힌다.
        // 둘을 한 덩어리로 실패시키면 부가 정보 하나 때문에 본문이 사라진다.
        List<PlateHistoryDay> days;
        try {
          days = (await _remote.history(lastWeekFrom, report.to)).toEntity();
        } on Exception {
          days = const <PlateHistoryDay>[];
        }

        return WeeklyReport.assemble(report: report, days: days);
      });

  @override
  Future<Result<PlateSimulation>> simulateAnalysis(
          String analysisToken, List<PlateActionCode> actions) =>
      callApi(() async =>
          (await _remote.simulateAnalysis(analysisToken, actions)).toEntity());

  @override
  Future<Result<PlateSimulation>> simulate(int plateId, List<PlateActionCode> actions) =>
      callApi(() async => (await _remote.simulate(plateId, actions)).toEntity());
}
