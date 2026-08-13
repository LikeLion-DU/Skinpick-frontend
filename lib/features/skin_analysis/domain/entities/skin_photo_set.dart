import 'package:image_picker/image_picker.dart';

import 'face_gate_result.dart';

/// 피부 분석 1회에 올리는 사진 세 장.
///
/// **세 장이 하나의 분석이다.** 정면·좌·우를 한 번의 Vision 호출로 함께 보내
/// 결과 하나를 받는다. 사진마다 따로 호출해 평균 내면 각도마다 점수가 달라져
/// "같은 얼굴이면 같은 점수"라는 재현성 주장이 무너진다. (PRD §14.3 ⑤)
///
/// 셋 다 XFile 이라 위치 인자로 넘기면 좌우가 조용히 뒤바뀐다. 이름을 붙여
/// 한 벌로 옮긴다.
class SkinPhotoSet {
  const SkinPhotoSet({
    required this.front,
    required this.left,
    required this.right,
  });

  final XFile front;
  final XFile left;
  final XFile right;

  /// 단계별로 모은 사진이 세 장 다 찼을 때만 만들어진다.
  static SkinPhotoSet? tryFrom(Map<FacePhotoType, XFile> shots) {
    final front = shots[FacePhotoType.front];
    final left = shots[FacePhotoType.left];
    final right = shots[FacePhotoType.right];
    if (front == null || left == null || right == null) return null;
    return SkinPhotoSet(front: front, left: left, right: right);
  }
}
