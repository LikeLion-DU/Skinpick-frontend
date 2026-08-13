import 'dart:io' show File, Platform;
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:camera/camera.dart'
    show CameraDescription, CameraImage, ImageFormatGroup, XFile;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/face_gate_result.dart';
import '../../domain/face_gate_config.dart';
import '../../domain/face_gate_rules.dart';
import 'face_gate.dart';

FaceGate createFaceGate(CameraDescription camera) => MlKitFaceGate(camera);

/// ML Kit 은 **값을 뽑기만 한다.** 판정은 [evaluateFaceGate] 가 하고,
/// 피부 상태는 서버가 한다. 이 파일에서 피부에 대한 결론을 내리지 않는다.
///
/// `enableClassification: false` 는 의도적이다. smilingProbability ·
/// leftEyeOpenProbability 로 트러블이나 홍조를 추정하려 들면 "AI 는 인식,
/// 로직은 Backend" 구조가 무너지고 근거 없는 숫자가 하나 더 생긴다.
class MlKitFaceGate implements FaceGate {
  MlKitFaceGate(this._camera)
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast, // 실시간 프리뷰용
            enableLandmarks: false, // 게이트에는 불필요
            enableClassification: false, // 웃음·눈뜸 확률 안 쓴다
          ),
        );

  final CameraDescription _camera;
  final FaceDetector _detector;

  /// 프레임을 세우기 위해 되돌려야 하는 각도.
  ///
  /// **iOS 는 항상 0이다.** `camera_avfoundation` 은 모든 카메라에
  /// `sensorOrientation: 90` 을 하드코딩해 놓고(utils.dart) 스트림 출력은
  /// `.portrait` 로 고정해서 내려준다 — 즉 프레임은 이미 똑바로 서서 온다.
  /// ML Kit iOS 브리지도 `InputImageMetadata.rotation` 을 아예 보지 않는다.
  ///
  /// 그 90을 그대로 믿으면 (a) 가로세로를 바꿔 얼굴 크기 비율이 1.78배로 부풀고
  /// 40% 게이트가 사실상 22%가 되며, (b) 걸린 적 없는 회전을 되돌리게 되어
  /// 휘도를 프레임 구석에서 재게 된다.
  int get _rotationDeg => Platform.isAndroid ? _camera.sensorOrientation : 0;

  @override
  Future<FaceGateResult> check(CameraImage frame, FacePhotoType photoType) async {
    final input = _toInputImage(frame);
    // 포맷을 못 읽으면 검증을 할 수 없다. 통과시키지 않는다.
    if (input == null) return const FaceGateUnavailable();

    final faces = await _detector.processImage(input);
    final face = faces.isEmpty ? null : faces.first;

    // 센서가 90/270도 돌아 있으면 ML Kit 좌표계는 가로세로가 바뀐 상태다.
    // 여기서 안 맞추면 얼굴 크기 비율이 통째로 틀어져 "조금 더 가까이"만 계속 뜬다.
    final rotation = _rotationDeg;
    final rotated = rotation == 90 || rotation == 270;
    final orientedHeight = (rotated ? frame.width : frame.height).toDouble();

    return evaluateFaceGate(
      photoType: photoType,
      faceCount: faces.length,
      faceBox: face?.boundingBox,
      frameHeight: orientedHeight,
      yaw: face?.headEulerAngleY,
      pitch: face?.headEulerAngleX,
      roll: face?.headEulerAngleZ,
      // boundingBox 는 회전된 좌표계인데 plane.bytes 는 센서 좌표계다.
      // 되돌리지 않고 그대로 인덱싱하면 얼굴이 아닌 영역의 밝기를 재게 된다.
      luminanceOf: () => _faceLuminance(
        frame,
        _toSensorRect(face!.boundingBox, rotation, frame.width, frame.height),
      ),
    );
  }

  /// `InputImage.fromBytes` 는 **플랫폼마다 다른 포맷**을 요구한다. 그리고 어긋나도
  /// 예외가 안 난다 — 검출이 그냥 0개로 나와서 "얼굴을 찾을 수 없어요"만 계속 뜬다.
  /// 카메라는 멀쩡히 얼굴을 비추고 있는데. 원인을 게이트 조건에서 찾게 되는 실패다.
  ///
  /// CameraController 는 반드시 Android nv21 / iOS bgra8888 로 만든다.
  InputImage? _toInputImage(CameraImage frame) {
    final format = InputImageFormatValue.fromRawValue(frame.format.raw);
    if (format == null) return null;

    // 센서 방향을 안 넘기면 세로로 든 폰에서 얼굴이 90도 누운 채로 들어가고,
    // ML Kit 은 누운 얼굴을 잘 못 찾는다. 게이트가 상시 막히는 원인 1순위다.
    // (iOS 는 프레임이 이미 서서 오고 ML Kit 이 이 값을 보지도 않는다 — _rotationDeg 주석)
    final rotation = InputImageRotationValue.fromRawValue(_rotationDeg);
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

  @override
  Future<PreparedPhoto> prepareSkinPhoto(
    XFile original, {
    FacePhotoType photoType = FacePhotoType.front,
    bool fullGate = false,
  }) async {
    // 정지 이미지 1장이라 여유가 있다. 실시간 검출기와 옵션이 달라 따로 만든다.
    final still = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );

    try {
      // fromFilePath 는 EXIF 방향까지 알아서 처리한다.
      final faces =
          await still.processImage(InputImage.fromFilePath(original.path));

      final raw = img.decodeImage(await original.readAsBytes());
      if (raw == null) {
        // 디코딩을 못 하면 검증도 크롭도 못 한다. 원본을 그냥 올리지 않는다.
        return const PreparedPhoto(null, FaceGateUnavailable());
      }
      // ML Kit 은 EXIF 를 적용한 좌표를 주는데 decodeImage 는 EXIF 를 적용하지 않는다.
      // 굽지 않으면 세로로 찍은 사진에서 엉뚱한 영역이 잘려 그대로 서버로 간다.
      final photo = img.bakeOrientation(raw);

      final face = faces.isEmpty ? null : faces.first;
      final gate = fullGate
          ? evaluateFaceGate(
              photoType: photoType,
              faceCount: faces.length,
              faceBox: face?.boundingBox,
              frameHeight: photo.height.toDouble(),
              yaw: face?.headEulerAngleY,
              pitch: face?.headEulerAngleX,
              roll: face?.headEulerAngleZ,
              luminanceOf: () => _stillLuminance(photo, face!.boundingBox),
            )
          // 카메라 경로. 크기·방향·밝기는 방금 프리뷰에서 통과했다. 종횡비가 달라
          // 다시 재면 초록불을 보고 찍은 사용자가 빠져나갈 수 없게 된다.
          // 사진에 얼굴이 정확히 하나인지만 다시 확인하고 크롭한다.
          : _faceCountOnly(faces, face);

      // 통과하지 못하면 파일을 만들지 않는다 — 올릴 수 있는 경로 자체를 없앤다.
      if (gate is! FaceGateOk) return PreparedPhoto(null, gate);

      final cropped = _crop(photo, gate.faceRect);
      // 얼굴만 1024px → OpenAI detail:"high" 에서 실효 해상도가 3배 이상 올라간다.
      // 다만 키우지는 않는다 — 갤러리 원본은 PhotoPicker 가 이미 1024px·q80 으로
      // 줄여 놓아서, 거기서 잘라낸 얼굴을 1024로 늘리면 정보 없이 용량만 늘고
      // 압축이 두 번 먹는다.
      final resized = cropped.width >= 1024
          ? img.copyResize(cropped, width: 1024)
          : cropped;

      final path = '${File(original.path).parent.path}/skin_${original.name}';
      await File(path).writeAsBytes(img.encodeJpg(resized, quality: 80));
      return PreparedPhoto(XFile(path), gate);
    } finally {
      still.close(); // 안 닫으면 촬영할 때마다 네이티브 검출기가 쌓인다
    }
  }

  @override
  void dispose() => _detector.close();
}

