import 'dart:io' show File;
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:camera/camera.dart'
    show CameraDescription, CameraImage, ImageFormatGroup, XFile;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../../core/mlkit/camera_input_image.dart';
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


  @override
  Future<FaceGateResult> check(CameraImage frame, FacePhotoType photoType) async {
    final input = toInputImage(frame, _camera);
    // 포맷을 못 읽으면 검증을 할 수 없다. 통과시키지 않는다.
    if (input == null) return const FaceGateUnavailable();

    final faces = await _detector.processImage(input);
    final face = faces.isEmpty ? null : faces.first;

    // 센서가 90/270도 돌아 있으면 ML Kit 좌표계는 가로세로가 바뀐 상태다.
    // 여기서 안 맞추면 얼굴 크기 비율이 통째로 틀어져 "조금 더 가까이"만 계속 뜬다.
    final rotation = rotationDegreesOf(_camera);
    final rotated = isRotatedQuarter(rotation);
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
      // 크롭만으로도 얼굴의 실효 해상도는 크게 올라간다 — 전체 프레임을 보내면
      // 얼굴이 200px 남짓인데, 잘라내면 그게 곧 이미지 전체가 된다.
      //
      // 다만 **1024px 를 채우지는 못한다.** ResolutionPreset.high 가 1280×720 이라
      // takePicture 원본도 그 크기이고, 얼굴 박스는 프레임의 절반 남짓이라
      // 크롭 결과가 400~600px 에 머문다. 아래 분기는 사실상 타지 않는다.
      // 1024 를 실제로 채우려면 프리셋을 veryHigh 이상으로 올려야 하는데,
      // 같은 컨트롤러가 실시간 스트림도 물고 있어서 ML Kit 처리량과 맞바꿔야 한다.
      // 기능 동결 전에 성능을 다시 재지 않고 올리지 않는다.
      //
      // 키우지는 않는다 — 없는 정보를 만들어내지 못하면서 용량만 늘고 압축이
      // 두 번 먹는다.
      final resized = cropped.width >= 1024
          ? img.copyResize(cropped, width: 1024)
          : cropped;

      final path = '${File(original.path).parent.path}/skin_${original.name}';
      await File(path).writeAsBytes(img.encodeJpg(resized, quality: 80));
      return PreparedPhoto(XFile(path), gate);
    } finally {
      // 기다리지 않으면 네이티브 검출기가 아직 살아 있는 채로 함수가 끝나고,
      // 닫다가 난 오류는 미처리 비동기 예외가 된다.
      await still.close();
    }
  }

  @override
  void dispose() {
    // prepareSkinPhoto 는 close 를 기다리지만 여기서는 기다릴 수 없다(State.dispose).
    // 그대로 두면 플랫폼 채널 실패가 미처리 zone 오류로 올라온다.
    _detector.close().ignore();
  }
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
