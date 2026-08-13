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

    return FittedBox(
      fit: BoxFit.cover,
      // previewSize 는 센서 기준(가로)이라 세로 화면에서는 뒤집어 쓴다.
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}