/// 촬영 원본에 얼굴이 정확히 하나인지만 본다. 통과해도 원본을 올리지는 않는다 —
/// 호출부가 [FaceGateOk.faceRect] 로 크롭한다.
FaceGateResult _faceCountOnly(List<Face> faces, Face? face) {
  if (face == null) {
    return const FaceGateBlocked(
      FaceGateReason.noFace,
      '얼굴을 찾을 수 없어요.\n얼굴이 잘 보이도록 촬영해주세요.',
      FaceGateDebug(faceCount: 0),
    );
  }
  if (faces.length > 1) {
    return FaceGateBlocked(
      FaceGateReason.multipleFaces,
      '한 명의 얼굴만 나오도록 촬영해주세요.',
      FaceGateDebug(faceCount: faces.length),
    );
  }
  return FaceGateOk(
    withMargin(face.boundingBox, FaceGateConfig.faceMarginRatio),
    FaceGateDebug(
      faceCount: 1,
      yaw: face.headEulerAngleY,
      pitch: face.headEulerAngleX,
      roll: face.headEulerAngleZ,
    ),
  );
}

/// ML Kit 좌표(회전 적용됨) → 센서 좌표(plane.bytes 배열의 좌표).
///
/// 회전값이 90/270 이면 가로세로가 바뀐 공간이라, 되돌리지 않고 그대로
/// `row * bytesPerRow + col` 로 읽으면 전혀 다른 영역을 훑는다.
Rect _toSensorRect(Rect box, int rotationDeg, int width, int height) {
  Offset back(double mx, double my) => switch (rotationDeg) {
        90 => Offset(my, height - 1 - mx),
        180 => Offset(width - 1 - mx, height - 1 - my),
        270 => Offset(width - 1 - my, mx),
        _ => Offset(mx, my),
      };

  final a = back(box.left, box.top);
  final b = back(box.right, box.bottom);

  return Rect.fromLTRB(
    math.min(a.dx, b.dx),
    math.min(a.dy, b.dy),
    math.max(a.dx, b.dx),
    math.max(a.dy, b.dy),
  );
}

