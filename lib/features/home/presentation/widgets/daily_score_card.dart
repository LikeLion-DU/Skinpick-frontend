import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/widgets/score_badge.dart';

/// 홈 맨 위의 "오늘의 피부 식단 점수" 카드.
///
/// 기록이 없는 날에는 시안이 점수 자리에 `OO점` 을 두고 안내 문구를 보여준다.
/// 0점을 쓰지 않는 이유가 분명하다 — 0점은 "아주 나쁘게 먹었다"로 읽힌다.
/// 아직 아무것도 안 먹은 것과 나쁘게 먹은 것은 다르다.
class DailyScoreCard extends StatelessWidget {
  const DailyScoreCard({
    super.key,
    required this.nickname,
    required this.score,
    required this.targetScore,
  });

  final String nickname;

  /// 그날 기록이 없으면 null. 서버가 준 평균을 그대로 받는다.
  final int? score;

  final int targetScore;

  @override
  Widget build(BuildContext context) {
    // 히스토리 응답에는 grade 필드가 없어 점수에서 낸다. 경계는 서버와 같은
    // 표(SkinLevel.fromScore)를 지나므로 리포트와 등급이 갈리지 않는다.
    final grade = score == null ? null : SkinLevel.fromScore(score!);

    return Container(
      height: 156,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 피부 식단 점수',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnCard,
                  ),
                ),
                const SizedBox(height: 8),
                _ScoreLine(score: score, grade: grade),
                const Spacer(),
                if (score == null)
                  Text(
                    '오늘은 뭘 드셨나요?\n$nickname님의 식단을 찍어보세요!',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  _Progress(score: score!, targetScore: targetScore),
              ],
            ),
          ),
          // 기록이 없을 때는 빈 원이다. 시안이 자리를 비워 두지 않는다 —
          // 채워질 곳이라는 걸 보여 주는 편이 낫다.
          Container(
            width: 67,
            height: 67,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.score, required this.grade});

  final int? score;
  final SkinLevel? grade;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          score?.toString() ?? 'OO',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        const Text(
          '점',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        if (grade != null) ...[
          const SizedBox(width: 8),
          ScoreBadge(grade: grade!),
        ],
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.score, required this.targetScore});

  final int score;
  final int targetScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            // 목표를 넘긴 날 막대가 넘치지 않도록 자른다. 100 점을 목표 80 으로
            // 나누면 1.25 가 되는데, 그대로 넘기면 렌더가 깨진다.
            value: (score / targetScore).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '목표 $targetScore점',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
