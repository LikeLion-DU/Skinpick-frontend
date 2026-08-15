import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../data/datasources/skin_profile_store.dart';
import '../../domain/entities/skin_profile.dart';
import '../providers/auth_notifier.dart';

/// S01c — 피부 프로필 설문. 확정 시안의 한 페이지 설문이다:
/// 피부 타입(필수) · 주요 피부 고민(복수, 필수) · 생활 습관 3종(선택).
///
/// 타입은 서버로 간다(`PATCH /auth/me`). **타입은 점수 계산에 들어가지
/// 않는다** — 자가 신고값이 점수에 개입하면 "같은 사진 두 번 찍어도 같은
/// 점수"라는 주장이 무너진다. 쓰이는 곳은 결과 화면의 갭 카드다. (PRD §4.4.1)
///
/// 고민·습관은 서버에 컬럼이 없어 기기에 저장한다([SkinProfileStore]).
class SkinTypePage extends ConsumerStatefulWidget {
  const SkinTypePage({super.key});

  @override
  ConsumerState<SkinTypePage> createState() => _SkinTypePageState();
}

class _SkinTypePageState extends ConsumerState<SkinTypePage> {
  SkinType? _type;
  final Set<SkinConcern> _concerns = {};
  SleepPattern? _sleep;
  StressLevel? _stress;
  ExerciseHabit? _exercise;

  /// 어느 습관 줄이 펼쳐져 있는지. 시안이 한 번에 하나만 펼친다.
  _HabitRow? _expanded;

  bool _busy = false;
  String? _error;

  static const _store = SkinProfileStore(FlutterSecureStorage());

