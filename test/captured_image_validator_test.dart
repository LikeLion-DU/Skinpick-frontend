import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/domain/captured_image_validator.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_config.dart';

/// 촬영본 확인 화면에 늘어놓는 항목들. **관문이 아니다** — 여기 경고가 있어도
/// 업로드는 사용자가 [다음] 을 누르면 그대로 진행된다.
void main() {
  const photo = Size(600, 1000);

  Rect box(double ratio, {double dx = 0, double dy = 0}) {
    final height = photo.height * ratio;
    return Rect.fromCenter(
      center: Offset(photo.width / 2 + photo.width * dx,
          photo.height / 2 + photo.height * dy),
      width: height * 0.75,
      height: height,
    );
  }

  List<PhotoCheck> run({
    FacePhotoType type = FacePhotoType.front,
    int faces = 1,
    double sizeRatio = 0.45,
    double dx = 0,
    double dy = 0,
    double? yaw = 0,
    double? roll = 0,
    int? luminance = 200,
  }) =>
      reviewCapturedPhoto(
        photoType: type,
        faceCount: faces,
        faceBox: faces == 0 ? null : box(sizeRatio, dx: dx, dy: dy),
        photoSize: photo,
        yaw: yaw,
        roll: roll,
        luminance: luminance,
      );

  PhotoCheck of(List<PhotoCheck> checks, String label) =>
      checks.firstWhere((c) => c.label == label);

  bool has(List<PhotoCheck> checks, String label) =>
      checks.any((c) => c.label == label);

  group('전부 정상이면 경고가 없다', () {
    test('정면', () {
      final checks = run();
      expect(checks.every((c) => c.state == PhotoCheckState.ok), isTrue,
          reason: checks.map((c) => '${c.label}=${c.state}').join(', '));
    });

    test('측면', () {
      const yaw = (FaceGateConfig.sideMinYaw + 5) *
          FaceGateConfig.userLeftYawSign;
      final checks = run(type: FacePhotoType.left, yaw: yaw);
      expect(checks.every((c) => c.state == PhotoCheckState.ok), isTrue);
    });
  });

  group('얼굴', () {
    test('못 찾으면 그 한 줄만 돌려준다 — 나머지는 잴 근거가 없다', () {
      final checks = run(faces: 0);
      expect(checks, hasLength(1));
      expect(checks.single.state, PhotoCheckState.warn);
    });

    test('여러 명이면 경고한다', () {
      expect(of(run(faces: 2), '얼굴 인식').state, PhotoCheckState.warn);
    });
  });

  group('크기 · 잘림 · 위치', () {
    test('작으면 경고', () {
      expect(of(run(sizeRatio: 0.2), '얼굴 크기').state, PhotoCheckState.warn);
    });

    test('너무 가까우면 경고', () {
      expect(of(run(sizeRatio: 0.8), '얼굴 크기').state, PhotoCheckState.warn);
    });

    test('사진 밖으로 나갔으면 경고', () {
      expect(of(run(sizeRatio: 0.5, dx: 0.4), '얼굴 잘림').state,
          PhotoCheckState.warn);
    });

    // 업로드하는 것은 얼굴 박스를 잘라낸 이미지라, 잘린 뒤에는 얼굴이 언제나
    // 가운데다. 자를 원본에서 치우쳤다고 알려 봐야 사용자가 보고 있는 사진과
    // 어긋나기만 한다 — 반듯하게 잘린 사진 밑에 "가운데에서 벗어났어요" 가 뜬다.
    test('위치는 항목에 없다 — 결과물은 얼굴 기준으로 잘려 있다', () {
      expect(has(run(dx: 0.4), '얼굴 위치'), isFalse);
    });

    test('그래도 잘림은 본다 — 크롭이 경계에 물리면 결과물에 그대로 보인다', () {
      expect(of(run(sizeRatio: 0.5, dx: 0.4), '얼굴 잘림').state,
          PhotoCheckState.warn);
    });
  });

  group('각도', () {
    test('정면인데 돌아가 있으면 경고', () {
      expect(of(run(yaw: 40), '얼굴 각도').state, PhotoCheckState.warn);
    });

    test('정면인데 기울어져 있으면 경고', () {
      expect(
          of(run(roll: FaceGateConfig.frontMaxRoll + 10), '얼굴 각도').state,
          PhotoCheckState.warn);
    });

    test('측면인데 덜 돌렸으면 경고', () {
      expect(of(run(type: FacePhotoType.left, yaw: 0), '얼굴 각도').state,
          PhotoCheckState.warn);
    });

    test('각도를 못 읽으면 확인 불가다 — ✓ 로 그리지 않는다', () {
      expect(of(run(yaw: null), '얼굴 각도').state, PhotoCheckState.unknown);
    });
  });

  group('조명', () {
    test('어두우면 경고', () {
      expect(of(run(luminance: 10), '조명').state, PhotoCheckState.warn);
    });

    test('못 쟀으면 확인 불가', () {
      expect(of(run(luminance: null), '조명').state, PhotoCheckState.unknown);
    });
  });

  group('없는 항목을 있는 척하지 않는다', () {
    // ML Kit Face Detection 이 주지 않는 값들이다. 목록에 ✓ 로 올리면 사용자는
    // 확인받았다고 믿는다. 별도 이미지 품질 분석이 붙기 전까지는 넣지 않는다.
    test('이마 · 머리카락 · 흔들림 · 노출은 항목에 없다', () {
      final labels = run().map((c) => c.label).toList();
      for (final absent in ['이마', '머리카락', '흔들림', '노출']) {
        expect(labels.any((l) => l.contains(absent)), isFalse, reason: absent);
      }
    });

    test('대신 확인 못 한다고 화면에 적는다', () {
      expect(capturedPhotoBlindSpots, contains('이마'));
      expect(capturedPhotoBlindSpots, contains('흔들'));
    });
  });

  group('임계값은 게이트와 같은 것을 쓴다', () {
    // 같은 조건이 화면마다 다른 숫자를 쓰면 "아까는 통과였는데" 가 생긴다.
    test('크기 하한이 게이트와 같다', () {
      expect(of(run(sizeRatio: FaceGateConfig.minFaceHeightRatio), '얼굴 크기').state,
          PhotoCheckState.ok);
      expect(
          of(run(sizeRatio: FaceGateConfig.minFaceHeightRatio - 0.01), '얼굴 크기')
              .state,
          PhotoCheckState.warn);
    });

    test('조명 하한이 게이트와 같다', () {
      expect(of(run(luminance: FaceGateConfig.minLuminance), '조명').state,
          PhotoCheckState.ok);
      expect(of(run(luminance: FaceGateConfig.minLuminance - 1), '조명').state,
          PhotoCheckState.warn);
    });
  });
}
