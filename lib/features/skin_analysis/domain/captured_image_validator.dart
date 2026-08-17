import 'dart:ui' show Rect, Size;

import 'entities/face_gate_result.dart';
import 'face_gate_config.dart';

/// 촬영이 끝난 **최종 이미지**에 대한 확인 항목 하나.
enum PhotoCheckState {
  /// 확인했고 문제없다.
  ok,

  /// 확인했고 문제가 있다. [PhotoCheck.note] 를 사용자에게 보여준다.
  warn,

  /// **판단할 수단이 없다.** 통과로 취급하지 않는다.
  unknown,
}

class PhotoCheck {
  const PhotoCheck(this.label, this.state, {this.note});

  /// 사용자에게 보이는 항목 이름. 기술 용어를 쓰지 않는다.
  final String label;
  final PhotoCheckState state;

  /// [PhotoCheckState.warn] 일 때 무엇이 문제인지. 없으면 라벨만 보여준다.
  final String? note;
}

/// 촬영본을 사용자에게 보여주기 전에 훑는다.
///
/// **실시간 게이트와 목적이 다르다.** 실시간 쪽은 "지금 찍어도 되는가"를 정하고,
/// 여기는 "이미 찍은 이 사진을 쓸 것인가"를 사용자가 정하도록 근거를 늘어놓는다.
/// 그래서 이 결과는 **업로드를 막지 않는다** — [다시 촬영] 과 [다음] 중 무엇을
/// 고를지는 사진을 직접 보고 있는 사람이 정한다.
///
/// 막지 않는 것이 중요하다. 프리뷰는 `fast` 검출기, 촬영본은 `accurate` 검출기라
/// 두 판정이 미묘하게 갈리는데, 여기서 막아 버리면 초록불을 보고 찍은 사용자가
/// 빠져나갈 수 없는 루프에 갇힌다. 업로드 관문은 지금처럼 `prepareSkinPhoto` 의
/// 얼굴 검출 하나로 충분하다.
///
/// **임계값을 새로 만들지 않는다.** 전부 [FaceGateConfig] 를 그대로 쓴다 —
/// 같은 조건이 화면마다 다른 숫자를 쓰면 "아까는 통과였는데" 가 생긴다.
///
/// 넣지 않은 항목이 둘 있다.
///
/// **이마 노출 · 머리카락 가림 · 흔들림(blur) · 노출 과다** 는 ML Kit Face
/// Detection 이 주지 않는다. 판단할 수단이 없는 것을 ✓ 로 그리면 사용자는
/// 확인받았다고 믿는다. 별도 이미지 품질 분석이 붙기 전까지는 목록에서 뺀다 —
/// 그때 [PhotoCheck] 를 하나 더 돌려주면 화면은 그대로 늘어난다.
///
/// **얼굴 위치(중앙 정렬)** 는 잴 수는 있지만 뺐다. 업로드하는 것은 프레임 전체가
/// 아니라 **얼굴 박스를 잘라낸 이미지**라, 잘린 뒤에는 얼굴이 언제나 가운데다.
/// 자를 원본에서 치우쳤다고 알려 봐야 사용자가 보고 있는 사진과 어긋나기만 한다 —
/// 에뮬레이터에서 실제로 반듯하게 잘린 사진 밑에 "가운데에서 벗어났어요" 가 떴다.
/// 위치는 프레임을 잡는 동안(실시간 게이트) 따지는 조건이지 결과물의 성질이 아니다.
/// 잘림은 남긴다 — 크롭이 프레임 경계에서 잘리면 결과물에 그대로 보인다.
List<PhotoCheck> reviewCapturedPhoto({
  required FacePhotoType photoType,
  required int faceCount,
  required Rect? faceBox,
  required Size photoSize,
  required double? yaw,
  required double? roll,
  required int? luminance,
}) {
  if (faceCount == 0 || faceBox == null) {
    return const [
      PhotoCheck('얼굴 인식', PhotoCheckState.warn, note: '사진에서 얼굴을 찾지 못했어요.'),
    ];
  }

  final checks = <PhotoCheck>[
    if (faceCount > 1)
      const PhotoCheck('얼굴 인식', PhotoCheckState.warn,
          note: '얼굴이 여러 개 보여요. 한 명만 나오게 다시 찍어주세요.')
    else
      const PhotoCheck('얼굴 인식', PhotoCheckState.ok),
    _size(faceBox, photoSize),
    _cut(faceBox, photoSize),
    _angle(photoType, yaw, roll),
    _light(luminance),
  ];

  return checks;
}

