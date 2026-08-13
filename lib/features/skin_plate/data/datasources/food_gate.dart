import 'package:camera/camera.dart' show CameraDescription, CameraImage;

import '../../domain/entities/food_detection.dart';

// dart.library.io 가 있으면 ML Kit 구현, 없으면(=웹) 스텁을 가져온다.
// kIsWeb 으로는 못 막는다 — 런타임 분기이고 import 는 컴파일 타임이라,
// 웹 번들을 만들 때 컴파일러가 도달 가능한 import 를 전부 따라간다.
import 'food_gate_stub.dart' if (dart.library.io) 'food_gate_mlkit.dart';

/// 프리뷰 프레임이 음식으로 보이는지만 본다. **ML Kit 타입이 등장하지 않는다.**
abstract interface class FoodGate {
  /// 프레임 1장을 라벨링한다. 읽을 수 없는 포맷이면 [FoodObservation.empty].
  Future<FoodObservation> observe(CameraImage frame);

  void dispose();
}

/// 호출부가 쓰는 유일한 진입점. 두 구현 파일이 같은 이름으로 제공한다.
FoodGate foodGate(CameraDescription camera) => createFoodGate(camera);
