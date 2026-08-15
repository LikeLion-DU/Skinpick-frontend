import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/score_grade.dart';

/// 분석 결과 맨 위의 "내 피부 적합도" 카드.
///
/// 시안 수치 그대로다 — 크림 배경(#FEF7F0) · 테두리 #FFDFD1 · 높이 156.
/// 오른쪽의 원형 게이지는 시안이 SVG 호 두 장으로 그려 놓았는데, 점수마다
/// 호의 길이가 달라져야 하므로 이미지 대신 CustomPaint 로 그린다.
class PlateScoreCard extends StatelessWidget {
  const PlateScoreCard({
    super.key,
    required this.score,
    required this.basisLabel,
  });

  final int score;

  /// "민감성 / 여드름 피부 기준" 같은 채점 기준 문구. 서버 값이 없으면 비운다.
  final String? basisLabel;

  @override
  Widget build(BuildContext context) {
    final grade = ScoreGrade.fromScore(score);

    return Container(
      height: 156,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내 피부 적합도',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnCard,
                  ),
                ),
                const SizedBox(height: 6),
                // 세 자리 점수(100점)가 와도 게이지 옆 좁은 칸에서 안 넘치도록
                // 줄 전체를 줄여서 맞춘다. 두 자리에서는 원래 크기 그대로다.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$score',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1,
                          )),
                      const Text('점',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1,
                          )),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: grade.tintColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          grade.badgeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: grade.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (basisLabel != null)
                  Text(
                    basisLabel!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textOnCard,
                    ),
                  ),
              ],
            ),
          ),
          ScoreGauge(score: score, grade: grade),
        ],
      ),
    );
  }
}

/// 점수에 비례해 차는 원호와 등급 표정.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, required this.grade});

  final int score;
  final ScoreGrade grade;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 118,
      child: CustomPaint(
        painter: _GaugePainter(
          // 0 점이어도 짧은 호를 남긴다. 완전히 비면 게이지가 아니라
          // 회색 원으로 보여서 "고장났나"가 먼저 떠오른다.
          fraction: (score / 100).clamp(0.04, 1.0),
          color: grade.accentColor,
        ),
        child: Center(
          child: Icon(
            switch (grade) {
              ScoreGrade.good => Icons.sentiment_satisfied_alt,
              ScoreGrade.normal => Icons.sentiment_neutral,
              ScoreGrade.caution => Icons.sentiment_dissatisfied,
            },
            size: 44,
            color: grade.accentColor,
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = AppColors.background;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
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
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
