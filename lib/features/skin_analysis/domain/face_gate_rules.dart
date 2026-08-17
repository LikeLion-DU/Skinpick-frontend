import 'dart:ui' show Offset, Rect, Size;

import 'entities/face_gate_result.dart';
import 'face_gate_config.dart';

/// 게이트 판정. **순수 함수다 — ML Kit 도 카메라도 모른다.**
///
/// 설계서 §2.12 는 이 로직을 ML Kit 구현 파일 안에 두었지만, 그러면 판정을
/// 검증하려면 네이티브 플러그인이 필요해져서 방향 판정 9종을 테스트할 수 없다.
/// 값을 뽑는 일(ML Kit)과 판정하는 일(여기)을 갈라 두면 양쪽 다 짧아진다.
///
/// **막는 이유는 언제나 하나만 돌려준다.** 조건을 위에서부터 보고 처음 걸린 데서
/// 멈춘다 — 순서가 곧 안내 우선순위다. 얼굴이 작으면서 중앙에서도 벗어났다면
/// "조금 더 가까이" 하나만 보여줘야 사용자가 한 번에 고칠 수 있다.
///
/// [faceBox] 는 **사용자가 보는 방향**의 좌표여야 한다(오른쪽 = x 큰 쪽).
/// 전면 카메라 스트림은 플랫폼에 따라 좌우가 뒤집혀 오므로 호출부가 되돌려서
/// 넘긴다. 안 되돌리면 "오른쪽으로 이동해주세요" 가 정확히 반대로 나간다.
///
/// [nose] 는 **그리기 전용으로 실어 나르기만 한다.** 판정에 쓰지 않는다 —
/// 코 위치로 조건을 하나 더 만들면 게이트 규칙이 두 벌이 된다.
///
/// [luminanceOf] 는 지연 계산이다. 앞 조건에서 막히면 픽셀을 한 번도 읽지 않는다 —
/// 실시간 프리뷰에서 프레임마다 얼굴 영역을 훑는 비용이 그대로 FPS 로 나온다.
///
/// [liveGuidance] 는 **프리뷰 전용 조건**(크기 상한·잘림·중앙 정렬)을 켠다.
/// 정지 이미지(갤러리)에는 끈다 — 이미 찍힌 사진을 두고 "조금 오른쪽으로
/// 이동해주세요" 라고 말할 수 없고, 얼굴이 한쪽에 있는 멀쩡한 셀카가 막힌다.
FaceGateResult evaluateFaceGate({
  required FacePhotoType photoType,
  required int faceCount,
  required Rect? faceBox,
  required Size frameSize,
  required double? yaw,
  required double? pitch,
  required double? roll,
  required int Function() luminanceOf,
  Offset? nose,
  double? eyeOpen,
  bool liveGuidance = true,
}) {
  final base = FaceGateDebug(
    faceCount: faceCount,
    yaw: yaw,
    pitch: pitch,
    roll: roll,
    faceBox: faceBox,
    nose: nose,
    frameSize: frameSize,
    eyeOpen: eyeOpen,
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
  final heightRatio =
      frameSize.height <= 0 ? 0.0 : faceBox.height / frameSize.height;
  final sized = base.copyWith(faceHeightRatio: heightRatio);

  // 상한과 잘림은 프리뷰에서만 본다. 순서가 중요하다 — 너무 가까우면 대개 얼굴이
  // 프레임 밖으로도 나가는데, 그때는 "멀어져 주세요" 가 "다 보이게 해주세요"
  // 보다 무엇을 하라는 말인지 분명하다.
  if (liveGuidance && heightRatio > FaceGateConfig.maxFaceHeightRatio) {
    return FaceGateBlocked(
      FaceGateReason.tooBig,
      '얼굴이 너무 커요.\n카메라에서 조금 멀어져 주세요.',
      sized,
    );
  }

  if (liveGuidance && _isCut(faceBox, frameSize)) {
    return FaceGateBlocked(
      FaceGateReason.outOfFrame,
      '얼굴이 화면 밖으로 잘렸어요.\n얼굴 전체가 보이도록 맞춰주세요.',
      sized,
    );
  }

  if (heightRatio < FaceGateConfig.minFaceHeightRatio) {
    return FaceGateBlocked(
      FaceGateReason.tooSmall,
      '얼굴이 너무 작아요.\n조금 더 가까이에서 촬영해주세요.',
      sized,
    );
  }

  // ── 조건 3. 중앙 정렬 — **정면 단계에만 적용한다** ──────────────────
  //
  // 고개를 돌리면 그 자체로 얼굴 박스가 한쪽으로 밀린다. 얼굴은 제자리인데
  // 보이는 면이 옮겨가기 때문이다. 측면 단계에서 이 검사를 돌리면 **시키는 대로
  // 돌린 사용자에게 "얼굴이 오른쪽으로 치우쳤어요"라고 답하게 된다** — 화면 위
  // 위치(어디에 있나)와 얼굴 방향(어디를 보나)은 별개의 조건이다.
  //
  // 임계값을 늘려 덮지 않는다. 그러면 정면 단계까지 같이 헐거워진다.
  // PRD §9.5 의 게이트 표도 측면 조건은 각도 하나뿐이고, 얼굴이 프레임 안에
  // 다 들어왔는지는 위의 잘림 검사가 이미 책임진다.
  if (liveGuidance && photoType == FacePhotoType.front) {
    final offCenter = _checkCenter(faceBox, frameSize);
    if (offCenter != null) {
      return FaceGateBlocked(FaceGateReason.offCenter, offCenter, sized);
    }
  }

  // ── 조건 4. 얼굴 방향 ─────────────────────────────────────────────
  final orientation = _checkOrientation(photoType, yaw, roll, pitch);
  if (orientation != null) {
    return FaceGateBlocked(orientation.$1, orientation.$2, sized);
  }

  // ── 조건 5. 눈 ───────────────────────────────────────────────────
  // 분류를 끈 경로에서는 eyeOpen 이 null 이다. 모르는 값으로 막지 않는다 —
  // yaw 와 같은 이유다. 게이트가 상시 닫히는 쪽이 훨씬 나쁘다.
  if (FaceGateConfig.eyeOpenThreshold > 0 &&
      eyeOpen != null &&
      eyeOpen < FaceGateConfig.eyeOpenThreshold) {
    return FaceGateBlocked(
      FaceGateReason.eyesClosed,
      '눈을 감으셨어요.\n눈을 뜬 상태로 촬영해주세요.',
      sized,
    );
  }

  // ── 조건 6. 휘도 ─────────────────────────────────────────────────
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

/// 얼굴 박스가 프레임 밖으로 나갔는가. ML Kit 박스는 프레임 경계를 넘어서도
/// 나오므로(음수 좌표가 실제로 온다) 이 검사가 성립한다.
bool _isCut(Rect face, Size frame) {
  final slackX = frame.width * FaceGateConfig.outOfFrameSlackRatio;
  final slackY = frame.height * FaceGateConfig.outOfFrameSlackRatio;

  return face.left < -slackX ||
      face.top < -slackY ||
      face.right > frame.width + slackX ||
      face.bottom > frame.height + slackY;
}

/// 중앙에서 벗어났으면 안내 문구, 아니면 null.
///
/// 가로·세로가 동시에 벗어나면 **더 많이 벗어난 쪽**만 말한다. 두 방향을 같이
/// 주면 사용자는 대각선으로 움직이다 둘 다 놓친다.
String? _checkCenter(Rect face, Size frame) {
  if (frame.isEmpty) return null;

  final offX = (face.center.dx - frame.width / 2) / frame.width;
  final offY = (face.center.dy - frame.height / 2) / frame.height;

  final overX = offX.abs() - FaceGateConfig.centerToleranceX;
  final overY = offY.abs() - FaceGateConfig.centerToleranceY;
  if (overX <= 0 && overY <= 0) return null;

  // 사용자 기준 좌표다 — x 가 크면 사용자의 오른쪽이다. 얼굴이 오른쪽에 있으면
  // 왼쪽으로 움직여야 가운데로 온다.
  if (overX >= overY) {
    return offX > 0
        ? '얼굴이 오른쪽으로 치우쳤어요.\n조금 왼쪽으로 이동해주세요.'
        : '얼굴이 왼쪽으로 치우쳤어요.\n조금 오른쪽으로 이동해주세요.';
  }
  return offY > 0
      ? '얼굴이 아래로 치우쳤어요.\n조금 위로 이동해주세요.'
      : '얼굴이 위로 치우쳤어요.\n조금 아래로 이동해주세요.';
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

/// 촬영 준비 단계. 한 프레임의 판정이 아니라 **연속으로 몇 프레임 통과했는지** 다.
///
/// 셔터를 [ready] 에서만 켜는 것이 이 enum 의 존재 이유다. 한 프레임 통과로 켜면
/// 고개를 돌리다 스쳐 지나가는 순간에 버튼이 깜빡이고, 그 사이 자동 촬영이 눌린다.
enum CaptureReadiness { invalid, validating, ready }

/// [okStreak] 는 지금까지 **연속으로** 통과한 프레임 수다. 한 번이라도 막히면
/// 호출부가 0 으로 되돌린다.
CaptureReadiness readinessOf(FaceGateResult? result, int okStreak) {
  if (result is! FaceGateOk || okStreak <= 0) return CaptureReadiness.invalid;
  return okStreak >= FaceGateConfig.stableFrames
      ? CaptureReadiness.ready
      : CaptureReadiness.validating;
}