/// 여백을 붙인 사각형이 사진 밖으로 나갈 수 있다. 그대로 넘기면 copyCrop 이 던진다.
img.Image _crop(img.Image photo, Rect rect) {
  final left = rect.left.toInt().clamp(0, photo.width - 1);
  final top = rect.top.toInt().clamp(0, photo.height - 1);
  final right = rect.right.toInt().clamp(left + 1, photo.width);
  final bottom = rect.bottom.toInt().clamp(top + 1, photo.height);

  return img.copyCrop(photo,
      x: left, y: top, width: right - left, height: bottom - top);
}

/// 얼굴 영역 평균 휘도 **0~255**. 임계값 [FaceGateConfig.minLuminance] 와 같은 단위다.
///
/// Android(nv21) 는 planes[0] 이 곧 휘도(Y)라 그대로 읽으면 된다.
/// iOS(bgra8888) 는 인터리브라 픽셀마다 4바이트를 건너뛰며 Rec.601 로 만든다.
///
/// image 패키지로 img.Image 를 만들어 평균을 내면 매 프레임 전체 변환이 들어간다.
/// 1080p 면 프레임당 200만 픽셀을 Dart 에서 도는 셈이라 프리뷰 FPS 가 눈에 띄게 떨어진다.
/// 8픽셀 간격 샘플링이면 계산량이 1/64 이고, 조도 판정에는 차고 넘친다.
///
/// [face] 는 **센서 좌표계** 사각형이어야 한다. 프레임 밖으로 나간 부분은 잘라내므로
/// 바운딩 박스 밖 픽셀이 평균에 섞이지 않는다.
int _faceLuminance(CameraImage frame, Rect face, {int step = 8}) {
  final plane = frame.planes.first;
  final isBgra = frame.format.group == ImageFormatGroup.bgra8888;
  var sum = 0, count = 0;

  final top = face.top.toInt().clamp(0, frame.height - 1);
  final bottom = face.bottom.toInt().clamp(0, frame.height);
  final left = face.left.toInt().clamp(0, frame.width - 1);
  final right = face.right.toInt().clamp(0, frame.width);

  for (var row = top; row < bottom; row += step) {
    final rowStart = row * plane.bytesPerRow;
    for (var col = left; col < right; col += step) {
      if (isBgra) {
        final i = rowStart + col * 4; // B G R A
        if (i + 2 >= plane.bytes.length) continue;
        sum += (plane.bytes[i + 2] * 77 +
                plane.bytes[i + 1] * 150 +
                plane.bytes[i] * 29) >>
            8;
      } else {
        final i = rowStart + col; // Y 평면
        if (i >= plane.bytes.length) continue;
        sum += plane.bytes[i];
      }
      count++;
    }
  }
  // 샘플이 하나도 없으면 어두운 게 아니라 못 읽은 것이다. 밝기로 막지 않는다 —
  // 얼굴 개수·크기·방향은 이미 통과한 상태다.
  return count == 0 ? FaceGateConfig.minLuminance : sum ~/ count;
}

/// 정지 이미지용 휘도. 실시간 경로와 같은 0~255 · Rec.601 · 8px 샘플링을 쓴다.
int _stillLuminance(img.Image photo, Rect face, {int step = 8}) {
  var sum = 0, count = 0;

  final top = face.top.toInt().clamp(0, photo.height - 1);
  final bottom = face.bottom.toInt().clamp(0, photo.height);
  final left = face.left.toInt().clamp(0, photo.width - 1);
  final right = face.right.toInt().clamp(0, photo.width);

  for (var y = top; y < bottom; y += step) {
    for (var x = left; x < right; x += step) {
      final p = photo.getPixel(x, y);
      sum += (p.r.toInt() * 77 + p.g.toInt() * 150 + p.b.toInt() * 29) >> 8;
      count++;
    }
  }
  return count == 0 ? FaceGateConfig.minLuminance : sum ~/ count;
}
