import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../../shared/widgets/pill.dart';
import '../../domain/entities/skin_profile.dart';
import '../providers/auth_notifier.dart';

/// S01c — 피부 프로필 설문. 확정 시안의 한 페이지 설문이다:
/// 피부 타입(필수) · 주요 피부 고민(복수, 선택) · 생활 습관 4종(선택).
///
/// 타입은 서버로 간다(`PATCH /auth/me`). **타입은 점수 계산에 들어가지
/// 않는다** — 자가 신고값이 점수에 개입하면 "같은 사진 두 번 찍어도 같은
/// 점수"라는 주장이 무너진다. 쓰이는 곳은 결과 화면의 갭 카드다. (PRD §4.4.1)
///
/// 고민·습관도 전부 서버가 소유한다. 인사이트(S10)가 서버 DB 의 값을 읽어
/// 주제를 고르므로, 기기에만 저장하면 그 기능이 통째로 동작하지 않는다.
/// 이 화면이 서는 두 자리.
enum ProfileFormMode {
  /// 홈의 "피부 프로필 수정"과 촬영 화면의 안내에서 넘어간 경우.
  /// 타입·고민·습관 전부, 건너뛰기 있음.
  full,

  /// 촬영을 마치고 분석을 기다리는 동안(S04 위) 뜨는 모드. 묻는 항목은 full 과
  /// 같고 건너뛰기만 없다 — 갇히지는 않는다. 타입에 "잘 모르겠어요"(UNKNOWN)가
  /// 있고, 닫고 나가면 밑에 로딩 화면이 그대로 있어 결과로 이어진다.
  /// 뒤로가기를 막지 않는 이유다.
  onboarding,

  /// 인사이트(S10)가 습관을 받으러 보내는 화면. 생활 습관 4종만 묻고 건너뛰기가
  /// 없다 — 네 개가 다 있어야 인사이트를 만들 수 있다.
  ///
  /// 여기서 타입·고민을 다시 묻지 않는다 — 가입 때 이미 받았고, 다시 그리면
  /// 사용자가 같은 설문을 두 번 하는 것처럼 느낀다.
  lifestyle,
}

class SkinTypePage extends ConsumerStatefulWidget {
  const SkinTypePage({super.key, this.mode = ProfileFormMode.full});

  final ProfileFormMode mode;

  @override
  ConsumerState<SkinTypePage> createState() => _SkinTypePageState();
}

class _SkinTypePageState extends ConsumerState<SkinTypePage> {
  SkinType? _type;
  final Set<SkinConcern> _concerns = {};
  SleepPattern? _sleep;
  StressLevel? _stress;
  ExerciseHabit? _exercise;
  WaterIntake? _water;

  /// 어느 습관 줄이 펼쳐져 있는지. 시안이 한 번에 하나만 펼친다.
  _HabitRow? _expanded;

  /// 보고 있는 단계. 확정 시안이 한 화면에 다 늘어놓던 세 구역을 **탭 세 개**로
  /// 갈랐다 — 타입 6칸 + 고민 9칸 + 습관 4줄이 한 스크롤에 있으면 첫 화면에서
  /// 끝이 안 보이고, 어디까지 답했는지도 알 수 없다.
  _ProfileStep _step = _ProfileStep.type;

  bool _busy = false;
  String? _error;

  bool get _lifestyleOnly => widget.mode == ProfileFormMode.lifestyle;

  /// 건너뛰기가 있는 모드는 full 하나뿐이다. 습관 모드는 네 개가 다 있어야 하고,
  /// 온보딩 모드는 첫 분석에 한 번 받아 두는 자리라 출구를 UNKNOWN 에 맡긴다.
  bool get _canSkip => widget.mode == ProfileFormMode.full;

  /// full — 고민은 제출 조건에 넣지 않는다. 넣으면 고민을 전부 해제한 사용자가 버튼이
  /// 왜 꺼졌는지 모른 채 갇히고, "이제 고민 없어요"를 서버에 저장할 방법이 사라진다
  /// — 서버가 빈 배열을 "전부 해제"로 읽도록 만들어 둔 경로가 통째로 사문이 된다.
  ///
  /// lifestyle — 네 개를 다 골라야 넘어간다. 하나라도 비면 그 항목은 인사이트에서
  /// 영영 빠지는데, 사용자는 왜 빠졌는지 알 길이 없다.
  bool get _complete => _lifestyleOnly
      ? (_sleep != null &&
          _stress != null &&
          _exercise != null &&
          _water != null)
      : _type != null;

