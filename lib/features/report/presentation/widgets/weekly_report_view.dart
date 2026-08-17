import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/kst_date.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import 'report_widgets.dart';
import 'score_trend_chart.dart';

/// 주간 리포트 탭.
///
/// **기록이 있으면 서버가 AI 문장을 만들어 붙이느라 최대 ~27초 걸린다.** 한 번의
/// 응답에 숫자와 문장이 같이 오는 구조라 앱이 둘을 나눠 받을 방법이 없다.
/// 그래서 로딩을 스피너 하나로 두지 않고 단계 문구가 넘어가는 [LoadingSteps] 를
/// 쓴다 — 피부 분석·인사이트가 같은 이유로 쓰던 위젯이다.
///
/// `Env.receiveTimeout` 이 32초라 앱이 서버보다 먼저 포기하지 않는다.
class WeeklyReportView extends ConsumerStatefulWidget {
  const WeeklyReportView({super.key});

  @override
  ConsumerState<WeeklyReportView> createState() => _WeeklyReportViewState();
}

/// `TabBarView` 는 화면 밖 자식을 살려 두지 않는다. 그대로 두면 탭을 한 번
/// 넘겼다 오는 것만으로 이 State 가 새로 만들어져 **보고 있던 주가 이번 주로
/// 되돌아가고**, autoDispose 프로바이더도 함께 버려져 최대 27초짜리 AI 생성이
/// 다시 돈다. 사용자가 한 것은 탭 두 번 누른 것뿐인데.
class _WeeklyReportViewState extends ConsumerState<WeeklyReportView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 오늘 포함 7일이 기본이다 — 서버의 기본 동작(`lastDays(7)`)과 같은 정의다.
  /// 달력 주가 아니라서 월요일에 리셋되지 않는다.
  static const _weekDays = 7;

  /// 몇 주 전을 보고 있는지. 0 이 이번 주다. **양수가 되지 않는다** —
  /// 미래는 서버가 막지 않고 빈 리포트를 주므로 앱이 막아야 한다.
  int _weeksAgo = 0;

  ({DateTime from, DateTime to}) get _range {
    final today = todayKst();
    final to = addDays(today, -_weeksAgo * _weekDays);
    return (from: addDays(to, -(_weekDays - 1)), to: to);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);   // AutomaticKeepAliveClientMixin 이 요구한다

    final range = _range;
    final report = ref.watch(weeklyReportProvider(range));

    return Column(
      children: [
        _RangeSelector(
          from: range.from,
          to: range.to,
          // 불러오는 중에는 양쪽 다 잠근다. 27초짜리 조회 위에서 화살표를
          // 연타하면 매번 다른 기간이라 요청이 그만큼 새로 나가고, Dio 는
          // 앞선 요청을 취소하지 않아 서버가 AI 를 그 횟수만큼 돌린다.
          canGoBack: !report.isLoading,
          // 이번 주보다 뒤로는 못 간다.
          canGoForward: !report.isLoading && _weeksAgo > 0,
          onShift: (weeks) => setState(() => _weeksAgo -= weeks),
        ),
        Expanded(
          child: report.when(
            loading: () => const LoadingSteps(steps: [
              '이번 주 기록을 모으고 있어요',
              '영양과 고민별 점수를 세는 중이에요',
              'AI가 이번 주를 정리하고 있어요',
            ]),
            error: (error, _) => _Retry(
              onRetry: () => ref.invalidate(weeklyReportProvider(range)),
            ),
            data: (result) => result.when(
              failure: (failure) => FailureView(
                failure: failure,
                onRetry: () => ref.invalidate(weeklyReportProvider(range)),
              ),
              success: (week) => RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(weeklyReportProvider(range).future),
                // 지난 주를 보고 있는데 "이번 주 점수"라고 쓰면 사용자가 날짜를
                // 넘긴 것을 잊고 오늘 숫자로 읽는다.
                child: _Body(report: week, current: _weeksAgo == 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ‹ 8.11 - 8.17 ›
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.from,
    required this.to,
    required this.canGoBack,
    required this.canGoForward,
    required this.onShift,
  });

  final DateTime from;
  final DateTime to;
  final bool canGoBack;
  final bool canGoForward;

  /// +1 이면 다음 주, -1 이면 이전 주.
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoBack ? () => onShift(-1) : null,
            icon: const Icon(Icons.chevron_left, size: 22),
            color: AppColors.textPrimary,
            tooltip: '이전 주',
          ),
          Expanded(
            child: Text(
              '${from.month}.${from.day} - ${to.month}.${to.day}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            // 미래 주는 잠근다. 열어 두면 빈 리포트가 뜨는데, 그건
            // "기록이 없다"와 구분되지 않는다.
            onPressed: canGoForward ? () => onShift(1) : null,
            icon: const Icon(Icons.chevron_right, size: 22),
            color: AppColors.textPrimary,
            tooltip: '다음 주',
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report, required this.current});

  final WeeklyReport report;

  /// 오늘이 든 기간을 보고 있는지. 문구가 "이번 주"인지 "이 기간"인지를 가른다.
  final bool current;

  @override
  Widget build(BuildContext context) {
    final comment = report.aiComment;
    final period = current ? '이번 주' : '이 기간';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        4,
        AppTheme.pagePadding,
        AppBottomNav.totalHeight + 16,
      ),
      children: [
        ReportScoreCard(
          title: '$period 피부 식단 점수',
          score: report.averageDailyScore,
          grade: report.grade,
          // 분모는 7일이 아니라 기록한 날이다. 그 사실이 화면에 보여야
          // 사용자가 "왜 5일치인데 평균이 이래?"를 묻지 않는다.
          footnote: report.isEmpty
              ? '$period에는 아직 기록이 없어요'
              : '${report.totalDays}일 중 ${report.recordedDays}일 기록 · '
                  '${report.recordCount}개',
        ),
        const SizedBox(height: 28),

        ReportSection(
          title: '일별 점수',
          subtitle: '기록이 없는 날은 비워 둡니다',
          child: report.dailyScores.isEmpty
              ? ReportEmpty(message: '$period에는 기록한 날이 없어요')
              : ScoreTrendChart(report: report),
        ),

        if (report.bestDay != null || report.worstDay != null) ...[
          const SizedBox(height: 28),
          _BestWorst(report: report, period: period),
        ],

        const SizedBox(height: 28),
        ReportSection(
          title: '주간 영양 밸런스',
          // 합계가 아니라는 것을 반드시 적는다. 안 적으면 사용자가 하루
          // 기준값과 견주는 막대를 주간 합계로 읽는다.
          subtitle: '기록한 날의 하루 평균이에요 · 섭취량 반영 추정치',
          child: NutritionBars(items: report.nutrition),
        ),
        const SizedBox(height: 28),

        ReportSection(
          title: '피부 고민 분석',
          subtitle: '변화량은 이번 기간 첫 기록일과 비교한 값이에요',
          child: ConcernList(items: report.concerns),
        ),
        const SizedBox(height: 28),

        // AI 가 실패해도 위의 점수·그래프·영양·고민은 전부 그대로 떠 있다.
        (comment != null && !comment.isEmpty)
            ? AiCard(
                title: 'AI 주간 분석',
                entries: [
                  if (comment.goodPoint != null)
                    (label: '잘한 점', text: comment.goodPoint!),
                  if (comment.improvePoint != null)
                    (label: '개선할 점', text: comment.improvePoint!),
                  if (comment.habit != null)
                    (label: '이번 주 습관', text: comment.habit!),
                  if (comment.nextWeek != null)
                    (label: '다음 주 제안', text: comment.nextWeek!),
                ],
              )
            : ReportEmpty(
                message: report.isEmpty
                    ? '기록이 쌓이면 AI가 $period를 정리해 드려요'
                    : 'AI 주간 분석을 가져오지 못했어요.\n점수와 그래프는 그대로 볼 수 있어요.',
              ),
      ],
    );
  }
}

/// 이번 주 BEST · 개선이 필요한 날. **동점 처리까지 서버가 정한 결과**라
/// 앱은 그대로 그린다.
class _BestWorst extends StatelessWidget {
  const _BestWorst({required this.report, required this.period});

  final WeeklyReport report;
  final String period;

  @override
  Widget build(BuildContext context) {
    final best = report.bestDay;
    final worst = report.worstDay;

    return Row(
      children: [
        if (best != null)
          Expanded(
              child: _DayCard(title: '$period BEST', day: best, best: true)),
        if (best != null && worst != null) const SizedBox(width: 12),
        if (worst != null)
          Expanded(
            child: _DayCard(title: '개선이 필요한 날', day: worst, best: false),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.title, required this.day, required this.best});

  final String title;
  final DayScore day;
  final bool best;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: best ? AppColors.good : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weekdayLabel(day.date)}요일',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnCard,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${day.dailyScore}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                '점',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('주간 리포트를 불러오지 못했어요.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
