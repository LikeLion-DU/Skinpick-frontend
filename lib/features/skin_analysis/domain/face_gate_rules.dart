import 'dart:ui' show Rect;

import 'entities/face_gate_result.dart';
import 'face_gate_config.dart';

/// 게이트 판정. **순수 함수다 — ML Kit 도 카메라도 모른다.**
///
/// 설계서 §2.12 는 이 로직을 ML Kit 구현 파일 안에 두었지만, 그러면 판정을
/// 검증하려면 네이티브 플러그인이 필요해져서 방향 판정 9종을 테스트할 수 없다.
/// 값을 뽑는 일(ML Kit)과 판정하는 일(여기)을 갈라 두면 양쪽 다 짧아진다.
///
/// [luminanceOf] 는 지연 계산이다. 앞 조건에서 막히면 픽셀을 한 번도 읽지 않는다 —
/// 실시간 프리뷰에서 프레임마다 얼굴 영역을 훑는 비용이 그대로 FPS 로 나온다.
FaceGateResult evaluateFaceGate({
  required FacePhotoType photoType,
  required int faceCount,
  required Rect? faceBox,
  required double frameHeight,
  required double? yaw,
  required double? pitch,
  required double? roll,
  required int Function() luminanceOf,
}) {
  final base = FaceGateDebug(
    faceCount: faceCount,
    yaw: yaw,
    pitch: pitch,
    roll: roll,
  );

  // ── 조건 1. 얼굴 개수 ─────────────────────────────────────────────
  // 가장 큰 얼굴 하나를 골라 통과시키지 않는다. 뒤에 사람이 지나가는 사진이
  // 피부 진단 입력으로 올라가면 어느 얼굴을 잰 점수인지 알 수 없게 된다.
  if (faceCount == 0 || faceBox == null) {
    return FaceGateBlocked(
      FaceGateReason.noFace,
      '얼굴을 찾을 수 없어요.\n얼굴이 잘 보이도록 촬영해주세요.',
      base,
    );
  }
  if (faceCount > 1) {
    // 프리뷰는 프레임의 위아래를 잘라 보여준다(BoxFit.cover). 잘린 띠에 걸린
    // 얼굴이나 배경 사진·반사도 검출에 잡히므로, 화면에는 한 명만 보이는데
    // 막히는 경우가 실제로 나온다. 이유를 같이 알려야 손을 쓸 수 있다.
    return FaceGateBlocked(
      FaceGateReason.multipleFaces,
      '한 명의 얼굴만 나오도록 촬영해주세요.\n화면 밖 사람이나 배경 사진도 얼굴로 잡힐 수 있어요.',
      base,
    );
  }

  // ── 조건 2. 얼굴 크기 ─────────────────────────────────────────────
  final heightRatio = frameHeight <= 0 ? 0.0 : faceBox.height / frameHeight;
  final sized = base.copyWith(faceHeightRatio: heightRatio);

  if (heightRatio < FaceGateConfig.minFaceHeightRatio) {
    return FaceGateBlocked(
      FaceGateReason.tooSmall,
      '얼굴이 너무 작아요.\n조금 더 가까이에서 촬영해주세요.',
      sized,
    );
  }

  // ── 조건 3. 얼굴 방향 ─────────────────────────────────────────────
  final orientation = _checkOrientation(photoType, yaw, roll, pitch);
  if (orientation != null) {
    return FaceGateBlocked(orientation.$1, orientation.$2, sized);
  }

  // ── 조건 4. 휘도 ─────────────────────────────────────────────────
  // ML Kit 은 밝기를 주지 않는다. 여기까지 왔을 때만 얼굴 영역을 훑는다.
  final luminance = luminanceOf();
  final lit = sized.copyWith(luminance: luminance);

  if (luminance < FaceGateConfig.minLuminance) {
    return FaceGateBlocked(
      FaceGateReason.tooDark,
      '사진이 너무 어두워요.\n조금 더 밝은 곳에서 촬영해주세요.',
      lit,
    );
  }

  return FaceGateOk(withMargin(faceBox, FaceGateConfig.faceMarginRatio), lit);
}

/// 통과면 null, 막으면 (이유, 안내문구).
(FaceGateReason, String)? _checkOrientation(
  FacePhotoType photoType,
  double? yaw,
  double? roll,
  double? pitch,
) {
  // yaw 를 못 읽는 기기가 있다. 방향을 모르는 채로 막으면 게이트가 상시 닫힌다.
  if (yaw == null) return null;

  if (FaceGateConfig.enablePitchCheck &&
      pitch != null &&
      pitch.abs() > FaceGateConfig.maxPitch) {
    return (FaceGateReason.wrongOrientation, '고개를 너무 숙이거나 들지 말아주세요.');
  }

  switch (photoType) {
    case FacePhotoType.front:
      if (roll != null && roll.abs() > FaceGateConfig.frontMaxRoll) {
        return (FaceGateReason.wrongOrientation, '고개를 기울이지 말고 촬영해주세요.');
      }
      if (yaw.abs() > FaceGateConfig.frontMaxYaw) {
        return (FaceGateReason.wrongOrientation, '정면을 바라보고 촬영해주세요.');
      }
      return null;

    // 사용자 기준 좌/우로 환산한다. 미러 처리 때문에 기기마다 부호가 뒤집힐 수
    // 있어서 userLeftYawSign 하나로 통째로 반전시킨다.
    case FacePhotoType.left:
      final toUserLeft = yaw * FaceGateConfig.userLeftYawSign;
      if (toUserLeft >= FaceGateConfig.sideMinYaw) return null;
      return toUserLeft <= -FaceGateConfig.sideMinYaw
          ? (FaceGateReason.wrongOrientation, '왼쪽 얼굴을 바라보고 촬영해주세요.')
          : (FaceGateReason.wrongOrientation, '얼굴을 왼쪽으로 조금 더 돌려주세요.');

    case FacePhotoType.right:
      final toUserRight = -yaw * FaceGateConfig.userLeftYawSign;
      if (toUserRight >= FaceGateConfig.sideMinYaw) return null;
      return toUserRight <= -FaceGateConfig.sideMinYaw
          ? (FaceGateReason.wrongOrientation, '오른쪽 얼굴을 바라보고 촬영해주세요.')
          : (FaceGateReason.wrongOrientation, '얼굴을 오른쪽으로 조금 더 돌려주세요.');
  }
}

/// 검출된 얼굴에 여백을 붙인다. 딱 맞게 자르면 이마와 턱이 잘리는데,
/// 그 두 곳이 유분·트러블 판정에서 정보량이 가장 많은 영역이다.
Rect withMargin(Rect face, double ratio) {
  final dx = face.width * ratio;
  final dy = face.height * ratio;
  return Rect.fromLTRB(
      face.left - dx, face.top - dy, face.right + dx, face.bottom + dy);
}