  @override
  void initState() {
    super.initState();
    // 홈의 "피부 프로필 수정"으로 다시 들어온 사용자다. 서버가 들고 있는 답을
    // 깔아 두지 않으면 빈 설문이 뜨고, 제출이 이전 답을 전부 덮어쓴다.
    final auth = ref.read(authNotifierProvider);
    if (auth is Authenticated) {
      _type = auth.user.declaredSkinType;
      _concerns.addAll(auth.user.skinConcerns);
      _sleep = auth.user.sleepPattern;
      _stress = auth.user.stressLevel;
      _exercise = auth.user.exerciseHabit;
      _water = auth.user.waterIntake;
    }
  }

  /// 막대가 얼마나 찼는가. **답한 개수가 아니라 보고 있는 단계**다 —
  /// 시안이 첫 탭에서 1/3 을 채워 두고, 고민은 건너뛸 수 있는 항목이라
  /// 답한 개수로 재면 막대가 뒤로 가는 경우가 생긴다.
  double get _progress => (_step.index + 1) / _ProfileStep.values.length;

  /// 완료를 막고 있는 항목으로 데려간다. 버튼을 꺼 두기만 하면 사용자는 무엇을
  /// 더 해야 하는지 모른 채 같은 버튼을 다시 누른다.
  void _showBlocking() {
    if (!_lifestyleOnly && _type == null) {
      setState(() => _step = _ProfileStep.type);
      _tell('피부 타입을 먼저 골라 주세요.');
      return;
    }
    // lifestyle 모드는 네 줄을 다 골라야 한다. 어느 줄이 비었는지 알려 준다.
    final missing = <String>[
      if (_sleep == null) '수면 패턴',
      if (_stress == null) '스트레스 정도',
      if (_exercise == null) '운동 습관',
      if (_water == null) '물 섭취',
    ];
    if (missing.isNotEmpty) _tell('${missing.join(' · ')} 을 골라 주세요.');
  }

  void _tell(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _submit() async {
    if (!_complete) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    // 타입·고민·습관이 한 요청으로 간다. 둘로 나눠 보내면 한쪽만 성공한 상태가
    // 생기고, 그때 화면은 성공도 실패도 아닌 것을 보여주게 된다.
    //
    // 고민은 비어 있어도 보낸다 — 서버가 [] 를 "전부 해제"로 읽는다. 안 보내면
    // 사용자가 방금 지운 고민이 서버에 그대로 남는다.
    //
    // lifestyle 모드는 습관만 보낸다. 여기서 고민을 같이 실으면 화면에 그리지도
    // 않은 값으로 서버의 고민을 덮어쓴다 — 빈 배열이 곧 "전부 해제"라 특히 위험하다.
    final failure =
        await ref.read(authNotifierProvider.notifier).updateProfile(
              declaredSkinType: _lifestyleOnly ? null : _type,
              skinConcerns: _lifestyleOnly ? null : _concerns,
              sleepPattern: _sleep,
              stressLevel: _stress,
              exerciseHabit: _exercise,
              waterIntake: _water,
            );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
      return;
    }

    // 습관만 묻는 화면은 인사이트(S10)가 불러서 온 곳이다. 부른 화면으로 그대로
    // 돌아가면 게이트가 풀린 상태로 다시 그려지고, 그때 인사이트를 처음 조회한다.
    _leave();
  }

  /// 온보딩(가입 직후)에서는 쌓인 화면이 없으니 홈으로 간다. 그 외에는 부른 화면으로
  /// 돌아간다 — `go` 로 통일하면 스택이 통째로 날아가서, 인사이트 화면이 습관을
  /// 받으러 보낸 사용자가 그 인사이트로 못 돌아간다.
  void _leave() =>
      context.canPop() ? context.pop() : context.go(Routes.home);

  /// **뒤로가기를 막지 않는다.** 예전에는 이 화면이 분석과 결과 사이에 낀 강제
  /// 단계라, 나가면 방금 한 분석을 다시 볼 길이 없어서 붙잡아 두어야 했다.
  /// 지금은 나가도 잃는 것이 없다 — 인사이트(S10)는 결과를 지나서 오고, 온보딩
  /// 모드 밑에는 로딩 화면이 깔려 있어 나가면 그대로 결과로 이어진다.
  /// 분석은 촬영하는 순간 이미 시작됐으므로 여기서 나가도 그 분석을 잃지 않는다.
  @override
  Widget build(BuildContext context) => _form(context);

