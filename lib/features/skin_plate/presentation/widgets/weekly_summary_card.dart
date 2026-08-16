import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/weekly_report_provider.dart';

/// 홈과 기록 화면에 같이 붙는 "이번 주 피부 식단" 요약 카드.
///
/// 위젯 하나를 두 곳에서 쓴다. 각자 그리면 한쪽만 고쳐지고, 같은 주가 두 화면에서
/// 다르게 보이는 순간 사용자는 두 숫자를 다 의심한다.
///
/// **불러오는 중이거나 실패했거나 이번 주 기록이 0건이면 아무것도 그리지 않는다.**
/// 리포트는 부가 정보라 이것 때문에 홈이 스피너를 띄우거나 오류를 보여줄 이유가
/// 없다. 기록이 쌓이면 카드가 저절로 나타난다.
class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // valueOrNull 이다. `.value` 는 에러 상태에서 예외를 **되던진다** — 리포트를
    // 못 불러왔다는 이유로 홈 전체가 빨간 화면이 된다.
    final report = ref.watch(weeklyReportProvider).valueOrNull?.dataOrNull;
    if (report == null || report.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push(Routes.weeklyReport),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
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
                    '이번 주 피부 식단',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnCard,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '평균 ${report.averageScore ?? 'OO'}점',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const ScoreDeltaLabel.compact(),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// 지난주 대비 증감. 비교할 지난주가 없으면 **아무것도 쓰지 않는다** —
/// 없는 주를 0 으로 놓고 빼면 첫 주에 "+78점 상승"이 뜬다.
class ScoreDeltaLabel extends ConsumerWidget {
  const ScoreDeltaLabel({super.key}) : _compact = false;
  const ScoreDeltaLabel.compact({super.key}) : _compact = true;

  final bool _compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delta =
        ref.watch(weeklyReportProvider).valueOrNull?.dataOrNull?.scoreDelta;
    if (delta == null) {
      return _compact
          ? const SizedBox.shrink()
          : Text(
              '지난주에는 기록이 없어 비교할 수 없어요',
              style: Theme.of(context).textTheme.bodySmall,
            );
    }

    // 같은 점수면 화살표를 그리지 않는다. 0 에 ↑ 나 ↓ 를 붙이면 방향이 생긴다.
    final (icon, color) = switch (delta) {
      > 0 => (Icons.arrow_upward, AppColors.good),
      < 0 => (Icons.arrow_downward, AppColors.bad),
      _ => (null, AppColors.textSecondary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '지난주 대비 ${delta > 0 ? '+' : ''}$delta점',
          style: TextStyle(
            fontSize: _compact ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (icon != null) Icon(icon, size: _compact ? 12 : 16, color: color),
      ],
    );
  }
}
