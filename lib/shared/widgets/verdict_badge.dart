import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../enums/skin_level.dart';
import 'pill.dart';

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

    return Pill(
      // 시안 값은 53×19 지만 **고정하지 않는다.** 글자 크기 2.0 에서 'GOOD' 이
      // 81×29 를 요구하는데, 고정 상자는 예외를 던지지 않고 조용히 'GOO' 로
      // 자른다 — 그래서 배율 테스트도 통과했다.
      minWidth: 53,
      minHeight: 19,
      // 좌우 6 이면 기본 크기에서 minWidth 53 이 그대로 폭을 정한다(글자 26 + 12).
      // 8 로 두어도 실기기에서는 53 이 이기지만, 여유를 좁혀 두면 폰트를 바꿀 때
      // 알약이 먼저 넓어지는 것을 눈으로 알아챈다.
      horizontalPadding: 6,
      borderRadius: 12.5,
      // **라벨은 오렌지다.** 숫자는 등급색(주의=빨강)을 따르고 라벨은 두 단으로
      // 접힌 판정이라 오렌지 하나다 — 기록·음식 결과 두 화면이 같은 조합을 쓴다.
      // 라벨까지 빨강으로 칠하면 한 줄에 같은 색이 둘이 되어 어느 쪽이 판정인지
      // 흐려진다.
      color: isGood ? AppColors.good : AppColors.primary,
      label: isGood ? 'GOOD' : 'BAD',
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
