import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

/// 프레임을 **`BoxFit.cover`** 로 채울 때의 배율.
///
/// `CameraPreviewBox` 는 프레임을 종횡비를 지켜 화면에 꽉 채운다 — 확대한 뒤
/// 넘치는 쪽을 잘라낸다. 가로세로 배율이 같아야 얼굴이 늘어나지 않으므로
/// **큰 쪽**을 쓴다.
double coverScale(Size frame, Size widget) => frame.isEmpty
    ? 1.0
    : math.max(widget.width / frame.width, widget.height / frame.height);

/// 프레임 좌표의 점이 프리뷰 위 어디에 오는가.
///
/// 잘려나간 만큼 원점이 음수로 밀린다. 이걸 빼먹고 단순 비례
/// (`size.width / frame.width`)로 맞추면 가이드가 얼굴에서 한쪽으로 밀린 채
/// 그려지고, 사용자는 카메라가 엉뚱한 것을 보고 있다고 읽는다.
///
/// [frame] 은 **회전을 적용한 뒤**의 크기여야 한다(세로 화면이면 세로로 긴 값).
Offset coverPointToWidget(Offset point, Size frame, Size widget) {
  if (frame.isEmpty) return point;

  final scale = coverScale(frame, widget);
  return Offset(
    point.dx * scale + (widget.width - frame.width * scale) / 2,
    point.dy * scale + (widget.height - frame.height * scale) / 2,
  );
}
