import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../enums/skin_level.dart';

/// 점수에 비례해 차는 원호.
///
/// 시안은 이걸 SVG 호 두 장으로 내보내는데, 점수마다 호의 길이가 달라져야
/// 하므로 이미지로는 못 쓴다. 그래서 코드로 그린다.
///
/// 음식 적합도 카드와 리포트 점수 카드가 같이 쓴다 — 두 벌로 그리면 같은
/// 점수가 화면마다 다른 두께·다른 시작 각도로 보인다. 가운데에 무엇을 넣을지만
/// 다르다(적합도는 등급 표정, 리포트는 숫자).
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.score,
    required this.grade,
    this.size = 118,
    this.strokeWidth = 8,
    this.trackColor = AppColors.background,
    this.child,
  });

  final int score;
  final SkinLevel grade;
  final double size;
  final double strokeWidth;

  /// 호가 지나지 않은 부분. 흰 카드 위에서는 흰색이 아니라 등급 틴트를 넘긴다 —
  /// 흰 트랙이 흰 배경에 묻히면 호가 얼마나 찼는지 알 수 없다.
  final Color trackColor;

  /// 원 가운데. 비우면 등급 표정을 그린다.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          // 0 점이어도 짧은 호를 남긴다. 완전히 비면 게이지가 아니라
          // 회색 원으로 보여서 "고장났나"가 먼저 떠오른다.
          fraction: (score / 100).clamp(0.04, 1.0),
          color: grade.accentColor,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: child ??
              Icon(grade.faceIcon, size: size * 0.37, color: grade.accentColor),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - strokeWidth / 2 - 1;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    // 12시 방향에서 시작해 시계 방향으로 찬다.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
