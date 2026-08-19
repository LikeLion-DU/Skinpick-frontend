import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/kst_date.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../skin_plate/data/datasources/plate_image_store.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';
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
    super.build(context); // AutomaticKeepAliveClientMixin 이 요구한다

    final range = _range;
    final report = ref.watch(weeklyReportProvider(range));
    final from = range.from;
    final to = range.to;

    return Column(
      children: [
        ReportDateNav(
          // 시안 표기 그대로다 — `26.8.3(월) ~ 8.9(일)`. 연도를 앞에 두 자리만
          // 쓰는 것은 폭 때문이다. 같은 해의 끝 날짜에 연도를 다시 적지 않는다.
          //
          // 연도는 **시작일**의 것이다. `to.year` 를 쓰면 해를 넘는 주가
          // `27.12.28(월) ~ 1.3(일)` 로 12월 28일을 다음 해로 적는다.
          label: '${from.year % 100}.${from.month}.${from.day}'
              '(${weekdayLabel(from)}) ~ '
              '${to.month}.${to.day}(${weekdayLabel(to)})',
          // 불러오는 중에는 양쪽 다 잠근다. 27초짜리 조회 위에서 화살표를
          // 연타하면 매번 다른 기간이라 요청이 그만큼 새로 나가고, Dio 는
          // 앞선 요청을 취소하지 않아 서버가 AI 를 그 횟수만큼 돌린다.
          canGoBack: !report.isLoading,
          // 이번 주보다 뒤로는 못 간다.
          canGoForward: !report.isLoading && _weeksAgo > 0,
          onShift: (weeks) => setState(() => _weeksAgo -= weeks),
          backTooltip: '이전 주',
          forwardTooltip: '다음 주',
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
        20,
        6,
        20,
        AppBottomNav.totalHeight + 16,
      ),
      children: [
        // 시안은 점수 배너와 그래프를 **한 카드 안**에 둔다. 평균 점수는 그래프의
        // 요약이라, 카드를 나누면 둘이 다른 것을 재는 숫자처럼 보인다.
        ReportCard(
          title: '$period 피부 식단 점수',
          note: '기록이 없는 날은 비워 둡니다',
          child: Column(
            children: [
              _AverageBanner(report: report, period: period),
              const SizedBox(height: 18),
              if (report.dailyScores.isEmpty)
                ReportEmpty(message: '$period에는 기록한 날이 없어요')
              else
                ScoreTrendChart(report: report),
            ],
          ),
        ),

        if (report.bestDay != null || report.worstDay != null) ...[
          const SizedBox(height: 19),
          _BestWorst(report: report, period: period),
        ],

        const SizedBox(height: 19),
        ReportCard(
          title: '$period 영양 밸런스',
          // 합계가 아니라는 것을 반드시 적는다. 안 적으면 사용자가 하루
          // 기준값과 견주는 막대를 주간 합계로 읽는다.
          note: '기록한 날의 하루 평균이에요 · 섭취량 반영 추정치',
          child: NutritionRows(items: report.nutrition),
        ),
        const SizedBox(height: 19),

        ReportCard(
          title: '피부 고민 분석',
          note: '변화량은 이번 기간 첫 기록일과 비교한 값이에요',
          child: ConcernList(
            items: report.concerns,
            hasRecords: !report.isEmpty,
          ),
        ),
        const SizedBox(height: 19),

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

/// 그래프 위의 평균 배너. 큰 숫자 하나와 분모 한 줄이다.
///
/// 점수가 없으면 `OO점` 이다 — 0 은 "아주 나쁘게 먹었다"고 이건 "아직 안
/// 찍었다"라서, 같은 자리에 같은 숫자로 쓰면 안 된다.
class _AverageBanner extends StatelessWidget {
  const _AverageBanner({required this.report, required this.period});

  final WeeklyReport report;
  final String period;

  @override
  Widget build(BuildContext context) {
    final score = report.averageDailyScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              // 분모는 7일이 아니라 기록한 날이다. 그 사실이 화면에 보여야
              // 사용자가 "왜 5일치인데 평균이 이래?"를 묻지 않는다.
              report.isEmpty
                  ? '$period에는 아직 기록이 없어요'
                  : '${report.totalDays}일 중 ${report.recordedDays}일 기록 · '
                      '${report.recordCount}개',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score?.toString() ?? 'OO',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: score == null ? AppColors.outline : AppColors.primary,
                ),
              ),
              const Text(
                '점',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 이번 주 BEST · 개선이 필요한 날. **동점 처리까지 서버가 정한 결과**라
/// 앱은 그대로 그린다.
///
/// 시안대로 그날 먹은 음식 썸네일을 붙인다. 서버가 `plateIds` 를 함께 보내 주므로
/// 앱이 그 id 로 로컬 사진(`plates/{plateId}.jpg`)을 찾는다 — 서버에 이미지는
/// 없다(PRD §9.6). **사진이 없으면 자리를 비우지 않고 음식 아이콘을 둔다** —
/// 다른 기기에서 저장한 기록은 이 기기에 파일이 없다.
class _BestWorst extends StatelessWidget {
  const _BestWorst({required this.report, required this.period});

  final WeeklyReport report;
  final String period;

  @override
  Widget build(BuildContext context) {
    final best = report.bestDay;
    final worst = report.worstDay;

    // 두 카드의 높이를 맞춘다. `stretch` 만 쓰면 ListView 안에서 세로가
    // 무한 제약으로 내려가 레이아웃이 죽는다 — 높이를 재 줄 사람이 필요하다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (best != null)
            Expanded(
                child: _DayCard(title: '$period BEST', day: best, best: true)),
          if (best != null && worst != null) const SizedBox(width: 11),
          if (worst != null)
            Expanded(
              child: _DayCard(title: '개선이 필요한 날', day: worst, best: false),
            ),
        ],
      ),
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
    // 제목("BEST" · "개선이 필요한 날")은 그 주 안에서의 **상대 위치**다. 색은
    // 서버가 그 점수에 매긴 **절대 등급**을 따른다 — 둘을 한 벌로 묶으면 전부
    // 90점대인 주의 최저일(92점·좋음)이 경고색으로 뜨고, 같은 92 가 옆 카드에서는
    // 초록으로 뜬다. 등급을 모르면 상대 위치 색으로 떨어진다.
    final accent = day.grade?.accentColor ??
        (best ? AppColors.good : AppColors.accentStrong);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.disabled, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${weekdayLabel(day.date)}요일',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // BEST/WORST 는 한 줄에 두 장이라 카드 폭이 절반이다. 큰 숫자(26)와
          // 날짜를 글자 크기 2.0 으로 함께 키우면 72px 넘친다 — 이 줄만 배율을
          // 1.3 까지 따른다. 요일·썸네일은 그대로 다 커진다.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${day.dailyScore}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Text(
                  '점',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                Text(
                  '${day.date.month}.${day.date.day}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 서버가 준 id 로 그날 사진을 찾는다. id 가 없는 응답(이 필드 이전 서버)
          // 이면 빈 배열이라 줄이 사라진다.
          if (day.plateIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DayThumbnails(plateIds: day.plateIds),
          ],
        ],
      ),
    );
  }
}

