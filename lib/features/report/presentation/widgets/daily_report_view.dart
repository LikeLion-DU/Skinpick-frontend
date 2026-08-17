import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import 'report_widgets.dart';

/// 오늘의 리포트 탭.
///
/// 한 번의 호출로 화면이 완성된다. **AI 를 부르지 않는 조회**라 즉시 온다 —
/// `aiComment` 는 기록을 저장할 때 이미 만들어져 저장돼 있던 문장이다.
class DailyReportView extends ConsumerStatefulWidget {
  const DailyReportView({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DailyReportView> createState() => _DailyReportViewState();
}

/// `TabBarView` 는 화면 밖 자식을 버린다. 살려 두지 않으면 탭을 넘길 때마다
/// 스켈레톤이 한 번 번쩍이고 조회가 다시 나간다 — 주간과 같은 이유다.
class _DailyReportViewState extends ConsumerState<DailyReportView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);   // AutomaticKeepAliveClientMixin 이 요구한다

    final date = widget.date;
    final report = ref.watch(dailyReportProvider(date));

    return report.when(
      loading: () => const ReportSkeleton(),
      // 여기까지 오는 것은 Result 로 감싸지 못한 예외뿐이다. 화면이 깨지지
      // 않도록 같은 재시도 통로를 둔다.
      error: (error, _) => _Retry(
        message: '리포트를 불러오지 못했어요.',
        onRetry: () => ref.invalidate(dailyReportProvider(date)),
      ),
      data: (result) => result.when(
        failure: (failure) => FailureView(
          failure: failure,
          onRetry: () => ref.invalidate(dailyReportProvider(date)),
        ),
        success: (daily) => RefreshIndicator(
          onRefresh: () => ref.refresh(dailyReportProvider(date).future),
          child: _Body(report: daily),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report});

  final DailyReport report;

  @override
  Widget build(BuildContext context) {
    final points = report.goodPoints.isNotEmpty || report.improvePoints.isNotEmpty;

    return ListView(
      // 내용이 한 화면보다 짧은 날(기록 0건)에도 당겨서 새로고침이 되게 한다.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        8,
        AppTheme.pagePadding,
        AppBottomNav.totalHeight + 16,
      ),
      children: [
        ReportScoreCard(
          title: '오늘의 종합 점수',
          score: report.dailyScore,
          grade: report.grade,
          footnote: report.isEmpty
              ? '아직 오늘 기록이 없어요'
              : '오늘 ${report.recordCount}개 기록했어요',
        ),
        const SizedBox(height: 28),

        ReportSection(
          title: '오늘의 영양 밸런스',
          // 결과 화면의 "1인분 기준"과 다른 숫자가 나오는 이유를 여기서 말한다.
          // 서버가 섭취량 계수(SMALL 0.7 · LARGE 1.3)를 곱해 합산한 값이라
          // 같은 음식이 두 화면에서 520 과 676kcal 로 갈린다. 앱이 맞추지 않는다 —
          // 두 화면이 다른 것을 재고 있다.
          subtitle: '기록한 끼니의 섭취량을 반영한 추정치예요',
          child: NutritionBars(items: report.nutrition),
        ),
        const SizedBox(height: 28),

        ReportSection(
          title: '내 피부 고민 기준 분석',
          subtitle: '고민과 관련된 항목만 다시 센 식단 점수예요',
          child: ConcernList(items: report.concerns),
        ),

        // 잘한 점·개선할 점은 기록이 있어야 생긴다. 없는 날 제목만 남기면
        // 사용자가 "불러오다 만 화면"으로 읽는다 — 섹션째 숨긴다.
        if (points) ...[
          const SizedBox(height: 28),
          if (report.improvePoints.isNotEmpty)
            ReportSection(
              title: '오늘의 개선 포인트',
              child: PointList(points: report.improvePoints, positive: false),
            ),
          if (report.improvePoints.isNotEmpty && report.goodPoints.isNotEmpty)
            const SizedBox(height: 24),
          if (report.goodPoints.isNotEmpty)
            ReportSection(
              title: '오늘 잘한 점',
              child: PointList(points: report.goodPoints, positive: true),
            ),
        ],

        const SizedBox(height: 28),
        // AI 문장이 없어도 리포트가 깨지지 않아야 한다. 자리는 지키고
        // 왜 비었는지만 알린다.
        report.aiComment != null
            ? AiCard(
                title: 'AI 오늘의 한마디',
                entries: [(label: null, text: report.aiComment!)],
              )
            : const ReportEmpty(
                message: '오늘의 AI 한마디는 아직 준비되지 않았어요.\n점수와 영양은 그대로 볼 수 있어요.',
              ),

        const SizedBox(height: 28),
        ReportSection(
          title: '오늘 먹은 음식',
          child: _Meals(report: report),
        ),
      ],
    );
  }
}

/// 끼니별로 묶어 보여준다. **그룹은 앱이 만든다** — 서버는 평평한 목록으로 준다.
class _Meals extends StatelessWidget {
  const _Meals({required this.report});

  final DailyReport report;

  @override
  Widget build(BuildContext context) {
    if (report.meals.isEmpty) {
      return const ReportEmpty(message: '오늘 기록된 음식이 없어요');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in report.byMealType) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              // 끼니를 모르면(서버가 새 값을 보냈다면) 라벨을 비운다.
              // 아무 끼니로나 떨어뜨리면 사용자가 자기 기록을 못 믿는다.
              group.key?.label ?? '기타',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          for (final meal in group.value)
            MealRow(
              meal: meal,
              onTap: () => context.push('${Routes.plateResult}/${meal.plateId}'),
            ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(Routes.plateHistory),
            child: const Text('전체 기록 보기'),
          ),
        ),
      ],
    );
  }
}

/// Result 로 감싸지 못한 예외용 재시도 화면. `FailureView` 와 같은 모양이다.
class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
