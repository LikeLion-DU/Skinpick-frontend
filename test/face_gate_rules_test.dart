import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_config.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_rules.dart';

/// 게이트 판정만 검증한다. ML Kit 도 카메라도 필요 없다 — 그러라고 순수 함수로 갈랐다.
void main() {
  const frame = Size(600, 1000);

  /// 높이 비율 [ratio] 짜리 얼굴 박스. 기본은 프레임 정중앙이고,
  /// [dx] · [dy] 로 프레임 크기 대비 비율만큼 밀어 놓는다.
  Rect box(double ratio, {double dx = 0, double dy = 0}) {
    final height = frame.height * ratio;
    return Rect.fromCenter(
      center: Offset(
        frame.width / 2 + frame.width * dx,
        frame.height / 2 + frame.height * dy,
      ),
      width: height * 0.75, // 사람 얼굴의 대략적인 가로세로비
      height: height,
    );
  }

  FaceGateResult run({
    FacePhotoType type = FacePhotoType.front,
    int faces = 1,
    double sizeRatio = 0.5,
    double dx = 0,
    double dy = 0,
    double? yaw = 0,
    double? roll = 0,
    double? pitch = 0,
    double? eyeOpen,
    bool liveGuidance = true,
    int luminance = 200,
    void Function()? onLuminanceRead,
  }) =>
      evaluateFaceGate(
        photoType: type,
        faceCount: faces,
        faceBox: faces == 0 ? null : box(sizeRatio, dx: dx, dy: dy),
        frameSize: frame,
        yaw: yaw,
        pitch: pitch,
        roll: roll,
        eyeOpen: eyeOpen,
        liveGuidance: liveGuidance,
        luminanceOf: () {
          onLuminanceRead?.call();
          return luminance;
        },
      );

  FaceGateReason? reasonOf(FaceGateResult r) =>
      r is FaceGateBlocked ? r.reason : null;

  String guideOf(FaceGateResult r) => (r as FaceGateBlocked).guide;

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
      expect(
          run(sizeRatio: FaceGateConfig.minFaceHeightRatio), isA<FaceGateOk>());
    });

    test('너무 크면 막는다 — 멀어지라고 안내한다', () {
      final result = run(sizeRatio: FaceGateConfig.maxFaceHeightRatio + 0.05);
      expect(reasonOf(result), FaceGateReason.tooBig);
      expect(guideOf(result), contains('멀어져'));
    });

    test('상한 이하는 통과한다', () {
      expect(
          run(sizeRatio: FaceGateConfig.maxFaceHeightRatio), isA<FaceGateOk>());
    });
  });

  group('조건 2-1 — 프레임 밖으로 잘림', () {
    test('오른쪽으로 밀려 잘리면 막는다', () {
      expect(reasonOf(run(sizeRatio: 0.5, dx: 0.4)),
          FaceGateReason.outOfFrame);
    });

    test('위로 밀려 잘리면 막는다', () {
      expect(reasonOf(run(sizeRatio: 0.5, dy: -0.4)),
          FaceGateReason.outOfFrame);
    });

    // 프레임 600 × 얼굴 가로 450(sizeRatio 0.6) 기준. 허용치는 600 × 0.02 = 12px.
    test('허용치 안쪽으로 삐져나간 정도는 봐준다 — 박스는 프레임마다 떨린다', () {
      // 오른쪽으로 9px 초과 — 허용치 12px 안이다.
      expect(run(sizeRatio: 0.6, dx: 0.14), isA<FaceGateOk>());
    });

    test('허용치를 넘어가면 막는다', () {
      // 오른쪽으로 15px 초과.
      expect(reasonOf(run(sizeRatio: 0.6, dx: 0.15)),
          FaceGateReason.outOfFrame);
    });
  });

  group('조건 3 — 중앙 정렬', () {
    test('왼쪽으로 치우치면 오른쪽으로 가라고 안내한다', () {
      final result = run(sizeRatio: 0.4, dx: -0.2);
      expect(reasonOf(result), FaceGateReason.offCenter);
      expect(guideOf(result), contains('오른쪽으로 이동'));
    });

    test('오른쪽으로 치우치면 왼쪽으로 가라고 안내한다', () {
      final result = run(sizeRatio: 0.4, dx: 0.2);
      expect(guideOf(result), contains('왼쪽으로 이동'));
    });

    test('위로 치우치면 아래로 가라고 안내한다', () {
      final result = run(sizeRatio: 0.4, dy: -0.2);
      expect(guideOf(result), contains('아래로 이동'));
    });

    test('아래로 치우치면 위로 가라고 안내한다', () {
      final result = run(sizeRatio: 0.4, dy: 0.2);
      expect(guideOf(result), contains('위로 이동'));
    });

    test('허용 범위 안이면 통과한다', () {
      expect(
        run(
          sizeRatio: 0.4,
          dx: FaceGateConfig.centerToleranceX - 0.01,
          dy: FaceGateConfig.centerToleranceY - 0.01,
        ),
        isA<FaceGateOk>(),
      );
    });

    test('가로세로가 같이 벗어나면 더 많이 벗어난 쪽만 말한다', () {
      // 대각선으로 움직이라고 하면 둘 다 놓친다.
      final result = run(sizeRatio: 0.4, dx: 0.25, dy: 0.18);
      expect(guideOf(result), contains('왼쪽으로 이동'));
      expect(guideOf(result), isNot(contains('위로')));
    });

    // 화면 위 위치(어디에 있나)와 얼굴 방향(어디를 보나)은 별개의 조건이다.
    // 고개를 돌리면 얼굴은 제자리여도 박스가 밀리는데, 그걸 "치우쳤다"고
    // 안내하면 시키는 대로 돌린 사용자가 옆으로 움직이게 된다.
    group('측면 단계에서는 중앙 정렬로 막지 않는다', () {
      const turned = FaceGateConfig.sideMinYaw + 5;
      const userLeft = turned * FaceGateConfig.userLeftYawSign;

      test('LEFT — 회전 때문에 박스가 밀려도 통과한다', () {
        expect(
          run(type: FacePhotoType.left, yaw: userLeft, sizeRatio: 0.4, dx: 0.25),
          isA<FaceGateOk>(),
        );
      });

      test('RIGHT — 반대 방향도 같다', () {
        expect(
          run(
              type: FacePhotoType.right,
              yaw: -userLeft,
              sizeRatio: 0.4,
              dx: -0.25),
          isA<FaceGateOk>(),
        );
      });

      test('측면에서 밀렸으면 방향 안내가 나온다 — 이동 안내가 아니라', () {
        final result =
            run(type: FacePhotoType.left, yaw: 0, sizeRatio: 0.4, dx: 0.25);
        expect(reasonOf(result), FaceGateReason.wrongOrientation);
        expect(guideOf(result), contains('왼쪽으로 조금 더 돌려'));
      });

      test('프레임 밖으로 잘리는 것은 측면에서도 그대로 막는다', () {
        expect(
          reasonOf(run(
              type: FacePhotoType.left, yaw: userLeft, sizeRatio: 0.5, dx: 0.4)),
          FaceGateReason.outOfFrame,
        );
      });

      test('정면에서는 중앙 정렬을 계속 본다 — 측면 때문에 풀어주지 않는다', () {
        expect(reasonOf(run(type: FacePhotoType.front, sizeRatio: 0.4, dx: 0.25)),
            FaceGateReason.offCenter);
      });
    });
  });

  group('조건 4 — 얼굴 방향', () {
    // 사용자 기준 좌/우를 ML Kit yaw 로 환산한다. 부호는 전면 카메라 미러 처리에
    // 따라 달라지는 **기기 특성**이지 규칙이 아니다. 여기에 숫자를 박아두면
    // 실기기에서 부호를 뒤집는 순간 멀쩡한 규칙 테스트가 같이 깨진다.
    const turned = FaceGateConfig.sideMinYaw + 5; // 확실히 돌린 각도
    const userLeft = turned * FaceGateConfig.userLeftYawSign;
    const userRight = -userLeft;

    test('FRONT + 정면 → 통과', () {
      expect(run(type: FacePhotoType.front, yaw: 0), isA<FaceGateOk>());
    });

    test('FRONT + 좌측 → 막힘', () {
      expect(reasonOf(run(type: FacePhotoType.front, yaw: userLeft)),
          FaceGateReason.wrongOrientation);
    });

    test('FRONT + 우측 → 막힘', () {
      expect(reasonOf(run(type: FacePhotoType.front, yaw: userRight)),
          FaceGateReason.wrongOrientation);
    });

    test('FRONT + 고개 기울임 → 막힘', () {
      final result = run(
          type: FacePhotoType.front, roll: FaceGateConfig.frontMaxRoll + 5);
      expect(reasonOf(result), FaceGateReason.wrongOrientation);
      expect(guideOf(result), contains('기울이지'));
    });

    test('LEFT + 좌측 → 통과', () {
      expect(run(type: FacePhotoType.left, yaw: userLeft), isA<FaceGateOk>());
    });

    test('LEFT + 정면 → 막힘 (조금 더 돌리라고 안내)', () {
      final result = run(type: FacePhotoType.left, yaw: 0);
      expect(reasonOf(result), FaceGateReason.wrongOrientation);
      expect(guideOf(result), contains('왼쪽으로 조금 더'));
    });

    test('LEFT + 우측 → 막힘 (반대쪽이라고 안내)', () {
      expect(guideOf(run(type: FacePhotoType.left, yaw: userRight)),
          contains('왼쪽 얼굴을'));
    });

    test('RIGHT + 우측 → 통과', () {
      expect(run(type: FacePhotoType.right, yaw: userRight), isA<FaceGateOk>());
    });

    test('RIGHT + 정면 → 막힘 (조금 더 돌리라고 안내)', () {
      expect(guideOf(run(type: FacePhotoType.right, yaw: 0)),
          contains('오른쪽으로 조금 더'));
    });

    test('RIGHT + 좌측 → 막힘 (반대쪽이라고 안내)', () {
      expect(guideOf(run(type: FacePhotoType.right, yaw: userLeft)),
          contains('오른쪽 얼굴을'));
    });

    test('yaw 를 못 읽는 기기에서는 방향으로 막지 않는다', () {
      expect(run(yaw: null), isA<FaceGateOk>());
    });
  });

  group('조건 5 — 눈', () {
    test('감고 있으면 막는다', () {
      final result =
          run(eyeOpen: FaceGateConfig.eyeOpenThreshold - 0.1);
      expect(reasonOf(result), FaceGateReason.eyesClosed);
      expect(guideOf(result), contains('눈을 뜬'));
    });

    test('뜨고 있으면 통과한다', () {
      expect(run(eyeOpen: 0.9), isA<FaceGateOk>());
    });

    test('확률을 못 읽으면 막지 않는다 — 모르는 값으로 게이트를 닫지 않는다', () {
      expect(run(eyeOpen: null), isA<FaceGateOk>());
    });
  });

  group('조건 6 — 휘도', () {
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

      run(sizeRatio: 0.4, dx: 0.3, onLuminanceRead: () => read = true);
      expect(read, isFalse);

      run(type: FacePhotoType.front, yaw: 90, onLuminanceRead: () => read = true);
      expect(read, isFalse);

      run(eyeOpen: 0.0, onLuminanceRead: () => read = true);
      expect(read, isFalse);
    });
  });

  group('안내 우선순위 — 한 번에 하나만 말한다', () {
    test('작으면서 중앙에서도 벗어났으면 "가까이" 를 먼저 말한다', () {
      final result = run(sizeRatio: 0.2, dx: 0.3);
      expect(reasonOf(result), FaceGateReason.tooSmall);
    });

    test('크면서 잘렸으면 "멀어져" 를 먼저 말한다 — 무엇을 하라는 말인지가 분명하다', () {
      final result = run(sizeRatio: 0.9, dx: 0.2);
      expect(reasonOf(result), FaceGateReason.tooBig);
    });
  });

  group('정지 이미지 경로 (liveGuidance: false)', () {
    // 이미 찍힌 사진에 "조금 오른쪽으로 이동해주세요" 를 말할 수 없다.
    test('중앙에서 벗어나도 통과한다', () {
      expect(run(sizeRatio: 0.4, dx: 0.35, liveGuidance: false),
          isA<FaceGateOk>());
    });

    test('얼굴이 커도 통과한다', () {
      expect(run(sizeRatio: 0.9, liveGuidance: false), isA<FaceGateOk>());
    });

    test('크기·방향·밝기는 그대로 본다', () {
      expect(reasonOf(run(sizeRatio: 0.1, liveGuidance: false)),
          FaceGateReason.tooSmall);
      expect(reasonOf(run(yaw: 90, liveGuidance: false)),
          FaceGateReason.wrongOrientation);
      expect(reasonOf(run(luminance: 10, liveGuidance: false)),
          FaceGateReason.tooDark);
    });
  });

  group('통과 결과', () {
    test('얼굴 박스에 여백을 붙여 돌려준다', () {
      final result = run() as FaceGateOk;
      final face = box(0.5);
      const margin = FaceGateConfig.faceMarginRatio;

      expect(result.faceRect.left, face.left - face.width * margin);
      expect(result.faceRect.top, face.top - face.height * margin);
      expect(result.faceRect.width, closeTo(face.width * (1 + margin * 2), 1e-9));
    });

    test('디버그 값이 채워진다 (§22 오버레이용)', () {
      final result =
          run(yaw: 3, pitch: 2, roll: 1, eyeOpen: 0.8, luminance: 123)
              as FaceGateOk;
      expect(result.debug.faceCount, 1);
      expect(result.debug.yaw, 3);
      expect(result.debug.faceHeightRatio, 0.5);
      expect(result.debug.eyeOpen, 0.8);
      expect(result.debug.luminance, 123);
    });

    test('막힌 결과에도 얼굴 박스가 실려 온다 — 막힌 동안에도 오버레이를 그린다', () {
      final result = run(sizeRatio: 0.1);
      expect(result.faceBox, isNotNull);
      expect(result.frameSize, frame);
    });

    test('얼굴이 없으면 박스도 없다', () {
      expect(run(faces: 0).faceBox, isNull);
    });
  });
}
