import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/score_grade.dart';
import '../../../../shared/widgets/score_badge.dart';
import '../../domain/entities/plate_history.dart';
import '../../domain/entities/weekly_report.dart';
import '../providers/weekly_report_provider.dart';
import '../widgets/weekly_summary_card.dart';

/// 주간 피부 식단 리포트.
///
/// 주인공은 **음식**이다. 피부 점수 추이는 서버가 `/reports` 로 같이 내려주지만
/// 그리지 않는다 — 이 화면이 답하는 질문은 "이번 주 나는 어떤 음식을 잘
/// 골랐는가" 하나다. 피부 변화는 피부 프로필이 맡는다.
class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(weeklyReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('피부 식단 리포트')),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('불러오지 못했습니다: $error')),
        data: (result) => result.when(
          failure: (failure) => FailureView(
            failure: failure,
            onRetry: () => ref.invalidate(weeklyReportProvider),
          ),
          success: (week) => RefreshIndicator(
            onRefresh: () => ref.refresh(weeklyReportProvider.future),
            child: _Body(week: week),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.week});

  final WeeklyReport week;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // 기록이 없는 주는 내용이 화면보다 짧아 스크롤 여지가 없다. 그러면 당겨도
      // 오버스크롤이 안 잡혀 새로고침이 먹지 않는다 — 하필 사용자가 가장 당겨
      // 보고 싶은 상태다("방금 기록했는데 왜 비어 있지").
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 14, AppTheme.pagePadding, 32),
      children: [
        Text(
          '${week.from.month}월 ${week.from.day}일 ~ '
          '${week.to.month}월 ${week.to.day}일',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),

        if (week.isEmpty)
          const _EmptyWeek()
        else ...[
          _AverageCard(week: week),
          const SizedBox(height: 24),

          // 잘 맞았던 음식이 하나도 없는 주가 있다. 그럴 때 빈 제목만 남기면
          // 사용자가 "불러오다 만 화면"으로 읽는다 — 섹션째 숨긴다.
          if (week.bestFoods.isNotEmpty) ...[
            _FoodSection(
              title: '이번 주 잘 맞았던 음식',
              foods: week.bestFoods,
            ),
            const SizedBox(height: 24),
          ],
          if (week.cautionFoods.isNotEmpty)
            _FoodSection(
              title: '주의가 필요했던 음식',
              foods: week.cautionFoods,
            ),
        ],
      ],
    );
  }
}

/// 이번 주 평균 + 기록 수 + 지난주 대비.
///
/// 평균과 기록 수는 **서버가 센 값 그대로**다(`GET /reports?period=WEEK`).
/// 앱이 같은 기록으로 평균을 다시 내면 반올림이 어긋나는 날 두 숫자가 생긴다.
class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.week});

  final WeeklyReport week;

  @override
  Widget build(BuildContext context) {
    final score = week.averageScore;
    final grade = score == null ? null : ScoreGrade.fromScore(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        children: [
          const Text(
            '이번 주 피부 식단 점수',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnCard,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score?.toString() ?? 'OO',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const Text(
                '점',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              if (grade != null) ...[
                const SizedBox(width: 8),
                ScoreBadge(grade: grade),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const ScoreDeltaLabel(),
          const SizedBox(height: 18),
          Text(
            '이번 주 ${week.recordCount}회 기록했어요',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  const _FoodSection({required this.title, required this.foods});

  final String title;
  final List<PlateHistoryItem> foods;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final food in foods)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                // 음식명이 길면 줄이 아니라 점수를 밀어낸다. 좁은 기기에서
                // 점수가 화면 밖으로 나가지 않도록 이름 쪽만 늘린다.
                Expanded(
                  child: Text(
                    food.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${food.plateScore}점',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                ScoreBadge(
                    grade: ScoreGrade.fromScore(food.plateScore), solid: true),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyWeek extends StatelessWidget {
  const _EmptyWeek();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.insert_chart_outlined,
              size: 40, color: AppColors.borderEmptySlot),
          const SizedBox(height: 14),
          Text(
            '이번 주에는 아직 기록이 없어요.\n음식을 찍으면 여기에 쌓입니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
