import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../skin_analysis/domain/entities/skin_analysis.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_notifier.dart';

/// 나의 피부 프로필 — **음식 개인화의 기준이 무엇인지 확인하고 고치는 화면.**
///
/// 피부 분석을 앱의 주인공으로 올리지 않는다. 여기는 "왜 저 음식이 62점이었나"의
/// 근거를 열어 보는 곳이고, 그래서 홈 최상단이 아니라 프로필 아이콘 뒤에 있다.
///
/// 새로 계산하는 값이 없다. 최신 분석(`/skin/analyses/latest`)과 서버 프로필
/// (`/auth/me`)을 그대로 펼쳐 놓고, 고치는 일은 기존 화면들에 넘긴다.
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
      appBar: AppBar(title: const Text('나의 피부 프로필')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(latestSkinAnalysisProvider.future),
        child: ListView(
          // 분석이 없거나 못 불러온 상태는 내용이 화면보다 짧아 스크롤 여지가
          // 없다. 그러면 당겨도 오버스크롤이 안 잡혀 새로고침이 먹지 않는다 —
          // 리포트 화면과 같은 이유다.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding, 14, AppTheme.pagePadding, 32),
          children: [
            if (user != null) ...[
              Text(
                '${user.nickname}님의 음식 점수는 이 기준으로 매겨져요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
            ],

            const _SectionTitle('최근 피부 분석'),
            const SizedBox(height: 10),
            if (loading)
              const _PlaceholderCard(child: CircularProgressIndicator())
            else if (loadFailed)
              _PlaceholderCard(
                child: Column(
                  children: [
                    Text('피부 분석을 불러오지 못했어요.',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(latestSkinAnalysisProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
            else if (analysis == null)
              const _PlaceholderCard(
                child: Text(
                  '아직 피부 분석 기록이 없어요.\n'
                  '한 번 분석하면 그 다음부터 음식 점수가 내 피부 기준으로 매겨집니다.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              _AnalysisCard(analysis: analysis),

            const SizedBox(height: 26),
            const _SectionTitle('피부 고민'),
            const SizedBox(height: 10),
            _ConcernChips(user: user),

            const SizedBox(height: 26),
            const _SectionTitle('생활 습관'),
            const SizedBox(height: 10),
            _LifestyleCard(user: user),

            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.push(Routes.skinCapture),
              child: Text(analysis == null ? '피부 분석하기' : '피부 다시 분석하기'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push(Routes.skinType),
              child: const Text('피부 고민 · 생활 습관 수정하기'),
            ),

            // 인사이트는 분석 하나를 기준으로 만들어진다. 분석이 없으면 열 수
            // 없으므로 버튼을 아예 그리지 않는다 — 눌러서 빈 화면을 보는 것보다
            // 없는 편이 낫다.
            if (analysis != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.push('${Routes.skinInsight}/${analysis.id}'),
                child: const Text('개인화 피부 인사이트 보기'),
              ),
            ],

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              child: const Text('로그아웃',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

/// 지표 5개를 전부 편다. 결과 화면(S05)이 4개만 보여 주는 것은 시안 의도지만,
/// 여기는 "채점 기준을 확인하는 곳"이라 트러블을 빼면 근거가 하나 사라진다.
class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final at = analysis.analyzedAt;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${at.year}. ${at.month}. ${at.day}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${analysis.skinScore}점',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final bar in analysis.metrics.toBars())
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _MetricRow(
                label: bar.label,
                value: bar.value,
                band: MetricBand.of(bar.value,
                    higherIsBetterMetric: bar.higherIsBetter),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.band,
  });

  final String label;
  final int value;
  final MetricBand band;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textOnCard)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(band.color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 62,
          child: Text(
            '$value · ${band.label}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: band.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// 분석 카드가 들어갈 자리를 채우는 빈 상자. 로딩·실패·기록 없음이 같은 크기의
/// 자리를 쓰게 해서, 상태가 바뀔 때 아래 내용이 튀지 않는다.
class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderEmptySlot),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodySmall!,
        child: Center(child: child),
      ),
    );
  }
}

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
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final concern in concerns)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border.all(color: AppColors.borderOnCream),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(concern.label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textOnCard)),
          ),
      ],
    );
  }
}

/// 생활 습관 4종. 미선택은 빈칸이 아니라 "미설정"으로 적는다 —
/// 빈칸은 불러오다 만 화면으로 읽히고, 이 값들은 인사이트의 입력이라
/// 비어 있다는 사실 자체가 사용자가 알아야 할 정보다.
class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String?)>[
      ('수면', user?.sleepPattern?.label),
      ('스트레스', user?.stressLevel?.label),
      ('운동', user?.exerciseHabit?.label),
      ('물 섭취', user?.waterIntake?.label),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textOnCard)),
                  const Spacer(),
                  Text(
                    value ?? '미설정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
