import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/metric_palette.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../../../shared/widgets/skin_mascot.dart';
import '../../../../shared/widgets/top_wash.dart';
import '../../../skin_analysis/domain/entities/skin_analysis.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_notifier.dart';

/// 마이페이지 — **음식 개인화의 기준이 무엇인지 확인하고 고치는 화면.**
///
/// 피부 분석을 앱의 주인공으로 올리지 않는다. 여기는 "왜 저 음식이 62점이었나"의
/// 근거를 열어 보는 곳이고, 그래서 홈 최상단이 아니라 프로필 아이콘 뒤에 있다.
///
/// 새로 계산하는 값이 없다. 최신 분석(`/skin/analyses/latest`)과 서버 프로필
/// (`/auth/me`)을 그대로 펼쳐 놓고, 고치는 일은 기존 화면들에 넘긴다.
///
/// **시안과 두 곳이 다르다.** 둘 다 시안이 앱에 없는 값을 그리고 있어서다:
///
/// 1. 시안은 지표 타일을 4개(수분·유분 밸런스·붉어짐·피부결) 그린다. 서버는 5개를
///    주고(수분·유분·홍조·트러블·장벽), 여기는 채점 기준을 확인하는 화면이라
///    하나를 빼면 근거가 사라진다. 5개를 다 그린다.
/// 2. 시안의 "민감도 높음" 배지는 서버 응답에 대응하는 필드가 없다. 상태 문구는
///    `skinType.label` 에 이미 조합돼 들어오므로(설계서 Part 3 · 8번이 "제목 하나로
///    그리고 타입 칩을 따로 달지 마라"라고 못 박은 자리다) 배지 자리에는 **측정 날짜**
///    를 넣는다 — 음식 점수가 어느 날 피부로 매겨졌는지가 이 화면의 존재 이유다.
/// 3. 시안은 "피부 고민" 제목 아래에 관리 방향 칩(수분·장벽 / 향산화 / 건강한 지방)을
///    그리는데, 그 둘은 **다른 값**이다. 고민은 사용자가 고른 것이고 관리 방향은
///    서버가 오늘 지표에서 낸 것(`careFocus`)이다. 제목과 내용을 맞추기 위해
///    구역을 둘로 나눴다 — 하나로 합치면 어느 쪽이 내 설정인지 알 수 없다.
class SkinProfilePage extends ConsumerWidget {
  const SkinProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user,
      _ => null,
    };
    // 세 가지를 구분한다 — **아직 안 왔다 · 못 불러왔다 · 정말 없다.**
    // 셋을 null 하나로 뭉치면, 분석을 해 둔 사용자가 오프라인으로 이 화면을 열었을 때
    // "아직 피부 분석 기록이 없어요" 라고 없는 사실을 말하게 된다. 재시도 버튼도 없다.
    final latest = ref.watch(latestSkinAnalysisProvider);
    final loaded = latest.valueOrNull;
    final analysis = loaded?.dataOrNull;
    final loadFailed = latest.hasError || (loaded != null && !loaded.isSuccess);
    final loading = loaded == null && !loadFailed;

    return Scaffold(
      body: Stack(
        children: [
          const TopWash(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(latestSkinAnalysisProvider.future),
              child: ListView(
                // 분석이 없거나 못 불러온 상태는 내용이 화면보다 짧아 스크롤 여지가
                // 없다. 그러면 당겨도 오버스크롤이 안 잡혀 새로고침이 먹지 않는다 —
                // 리포트 화면과 같은 이유다.
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    // 아이콘은 시안대로 19 지만 누를 곳은 44 다. constraints 를
                    // 비워 두면 IconButton 이 아이콘 크기로 쪼그라들어서, 이 화면의
                    // 유일한 출구가 19dp 짜리 과녁이 된다.
                    child: IconButton(
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 44, minHeight: 44),
                      tooltip: '뒤로',
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 19, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Identity(user: user),
                  const SizedBox(height: 27),

                  if (loading)
                    const _CardShell(child: _CenteredNote(child: CircularProgressIndicator()))
                  else if (loadFailed)
                    _CardShell(
                      child: _CenteredNote(
                        child: Column(
                          children: [
                            const Text('피부 분석을 불러오지 못했어요.'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  ref.invalidate(latestSkinAnalysisProvider),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (analysis == null)
                    const _CardShell(
                      child: _CenteredNote(
                        child: Text(
                          '아직 피부 분석 기록이 없어요.\n'
                          '한 번 분석하면 그 다음부터 음식 점수가 내 피부 기준으로 매겨집니다.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    _SkinTypeCard(
                      analysis: analysis,
                      onTap: () => context.push('${Routes.skinInsight}/${analysis.id}'),
                    ),

                  // 서버가 오늘 지표에서 낸 관리 방향. 분석이 없으면 자리째 없다.
                  if (analysis != null && analysis.careFocus.isNotEmpty) ...[
                    const SizedBox(height: 29),
                    const _SectionHeading('지금 필요한 관리'),
                    const SizedBox(height: 12),
                    _CareFocusChips(focus: analysis.careFocus),
                  ],

                  const SizedBox(height: 29),
                  const _SectionHeading('피부 고민'),
                  const SizedBox(height: 12),
                  _ConcernChips(user: user),

                  const SizedBox(height: 34),
                  _SectionHeading(
                    '생활 습관',
                    onTap: () => context.push(Routes.lifestyle),
                  ),
                  const SizedBox(height: 12),
                  _LifestyleCard(
                    user: user,
                    onTap: () => context.push(Routes.lifestyle),
                  ),

                  const SizedBox(height: 28),
                  _OutlineAction(
                    label: '피부 프로필 수정하기',
                    onPressed: () => context.push(Routes.skinType),
                  ),
                  const SizedBox(height: 15),
                  _FilledAction(
                    label: analysis == null ? '피부 분석하기' : '피부 다시 분석하기',
                    onPressed: () => context.push(Routes.skinCapture),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(authNotifierProvider.notifier).logout(),
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final joinedAt = user?.joinedAt;

    return Row(
      children: [
        const SkinMascot(size: 76),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.nickname ?? ''}님',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              // 가입일이 없으면 줄을 만들지 않는다. 서버가 이 키를 빼는 경우가
              // 있고, "님" 아래 빈 줄은 불러오다 만 화면으로 읽힌다.
              if (joinedAt != null) ...[
                const SizedBox(height: 7),
                Text(
                  '${joinedAt.year}.${joinedAt.month}.${joinedAt.day} 가입',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 시안의 카드 껍데기. 홈의 카드와 달리 **그림자가 오렌지 계열**이다 —
/// 옅은 오렌지 물 위에 검은 그림자를 깔면 카드 밑이 회색으로 죽는다.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x40FF7D40), blurRadius: 10.6),
        ],
      ),
      child: child,
    );
  }
}

/// 로딩·실패·기록 없음이 같은 자리를 쓰게 해서 상태가 바뀔 때 아래 내용이 튀지 않는다.
class _CenteredNote extends StatelessWidget {
  const _CenteredNote({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodySmall!,
        textAlign: TextAlign.center,
        child: Center(child: child),
      ),
    );
  }
}

/// 오늘의 피부 타입과 지표 5개.
///
/// 제목은 서버가 조합해 준 `skinType.label`("건성 · 붉은기") 을 그대로 쓴다.
/// **타입 칩을 따로 달지 않는다** — `skinType.primary` 와 `skinTypeGap.observed` 는
/// 항상 같은 값이라, 칩을 붙이면 같은 사실이 화면에 두 번 적힌다(설계서 Part 3 · 8번).
class _SkinTypeCard extends StatelessWidget {
  const _SkinTypeCard({required this.analysis, required this.onTap});

  final SkinAnalysis analysis;

  /// 인사이트로 넘어간다. 시안의 카드 우상단 화살표가 이 자리다.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final observed = analysis.skinType;
    final title = (observed?.label.isNotEmpty ?? false)
        ? observed!.label
        : observed?.primary?.label ?? '피부 타입 미확인';
    final at = analysis.analyzedAt;

    return _CardShell(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right,
                    size: 20, color: AppColors.textSecondary),
              ),
              // 시안은 이 자리에 "민감도 높음" 배지를 두는데 서버에 대응하는
              // 필드가 없다. 대신 **언제 측정한 기준인지**를 넣는다 — 음식 점수가
              // 어느 날 피부로 매겨졌는지가 이 화면의 존재 이유라, 날짜가 없으면
              // 사흘 전 피부를 오늘 상태로 읽는다.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDFCE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${at.year}. ${at.month}. ${at.day} 측정',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              // 타입 설명은 서버에 필드가 없어 enum 에 붙은 고정 UI 문구다
              // (`SkinLevel.summary` 와 같은 부류다 — 숫자도 판정도 언급하지 않는다).
              if (observed?.primary?.description case final description?) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    height: 15 / 10,
                    color: AppColors.bodyInk,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  for (final bar in analysis.metrics.toBars())
                    Expanded(
                      child: _MetricTile(
                        metricKey: bar.key,
                        label: bar.label,
                        // 상태어는 서버가 그 지표에 매긴 등급에서 나온다.
                        band: MetricBand.of(analysis.levelOf(bar.key),
                            higherIsBetterMetric: bar.higherIsBetter),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 지표 한 칸. 아이콘 원 + 지표명 + 상태어.
///
/// **숫자를 쓰지 않는 것이 시안 의도다.** 여기는 기준을 훑는 화면이고, 값이 궁금하면
/// 피부 결과(S05)에 막대와 숫자가 있다.
///
/// 원과 아이콘은 **지표의 이름표 색**이다([MetricPalette]) — 수분은 늘 파랑, 홍조는
/// 늘 빨강이고 값이 좋아도 나빠도 같다. 상태는 아래 상태어와 그 색이 말한다.
/// 예전에는 원을 상태색으로 칠했는데, 그러면 시안의 파스텔 다섯 색과 어긋나고
/// 무엇보다 색이 지표와 상태를 동시에 말하려다 둘 다 흐려진다.
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.metricKey,
    required this.label,
    required this.band,
  });

  /// `SkinMetrics.toBars()` 의 key. 색과 아이콘을 고르는 데만 쓴다.
  final String metricKey;

  final String label;

  /// 서버 등급을 모르면 null 이고, 그때는 상태어 자리를 비운다.
  final MetricBand? band;

  @override
  Widget build(BuildContext context) {
    final palette = MetricPalette.of(metricKey);
    final band = this.band;

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: palette.background,
            shape: BoxShape.circle,
          ),
          child: Icon(palette.icon, size: 20, color: palette.foreground),
        ),
        const SizedBox(height: 11),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (band != null) ...[
          const SizedBox(height: 5),
          Text(
            band.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: band.color,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, {this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          const LeafMark(),
          const SizedBox(width: 6),
          // 글자 크기 2.0 에서 제목이 한 줄에 안 들어간다 — 감싸 두면 접힌다.
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.bodyInk,
              ),
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// 서버가 오늘 지표에서 낸 관리 방향(`careFocus`). 시안이 "피부 고민" 제목 아래
/// 그려 둔 칩이 실제로는 이것이다 — 제목만 맞지 않았다.
///
/// **앱이 지표를 보고 축을 고르지 않는다.** 라벨까지 서버가 함께 보내므로 축이
/// 늘어나거나 문구가 다듬어져도 이 위젯은 그대로다.
class _CareFocusChips extends StatelessWidget {
  const _CareFocusChips({required this.focus});

  final List<CareFocus> focus;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final item in focus)
          Container(
            // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
            // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
            constraints: const BoxConstraints(minHeight: 22),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 사용자가 고른 고민. 위의 관리 방향과 **다른 값**이다 — 이쪽은 설정이고
/// 저쪽은 오늘의 관찰에서 나온 것이다.
class _ConcernChips extends StatelessWidget {
  const _ConcernChips({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final concerns = user?.skinConcerns ?? const {};
    if (concerns.isEmpty) {
      return Text('선택한 고민이 없어요.',
          style: Theme.of(context).textTheme.bodySmall);
    }

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final concern in concerns)
          Container(
            // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
            // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
            constraints: const BoxConstraints(minHeight: 22),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                concern.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 생활 습관 4종. 미선택은 빈칸이 아니라 "미설정"으로 적는다 —
/// 빈칸은 불러오다 만 화면으로 읽히고, 이 값들은 인사이트의 입력이라
/// 비어 있다는 사실 자체가 사용자가 알아야 할 정보다.
class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({required this.user, required this.onTap});

  final AuthUser? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String?)>[
      (Icons.nightlight_round, '수면 패턴', user?.sleepPattern?.label),
      (Icons.sentiment_dissatisfied, '스트레스 정도', user?.stressLevel?.label),
      (Icons.directions_run, '운동 습관', user?.exerciseHabit?.label),
      (Icons.water_drop_outlined, '물 섭취', user?.waterIntake?.label),
    ];

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 16, 9, 16),
        child: Column(
          children: [
            for (final (icon, label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                          color: AppColors.borderEmptySlot, width: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          value ?? '미설정',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: value == null
                                ? AppColors.outline
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 시안의 큰 버튼 두 개. 테마의 `ElevatedButton`(radius 8 · h48)과 곡률·높이가
/// 달라(radius 14 · h50) 테마를 건드리지 않고 이 화면에서만 모양을 잡는다.
class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.background,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  const _FilledAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}
