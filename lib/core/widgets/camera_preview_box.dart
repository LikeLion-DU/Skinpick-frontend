import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// 프리뷰를 **종횡비를 지켜** 화면에 꽉 채운다.
///
/// `Stack(fit: StackFit.expand)` 아래에 `CameraPreview` 를 그대로 두면 tight
/// 제약이 내려가고, `RenderAspectRatio` 는 tight 제약에서 종횡비를 버리고
/// `constraints.smallest` 를 쓴다. 결과적으로 16:9 텍스처가 상자에 맞춰 늘어난다.
///
/// 720×1280 프레임을 393×600 영역에 늘리면 얼굴이 실제보다 16% 넓게 보인다.
/// 게이트는 원본 프레임에서 비율을 재는데 사용자는 늘어난 화면을 보므로,
/// **가이드 타원과 실제 통과 조건이 어긋난다.**
class CameraPreviewBox extends StatelessWidget {
  const CameraPreviewBox(this.controller, {super.key});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);

    // clipBehavior 기본값이 Clip.none 이라, 두지 않으면 cover 로 확대된 영상이
    // 부모 영역 밖으로 그려져 아래에 있는 안내 문구를 덮는다.
    //
    // ponytail: cover 는 프레임의 위아래 약 14% 를 화면 밖으로 잘라내는데
    // 게이트는 원본 프레임 전체를 본다. 잘린 띠에 다른 사람 얼굴이 걸리면
    // 화면에는 한 명만 보이는데 "한 명의 얼굴만" 으로 막힌다. 안내 문구로
    // 완화해 두었다. 정확히 맞추려면 BoxFit.contain 으로 바꿔 프레임 전체를
    // 보여주면 되지만 위아래 검은 띠가 생긴다.
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      // previewSize 는 센서 기준(가로)이라 세로 화면에서는 뒤집어 쓴다.
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}
