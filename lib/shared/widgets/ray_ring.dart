import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 시안의 방사 눈금 고리 — 굵은 원 하나에 바깥으로 짧은 눈금이 둘러 있다.
///
/// 촬영 안내(마스코트 뒤)와 촬영 중 얼굴 가이드가 같은 모양을 쓴다. 두 곳에서
/// 다른 고리를 그리면 "안내에서 본 그 자리"라는 느낌이 끊긴다.
///
/// 눈금은 SVG 로 내보내면 반복 요소가 통째로 하나의 path 가 되어 크기를 바꿀 때
/// 굵기가 같이 늘어난다. 원과 눈금을 코드로 그려야 지름이 달라져도 선 굵기가
/// 유지된다.
class RayRing extends StatelessWidget {
  const RayRing({
    super.key,
    required this.diameter,
    this.color = AppColors.primary,
    this.strokeWidth = 3,
    this.child,
  });

  final double diameter;
  final Color color;
  final double strokeWidth;

  /// 고리 안에 놓을 것. 안내 화면은 마스코트, 완료 화면은 체크다.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: RayRingPainter(color: color, strokeWidth: strokeWidth),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

/// [RayRing] 의 알맹이. 얼굴 가이드는 화면 전체를 덮는 페인터 안에서 이 그리기를
/// 직접 불러 쓰므로 위젯과 따로 열어 둔다.
class RayRingPainter extends CustomPainter {
  const RayRingPainter({
    required this.color,
    required this.strokeWidth,
    this.tickCount = 44,
  });

  final Color color;
  final double strokeWidth;

  /// 눈금 개수. 시안은 셈이 아니라 반복 요소라 개수가 적혀 있지 않다 —
  /// 지름 대비 간격이 시안 렌더와 맞는 값으로 골랐다.
  final int tickCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // 눈금이 바깥에 서므로 원은 상자보다 안쪽에 있어야 한다.
    final radius = size.shortestSide / 2 * 0.82;
    paintRing(canvas, center, radius);
  }

  /// 원과 눈금을 지정한 중심·반지름에 그린다. 얼굴 가이드가 타원 기준으로
  /// 부르므로 크기 계산을 밖에서 넘길 수 있게 갈라 두었다.
  void paintRing(Canvas canvas, Offset center, double radius) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, stroke);

    final tick = Paint()
      ..strokeWidth = strokeWidth * 0.7
      ..strokeCap = StrokeCap.round
      ..color = color;

    final inner = radius + strokeWidth * 2;
    final outer = inner + radius * 0.09;

    for (var index = 0; index < tickCount; index++) {
      final angle = 2 * math.pi * index / tickCount;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + direction * inner, center + direction * outer, tick);
    }
  }

  @override
  bool shouldRepaint(RayRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.tickCount != tickCount;
}