/// 원본에서 얼굴이 차지한 비율을 본다. **화면에 보이는 크기가 아니다** —
/// 확인 화면에는 얼굴만 잘라낸 이미지가 뜨므로 거기서는 언제나 크게 보인다.
///
/// 그래도 이 항목은 남긴다. 위치와 달리 **결과물의 성질**이기 때문이다. 멀리서
/// 찍으면 잘라낸 이미지의 실효 해상도가 그만큼 낮고, 홍조·트러블 판정 근거가
/// 사라진다. 문구는 "사진이 이렇게 보인다"가 아니라 "이렇게 찍혔다"로 쓴다 —
/// 눈앞의 반듯한 사진과 어긋나는 말을 하면 사용자는 안내를 믿지 않게 된다.
PhotoCheck _size(Rect face, Size photo) {
  if (photo.height <= 0) {
    return const PhotoCheck('얼굴 크기', PhotoCheckState.unknown);
  }
  final ratio = face.height / photo.height;

  if (ratio < FaceGateConfig.minFaceHeightRatio) {
    return const PhotoCheck('얼굴 크기', PhotoCheckState.warn,
        note: '멀리서 찍혀 세부가 흐릴 수 있어요.\n조금 더 가까이에서 찍으면 더 정확해요.');
  }
  if (ratio > FaceGateConfig.maxFaceHeightRatio) {
    return const PhotoCheck('얼굴 크기', PhotoCheckState.warn,
        note: '너무 가까워서 이마·턱 여백이 부족해요.');
  }
  return const PhotoCheck('얼굴 크기', PhotoCheckState.ok);
}

PhotoCheck _cut(Rect face, Size photo) {
  if (photo.isEmpty) {
    return const PhotoCheck('얼굴 잘림', PhotoCheckState.unknown);
  }
  final slackX = photo.width * FaceGateConfig.outOfFrameSlackRatio;
  final slackY = photo.height * FaceGateConfig.outOfFrameSlackRatio;

  final cut = face.left < -slackX ||
      face.top < -slackY ||
      face.right > photo.width + slackX ||
      face.bottom > photo.height + slackY;

  return cut
      ? const PhotoCheck('얼굴 잘림', PhotoCheckState.warn,
          note: '얼굴 일부가 사진 밖으로 잘렸어요.')
      : const PhotoCheck('얼굴 잘림', PhotoCheckState.ok);
}

PhotoCheck _angle(FacePhotoType photoType, double? yaw, double? roll) {
  // 각도를 못 읽는 기기가 있다. 모르는 것을 ✓ 로 그리지 않는다.
  if (yaw == null) return const PhotoCheck('얼굴 각도', PhotoCheckState.unknown);

  switch (photoType) {
    case FacePhotoType.front:
      if (roll != null && roll.abs() > FaceGateConfig.frontMaxRoll) {
        return const PhotoCheck('얼굴 각도', PhotoCheckState.warn,
            note: '고개가 기울어져 있어요.');
      }
      return yaw.abs() > FaceGateConfig.frontMaxYaw
          ? const PhotoCheck('얼굴 각도', PhotoCheckState.warn,
              note: '정면이 아니라 조금 돌아가 있어요.')
          : const PhotoCheck('얼굴 각도', PhotoCheckState.ok);

    case FacePhotoType.left:
      return yaw * FaceGateConfig.userLeftYawSign >= FaceGateConfig.sideMinYaw
          ? const PhotoCheck('얼굴 각도', PhotoCheckState.ok)
          : const PhotoCheck('얼굴 각도', PhotoCheckState.warn,
              note: '고개가 왼쪽으로 충분히 돌아가지 않았어요.');

    case FacePhotoType.right:
      return -yaw * FaceGateConfig.userLeftYawSign >= FaceGateConfig.sideMinYaw
          ? const PhotoCheck('얼굴 각도', PhotoCheckState.ok)
          : const PhotoCheck('얼굴 각도', PhotoCheckState.warn,
              note: '고개가 오른쪽으로 충분히 돌아가지 않았어요.');
  }
}

PhotoCheck _light(int? luminance) {
  if (luminance == null) {
    return const PhotoCheck('조명', PhotoCheckState.unknown);
  }
  return luminance < FaceGateConfig.minLuminance
      ? const PhotoCheck('조명', PhotoCheckState.warn,
          note: '사진이 어두워요. 더 밝은 곳에서 찍으면 더 정확해요.')
      : const PhotoCheck('조명', PhotoCheckState.ok);
}

/// 자동으로 확인하지 못하는 것들. 화면에 **그대로 적어** 사용자가 직접 보게 한다.
///
/// 확인 못 하는 항목을 조용히 빼면 사용자는 목록이 전부인 줄 안다.
const capturedPhotoBlindSpots =
    '이마가 머리카락에 가렸는지, 사진이 흔들렸는지는 자동으로 확인하지 못해요.\n'
    '사진을 직접 보고 정해주세요.';
