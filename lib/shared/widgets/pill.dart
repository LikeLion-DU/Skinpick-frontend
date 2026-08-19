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
/// 3. **세로 패딩의 기본값 2.** 같은 줄의 칩들이 이 값을 각자 적으면 높이가 어긋난다.
///    자리마다 다른 값이 필요한 칩도 있어서(끼니 배지 3 · 음식명 칩 5 · 갭 칩 6)
///    닫아 두지는 않았다 — 기본값을 두고 필요한 자리만 적는다.
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
    this.verticalPadding = 2,
    this.maxLines,
    this.overflow,
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

  /// 세로 패딩. **기본 2 이고 자리마다 바꿀 수 있다.**
  ///
  /// 처음에는 "모든 알약이 2 라서" 닫아 두었는데 사실이 아니었다 — 끼니 배지는 3,
  /// 음식명 칩은 5, 갭 칩은 6 이다. 닫아 두면 그 칩들이 이 위젯을 쓸 수 없고, 위
  /// 세 규칙이 그만큼 다른 곳에 남는다. 값을 바꿀 수 있게 열고 기본값만 둔다.
  final double verticalPadding;

  /// 한 줄에 안 들어가는 라벨을 어떻게 다룰지. 단계 탭처럼 폭이 고정된 칸에서만
  /// 필요하다 — 대부분의 알약은 Wrap 안에서 폭을 스스로 정한다.
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        minHeight: minHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      // alignment 로 바꾸지 마라 — Wrap 에서 한 줄을 통째로 먹는다(위 1번).
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}
