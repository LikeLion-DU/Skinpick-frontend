import 'package:flutter/material.dart';

/// 한 줄짜리 알약(칩). 화면 곳곳의 태그·등급·상태 라벨이 같은 골격을 쓴다.
///
/// **모양을 통일하려고 만든 게 아니다.** 색·테두리·반경·글자는 자리마다 다르고
/// 그대로 호출부가 정한다. 이 위젯이 소유하는 것은 <b>틀리기 쉬운 세 가지</b>뿐이다.
///
/// 1. **[Center] 의 `widthFactor: 1`.** 알약이 [Wrap] 안에 들어가는 자리가 많은데,
///    여기를 `Container(alignment: ...)` 로 쓰면 Container 가 부모가 준 폭을 전부
///    차지한다 — 칩 하나가 한 줄을 통째로 먹고 다음 칩이 아래로 밀린다. 예외가
///    나지 않아서 오버플로만 보는 테스트로는 안 잡힌다. 실제로 났던 버그다.
/// 2. **높이는 [BoxConstraints.minHeight] 로만 준다.** 시안 값을 `height` 로 박으면
///    글자 크기를 키운 기기에서 상자가 글자를 자르는데, 이것도 예외가 없다.
/// 3. **세로 패딩 2.** 알약 사이에서 이 값이 갈리면 같은 줄의 칩 높이가 어긋난다.
///
/// 그래서 파라미터에 기본값을 거의 두지 않았다 — 기본값이 자리마다 다른 시안 값과
/// 어긋나면 조용히 다른 모양이 된다. 부르는 쪽이 자기 숫자를 적는 편이 낫다.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.style,
    required this.minHeight,
    required this.horizontalPadding,
    required this.borderRadius,
    this.color,
    this.border,
    this.minWidth,
    this.textAlign,
  });

  final String label;
  final TextStyle style;

  /// 시안 높이를 <b>최소값으로만</b> 쓴다. 고정 높이가 아니다(위 2번).
  final double minHeight;

  /// 시안 폭을 최소값으로 쓰는 자리에만 준다(GOOD/BAD 배지의 53).
  final double? minWidth;

  final double horizontalPadding;
  final double borderRadius;
  final Color? color;
  final BoxBorder? border;
  final TextAlign? textAlign;

  /// 세로 패딩. 모든 알약이 같은 값이라 파라미터로 열지 않았다(위 3번).
  static const double _verticalPadding = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        minHeight: minHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      // alignment 로 바꾸지 마라 — Wrap 에서 한 줄을 통째로 먹는다(위 1번).
      child: Center(
        widthFactor: 1,
        child: Text(label, style: style, textAlign: textAlign),
      ),
    );
  }
}
