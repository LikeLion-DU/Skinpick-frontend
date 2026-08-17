import 'dart:io' show File;
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:camera/camera.dart'
    show CameraDescription, CameraImage, ImageFormatGroup, XFile;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../../core/mlkit/camera_input_image.dart';
import '../../domain/captured_image_validator.dart';
import '../../domain/entities/face_gate_result.dart';
import '../../domain/face_gate_config.dart';
import '../../domain/face_gate_rules.dart';
import 'face_gate.dart';

FaceGate createFaceGate(CameraDescription camera) => MlKitFaceGate(camera);

/// ML Kit 은 **값을 뽑기만 한다.** 판정은 [evaluateFaceGate] 가 하고,
/// 피부 상태는 서버가 한다. 이 파일에서 피부에 대한 결론을 내리지 않는다.
///
/// `enableClassification: true` 는 **눈 뜸 확률 하나만** 쓰려고 켠다 — 감은 눈으로
/// 찍힌 사진을 걸러내기 위해서다. smilingProbability 로 트러블이나 홍조를 추정하는
/// 순간 "AI 는 인식, 로직은 Backend" 구조가 무너지므로, 그 값은 읽지도 않는다.
/// 게이트와 크롭까지가 전부다 (PRD §9.5).
///
/// `enableLandmarks: true` 는 **코 위치 하나만** 쓰려고 켠다. 화면 가이드가 코를
/// 기준으로 방향을 그리기 때문이다. **판정에는 쓰지 않는다** — 게이트 조건은
/// 여전히 박스·각도·밝기뿐이고, 코는 그리기 전용이다.
///
/// `enableContours` 는 계속 끈다. 윤곽선 132점은 어디에도 쓰지 않으면서
/// 프레임당 처리 시간만 크게 늘린다.
class MlKitFaceGate implements FaceGate {
  MlKitFaceGate(this._camera)
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast, // 실시간 프리뷰용
            enableLandmarks: true, // 코 위치만 쓴다 (가이드 렌더링)
            enableClassification: true, // 눈 뜸 확률만 쓴다
          ),
        );

  final CameraDescription _camera;
  final FaceDetector _detector;

  /// 거울상 프레임이면 -1. yaw 하나에만 곱한다.
  ///
  /// roll 도 미러링에서 부호가 뒤집히지만 판정은 `roll.abs()` 만 보므로 결과가
  /// 같다. pitch 는 좌우 반전과 무관하다. 건드리는 값을 늘리지 않는다.
  ///
  /// **[_camera] 가 진짜 카메라일 때만 의미가 있다.** 촬영 화면은 카메라를 열기
  /// 전에 `_stillOnlyCamera`(전면으로 선언된 자리표시자)로 이 게이트를 만든다 —
  /// 그 인스턴스는 iOS 에서 -1 을 갖지만 [check] 에 프레임이 들어오지 않아 쓰이지
  /// 않는다(카메라가 열리면 진짜 CameraDescription 으로 다시 만든다).
  /// 자리표시자 게이트로 라이브 프레임을 보게 고치면 좌/우가 뒤집힌다.
  late final double _yawSign = isMirroredStream(_camera) ? -1.0 : 1.0;


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
    final oriented = rotated
        ? Size(frame.height.toDouble(), frame.width.toDouble())
        : Size(frame.width.toDouble(), frame.height.toDouble());

    return evaluateFaceGate(
      photoType: photoType,
      faceCount: faces.length,
      // 좌우 안내와 오버레이 박스가 같이 걸려 있다. 거울상 여부를 여기서 흡수해
      // 판정 함수는 언제나 사용자 기준 좌표만 본다.
      faceBox: face == null
          ? null
          : toUserSpace(face.boundingBox, _camera, oriented.width),
      nose: _nose(face, _camera, oriented.width),
      frameSize: oriented,
      eyeOpen: _eyeOpen(face),
      // 거울상으로 들어온 프레임이면 **여기서** 사용자 기준으로 되돌린다.
      // 정지 이미지 경로(prepareSkinPhoto)는 뒤집히지 않아 곱하지 않는다.
      yaw: face?.headEulerAngleY == null
          ? null
          : face!.headEulerAngleY! * _yawSign,
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
      final raw = img.decodeImage(await original.readAsBytes());
      if (raw == null) {
        // 디코딩을 못 하면 검증도 크롭도 못 한다. 원본을 그냥 올리지 않는다.
        return const PreparedPhoto(null, FaceGateUnavailable());
      }
      // 세로로 찍은 사진은 EXIF 회전이 붙어 온다. 굽지 않으면 엉뚱한 영역이
      // 잘려 그대로 서버로 간다.
      final photo = img.bakeOrientation(raw);

      // **원본 파일을 ML Kit 에 그대로 넘기지 않는다.** 방금 구운 픽셀을 사본으로
      // 써서 넘긴다.
      //
      // iOS 의 `InputImage.fromFilePath` 는 `UIImage imageWithContentsOfFile:` 라
      // EXIF 해석을 ImageIO 에 맡기는데, `camera_avfoundation` 의 촬영본은
      // **1280x720 가로 래스터 + 회전 태그**이고 ImageIO 가 그 태그를 읽지 못한다
      // (APP1 EXIF 블록이 두 개다 — sips·mdls 도 orientation 을 못 본다).
      // 그래서 ML Kit 에는 90도 누운 얼굴이 들어가고, 검출이 조용히 0개가 된다.
      // 프리뷰는 통과했는데 촬영본에서만 "얼굴을 찾을 수 없어요" 로 막히는 게
      // 이것이다 — 실기기(iPhone 14 Pro / iOS 26.6)에서 확인했다.
      //
      // 사본을 쓰면 부수효과가 하나 더 있다. ML Kit 이 돌려주는 좌표계가
      // [photo] 와 **같은 버퍼**가 되어, 크롭이 어긋날 여지가 사라진다.
      // 예전에는 "ML Kit 은 EXIF 를 적용한 좌표를 준다"는 전제에 기대고 있었다.
      final upright =
          File('${File(original.path).parent.path}/upright_${original.name}');

      final List<Face> faces;
      try {
        // 쓰기도 try 안에 둔다. 밖에 두면 쓰다 실패했을 때(디스크 부족·샌드박스)
        // 반쪽짜리 파일이 남고, 그게 촬영할 때마다 하나씩 쌓인다.
        await upright.writeAsBytes(img.encodeJpg(photo, quality: 90));
        faces = await still.processImage(InputImage.fromFilePath(upright.path));
      } finally {
        // 검출에만 쓰는 중간 파일이다. 없으면 없는 대로 넘어간다.
        upright.delete().ignore();
      }

      final face = faces.isEmpty ? null : faces.first;

      // 이 경로에는 화면에 뜨는 디버그 오버레이가 없다. 프리뷰는 통과했는데
      // 촬영본에서만 막히면(실제로 iOS 에서 그렇게 나왔다) 볼 수 있는 값이
      // 하나도 없어서 원인이 라이브인지 정지인지조차 못 가른다.
      if (kDebugMode) {
        debugPrint('[SkinStill] faces=${faces.length} '
            'photo=${photo.width}x${photo.height} raw=${raw.width}x${raw.height} '
            'exif=${raw.exif.imageIfd.orientation} '
            'yaw=${face?.headEulerAngleY?.toStringAsFixed(1) ?? '-'} '
            'box=${face?.boundingBox.size}');
      }

      final gate = fullGate
          ? evaluateFaceGate(
              photoType: photoType,
              faceCount: faces.length,
              faceBox: face?.boundingBox,
              frameSize:
                  Size(photo.width.toDouble(), photo.height.toDouble()),
              yaw: face?.headEulerAngleY,
              pitch: face?.headEulerAngleX,
              roll: face?.headEulerAngleZ,
              // 이미 찍힌 사진에는 "조금 오른쪽으로 이동해주세요" 를 말할 수 없다.
              // 프리뷰 전용 조건(크기 상한·잘림·중앙 정렬)을 끄지 않으면 얼굴이
              // 한쪽에 있는 멀쩡한 셀카가 갤러리 경로에서 통째로 막힌다.
              liveGuidance: false,
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

      // 확인 화면은 **카메라 경로에서만** 뜬다. 갤러리는 사용자가 방금 피커에서
      // 고른 사진이라 확인 단계를 거치지 않으므로, 여기서 계산하면 아무도 안 보는
      // 목록을 만들자고 원본 전체를 한 번 더 훑게 된다(갤러리 경로는 게이트가
      // 이미 휘도를 쟀다). 막힌 경우에도 마찬가지라 통과한 뒤에만 만든다.
      final checks = fullGate
          ? const <PhotoCheck>[]
          : reviewCapturedPhoto(
              photoType: photoType,
              faceCount: faces.length,
              faceBox: face?.boundingBox,
              photoSize: Size(photo.width.toDouble(), photo.height.toDouble()),
              yaw: face?.headEulerAngleY,
              roll: face?.headEulerAngleZ,
              luminance: face == null
                  ? null
                  : _stillLuminance(photo, face.boundingBox),
            );

      return PreparedPhoto(XFile(path), gate, checks: checks);
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

/// 코 밑점의 위치. **그리기 전용이다 — 판정에 쓰지 않는다.**
///
/// 랜드마크를 못 읽는 기기·각도가 있다. 그때는 얼굴 박스 중심으로 대신한다 —
/// 가이드가 통째로 사라지는 것보다 조금 어긋나는 편이 낫다. 옆얼굴에서는 코가
/// 박스 가장자리로 가므로 정확한 랜드마크가 있을 때 값이 가장 크다.
Offset? _nose(Face? face, CameraDescription camera, double frameWidth) {
  if (face == null) return null;
  final point = face.landmarks[FaceLandmarkType.noseBase]?.position;
  final raw = point == null
      ? face.boundingBox.center
      : Offset(point.x.toDouble(), point.y.toDouble());

  // 박스와 같은 좌표계로 맞춘다. 하나만 뒤집으면 코가 반대쪽 뺨에 붙는다.
  return toUserSpacePoint(raw, camera, frameWidth);
}

/// 눈 뜸 확률 — **양쪽 중 큰 값**이다.
///
/// 측면 단계에서는 먼 쪽 눈이 얼굴에 가려 확률이 바닥으로 떨어진다. 두 눈을 모두
/// 요구하면 LEFT·RIGHT 촬영이 상시 막힌다. 둘 다 못 읽으면 null 이고, 판정은
/// 모르는 값으로 막지 않는다.
double? _eyeOpen(Face? face) {
  final left = face?.leftEyeOpenProbability;
  final right = face?.rightEyeOpenProbability;
  if (left == null) return right;
  if (right == null) return left;
  return math.max(left, right);
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
      '한 명의 얼굴만 나오도록 촬영해주세요.\n화면 밖 사람이나 배경 사진도 얼굴로 잡힐 수 있어요.',
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
