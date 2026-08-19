import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/utils/kst_date.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import 'report_widgets.dart';

/// 오늘의 리포트 탭.
///
/// 한 번의 호출로 화면이 완성된다. **AI 를 부르지 않는 조회**라 즉시 온다 —
/// `aiComment` 는 기록을 저장할 때 이미 만들어져 저장돼 있던 문장이다.
///
/// 확정 시안이 **날짜 이동 화살표**를 넣었다. 그래서 보고 있는 날이 이 State 에
/// 있다 — 화면 밖으로 올려 두면 탭을 넘길 때 오늘로 되돌아간다.
class DailyReportView extends ConsumerStatefulWidget {
  const DailyReportView({super.key, required this.date});

  /// 화면을 열었을 때의 KST 오늘. 화살표로 움직이는 기준점이다.
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

  /// 며칠 전을 보고 있는지. 0 이 오늘이다. **음수가 되지 않는다** —
  /// 미래는 서버가 막지 않고 빈 리포트를 주므로 앱이 막아야 한다.
  int _daysAgo = 0;

  DateTime get _date => addDays(widget.date, -_daysAgo);

  @override
  Widget build(BuildContext context) {
    super.build(context);   // AutomaticKeepAliveClientMixin 이 요구한다

    final date = _date;
    final report = ref.watch(dailyReportProvider(date));

    return Column(
      children: [
        ReportDateNav(
          label: '${date.year}년 ${date.month}월 ${date.day}일 '
              '(${weekdayLabel(date)})',
          canGoBack: !report.isLoading,
          // 오늘보다 앞으로는 못 간다.
          canGoForward: !report.isLoading && _daysAgo > 0,
          onShift: (days) => setState(() => _daysAgo -= days),
          backTooltip: '이전 날',
          forwardTooltip: '다음 날',
        ),
        Expanded(
          child: report.when(
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
                child: _Body(report: daily, isToday: _daysAgo == 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report, required this.isToday});

  final DailyReport report;

  /// 오늘을 보고 있는지. 문구가 "오늘"인지 "이 날"인지를 가른다 — 날짜를
  /// 넘겨 놓고 "오늘 3개 기록했어요"를 읽으면 사용자가 날짜를 잊는다.
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final day = isToday ? '오늘' : '이 날';
    final points =
        report.goodPoints.isNotEmpty || report.improvePoints.isNotEmpty;

    return ListView(
      // 내용이 한 화면보다 짧은 날(기록 0건)에도 당겨서 새로고침이 되게 한다.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        6,
        20,
        AppBottomNav.totalHeight + 16,
      ),
      children: [
        ReportScoreCard(
          score: report.dailyScore,
          grade: report.grade,
          footnote: report.isEmpty
              ? '아직 $day 기록이 없어요'
              : '$day ${report.recordCount}개 기록했어요',
        ),
        const SizedBox(height: 19),

        ReportCard(
          title: '영양 밸런스',
          // 결과 화면의 "1인분 기준"과 다른 숫자가 나오는 이유를 여기서 말한다.
          // 서버가 섭취량 계수(SMALL 0.7 · LARGE 1.3)를 곱해 합산한 값이라
          // 같은 음식이 두 화면에서 520 과 676kcal 로 갈린다. 앱이 맞추지 않는다 —
          // 두 화면이 다른 것을 재고 있다.
          note: '기록한 끼니의 섭취량을 반영한 추정치예요',
          child: NutritionTiles(items: report.nutrition),
        ),
        const SizedBox(height: 19),

        // 시안이 영양 밸런스와 **다른 카드**로 그리는 묶음이다. 서버도 배열을 따로
        // 내려보낸다 — 단위가 mg·회로 다르고, 무엇보다 측정 가능 여부가 다르다.
        // 이 필드가 없던 서버와 붙으면 빈 배열이라 카드째 사라진다.
        if (report.skinNutrients.isNotEmpty) ...[
          ReportCard(
            title: '피부 영양 포인트',
            // 표준 음식표에서 찾은 끼니만 실측값이 있다. 그 사실을 적지 않으면
            // "알 수 없음"이 오류로 읽힌다.
            note: '표준 음식표에서 찾은 끼니만 실측값이 있어요',
            child: NutritionTiles(items: report.skinNutrients),
          ),
          const SizedBox(height: 19),
        ],

        // AI 문장이 없어도 리포트가 깨지지 않아야 한다. 자리는 지키고
        // 왜 비었는지만 알린다.
        report.aiComment != null
            ? AiCard(
                title: 'AI $day의 한마디',
                entries: [(label: null, text: report.aiComment!)],
              )
            : const ReportEmpty(
                message: 'AI 한마디는 아직 준비되지 않았어요.\n점수와 영양은 그대로 볼 수 있어요.',
              ),
        const SizedBox(height: 19),

        ReportCard(
          title: '내 피부 고민 기준 분석',
          note: '고민과 관련된 항목만 다시 센 식단 점수예요',
          child: ConcernList(
            items: report.concerns,
            hasRecords: !report.isEmpty,
          ),
        ),

        // 잘한 점·개선할 점은 기록이 있어야 생긴다. 없는 날 제목만 남기면
        // 사용자가 "불러오다 만 화면"으로 읽는다 — 카드째 숨긴다.
        if (points) ...[
          const SizedBox(height: 19),
          ReportCard(
            title: '$day의 식단 포인트',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.improvePoints.isNotEmpty)
                  PointList(points: report.improvePoints, positive: false),
                if (report.improvePoints.isNotEmpty &&
                    report.goodPoints.isNotEmpty)
                  const SizedBox(height: 10),
                if (report.goodPoints.isNotEmpty)
                  PointList(points: report.goodPoints, positive: true),
              ],
            ),
          ),
        ],

        const SizedBox(height: 19),
        ReportCard(
          title: '$day 먹은 음식',
          child: _Meals(report: report, day: day),
        ),
      ],
    );
  }
}

/// 끼니 순서로 늘어놓는다. **정렬은 앱이 한다** — 서버는 평평한 목록으로 주고
/// 순서가 기록 시각이라, 아침을 저녁보다 늦게 저장하면 순서가 뒤집힌다.
///
/// 시안은 끼니 라벨을 그룹 머리글이 아니라 **줄 안**에 둔다. 하루에 같은 끼니가
/// 둘이면 라벨이 두 번 나오는데, 그게 머리글 하나에 두 줄이 매달린 모양보다
/// 읽기 쉽다 — 줄만 보고 어느 끼니인지 알 수 있다.
class _Meals extends StatelessWidget {
  const _Meals({required this.report, required this.day});

  final DailyReport report;
  final String day;

  @override
  Widget build(BuildContext context) {
    if (report.meals.isEmpty) {
      return ReportEmpty(message: '$day 기록된 음식이 없어요');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in report.byMealType)
          for (final meal in group.value)
            MealRow(
              meal: meal,
              onTap: () => context.push('${Routes.plateResult}/${meal.plateId}'),
            ),
        const SizedBox(height: 6),
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
