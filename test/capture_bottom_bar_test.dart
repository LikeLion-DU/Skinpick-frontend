import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_rules.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_capture_page.dart';

/// 촬영 안내가 하단 안내·셔터와 겹치거나 순서가 뒤집히지 않는다.
///
/// 예전에는 방향 안내를 `Alignment(0, 0.47)` 로 따로 띄웠다. 그 0.47 은 SafeArea
/// 높이 기준이고, 밑에 두려던 타원의 0.47 은 전체 화면 높이 기준이라
/// (`_FaceGuidePainter`) 애초에 다른 좌표계였다 — 큰 화면에서만 우연히 맞았다.
/// 360x640 에서는 하단 안내와 겹쳤고 320x568 에서는 순서까지 뒤집혔다.
///
/// 지금은 한 Column 이라 겹침이 구조적으로 불가능하다. 이 테스트는 그 구조가
/// 유지되는지를 본다 — 누가 다시 절대 좌표로 띄우면 여기서 걸린다.
void main() {
  /// 실기기에서 좁은 축부터 넓은 축까지. 320x568 은 앱이 지원하는 가장 좁은 화면이다.
  const sizes = [Size(320, 568), Size(360, 640), Size(390, 844)];

  Future<void> pumpBar(
    WidgetTester tester,
    Size size, {
    required FacePhotoType stage,
    String? guide,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Stack(
                children: [
                  CaptureBottomBar(
                    stage: stage,
                    needsTurn: stage != FacePhotoType.front,
                    instruction: '정면을 바라봐주세요',
                    guide: guide,
                    ready: false,
                    busy: false,
                    readiness: CaptureReadiness.invalid,
                    onCapture: () {},
                    onPickFromGallery: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('$label — 방향 안내가 하단 안내보다 위에 있고 겹치지 않는다', (tester) async {
      await pumpBar(tester, size,
          stage: FacePhotoType.front, guide: '얼굴이 너무 작아요 · 조금 더 가까이');

      final instruction = tester.getRect(find.text('정면을 바라봐주세요'));
      final guide = tester.getRect(find.text('얼굴이 너무 작아요 · 조금 더 가까이'));

      expect(instruction.bottom, lessThanOrEqualTo(guide.top),
          reason: '겹치거나 순서가 뒤집혔다');
    });

    testWidgets('$label — 측면 단계(회전 힌트 44px)에서도 셔터를 침범하지 않는다',
        (tester) async {
      await pumpBar(tester, size, stage: FacePhotoType.left);

      final instruction = tester.getRect(find.text('정면을 바라봐주세요'));
      final shutter = tester.getRect(find.text('갤러리에서 선택'));

      expect(instruction.bottom, lessThanOrEqualTo(shutter.top));
      expect(tester.takeException(), isNull, reason: '세로가 모자라 넘쳤다');
    });
  }

  testWidgets('안내는 절대 좌표가 아니라 하단 블록과 같은 Column 에 있다', (tester) async {
    await pumpBar(tester, sizes.first, stage: FacePhotoType.front);

    // Column 은 자식을 겹칠 수 없다. 안내가 그 안에 있다는 것이 곧 겹치지 않는다는
    // 보증이라, 좌표를 재는 위 테스트들보다 이쪽이 회귀를 먼저 잡는다.
    expect(
      find.ancestor(
        of: find.text('정면을 바라봐주세요'),
        matching: find.descendant(
          of: find.byType(CaptureBottomBar),
          matching: find.byType(Column),
        ),
      ),
      findsWidgets,
    );
  });
}
