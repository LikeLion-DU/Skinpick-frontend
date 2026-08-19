import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

import '../../../../shared/enums/skin_level.dart';

/// 분석 결과 맨 위의 "내 피부 적합도" 카드.
///
/// 시안 수치 그대로다 — 크림 배경(#FEF7F0) · 테두리 #FFDFD1 · 높이 156.
/// 오른쪽의 원형 게이지는 시안이 SVG 호 두 장으로 그려 놓았는데, 점수마다
/// 호의 길이가 달라져야 하므로 이미지 대신 CustomPaint 로 그린다.
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: grade.tintColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grade.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: grade.accentColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
