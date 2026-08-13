import 'package:camera/camera.dart' show CameraDescription, CameraImage;

import '../../domain/entities/food_detection.dart';
import 'food_gate.dart';

/// 웹에는 ML Kit 이 없다.
///
/// 얼굴 게이트와 달리 **막지 않는다.** 음식 게이트는 촬영을 차단하는 장치가
/// 아니라 촬영 가이드일 뿐이라, 판단할 수 없으면 안내를 접고 그대로 찍게 둔다.
/// 실제 음식 여부는 어차피 서버의 OpenAI Vision 이 정한다.
FoodGate createFoodGate(CameraDescription camera) => _NoGate();

class _NoGate implements FoodGate {
  @override
  Future<FoodObservation> observe(CameraImage frame) async =>
      FoodObservation.empty;

  @override
  void dispose() {}
}
