import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../entities/plate_analysis.dart';
import '../entities/skin_plate.dart';

abstract interface class PlateRepository {
  /// 음식 사진을 올리고 임시 분석 결과를 받는다. **저장되지 않는다.**
  /// [skinAnalysisId]를 생략하면 서버가 최신 피부 분석을 자동으로 사용한다.
  Future<Result<PlateAnalysis>> analyze(Uint8List image, {int? skinAnalysisId});

  /// 분석 결과를 기록으로 확정한다. 여기서 처음으로 히스토리·리포트에 반영된다.
  Future<Result<SkinPlate>> saveRecord(String analysisToken);

  Future<Result<SkinPlate>> getById(int id);

  /// 추천 행동을 실행했다고 가정하고 점수를 다시 계산한다. 서버에 저장되지 않는다.
  ///
  /// 저장 전에는 토큰으로, 저장 후에는 plateId 로 묻는다. 결과 모양은 같다.
  /// 저장된 뒤에도 토큰을 쓰면 30분 TTL 에 걸려 멀쩡한 기록에서 만료가 난다.
  Future<Result<PlateSimulation>> simulateAnalysis(
      String analysisToken, List<PlateActionCode> actions);

  Future<Result<PlateSimulation>> simulate(int plateId, List<PlateActionCode> actions);
}
