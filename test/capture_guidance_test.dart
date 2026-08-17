import 'dart:io' show Platform;
import 'dart:ui' show Rect, Size;

import 'package:camera/camera.dart'
    show CameraDescription, CameraLensDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/camera/preview_fit.dart';
import 'package:skinplate/core/mlkit/camera_input_image.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_config.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_rules.dart';

/// 촬영 가능 판정(안정화)과 좌표 변환. 둘 다 순수 함수라 카메라가 필요 없다.
void main() {
  const debug = FaceGateDebug(faceCount: 1);
  const ok = FaceGateOk(Rect.fromLTWH(0, 0, 10, 10), debug);
  const blocked =
      FaceGateBlocked(FaceGateReason.tooSmall, '얼굴이 너무 작아요.', debug);

  group('안정화 — 한 프레임 통과로는 셔터를 켜지 않는다', () {
    test('판정 전에는 촬영 불가', () {
      expect(readinessOf(null, 0), CaptureReadiness.invalid);
    });

    test('막힌 프레임은 촬영 불가', () {
      expect(readinessOf(blocked, 0), CaptureReadiness.invalid);
    });

    test('막히지 않았어도 아직 유지 중이면 촬영 불가', () {
      for (var streak = 1; streak < FaceGateConfig.stableFrames; streak++) {
        expect(readinessOf(ok, streak), CaptureReadiness.validating,
            reason: 'streak=$streak');
      }
    });

    test('연속으로 유지되면 촬영 가능', () {
      expect(readinessOf(ok, FaceGateConfig.stableFrames),
          CaptureReadiness.ready);
      expect(readinessOf(ok, FaceGateConfig.stableFrames + 5),
          CaptureReadiness.ready);
    });

    test('한 프레임이라도 막히면 처음부터 다시 센다', () {
      // 화면이 하는 일과 같다 — 통과하면 +1, 막히면 0.
      var streak = 0;
      CaptureReadiness feed(FaceGateResult result) {
        streak = result is FaceGateOk ? streak + 1 : 0;
        return readinessOf(result, streak);
      }

      for (var i = 0; i < FaceGateConfig.stableFrames - 1; i++) {
        expect(feed(ok), CaptureReadiness.validating);
      }
      // 스쳐 지나가듯 한 프레임 어긋났다 → 되돌아간다
      expect(feed(blocked), CaptureReadiness.invalid);
      expect(feed(ok), CaptureReadiness.validating);
    });

    test('통과 상태여도 스트릭이 0 이면 아직 준비가 아니다', () {
      expect(readinessOf(ok, 0), CaptureReadiness.invalid);
    });
  });

  group('프리뷰 좌표 변환 (BoxFit.cover)', () {
    // 세로로 긴 프레임을 더 세로로 긴 화면에 채우면 좌우가 잘린다.
    const frame = Size(720, 1280);
    const widget = Size(400, 800); // 프레임보다 세로로 길다

    test('프레임 중앙의 점은 화면 중앙에 온다', () {
      final mapped = coverPointToWidget(
          Offset(frame.width / 2, frame.height / 2), frame, widget);
      expect(mapped.dx, closeTo(widget.width / 2, 0.001));
      expect(mapped.dy, closeTo(widget.height / 2, 0.001));
    });

    test('꽉 채운 뒤 잘리므로 가로 양끝은 화면 밖으로 나간다', () {
      final left = coverPointToWidget(const Offset(0, 0), frame, widget);
      final right = coverPointToWidget(Offset(frame.width, 0), frame, widget);

      expect(left.dx, lessThan(0));
      expect(right.dx, greaterThan(widget.width));
      // 잘려나간 만큼 좌우로 **같이** 밀린다 — 한쪽만 밀리면 얼굴이 어긋난다.
      expect(left.dx, closeTo(widget.width - right.dx, 0.001));
    });

    test('세로는 꽉 맞는다 — 이 프레임에서는 위아래가 잘리지 않는다', () {
      expect(coverPointToWidget(const Offset(0, 0), frame, widget).dy,
          closeTo(0, 0.001));
      expect(coverPointToWidget(Offset(0, frame.height), frame, widget).dy,
          closeTo(widget.height, 0.001));
    });

    test('가로세로 배율이 같다 — 다르면 얼굴이 늘어난 채로 그려진다', () {
      final origin = coverPointToWidget(const Offset(100, 100), frame, widget);
      final moved = coverPointToWidget(const Offset(300, 300), frame, widget);
      expect(moved.dx - origin.dx, closeTo(moved.dy - origin.dy, 0.001));
    });

    test('배율은 넘치는 쪽 기준이다 — 작은 쪽을 쓰면 화면에 빈 띠가 생긴다', () {
      expect(coverScale(frame, widget),
          closeTo(widget.height / frame.height, 0.001));
    });

    test('프레임 크기를 모르면 그대로 돌려준다 — 0 으로 나누지 않는다', () {
      const point = Offset(1, 2);
      expect(coverPointToWidget(point, Size.zero, widget), point);
      expect(coverScale(Size.zero, widget), 1.0);
    });
  });

  group('플랫폼 좌표계 — 전면 카메라 미러', () {
    const front = CameraDescription(
      name: 'front',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 90,
    );
    const back = CameraDescription(
      name: 'back',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    );

    const frameWidth = 720.0;
    const left = Rect.fromLTWH(50, 100, 200, 300); // 프레임 왼쪽에 있는 얼굴

    test('후면 카메라는 뒤집지 않는다', () {
      expect(toUserSpace(left, back, frameWidth), left);
    });

    test('두 번 뒤집으면 제자리 — 변환이 대칭이다', () {
      final once = toUserSpace(left, front, frameWidth);
      final twice = toUserSpace(once, front, frameWidth);
      expect(twice, left);
    });

    test('스트림이 거울상이 아니면 좌우를 뒤집는다 (Android 전면)', () {
      // 테스트는 데스크톱에서 돌아 Platform.isIOS 가 false 다 —
      // isMirroredStream 이 false 이므로 Android 전면과 같은 경로를 탄다.
      expect(isMirroredStream(front), isFalse);

      final flipped = toUserSpace(left, front, frameWidth);
      expect(flipped.left, frameWidth - left.right); // 50 → 470
      expect(flipped.right, frameWidth - left.left);
      // 세로는 건드리지 않는다. 미러는 좌우만 뒤집는다.
      expect(flipped.top, left.top);
      expect(flipped.bottom, left.bottom);
    });

    test('iOS 전면은 스트림이 이미 거울상이라 그대로 쓴다', () {
      // 실기기에서만 참인 분기라 계약만 못 박아 둔다.
      expect(isMirroredStream(front), Platform.isIOS);
    });

    // 코와 박스가 **같은 좌표계**여야 한다. 하나만 뒤집으면 가이드가 반대쪽
    // 뺨에 붙은 채로 그려지고, 화면은 얼굴을 잡고 있는데 안내는 엉뚱해진다.
    test('코 점과 얼굴 박스가 같은 방향으로 옮겨진다', () {
      for (final camera in [front, back]) {
        expect(
          toUserSpacePoint(left.center, camera, frameWidth),
          toUserSpace(left, camera, frameWidth).center,
          reason: camera.name,
        );
      }
    });

    test('코 점도 두 번 뒤집으면 제자리다', () {
      const nose = Offset(180, 260);
      final once = toUserSpacePoint(nose, front, frameWidth);
      expect(toUserSpacePoint(once, front, frameWidth), nose);
      expect(once.dy, nose.dy); // 세로는 안 건드린다
    });

    test('세로 화면에서 센서가 90/270도면 가로세로가 바뀐 좌표계다', () {
      expect(isRotatedQuarter(90), isTrue);
      expect(isRotatedQuarter(270), isTrue);
      expect(isRotatedQuarter(0), isFalse);
      expect(isRotatedQuarter(180), isFalse);
    });
  });
}
