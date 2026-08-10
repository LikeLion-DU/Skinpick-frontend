import 'dart:io';

import '../../../../core/result/result.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../entities/skin_plate.dart';

abstract interface class PlateRepository {
  /// 음식 사진을 업로드하고 Skin Plate Score를 받는다.
  /// [skinAnalysisId]를 생략하면 서버가 최신 피부 분석을 자동으로 사용한다.
  Future<Result<SkinPlate>> create(File image, {int? skinAnalysisId});

  Future<Result<SkinPlate>> getById(int id);

  /// 추천 행동을 실행했다고 가정하고 점수를 다시 계산한다. 서버에 저장되지 않는다.
  Future<Result<PlateSimulation>> simulate(int plateId, List<PlateActionCode> actions);
}
