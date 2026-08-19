import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../enums/skin_level.dart';

/// GOOD / BAD 라벨. 끼니 한 줄이 "먹어도 됐나"에 답하는 자리다.
///
/// 홈의 오늘 기록 카드 · 리포트의 먹은 음식 · 기록 화면의 끼니 카드가 같이 쓴다 —
/// 세 벌로 그리면 같은 점수가 화면마다 다른 색·다른 크기가 된다.
///
/// **두 단계로 접는 것은 시안 의도다.** 접는 규칙은 [SkinLevel.isGood] 하나뿐이라
/// 등급 어휘(좋음·보통·주의)와 갈리지 않는다 — 58점은 어디서나 `보통` 등급이면서
/// 이 라벨로는 `BAD` 다. 세 단계가 필요한 자리(점수 카드·고민 칩)는 등급 어휘를 쓴다.
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.grade});

  final SkinLevel grade;

  @override
  Widget build(BuildContext context) {
    final isGood = grade.isGood;

    return Container(
      width: 53,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // 주의 점수를 빨강으로 칠하지 않는다 — 빨강(bad)은 결과 화면의
        // BAD 카드 전용이고, 여기 라벨은 오렌지다.
        color: isGood ? AppColors.good : AppColors.primary,
        borderRadius: BorderRadius.circular(12.5),
      ),
      child: Text(
        isGood ? 'GOOD' : 'BAD',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
