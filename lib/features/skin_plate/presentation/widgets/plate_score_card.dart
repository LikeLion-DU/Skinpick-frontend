import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

import '../../../../shared/enums/skin_level.dart';

/// 음식 결과 화면의 큰 점수 한 줄 — 숫자 + "점" + 등급 배지.
///
/// **카드도 게이지도 캡션도 없다.** 확정 시안이 이 자리를 크림 카드에서 배경 위
/// 큰 숫자로 바꿨다("내 피부 적합도" 라는 제목 줄도 시안에 없다). 무엇을 매긴
/// 점수인지는 바로 아래 [SkinBasisLine] 이 말한다.
/// 이름에 Card 가 남은 것은 호출부 두 곳의 이름을 유지하기 위해서다.
///
/// **채점 기준 문구(basisLabel)를 여기 다시 만들지 마라.** 자가신고 피부 타입을
/// 넣었다가 "잘 모르겠어요 피부 기준" 이 그대로 화면에 떴다. 음식 판정은 실제
/// 측정 지표로 하므로 기준을 말하는 자리는 [SkinBasisLine] 하나다.
class PlateScoreCard extends StatelessWidget {
  const PlateScoreCard({super.key, required this.score, required this.grade});

  final int score;

  /// 서버가 매긴 등급. **앱이 점수에서 다시 내지 않는다** — 경계표가 두 벌이 되면
  /// 서버가 경계를 옮긴 날 같은 점수가 화면마다 다른 등급으로 뜬다.
  ///
  /// 모르면(옛 서버) 숫자를 기본 잉크색으로 그리고 배지를 뺀다.
  final SkinLevel? grade;

  @override
  Widget build(BuildContext context) {
    final grade = this.grade;
    final numberColor = grade?.accentColor ?? AppColors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 세 자리 점수(100점)가 와도 배지가 밀려나지 않도록 줄을 줄여서 맞춘다.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: numberColor,
                  ),
                ),
                Text(
                  '점',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: numberColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (grade != null) ...[
          const SizedBox(width: 12),
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: grade.tintColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                grade.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: grade.accentColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
