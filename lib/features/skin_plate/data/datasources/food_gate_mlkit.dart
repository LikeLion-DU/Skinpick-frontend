import 'package:camera/camera.dart' show CameraDescription, CameraImage;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../../../core/mlkit/camera_input_image.dart';
import '../../domain/entities/food_detection.dart';
import '../../domain/food_gate_config.dart';
import '../../domain/food_gate_rules.dart';
import 'food_gate.dart';

FoodGate createFoodGate(CameraDescription camera) => MlKitFoodGate(camera);

/// ML Kit 은 **라벨만 뽑는다.** 음식 종류·구성요소·영양성분은 촬영 후 서버의
/// OpenAI Vision 이 정한다. 여기서 떡볶이인지 칼로리가 얼마인지 추정하지 않는다.
///
/// 이 게이트가 답하는 질문은 하나뿐이다 — "지금 화면이 음식 사진으로 보이는가".
class MlKitFoodGate implements FoodGate {
  MlKitFoodGate(this._camera)
      : _labeler = ImageLabeler(
          options: ImageLabelerOptions(
            // 판정 임계값보다 낮게 둬야 디버그 화면에서 "0.6까지 나왔는데 왜
            // 안 잡히지" 를 눈으로 확인하고 임계값을 조정할 수 있다.
            confidenceThreshold: FoodGateConfig.labelerConfidenceFloor,
          ),
        );

  final CameraDescription _camera;
  final ImageLabeler _labeler;

  @override
  Future<FoodObservation> observe(CameraImage frame) async {
    final input = toInputImage(frame, _camera);
    // 읽을 수 없는 포맷이면 그 프레임을 건너뛴다. 창에 표를 넣지 않으므로
    // 상태는 checking 에 머문다 — 촬영은 어차피 막지 않는다.
    if (input == null) return FoodObservation.empty;

    final labels = await _labeler.processImage(input);
    return observeFood([for (final l in labels) (l.label, l.confidence)]);
  }

  @override
  void dispose() => _labeler.close();
}
