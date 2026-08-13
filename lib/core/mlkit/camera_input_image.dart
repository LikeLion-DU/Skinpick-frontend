import 'dart:io' show Platform;
import 'dart:ui' show Size;

import 'package:camera/camera.dart' show CameraDescription, CameraImage;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// 카메라 프레임을 ML Kit 입력으로 바꾼다.
///
/// **`dart:io` 전용 파일이다.** 웹에서 닿는 코드가 이걸 import 하면 웹 빌드가
/// 깨진다. 조건부 import 뒤의 `*_mlkit.dart` 구현에서만 쓴다.
///
/// 얼굴 게이트와 음식 게이트가 같은 변환을 쓴다. 여기서 한 번만 맞춰 두지 않으면
/// 회전 보정 같은 수정이 한쪽에만 반영되고, 그 차이는 "검출이 그냥 0개로 나온다"
/// 는 형태로만 드러나서 원인을 찾기 어렵다.

/// 프레임을 세우기 위해 되돌려야 하는 각도.
///
/// **iOS 는 항상 0이다.** `camera_avfoundation` 은 모든 카메라에
/// `sensorOrientation: 90` 을 하드코딩해 놓고(utils.dart) 스트림 출력은
/// `.portrait` 로 고정해 내려준다 — 프레임이 이미 똑바로 서서 온다.
/// ML Kit iOS 브리지도 `InputImageMetadata.rotation` 을 보지 않는다.
///
/// 이 값은 **세로로 든 상태**를 전제로 한다. 호출하는 화면은 세로로 고정해야 한다.
int rotationDegreesOf(CameraDescription camera) =>
    Platform.isAndroid ? camera.sensorOrientation : 0;

/// 센서가 90/270도 돌아 있으면 ML Kit 좌표계는 가로세로가 바뀐 상태다.
bool isRotatedQuarter(int rotationDeg) =>
    rotationDeg == 90 || rotationDeg == 270;

/// `InputImage.fromBytes` 는 **플랫폼마다 다른 포맷**을 요구한다. 그리고 어긋나도
/// 예외가 안 난다 — 검출이 그냥 0개로 나온다. 카메라는 멀쩡히 대상을 비추고 있는데.
/// 원인을 판정 조건에서 찾게 되는 종류의 실패다.
///
/// CameraController 는 반드시 Android `nv21` / iOS `bgra8888` 로 만든다.
/// 양쪽을 yuv420 으로 통일하면 iOS 에서 ML Kit 이 프레임을 못 읽는다.
///
/// 읽을 수 없는 포맷이면 null 을 돌려준다. 호출부가 그 프레임을 건너뛰면 된다.
InputImage? toInputImage(CameraImage frame, CameraDescription camera) {
  final format = InputImageFormatValue.fromRawValue(frame.format.raw);
  if (format == null) return null;

  // 센서 방향을 안 넘기면 세로로 든 폰에서 대상이 90도 누운 채로 들어가고,
  // ML Kit 은 누운 얼굴을 잘 못 찾는다. 게이트가 상시 막히는 원인 1순위다.
  final rotation =
      InputImageRotationValue.fromRawValue(rotationDegreesOf(camera));
  if (rotation == null) return null;

  final plane = frame.planes.first;

  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(frame.width.toDouble(), frame.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    ),
  );
}