/// 그날 먹은 음식 썸네일. 시안이 세 칸을 그리므로 세 개까지만 보여준다 —
/// 네 끼 이상 기록한 날에 카드가 늘어나면 두 카드의 높이가 어긋난다.
///
/// **폭을 고정하지 않는다.** 시안 값 44 를 세 칸 박아 두면 시안 폭(402)에서도
/// 2.5px 넘친다 — 이 카드는 화면을 반으로 나눈 폭이라 44×3 + 여백이 들어가지 않는다.
/// 높이만 44 로 두고 폭은 남는 자리를 나눈다.
///
/// `LayoutBuilder` 로 재지 않는 이유는 이 위젯이 [_BestWorst] 의 `IntrinsicHeight`
/// 안에 있기 때문이다 — 고유 높이를 물어보는 부모 밑에서는 LayoutBuilder 가 죽는다.
///
/// 기록이 한두 끼뿐인 날은 칸이 정사각형보다 넓어진다. 억지로 세 칸을 채우지
/// 않는다 — 빈 칸을 만들면 안 찍은 끼니가 "사진을 못 찾은 끼니"로 보인다.
class _DayThumbnails extends ConsumerWidget {
  const _DayThumbnails({required this.plateIds});

  final List<int> plateIds;

  static const int _maxCount = 3;
  static const double _height = 44;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(plateImageDirectoryProvider).valueOrNull;
    final ids = plateIds.take(_maxCount).toList();
    final hidden = plateIds.length - ids.length;

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          for (final (index, plateId) in ids.indexed)
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: index == ids.length - 1 ? 0 : _gap),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: directory == null
                      ? const _MissingThumbnail()
                      : Image.file(
                          PlateImageStore.fileFor(directory, plateId),
                          height: _height,
                          fit: BoxFit.cover,
                          // 작은 칸에 원본을 그대로 디코드하면 캐시를 먹는다.
                          // 폭이 유동이라 높이 기준으로 잡는다.
                          cacheHeight:
                              (_height * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          // 다른 기기에서 저장한 기록은 이 기기에 파일이 없다.
                          errorBuilder: (_, __, ___) =>
                              const _MissingThumbnail(),
                        ),
                ),
              ),
            ),
          // 네 끼 이상 먹은 날은 칸이 모자란다. **말없이 자르지 않는다** —
          // 세 장만 보이면 그날 기록이 셋인 줄로 읽힌다.
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.only(left: _gap),
              child: Text(
                '+$hidden',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 사진을 못 찾은 자리. 비워 두지 않는다 — 빈 칸은 "불러오는 중"으로 읽힌다.
class _MissingThumbnail extends StatelessWidget {
  const _MissingThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E7E6),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, size: 18, color: AppColors.outline),
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
