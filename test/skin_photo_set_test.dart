import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_photo_set.dart';

/// 세 장이 하나의 분석이다. 덜 모인 채로 업로드가 나가면 서버가 400 을 돌려주고
/// 화면에는 "요청 값이 올바르지 않습니다"만 떠서 원인이 안 보인다.
void main() {
  final front = XFile('front.jpg');
  final left = XFile('left.jpg');
  final right = XFile('right.jpg');

  test('세 장이 다 모여야 만들어진다', () {
    expect(SkinPhotoSet.tryFrom({}), isNull);
    expect(SkinPhotoSet.tryFrom({FacePhotoType.front: front}), isNull);
    expect(
      SkinPhotoSet.tryFrom({
        FacePhotoType.front: front,
        FacePhotoType.left: left,
      }),
      isNull,
    );
  });

  test('세 장이 모이면 방향대로 담긴다 — 좌우가 바뀌지 않는다', () {
    final photos = SkinPhotoSet.tryFrom({
      FacePhotoType.right: right,
      FacePhotoType.front: front,
      FacePhotoType.left: left,
    });

    expect(photos, isNotNull);
    expect(photos!.front.path, 'front.jpg');
    expect(photos.left.path, 'left.jpg');
    expect(photos.right.path, 'right.jpg');
  });
}
