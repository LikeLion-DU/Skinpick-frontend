import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_config.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_rules.dart';

/// 게이트 판정만 검증한다. ML Kit 도 카메라도 필요 없다 — 그러라고 순수 함수로 갈랐다.
void main() {
  const frameHeight = 1000.0;

  /// 높이 비율 [ratio] 짜리 얼굴 박스
  Rect box(double ratio) =>
      Rect.fromLTWH(100, 100, 400, frameHeight * ratio);

  FaceGateResult run({
    FacePhotoType type = FacePhotoType.front,
    int faces = 1,
    double sizeRatio = 0.5,
    double? yaw = 0,
    double? roll = 0,
    double? pitch = 0,
    int luminance = 200,
    void Function()? onLuminanceRead,
  }) =>
      evaluateFaceGate(
        photoType: type,
        faceCount: faces,
        faceBox: faces == 0 ? null : box(sizeRatio),
        frameHeight: frameHeight,
        yaw: yaw,
        pitch: pitch,
        roll: roll,
        luminanceOf: () {
          onLuminanceRead?.call();
          return luminance;
        },
      );

  FaceGateReason? reasonOf(FaceGateResult r) =>
      r is FaceGateBlocked ? r.reason : null;

  group('조건 1 — 얼굴 개수', () {
    test('얼굴 없음은 막는다', () {
      expect(reasonOf(run(faces: 0)), FaceGateReason.noFace);
    });

    test('얼굴 1개는 통과한다', () {
      expect(run(faces: 1), isA<FaceGateOk>());
    });

    test('얼굴 2개 이상은 막는다 — 가장 큰 얼굴을 골라 통과시키지 않는다', () {
      expect(reasonOf(run(faces: 2)), FaceGateReason.multipleFaces);
      expect(reasonOf(run(faces: 5)), FaceGateReason.multipleFaces);
    });
  });

  group('조건 2 — 얼굴 크기', () {
    test('임계값 미만은 막는다', () {
      expect(
        reasonOf(run(sizeRatio: FaceGateConfig.minFaceHeightRatio - 0.05)),
        FaceGateReason.tooSmall,
      );
    });

    test('임계값 이상은 통과한다', () {
      expect(run(sizeRatio: FaceGateConfig.minFaceHeightRatio), isA<FaceGateOk>());
    });
  });

  group('조건 3 — 얼굴 방향', () {
    const side = FaceGateConfig.sideMinYaw + 5; // 확실히 돌린 각도

    test('FRONT + 정면 → 통과', () {
      expect(run(type: FacePhotoType.front, yaw: 0), isA<FaceGateOk>());
    });

    test('FRONT + 좌측 → 막힘', () {
      expect(reasonOf(run(type: FacePhotoType.front, yaw: side)),
          FaceGateReason.wrongOrientation);
    });

    test('FRONT + 우측 → 막힘', () {
      expect(reasonOf(run(type: FacePhotoType.front, yaw: -side)),
          FaceGateReason.wrongOrientation);
    });

    test('LEFT + 좌측 → 통과', () {
      expect(run(type: FacePhotoType.left, yaw: side), isA<FaceGateOk>());
    });

    test('LEFT + 정면 → 막힘 (조금 더 돌리라고 안내)', () {
      final result = run(type: FacePhotoType.left, yaw: 0);
      expect(reasonOf(result), FaceGateReason.wrongOrientation);
      expect((result as FaceGateBlocked).guide, contains('왼쪽으로 조금 더'));
    });

    test('LEFT + 우측 → 막힘 (반대쪽이라고 안내)', () {
      final result = run(type: FacePhotoType.left, yaw: -side);
      expect((result as FaceGateBlocked).guide, contains('왼쪽 얼굴을'));
    });

    test('RIGHT + 우측 → 통과', () {
      expect(run(type: FacePhotoType.right, yaw: -side), isA<FaceGateOk>());
    });

    test('RIGHT + 정면 → 막힘 (조금 더 돌리라고 안내)', () {
      final result = run(type: FacePhotoType.right, yaw: 0);
      expect((result as FaceGateBlocked).guide, contains('오른쪽으로 조금 더'));
    });

    test('RIGHT + 좌측 → 막힘 (반대쪽이라고 안내)', () {
      final result = run(type: FacePhotoType.right, yaw: side);
      expect((result as FaceGateBlocked).guide, contains('오른쪽 얼굴을'));
    });

    test('yaw 를 못 읽는 기기에서는 방향으로 막지 않는다', () {
      expect(run(yaw: null), isA<FaceGateOk>());
    });
  });

  group('조건 4 — 휘도', () {
    test('너무 어두우면 막는다', () {
      expect(reasonOf(run(luminance: FaceGateConfig.minLuminance - 1)),
          FaceGateReason.tooDark);
    });

    test('임계값 이상이면 통과한다', () {
      expect(run(luminance: FaceGateConfig.minLuminance), isA<FaceGateOk>());
    });

    test('앞 조건에서 막히면 픽셀을 읽지 않는다 — 프리뷰 FPS 가 여기 달려 있다', () {
      var read = false;
      run(faces: 0, onLuminanceRead: () => read = true);
      expect(read, isFalse);

      run(sizeRatio: 0.1, onLuminanceRead: () => read = true);
      expect(read, isFalse);

      run(type: FacePhotoType.front, yaw: 90, onLuminanceRead: () => read = true);
      expect(read, isFalse);
    });
  });

  group('통과 결과', () {
    test('얼굴 박스에 여백을 붙여 돌려준다', () {
      final result = run() as FaceGateOk;
      final face = box(0.5);
      const margin = FaceGateConfig.faceMarginRatio;

      expect(result.faceRect.left, face.left - face.width * margin);
      expect(result.faceRect.top, face.top - face.height * margin);
      expect(result.faceRect.width, face.width * (1 + margin * 2));
    });

    test('디버그 값이 채워진다 (§22 오버레이용)', () {
      final result = run(yaw: 3, pitch: 2, roll: 1, luminance: 123) as FaceGateOk;
      expect(result.debug.faceCount, 1);
      expect(result.debug.yaw, 3);
      expect(result.debug.faceHeightRatio, 0.5);
      expect(result.debug.luminance, 123);
    });
  });
}