  bool get _complete => _type != null && _concerns.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 홈의 "피부 프로필 수정"으로 다시 들어온 사용자다. 저장해 둔 답을 깔아
    // 두지 않으면 빈 설문이 뜨고, 제출이 이전 답(습관 포함)을 전부 null 로
    // 덮어쓴다 — 저장소에 쓰기만 하고 읽는 곳이 없는 상태였다.
    _store.load().then((saved) {
      if (!mounted) return;
      setState(() {
        _concerns.addAll(saved.concerns);
        _sleep ??= saved.sleep;
        _stress ??= saved.stress;
        _exercise ??= saved.exercise;
      });
    });
    // 타입은 서버 소유다. 로그인 상태에서 이미 들고 있다.
    final auth = ref.read(authNotifierProvider);
    if (auth is Authenticated) _type = auth.user.declaredSkinType;
  }

  /// 진행 점 4개 중 몇 개가 찼는가. 시작(1) + 타입 + 고민 + 습관.
  int get _progress =>
      1 +
      (_type != null ? 1 : 0) +
      (_concerns.isNotEmpty ? 1 : 0) +
      ((_sleep ?? _stress ?? _exercise) != null ? 1 : 0);

  Future<void> _submit() async {
    final type = _type;
    if (type == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    // 습관은 실패해도 흐름을 막지 않는다(store 가 삼킨다). 타입만 서버 왕복이다.
    await _store.save(SkinProfile(
      concerns: _concerns,
      sleep: _sleep,
      stress: _stress,
      exercise: _exercise,
    ));
    final failure =
        await ref.read(authNotifierProvider.notifier).updateSkinType(type);

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
      return;
    }
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          // 건너뛰기는 API 를 호출하지 않는 것이다. declared_skin_type 이 NULL 로
          // 남아야 "아직 안 정함"과 "잘 모르겠어요(UNKNOWN)"가 구분된다.
          TextButton(
            onPressed: _busy ? null : () => context.go(Routes.home),
            child: const Text('건너뛰기',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 0, AppTheme.pagePadding, 24),
        children: [
          Text('피부 프로필을\n설정해 볼까요?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('정확한 분석을 위해 알려주세요',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          _ProgressDots(filled: _progress),
          const SizedBox(height: 26),

          Text('피부 타입', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _TypeTiles(
            selected: _type,
            onSelect: _busy ? null : (type) => setState(() => _type = type),
          ),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('주요 피부 고민',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text('(복수 선택 가능)',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ConcernChips(
            selected: _concerns,
            onToggle: _busy
                ? null
                : (concern) => setState(() {
                      if (!_concerns.remove(concern)) _concerns.add(concern);
                    }),
          ),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('나의 생활 습관',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text('(선택)',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _HabitSection(
            row: _HabitRow.sleep,
            icon: Icons.nightlight_outlined,
            label: '수면 패턴',
            value: _sleep?.label,
            expanded: _expanded == _HabitRow.sleep,
            onToggleExpand: () => setState(() =>
                _expanded = _expanded == _HabitRow.sleep ? null : _HabitRow.sleep),
            child: _CardOptions<SleepPattern>(
              options: SleepPattern.values,
              selected: _sleep,
              labelOf: (option) => option.label,
              descriptionOf: (option) => option.description,
              iconOf: (option) => switch (option) {
                SleepPattern.lacking => Icons.sentiment_dissatisfied,
                SleepPattern.normal => Icons.sentiment_neutral,
                SleepPattern.enough => Icons.sentiment_satisfied_alt,
              },
              iconColorOf: (option, selected) =>
                  selected ? AppColors.primary : AppColors.textSecondary,
              onSelect: (option) => setState(() {
                _sleep = option;
                _expanded = null;
              }),
            ),
          ),
          const SizedBox(height: 8),

          _HabitSection(
            row: _HabitRow.stress,
            icon: Icons.sentiment_very_dissatisfied_outlined,
            label: '스트레스 정도',
            value: _stress?.label,
            expanded: _expanded == _HabitRow.stress,
            onToggleExpand: () => setState(() => _expanded =
                _expanded == _HabitRow.stress ? null : _HabitRow.stress),
            child: _CardOptions<StressLevel>(
              options: StressLevel.values,
              selected: _stress,
              labelOf: (option) => option.label,
              descriptionOf: (option) => option.description,
              iconOf: (option) => switch (option) {
                StressLevel.low => Icons.sentiment_satisfied_alt,
                StressLevel.normal => Icons.sentiment_neutral,
                StressLevel.high => Icons.sentiment_very_dissatisfied,
              },
              // 스트레스는 시안이 신호등 색을 쓴다 — 선택 여부와 무관하게 항상.
              iconColorOf: (option, _) => switch (option) {
                StressLevel.low => AppColors.good,
                StressLevel.normal => const Color(0xFFFFC107),
                StressLevel.high => AppColors.bad,
              },
              onSelect: (option) => setState(() {
                _stress = option;
                _expanded = null;
              }),
            ),
          ),
          const SizedBox(height: 8),

          _HabitSection(
            row: _HabitRow.exercise,
            icon: Icons.fitness_center,
            label: '운동 습관',
            value: _exercise?.label,
            expanded: _expanded == _HabitRow.exercise,
            onToggleExpand: () => setState(() => _expanded =
                _expanded == _HabitRow.exercise ? null : _HabitRow.exercise),
            child: _RowOptions(
              selected: _exercise,
              onSelect: (option) => setState(() {
                _exercise = option;
                _expanded = null;
              }),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: AppColors.bad, fontSize: 12)),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (_busy || !_complete) ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('프로필 설정 완료'),
          ),
        ],
      ),
    );
  }
}

enum _HabitRow { sleep, stress, exercise }

/// 진행 표시 — 선 위의 점 4개. 채워진 만큼 오렌지다.
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 1, color: AppColors.borderOnWhite),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < filled
                        ? AppColors.primary
                        : AppColors.borderEmptySlot,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 피부 타입 타일 4개(시안 크기 77×91) + "잘 모르겠어요" 한 줄.
///
/// UNKNOWN 을 빼지 않는다 — 빼면 정말 모르는 사용자의 출구가 건너뛰기뿐이고,
/// 그건 "아직 안 정함(NULL)"이라 두 상태가 섞인다. 시안의 4타일 줄은 그대로
/// 두고, 다섯째 선택지는 아래 전폭 줄로 붙인다(77px 타일 5개는 폭에 안 들어간다).
class _TypeTiles extends StatelessWidget {
  const _TypeTiles({required this.selected, required this.onSelect});

  final SkinType? selected;
  final ValueChanged<SkinType>? onSelect;

  static const _tiles = [
    (SkinType.dry, Icons.format_color_reset_outlined),
    (SkinType.oily, Icons.water_drop_outlined),
    (SkinType.combination, Icons.sentiment_dissatisfied_outlined),
    (SkinType.sensitive, Icons.mood_bad_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final (index, tile) in _tiles.indexed) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onSelect == null ? null : () => onSelect!(tile.$1),
                  child: _Selectable(
                    selected: selected == tile.$1,
                    height: 91,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tile.$2,
                            size: 30,
                            color: selected == tile.$1
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          tile.$1.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected == tile.$1
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onSelect == null ? null : () => onSelect!(SkinType.unknown),
          child: _Selectable(
            selected: selected == SkinType.unknown,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline,
                    size: 18,
                    color: selected == SkinType.unknown
                        ? AppColors.primary
                        : AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  SkinType.unknown.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected == SkinType.unknown
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 고민 칩 9개 — 3열 그리드. 선택되면 오렌지 채움에 흰 글씨다.
class _ConcernChips extends StatelessWidget {
  const _ConcernChips({required this.selected, required this.onToggle});

  final Set<SkinConcern> selected;
  final ValueChanged<SkinConcern>? onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 11,
      childAspectRatio: 106 / 36,
      children: [
        for (final concern in SkinConcern.values)
          GestureDetector(
            onTap: onToggle == null ? null : () => onToggle!(concern),
            child: Container(
              decoration: BoxDecoration(
                color: selected.contains(concern)
                    ? AppColors.primary
                    : AppColors.background,
                border: Border.all(
                  color: selected.contains(concern)
                      ? AppColors.primary
                      : AppColors.borderEmptySlot,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  concern.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected.contains(concern)
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 접히는 습관 한 줄. 펼치면 아래에 선택지가 나온다.
class _HabitSection extends StatelessWidget {
  const _HabitSection({
    required this.row,
    required this.icon,
    required this.label,
    required this.value,
    required this.expanded,
    required this.onToggleExpand,
    required this.child,
  });

  final _HabitRow row;
  final IconData icon;
  final String label;
  final String? value;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                  color: expanded
                      ? AppColors.primary
                      : AppColors.borderEmptySlot),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textOnCard),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    )),
                const Spacer(),
                Text(
                  value ?? '보통',
                  style: TextStyle(
                    fontSize: 11,
                    // 고른 값이 있으면 오렌지 — 시안의 "부족해요" 상태다.
                    color: value == null
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(padding: const EdgeInsets.only(top: 8), child: child),
      ],
    );
  }
}

/// 카드형 선택지(수면·스트레스) — 얼굴 아이콘 + 라벨 + 설명 세로 카드.
class _CardOptions<T> extends StatelessWidget {
  const _CardOptions({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.descriptionOf,
    required this.iconOf,
    required this.iconColorOf,
    required this.onSelect,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final String Function(T) descriptionOf;
  final IconData Function(T) iconOf;
  final Color Function(T, bool) iconColorOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, option) in options.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: _Selectable(
                selected: selected == option,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconOf(option),
                        size: 26,
                        color: iconColorOf(option, selected == option)),
                    const SizedBox(height: 6),
                    Text(labelOf(option),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected == option
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      descriptionOf(option),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 목록형 선택지(운동) — 가로로 긴 줄 4개.
class _RowOptions extends StatelessWidget {
  const _RowOptions({required this.selected, required this.onSelect});

  final ExerciseHabit? selected;
  final ValueChanged<ExerciseHabit> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in ExerciseHabit.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: _Selectable(
                selected: selected == option,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(option.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          )),
                      const Spacer(),
                      Text(option.description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 선택 가능한 상자의 공통 모양 — 선택되면 오렌지 테두리 + 크림 배경.
class _Selectable extends StatelessWidget {
  const _Selectable({
    required this.selected,
    required this.height,
    required this.child,
  });

  final bool selected;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceCard : AppColors.background,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderEmptySlot,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
