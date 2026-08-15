import 'package:flutter/material.dart';

import '../enums/score_grade.dart';

/// 점수 옆에 붙는 등급 배지.
///
/// 시안에 두 가지 모양이 있다. 기록 카드는 진한 채움에 흰 글씨, 홈과 결과
/// 화면의 큰 점수 옆은 옅은 틴트에 색 글씨다. 같은 뜻을 두 벌로 그리는 것이라
/// 위젯을 나누지 않고 `solid` 로만 가른다 — 나누면 한쪽만 고쳐지기 쉽다.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.grade, this.solid = false});

  final ScoreGrade grade;

  /// true 면 진한 채움(기록 카드), false 면 옅은 틴트(홈·결과).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: solid ? grade.solidColor : grade.tintColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        grade.badgeLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: solid ? Colors.white : grade.accentColor,
        ),
      ),
    );
  }
}
