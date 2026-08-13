import 'package:camera/camera.dart' show CameraDescription, CameraImage, XFile;

import '../../domain/entities/face_gate_result.dart';
import 'face_gate.dart';

/// 웹에는 ML Kit 이 없다.
///
/// 예전에는 여기서 통과시키고 서버의 faceDetected:false 폴백에 맡겼지만,
/// 게이트를 통과하지 못한 이미지를 서버로 보내지 않기로 하면서 막는 쪽으로 바꿨다.
/// **결과적으로 웹에서는 피부 분석 촬영 경로가 닫힌다.**
FaceGate createFaceGate(CameraDescription camera) => _NoGate();

class _NoGate implements FaceGate {
  @override
  Future<FaceGateResult> check(CameraImage frame, FacePhotoType photoType) async =>
      const FaceGateUnavailable();

  /// 검출을 할 수 없으므로 통과시키지 않는다. 원본을 그대로 올리는 폴백은 없다.
  @override
  Future<PreparedPhoto> prepareSkinPhoto(
    XFile original, {
    FacePhotoType photoType = FacePhotoType.front,
    bool fullGate = false,
  }) async =>
      const PreparedPhoto(null, FaceGateUnavailable());

  @override
  void dispose() {}
}