  /// 생활 습관 4종. 한 번에 한 줄만 펼친다 — 넷을 다 펼치면 화면이 옵션으로 덮인다.
  Widget _habits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 습관은 full 모드에서 선택이고 lifestyle 모드에서 필수다. 그 차이를
        // 적어 두지 않으면 왜 버튼이 안 열리는지 알 수 없다.
        Text(
          _lifestyleOnly ? '네 가지를 모두 알려주세요' : '지금 넘어가도 나중에 채울 수 있어요',
          style: TextStyle(
            fontSize: 12,
            color: _lifestyleOnly ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

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
        const SizedBox(height: 8),

        _HabitSection(
          row: _HabitRow.water,
          icon: Icons.water_drop_outlined,
          // 시안·마이페이지가 '물 섭취' 로 쓴다. 예전 '수분 섭취' 는 피부 지표의
          // '수분' 과 같은 낱말이라, 한 앱에서 두 가지를 같은 말로 부르고 있었다.
          label: '물 섭취',
          value: _water?.label,
          expanded: _expanded == _HabitRow.water,
          onToggleExpand: () => setState(() =>
              _expanded = _expanded == _HabitRow.water ? null : _HabitRow.water),
          // 수면과 같은 3단계 척도라 같은 카드형을 쓴다. 운동의 _RowOptions 는
          // ExerciseHabit 이 박혀 있어 여기 쓰려면 제네릭화부터 해야 한다.
          child: _CardOptions<WaterIntake>(
            options: WaterIntake.values,
            selected: _water,
            labelOf: (option) => option.label,
            descriptionOf: (option) => option.description,
            iconOf: (option) => switch (option) {
              WaterIntake.lacking => Icons.sentiment_dissatisfied,
              WaterIntake.normal => Icons.sentiment_neutral,
              WaterIntake.enough => Icons.sentiment_satisfied_alt,
            },
            iconColorOf: (option, selected) =>
                selected ? AppColors.primary : AppColors.textSecondary,
            onSelect: (option) => setState(() {
              _water = option;
              _expanded = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          // 건너뛰기는 API 를 호출하지 않는 것이다. declared_skin_type 이 NULL 로
          // 남아야 "아직 안 정함"과 "잘 모르겠어요(UNKNOWN)"가 구분된다.
          if (_canSkip)
            TextButton(
              onPressed: _busy ? null : _leave,
              child: const Text('건너뛰기',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 0, AppTheme.pagePadding, 24),
        children: [
          // 시안은 진행 막대를 화면 맨 위에 둔다 — 제목보다 위다. 어디까지
          // 왔는지가 제목보다 먼저 보여야 세 단계짜리 설문으로 읽힌다.
          if (!_lifestyleOnly) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3.5),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFECEBEF),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 33),
          ],
          // 습관 모드 문구는 온보딩 어투를 쓰지 않는다. 예전에는 가입 흐름 안에
          // 있어서 "거의 다 왔어요!" 가 맞았지만, 지금은 인사이트를 보려다 들른
          // 화면이라 그 말이 어디에 가까워졌다는 것인지 알 수 없다.
          Text(
              switch (widget.mode) {
                ProfileFormMode.lifestyle => '생활 습관을\n알려주세요',
                ProfileFormMode.onboarding => '사진 촬영이 끝났습니다',
                ProfileFormMode.full => '피부 프로필을\n설정해 볼까요?',
              },
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
              switch (widget.mode) {
                ProfileFormMode.lifestyle =>
                  '수면·스트레스·운동·수분 네 가지를 알려주시면\n'
                      '오늘 피부 상태와 함께 인사이트를 만들어 드려요.',
                // 촬영을 마친 직후라서 할 수 있는 말이다. 설문이 촬영보다 앞에
                // 있던 시절에는 "사진 촬영이 끝났습니다" 자체가 거짓이었다.
                ProfileFormMode.onboarding => 'AI의 진단이 정확하지 않을 수 있으니\n'
                    '프로필 설정으로 추가적인 피부 타입을 알려주세요',
                ProfileFormMode.full => '정확한 분석을 위해 알려주세요',
              },
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          // 습관만 묻는 모드는 단계가 하나뿐이라 탭도 막대도 그리지 않는다.
          if (!_lifestyleOnly) ...[
            _StepSwitcher(
              current: _step,
              onSelect: _busy ? null : (step) => setState(() => _step = step),
            ),
            const SizedBox(height: 28),
          ],

          if (!_lifestyleOnly && _step == _ProfileStep.type)
            _TypeTiles(
              selected: _type,
              onSelect: _busy ? null : (type) => setState(() => _type = type),
            ),

          if (!_lifestyleOnly && _step == _ProfileStep.concern) ...[
            const Text(
              '(복수 선택 가능)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _ConcernTiles(
              selected: _concerns,
              onToggle: _busy
                  ? null
                  : (concern) => setState(() {
                        if (!_concerns.remove(concern)) _concerns.add(concern);
                      }),
            ),
          ],

          if (_lifestyleOnly || _step == _ProfileStep.habit) _habits(),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: AppColors.bad, fontSize: 12)),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            // **완료를 못 누르는 이유를 화면이 말해야 한다.** 탭으로 갈라 놓은
            // 뒤에는 막고 있는 항목(피부 타입)이 다른 탭에 있어서, 버튼이 죽은
            // 이유가 보이지 않았다. 누르면 그 탭으로 데려가고 한 줄로 알린다.
            onPressed: _busy
                ? null
                : (_complete ? _submit : _showBlocking),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                // 습관 모드는 인사이트가 불러서 온 화면이다. 제출하면 결과가
                // 아니라 그 인사이트로 돌아간다 — 버튼도 그렇게 말해야 한다.
                : Text(_lifestyleOnly ? '완료하고 인사이트 보기' : '프로필 설정 완료'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 설문 세 단계. 순서가 곧 탭 순서이고 진행 막대의 분모다.
enum _ProfileStep {
  type('피부 타입'),
  concern('주요 피부 고민'),
  habit('나의 생활 습관');

  const _ProfileStep(this.label);

  final String label;
}

enum _HabitRow { sleep, stress, exercise, water }

/// 진행 표시 — 선 위의 점 4개. 채워진 만큼 오렌지다.
/// 선택 타일 하나 — 큰 동그라미 안에 그림, 아래에 이름.
///
/// 시안이 사각 카드를 **동그라미**로 바꿨다. 그림이 얼굴 계열이라 원 안에 두면
/// 아이콘이 아니라 초상처럼 읽히고, 두 열로 나란히 놓았을 때 격자보다 목록처럼
/// 훑기 쉽다.
///
/// 그림은 오렌지 한 벌만 넣고 미선택은 회색으로 물들인다 — 시트에 회색 벌도
/// 있지만 두 벌을 넣으면 색을 바꿀 때 두 파일을 갈아야 한다.
class _GlyphTile extends StatelessWidget {
  const _GlyphTile({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.diameter,
    required this.glyphSize,
    required this.labelSize,
    this.onTap,
  });

  final String glyph;
  final String label;
  final bool selected;
  final double diameter;
  final double glyphSize;
  final double labelSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // 이름이 두 줄로 접혀도 옆 칸과 어긋나지 않게 폭을 원에 맞춰 고정한다.
        width: diameter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diameter,
              height: diameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFFFFEEE6) : AppColors.background,
                border: Border.all(
                  color:
                      selected ? AppColors.primary : AppColors.borderEmptySlot,
                  width: 1.2,
                ),
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                child: Image.asset(
                  glyph,
                  width: glyphSize,
                  height: glyphSize,
                  // 원 안에 들어갈 크기만큼만 디코드한다. 원본은 132px 이고
                  // 아홉 칸이 동시에 뜨는 화면이라 그대로 두면 캐시를 먹는다.
                  cacheWidth: (glyphSize *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 단계 세 개를 고르는 알약 줄.
///
/// 답을 안 해도 아무 단계로나 갈 수 있다 — 순서를 강제하면 고민을 건너뛰려는
/// 사용자가 습관에 닿지 못한다. 고민은 원래 필수가 아니다.
class _StepSwitcher extends StatelessWidget {
  const _StepSwitcher({required this.current, required this.onSelect});

  final _ProfileStep current;
  final ValueChanged<_ProfileStep>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, step) in _ProfileStep.values.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(step),
              behavior: HitTestBehavior.opaque,
              // 이 줄도 알약이다. 예전에는 높이를 36 으로 박아 두어서 글자 크기
              // 2.0 에서 라벨이 8px 잘렸다(그려진 32 / 필요한 40) — 예외가 나지
              // 않으니 오버플로만 보는 테스트로는 안 잡혔다.
              // 말줄임이 아니라 축소다 — "주요 피부 …" 는 무엇의 탭인지 지운다.
              child: Pill(
                label: step.label,
                minHeight: 36,
                horizontalPadding: 8,
                borderRadius: 16,
                fitDown: true,
                color: step == current
                    ? const Color(0xFFFFEEE6)
                    : AppColors.background,
                border: Border.all(
                  color: step == current
                      ? AppColors.primary
                      : const Color(0xFFE8E8E8),
                  width: 2,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: step == current
                      ? AppColors.primary
                      : const Color(0xFFB6B6B6),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 피부 타입 타일 — 2열 동그라미.
///
/// UNKNOWN 을 빼지 않는다 — 빼면 정말 모르는 사용자의 출구가 건너뛰기뿐이고,
/// 그건 "아직 안 정함(NULL)"이라 두 상태가 섞인다.
///
/// **시안의 "수부지" 칸은 서버가 값을 가진 뒤에 켰다**(2026-08-19 · 선언 전용
/// 타입). 그전에는 고르면 저장할 곳이 없어 그리지 않았다 — 그 시절 주석을 보고
/// 칸을 다시 빼면 시안과 어긋난다.
class _TypeTiles extends StatelessWidget {
  const _TypeTiles({required this.selected, required this.onSelect});

  final SkinType? selected;
  final ValueChanged<SkinType>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 34,
      runSpacing: 26,
      alignment: WrapAlignment.center,
      children: [
        for (final type in SkinType.selectable)
          _GlyphTile(
            glyph: type.glyph,
            label: type.label,
            selected: selected == type,
            diameter: 109,
            glyphSize: 62,
            labelSize: 16,
            onTap: onSelect == null ? null : () => onSelect!(type),
          ),
      ],
    );
  }
}

/// 고민 타일 9개 — 3열 동그라미. 복수 선택이다.
class _ConcernTiles extends StatelessWidget {
  const _ConcernTiles({required this.selected, required this.onToggle});

  final Set<SkinConcern> selected;
  final ValueChanged<SkinConcern>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        for (final concern in SkinConcern.values)
          _GlyphTile(
            glyph: concern.glyph,
            label: concern.label,
            selected: selected.contains(concern),
            diameter: 74,
            glyphSize: 42,
            labelSize: 12,
            onTap: onToggle == null ? null : () => onToggle!(concern),
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
                  // **미선택을 '보통' 으로 적지 않는다.** 스트레스의 실제 보기에
                  // '보통' 이 있어서 안 고른 줄과 고른 줄이 같은 글자가 됐다
                  // (색만 달랐다). 마이페이지도 같은 목록을 '미설정' 으로 적는다.
                  value ?? '미설정',
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
    // 세 칸의 높이를 맞춘다. 최소 높이만 두면 설명이 긴 보기 하나만 커지고
    // 나머지 둘이 가운데 떠서, 시안의 똑같은 타일 셋이 서로 다른 높이가 된다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        for (final (index, option) in options.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: _Selectable(
                selected: selected == option,
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
          ),
        ],
        ],
      ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  // 라벨과 설명 둘 다 Flexible 이다. 고정으로 두었더니 글자 크기
                  // 2.0 에서 줄이 206px 넘쳐 설명이 화면 밖으로 나갔다.
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(option.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      const SizedBox(width: 10),
                      // Flexible 이 아니라 Expanded 다 — loose fit 이면 설명이
                      // 라벨 옆에 붙고 오른쪽에 빈 공간이 남는다(Spacer 가 하던
                      // 일이 사라진다). Expanded 면 남은 폭을 다 받아 우측 정렬이
                      // 살아 있고, 글자가 커져도 그 안에서 접힌다.
                      Expanded(
                        child: Text(option.description,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            )),
                      ),
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

  /// 시안 높이. **최소 높이로만 쓴다** — 고정하면 글자 크기를 키운 기기에서
  /// 설명 두 줄이 네 줄로 접히며 카드 밖으로 넘친다(실제로 44~101px 넘쳤다).
  final double height;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
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
