import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/score_grade.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/score_badge.dart';
import '../../data/datasources/plate_image_store.dart';
import '../../domain/entities/plate_history.dart';
import '../providers/plate_history_provider.dart';

/// S09 — 오늘의 기록. 시안대로 **하루 단위**로 보여주고 ‹ › 로 날짜를 넘긴다.
///
/// **저장한 것만 보인다.** 촬영해서 분석만 하고 나간 음식은 여기에 없다 —
/// 그게 분석과 기록을 나눈 이유다.
///
/// 사진은 서버가 주지 않는다. 기록이 확정될 때 앱이 기기에 남긴
/// `<documents>/plates/{plateId}.jpg` 를 읽는다. 없으면 음식 아이콘이다.
class PlateHistoryPage extends ConsumerStatefulWidget {
  const PlateHistoryPage({super.key});

  @override
  ConsumerState<PlateHistoryPage> createState() => _PlateHistoryPageState();
}

class _PlateHistoryPageState extends ConsumerState<PlateHistoryPage> {
  /// 보고 있는 날. 히스토리 provider 와 같은 KST 달력일 기준이다.
  late DateTime _selected;

  /// 조회 범위와 같은 7일. 이 밖으로는 화살표가 잠긴다 — 데이터가 없는 날로
  /// 보내 놓고 "기록이 없다"고 하면 조회를 안 한 것과 구분이 안 된다.
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toUtc().add(const Duration(hours: 9));
    _selected = DateTime(_today.year, _today.month, _today.day);
  }

  bool get _canGoBack =>
      _selected.isAfter(_today.subtract(const Duration(days: 6)));
  bool get _canGoForward => _selected
      .isBefore(DateTime(_today.year, _today.month, _today.day));

  void _shift(int days) =>
      setState(() => _selected = _selected.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(plateHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 기록')),
      body: Column(
        children: [
          _DateSelector(
            date: _selected,
            canGoBack: _canGoBack,
            canGoForward: _canGoForward,
            onShift: _shift,
          ),
          Expanded(
            child: RefreshIndicator(
              // invalidate 는 void 라 당기자마자 스피너가 접힌다. 요청이 끝날
              // 때까지 붙잡으려면 새 값을 기다려야 한다.
              onRefresh: () => ref.refresh(plateHistoryProvider.future),
              child: history.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => _Scrollable(children: [
                  Text('불러오지 못했습니다: $error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => ref.invalidate(plateHistoryProvider),
                      child: const Text('다시 시도'),
                    ),
                  ),
                ]),
                data: (result) => result.when(
                  failure: (failure) => FailureView(
                    failure: failure,
                    onRetry: () => ref.invalidate(plateHistoryProvider),
                  ),
                  success: (days) => _DayView(
                    day: _dayFor(days),
                    selected: _selected,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.records,
        onCapture: () => context.push(Routes.foodCapture),
        onTabSelected: (tab) {
          if (tab == AppTab.home) context.pop();
        },
      ),
    );
  }

  PlateHistoryDay? _dayFor(List<PlateHistoryDay> days) {
    for (final day in days) {
      if (day.date.year == _selected.year &&
          day.date.month == _selected.month &&
          day.date.day == _selected.day) {
        return day;
      }
    }
    return null;
  }
}

/// ‹ 8월 14일 › — 시안의 날짜 이동 줄.
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.date,
    required this.canGoBack,
    required this.canGoForward,
    required this.onShift,
  });

  final DateTime date;
  final bool canGoBack;
  final bool canGoForward;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoBack ? () => onShift(-1) : null,
            icon: const Icon(Icons.chevron_left, size: 22),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              '${date.month}월 ${date.day}일',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          IconButton(
            onPressed: canGoForward ? () => onShift(1) : null,
            icon: const Icon(Icons.chevron_right, size: 22),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.day, required this.selected});

  final PlateHistoryDay? day;
  final DateTime selected;

  @override
  Widget build(BuildContext context) {
    if (day == null || day!.plates.isEmpty) {
      return const _Scrollable(
        children: [Center(child: Text('이날 저장한 기록이 없어요'))],
      );
    }

    // 시안은 아침→점심→저녁 순서로 그린다. 서버는 최신순으로 주므로 뒤집는다.
    final ordered = day!.plates.reversed.toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 8, AppTheme.pagePadding,
          AppBottomNav.totalHeight + 16),
      children: [
        for (final item in ordered)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _MealCard(item: item),
          ),
        if (day!.aiComment != null) _AiCommentCard(comment: day!.aiComment!),
        const SafetyNotice(),
      ],
    );
  }
}

/// 끼니 하나의 카드. 시안 수치 — 높이 241 · 사진 120 · 모서리 9.
class _MealCard extends ConsumerWidget {
  const _MealCard({required this.item});

  final PlateHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ScoreGrade.fromScore(item.plateScore);
    final time = '${item.recordedAt.hour}:'
        '${item.recordedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderOnWhite),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.mealType != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: const Color(0xFFFF9362)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item.mealType!.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(plateId: item.plateId),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('피부 적합도',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textOnCard,
                        )),
                    Row(
                      children: [
                        Text(
                          '${item.plateScore}점',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            // 시안이 주의 점수를 빨강이 아니라 오렌지로 쓴다.
                            // 빨강은 BAD 라벨 전용이다.
                            color: grade == ScoreGrade.good
                                ? AppColors.good
                                : AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        ScoreBadge(grade: grade, solid: true),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderOnWhite),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    context.push('${Routes.plateResult}/${item.plateId}'),
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  children: [
                    Text('분석 결과 보기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textOnCard,
                        )),
                    Icon(Icons.chevron_right,
                        size: 16, color: AppColors.textOnCard),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "오늘의 AI 코멘트" — 시안의 그라디언트 크림 카드.
/// 문장은 기록을 저장할 때 서버가 만들어 둔 것이다. 여기서 생성하지 않는다.
class _AiCommentCard extends StatelessWidget {
  const _AiCommentCard({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFEF7F0), Color(0xFFFFF2E4)],
        ),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 AI 코멘트',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
          const SizedBox(height: 12),
          Text(comment,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF411B09),
                height: 1.32,
              )),
        ],
      ),
    );
  }
}

/// 내용이 한 화면보다 짧아도 당겨서 새로고침이 되게 한다.
/// Center 만 두면 스크롤 여지가 없어 RefreshIndicator 가 영영 안 뜬다.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      children: children,
    );
  }
}

/// 로컬 파일이 있으면 사진, 없으면 음식 아이콘. 시안 크기 120 이다.
///
/// `existsSync()` 를 미리 부르지 않는다 — 파일이 사라진 경우와 읽기가 실패한
/// 경우를 따로 다룰 이유가 없고, `errorBuilder` 가 두 경우를 다 받아낸다.
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.plateId});

  final int plateId;

  static const double _size = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(plateImageDirectoryProvider).valueOrNull;
    if (directory == null) return const _FoodIcon(size: _size);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        PlateImageStore.fileFor(directory, plateId),
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        // 원본을 그대로 디코드하면 일주일치가 이미지 캐시 예산을 넘긴다.
        // 기기 배율에 맞는 크기로만 디코드한다.
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (_, __, ___) => const _FoodIcon(size: _size),
      ),
    );
  }
}

class _FoodIcon extends StatelessWidget {
  const _FoodIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, size: size / 3, color: AppColors.outline),
    );
  }
}
