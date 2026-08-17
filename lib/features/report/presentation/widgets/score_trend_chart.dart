import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/kst_date.dart';
import '../../domain/entities/report.dart';

/// 일별 점수 추이.
///
/// **차트 패키지를 들이지 않는다.** 그리는 것은 최대 7개의 점과 그 사이의 선
/// 하나뿐이라 `CustomPainter` 로 끝난다. 패키지를 하나 넣으면 pubspec 과
/// 네이티브 설정을 건드리게 되는데(이 저장소는 그걸 한 사람이 전담한다)
/// 얻는 것이 축 라벨 자동 배치 정도다.
///
/// **기록이 없는 날은 점을 찍지 않는다.** 0 으로 떨어뜨리면 안 찍은 날이
/// 폭락한 날처럼 보인다. 대신 축에는 그 날짜가 회색으로 남아 "빈 날"이 보인다.
/// 빈 날을 사이에 둔 두 점은 **점선**으로 잇는다 — 실선으로 이으면 그 사이를
/// 보간한 것처럼 읽힌다.
class ScoreTrendChart extends StatelessWidget {
  const ScoreTrendChart({super.key, required this.report});

  final WeeklyReport report;

  static const double _plotHeight = 150;

  @override
  Widget build(BuildContext context) {
    final axis = report.axis;
    final scores = [for (final date in axis) report.scoreOn(date)?.dailyScore];

    return Column(
      children: [
        SizedBox(
          height: _plotHeight,
          child: CustomPaint(
            size: Size.infinite,
            painter: _TrendPainter(scores: scores),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < axis.length; index++)
              Expanded(
                child: Text(
                  weekdayLabel(axis[index]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: scores[index] == null
                        ? FontWeight.w400
                        : FontWeight.w700,
                    color: scores[index] == null
                        ? AppColors.borderEmptySlot
                        : AppColors.textOnCard,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.scores});

  /// 축 한 칸당 하나. 기록이 없는 날은 null 이다.
  final List<int?> scores;

  /// 점수 라벨이 들어갈 위쪽 여백. 이만큼 안 비우면 100 점짜리 점의 라벨이 잘린다.
  static const double _labelSpace = 22;

  /// 세로 축은 **0~100 고정**이다. 데이터 최소·최대에 맞춰 늘리면 70~72 점짜리
  /// 한 주가 폭락한 그래프로 보인다.
  static const double _maxScore = 100;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final slot = size.width / scores.length;
    const plotTop = _labelSpace;
    final plotHeight = size.height - _labelSpace;

    Offset pointAt(int index, int score) => Offset(
          slot * (index + 0.5),
          plotTop + plotHeight * (1 - score / _maxScore),
        );

    // 바닥선. 점이 하나도 없어도 축이 보여야 "그리다 만 화면"으로 안 읽힌다.
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = AppColors.borderOnWhite
        ..strokeWidth = 1,
    );

    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 값이 있는 칸끼리 순서대로 잇는다. 사이에 빈 날이 끼면 점선이다.
    int? previousIndex;
    for (var index = 0; index < scores.length; index++) {
      final score = scores[index];
      if (score == null) continue;

      if (previousIndex != null) {
        final from = pointAt(previousIndex, scores[previousIndex]!);
        final to = pointAt(index, score);
        if (index - previousIndex == 1) {
          canvas.drawLine(from, to, line);
        } else {
          _drawDashed(canvas, from, to, line);
        }
      }
      previousIndex = index;
    }

    for (var index = 0; index < scores.length; index++) {
      final score = scores[index];
      if (score == null) continue;

      final center = pointAt(index, score);
      // 흰 속을 채운 뒤 테두리를 그린다. 선 위에 그냥 점을 찍으면 선이
      // 점을 관통해 보여 값이 어디인지 흐려진다.
      canvas.drawCircle(center, 4.5, Paint()..color = AppColors.background);
      canvas.drawCircle(
        center,
        4.5,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      _drawLabel(canvas, center, '$score', slot);
    }
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;

    final total = (to - from).distance;
    if (total == 0) return;

    final step = (to - from) / total;
    final dashed = Paint()
      ..color = paint.color.withValues(alpha: 0.45)
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (var drawn = 0.0; drawn < total; drawn += dash + gap) {
      final end = (drawn + dash).clamp(0.0, total);
      canvas.drawLine(from + step * drawn, from + step * end, dashed);
    }
  }

  void _drawLabel(Canvas canvas, Offset point, String text, double slot) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: slot);

    painter.paint(
      canvas,
      Offset(point.dx - painter.width / 2, point.dy - painter.height - 9),
    );
  }

  /// 주를 넘기면 매번 새 리스트라 값이 같아도 참조가 다르다. 7칸짜리 비교를
  /// 아끼려고 조건을 만드는 것보다 다시 그리는 편이 싸다.
  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => true;
}
