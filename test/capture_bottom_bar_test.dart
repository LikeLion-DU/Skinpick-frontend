import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';
import 'package:skinplate/features/skin_analysis/domain/face_gate_rules.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_capture_page.dart';
import 'package:skinplate/shared/widgets/capture_shutter.dart';

/// 촬영 화면 아래쪽 배치. **얼굴 가이드와 하단 인셋을 같이 세워 놓고 잰다.**
///
/// 예전 판은 `CaptureBottomBar` 만 띄우고 `setSurfaceSize` 로만 크기를 줬다.
/// 그래서 가이드 타원도 없고 하단 인셋도 늘 0 이라, 셔터가 타원을 파고드는
/// 회귀를 통과시켰다 — 있는데 아무것도 안 지키는 테스트였다.
///
/// 지금은 타원 기하(`faceGuideOval`)를 프로덕션과 같은 함수에서 가져와 실제
/// 위치 관계를 본다.
///
/// **한계 하나는 남는다.** 촬영 화면은 카메라 프리뷰가 열린 뒤에만 이 배치를
/// 그려서 페이지를 통째로 띄울 수 없고, 여기서는 마운트 방식을 흉내 낸다.
/// 그래서 "하단 블록을 어디에 매다는가" 자체가 바뀌는 회귀는 못 잡는다 —
/// 예전처럼 절대 좌표 Align 으로 되돌려도 이 파일은 초록이다.
///
/// **구조가 침범을 막아 주지는 않는다.** [CaptureBottomBar] 는 `faceGuideOval` 을
/// 읽지 않는다 — 화면 아래에 붙고 고정 간격만 쓴다. 타원과의 여유는 그 결과로
/// 생기는 값이라, 아래 좌표 단언들이 유일한 안전망이다. `faceGuideOval` 이
/// 하는 일은 **그리는 쪽과 재는 쪽이 같은 수를 보게 하는 것**뿐이다.
void main() {
  const sizes = [Size(320, 568), Size(360, 640), Size(390, 844)];
  const insets = [0.0, 24.0, 48.0];

  /// 실기기에 있는 조합. 568·640 높이 기기는 홈 인디케이터가 없어 인셋이 0 이고,
  /// 인셋이 큰 기기는 화면이 길다. 이 조합에서는 셔터가 타원 밖에 있어야 한다.
  bool onRealDevice(Size size, double inset) =>
      inset == 0 || size.height >= 844 || (size.height >= 640 && inset <= 24);

  Future<void> pump(
    WidgetTester tester,
    Size size,
    double inset, {
    required FacePhotoType stage,
    String? guide,
    bool ready = false,
    bool busy = false,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: EdgeInsets.only(bottom: inset),
        viewPadding: EdgeInsets.only(bottom: inset),
      ),
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 프로덕션과 같은 순서 — 가이드가 깔리고 그 위에 하단 블록이 온다.
              CustomPaint(painter: _OvalStand(size)),
              SafeArea(
                top: false,
                child: CaptureBottomBar(
                  stage: stage,
                  needsTurn: stage != FacePhotoType.front,
                  instruction: '정면을 바라봐주세요',
                  guide: guide,
                  ready: ready,
                  busy: busy,
                  readiness: CaptureReadiness.invalid,
                  onCapture: () {},
                  onPickFromGallery: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  for (final size in sizes) {
    for (final inset in insets) {
      final label = '${size.width.toInt()}x${size.height.toInt()} 인셋${inset.toInt()}';

      testWidgets('$label — 넘치지 않고 순서가 유지된다', (tester) async {
        await pump(tester, size, inset,
            stage: FacePhotoType.left, guide: '얼굴이 너무 작아요 · 조금 더 가까이');

        final instruction = tester.getRect(find.text('정면을 바라봐주세요'));
        final guide = tester.getRect(find.text('얼굴이 너무 작아요 · 조금 더 가까이'));
        final shutter = tester.getRect(find.byType(CaptureShutter));
        final gallery = tester.getRect(find.text('갤러리에서 선택'));

        expect(instruction.bottom, lessThanOrEqualTo(guide.top), reason: '순서 역전');
        expect(guide.bottom, lessThanOrEqualTo(shutter.top), reason: '순서 역전');
        expect(shutter.bottom, lessThanOrEqualTo(gallery.top), reason: '순서 역전');

        // 화면 밖으로 밀려나면 셔터를 아예 누를 수 없다. 겹치는 것보다 나쁘다.
        expect(gallery.bottom, lessThanOrEqualTo(size.height), reason: '화면 밖으로 밀려났다');
        expect(tester.takeException(), isNull, reason: '세로가 모자라 넘쳤다');
      });

      if (onRealDevice(size, inset)) {
        testWidgets('$label — 셔터가 얼굴 가이드를 침범하지 않는다', (tester) async {
          await pump(tester, size, inset, stage: FacePhotoType.front);

          final oval = faceGuideOval(size);
          final shutter = tester.getRect(find.byType(CaptureShutter));

          expect(
            shutter.top,
            greaterThanOrEqualTo(oval.bottom),
            reason: '셔터가 타원 안으로 들어갔다 — 사용자가 자기 턱을 못 본다',
          );
        });
      }
    }
  }

  testWidgets('촬영 중은 꺼짐과 다르게 보인다 — 스피너가 산다', (tester) async {
    await pump(tester, sizes.last, 0, stage: FacePhotoType.front, busy: true);

    // 흐리게만 처리하면 "그냥 안 되는 버튼" 으로 읽혀 사용자가 다시 누른다.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 흐림은 그리는 색의 알파라 위젯 트리에 안 남는다. 규칙을 직접 본다.
    expect(CaptureShutter.dimmedFor(enabled: false, busy: true), isFalse,
        reason: '촬영 중을 꺼짐과 같이 흐리게 하면 스피너까지 사라진다');
    expect(CaptureShutter.dimmedFor(enabled: false, busy: false), isTrue);
    expect(CaptureShutter.dimmedFor(enabled: true, busy: false), isFalse);
  });

  testWidgets('안내와 조작이 한 Column 에 남아 있다', (tester) async {
    // 좌표를 재는 위 테스트들과 역할이 다르다. 저건 "지금 배치가 겹치지 않는가",
    // 이건 "안내를 다시 떼어내지 않았는가" 다. Column 은 자식을 겹칠 수 없어서,
    // 한 줄에 있는 한 순서 역전과 상호 겹침은 생기지 않는다.
    //
    // 이 단언이 타원 침범까지 막아 주지는 않는다 — 그건 위 좌표 단언 몫이다.
    await pump(tester, sizes.first, 0, stage: FacePhotoType.front);

    expect(
      find.ancestor(
        of: find.text('정면을 바라봐주세요'),
        matching: find.descendant(
          of: find.byType(CaptureBottomBar),
          matching: find.byType(Column),
        ),
      ),
      findsWidgets,
      reason: '안내를 하단 블록 밖으로 다시 떼어냈다',
    );
  });

  testWidgets('셔터를 스크린리더가 읽는다', (tester) async {
    final handle = tester.ensureSemantics();

    await pump(tester, sizes.last, 0, stage: FacePhotoType.front, ready: true);
    expect(find.bySemanticsLabel('사진 촬영'), findsOneWidget);

    await pump(tester, sizes.last, 0, stage: FacePhotoType.front, busy: true);
    expect(find.bySemanticsLabel('사진 촬영 중'), findsOneWidget);

    handle.dispose();
  });
}

/// 프로덕션과 같은 기하로 타원을 세워 둔다. 위치 비교용이라 색은 상관없다.
class _OvalStand extends CustomPainter {
  const _OvalStand(this.frame);

  final Size frame;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawOval(faceGuideOval(size), Paint()..color = Colors.white24);

  @override
  bool shouldRepaint(_OvalStand oldDelegate) => false;
}
