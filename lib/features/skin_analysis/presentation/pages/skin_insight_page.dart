import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/entities/skin_insight.dart';
import '../providers/skin_analysis_notifier.dart';

/// S10 — 개인화 피부 인사이트.
///
/// 사용자가 3초 안에 넷을 읽어야 한다: 내 피부가 지금 어떤지, 최근 생활이 어떤지,
/// AI 가 무엇을 중요하게 보는지, 오늘 무엇을 하면 되는지. 섹션 순서가 그 순서다.
///
/// **문장은 하나도 앱이 만들지 않는다.** summary·description·행동 문구 전부 서버가
/// 준 것을 그대로 싣는다 — 앱이 인과관계를 지어내면 의학적 표현 금지 규칙이 두
/// 곳으로 갈리고, 그중 하나는 아무도 안 본다.
class SkinInsightPage extends ConsumerWidget {
  const SkinInsightPage({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final needsLifestyle =
        auth is Authenticated && auth.user.hasIncompleteLifestyle;

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 피부 인사이트')),
      // **습관이 비어 있으면 조회 자체를 하지 않는다.** `GET /skin-insights` 는
      // get-or-create 라, 한 번이라도 부르면 서버가 습관 없이 인사이트를 만들어
      // 저장한다 — 그 뒤에 습관을 채워도 생활 관련 주제는 영영 안 들어간다.
      // 그래서 [skinInsightProvider] 를 watch 하기 **전에** 갈라야 한다.
      //
      // 게이트를 진입점(결과 화면·피부 프로필)이 아니라 여기 두는 이유 — 진입점이
      // 둘이고 앞으로 늘어난다. 화면마다 가드를 두면 언젠가 한 곳을 빠뜨리고,
      // 그 한 곳이 습관 없는 인사이트를 굳혀 버린다.
      body: needsLifestyle
          ? const _LifestyleNeeded()
          : _InsightView(skinAnalysisId: skinAnalysisId),
    );
  }
}

/// 습관을 아직 안 채운 사용자에게 **왜** 필요한지 먼저 말한다.
///
/// 곧바로 설문으로 튕기지 않는 이유 — 이 화면은 사용자가 "내 생활 상태와 함께
/// 분석하기" 를 눌러서 온 곳이다. 이유 없이 설문이 뜨면 가입 때 "선택" 이라고
/// 했던 항목이 갑자기 필수가 된 것으로만 읽힌다.
class _LifestyleNeeded extends StatelessWidget {
  const _LifestyleNeeded();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '맞춤 인사이트를 보려면\n생활 습관 정보가 필요해요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '수면·스트레스·운동·수분 네 가지를 알려주시면\n'
              '오늘 피부 상태와 함께 봐 드릴게요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              // push 다 — 입력을 마치면 이 화면으로 돌아와야 한다. 돌아오면
              // authNotifier 의 사용자 정보가 갱신돼 있어 게이트가 풀리고,
              // 그때 처음으로 인사이트를 조회한다.
              onPressed: () => context.push(Routes.lifestyle),
              child: const Text('생활 습관 입력하기'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게이트를 지난 뒤에만 만들어진다. 여기서 처음 [skinInsightProvider] 를 건드린다.
class _InsightView extends ConsumerWidget {
  const _InsightView({required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(skinInsightProvider(skinAnalysisId));

    return insight.when(
      // 첫 조회는 서버가 AI 를 기다리느라 최대 ~27초다. 스피너만 돌면 멈춘 줄 안다.
      loading: () => const LoadingSteps(
        steps: [
          '피부와 생활 상태를 함께 보고 있어요',
          '오늘 측정한 지표를 살펴보는 중이에요',
          '설정해 둔 생활 습관과 맞춰 보는 중이에요',
          '오늘 신경 쓰면 좋을 것을 고르고 있어요',
        ],
      ),
      error: (error, _) => Center(child: Text('$error')),
      data: (result) => result.when(
        // AI 실패(502·504)는 mapToFailure 가 AnalysisFailure 로 번역하고
        // shouldRetakePhoto 가 false 라 "다시 시도" 가 나온다. 서버가 실패한
        // 인사이트를 저장하지 않으므로 같은 GET 이 그대로 재시도가 된다.
        //
        // 404(타인·없는 분석)는 ServerFailure 로 떨어져 서버 메시지만 보인다.
        failure: (failure) => FailureView(
          failure: failure,
          onRetry: () => ref.invalidate(skinInsightProvider(skinAnalysisId)),
        ),
        success: (data) => _Body(insight: data),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.insight});

  final SkinInsight insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 지표 값은 인사이트 응답에 없다. 분석 쪽에서 읽어 온다.
    //
    // ponytail: 최신 분석 = 이 화면의 분석이라고 가정한다. 피부 히스토리 화면이
    // 없어 진입 경로가 결과 화면 하나뿐이라 지금은 참이다. 과거 분석으로 들어오는
    // 길이 생기면 id 를 비교해 skinRepository.getById 로 떨어뜨린다.
    final analysis = ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;
    final auth = ref.watch(authNotifierProvider);
    final user = auth is Authenticated ? auth.user : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 8, AppTheme.pagePadding, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (analysis != null) ...[
            const _SectionTitle('현재 피부 상태'),
            const SizedBox(height: 10),
            _MetricsCard(metrics: analysis.metrics, changes: insight.changes),
            const SizedBox(height: 22),
          ],
          const _SectionTitle('현재 설정된 생활 상태'),
          const SizedBox(height: 10),
          _LifestyleCard(
            user: user,
            insightsAreEmpty: insight.insights.isEmpty,
            // 설정하고 돌아오면 다시 물어본다. 이 화면은 아래 깔린 채로 살아 있어서
            // autoDispose 가 안 걸리고, 그냥 두면 방금 채운 습관이 반영되지 않는다.
            onProfileChanged: () =>
                ref.invalidate(skinInsightProvider(insight.skinAnalysisId)),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('AI 인사이트'),
          const SizedBox(height: 10),
          _SummaryCard(summary: insight.summary),
          if (insight.insights.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle('오늘의 우선 관리'),
            const SizedBox(height: 10),
            for (final (index, item) in insight.insights.indexed) ...[
              // 첫 항목만 강조 카드다. priority 를 글자로 노출하지 않는다 —
              // HIGH/MEDIUM 은 서버 내부 어휘지 사용자가 배울 말이 아니다.
              _InsightCard(item: item, emphasized: index == 0),
              if (index != insight.insights.length - 1)
                const SizedBox(height: 8),
            ],
          ],
          if (insight.todayActions.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle('오늘의 행동'),
            const SizedBox(height: 10),
            // 우선 관리와 같은 주제가 다시 나온다(서버가 같은 items 로 만든다).
            // 아이콘 없이 한 줄로 납작하게 그려 같은 카드를 두 번 그린 것처럼
            // 보이지 않게 한다 — 위는 "무엇을 볼까", 여기는 "무엇을 할까"다.
            for (final action in insight.todayActions) ...[
              _ActionRow(title: action.title),
              const SizedBox(height: 6),
            ],
          ],
          const SizedBox(height: 18),
          const Text(
            '측정 환경에 따라 결과가 달라질 수 있어요',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSecondary, height: 1.35),
          ),
          const SafetyNotice(),
        ],
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

/// 5지표. 결과 화면(S05)은 시안대로 4개만 그리지만 여기는 다 그린다 —
/// changes 가 5개 전부의 델타를 주고, 트러블 인사이트가 떴을 때 근거 지표가
/// 화면에 없으면 설명이 붕 뜬다.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.metrics, this.changes});

  final SkinMetrics metrics;
  final SkinInsightChanges? changes;

  @override
  Widget build(BuildContext context) {
    return _Card(
      cream: true,
      child: Column(
        children: [
          for (final bar in metrics.toBars()) ...[
            _MetricRow(
              label: bar.label,
              value: bar.value,
              // 결과 화면(S05)과 같은 밴드를 쓴다. ScoreGrade 로 매기면 경계가
              // 75/60 이라 홍조 50 같은 평범한 값이 빨강이 되고, 한 탭 전에 본
              // 같은 지표가 다른 색이 된다.
              band: MetricBand.of(bar.value,
                  higherIsBetterMetric: bar.higherIsBetter),
              delta: changes?.byKey(bar.key),
            ),
            if (bar.key != 'barrier') const SizedBox(height: 12),
          ],
          if (changes == null) ...[
            const SizedBox(height: 14),
            // 0 을 그리거나 칸을 비워 두면 "변화가 없었다"로 읽힌다.
            const Text(
              '첫 피부 분석이라 아직 비교할 데이터가 없어요',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
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
    this.delta,
  });

  final String label;
  final int value;
  final MetricBand band;

  /// null = 첫 분석이라 비교 대상이 없다.
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final change = delta;

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textOnCard, height: 1)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(band.color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text('$value',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: band.color,
                    height: 1)),
          ),
        ),
        SizedBox(
          width: 34,
          child: change == null
              ? null
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  // 부호를 그대로 보여준다. 좋아졌다/나빠졌다는 앱이 말하지 않는다 —
                  // 측정 환경 차이를 서버도 단정하지 않기 때문이다.
                  child: Text(
                    change > 0 ? '+$change' : '$change',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1),
                  ),
                ),
        ),
      ],
    );
  }
}

/// ponytail: 게이트가 S10 앞에 서면서 이 카드의 **"미설정" 갈래 전체**가 로그인한
/// 사용자에게 닿지 않는다 — 습관 네 칸이 다 차야 여기까지 온다. 구체적으로
/// [_notice] 의 미완료 분기, "생활 상태 설정" 버튼, 거기에 물린 [onProfileChanged]
/// 와 그 안의 `ref.invalidate` 가 전부 그렇다.
///
/// `user == null`(비로그인) 방어용으로만 남겨 둔다. 라우터가 그 상태를 막고 있어
/// 실제로는 보이지 않는다. 지우려면 넷을 같이 지워야 한다.
class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({
    required this.user,
    required this.insightsAreEmpty,
    required this.onProfileChanged,
  });

  final AuthUser? user;

  /// 저장 여부가 안내 문구를 가른다. 서버는 빈 인사이트를 저장하지 않으므로
  /// 그 경우엔 지금 설정하면 이 분석의 인사이트가 새로 만들어진다.
  final bool insightsAreEmpty;

  final VoidCallback onProfileChanged;

  /// 인사이트가 비어 있는 이유가 둘이라 문구가 갈린다.
  ///
  /// 서버는 나쁜 값에만 습관 주제를 만든다(수면 부족·스트레스 높음·운동 안 함·수분
  /// 부족). 그러니 프로필을 이미 다 채운 사람에게 "설정하고 다시 보라"고 하면
  /// 설정할 것도 없고 다시 봐도 안 채워진다 — 화면이 못 지킬 약속을 하는 셈이다.
  String get _notice {
    if (!insightsAreEmpty) {
      // 저장된 인사이트다. 스냅샷은 분석 시점이 아니라 이 인사이트를 처음 조회한
      // 시점의 프로필이다(서버가 GET 안에서 만든다).
      return '이 인사이트는 처음 확인한 시점의 생활 상태를 기준으로 만들어졌어요.'
          ' 바꾼 내용은 다음 피부 분석부터 반영돼요.';
    }
    if (user?.hasIncompleteLifestyle ?? true) {
      return '생활 상태를 설정하고 다시 보면 인사이트가 채워져요';
    }
    return '지금은 따로 챙길 주제가 없어요. 지금처럼 유지해 보세요.';
  }

  @override
  Widget build(BuildContext context) {
    final profile = user;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LifestyleRow(
              icon: Icons.nightlight_outlined,
              label: '수면',
              value: profile?.sleepPattern?.label),
          const SizedBox(height: 10),
          _LifestyleRow(
              icon: Icons.sentiment_very_dissatisfied_outlined,
              label: '스트레스',
              value: profile?.stressLevel?.label),
          const SizedBox(height: 10),
          _LifestyleRow(
              icon: Icons.fitness_center,
              label: '운동',
              value: profile?.exerciseHabit?.label),
          const SizedBox(height: 10),
          _LifestyleRow(
              icon: Icons.water_drop_outlined,
              label: '수분 섭취',
              value: profile?.waterIntake?.label),
          const SizedBox(height: 14),
          Text(
            _notice,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary, height: 1.35),
          ),
          if (profile?.hasIncompleteLifestyle ?? true)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  await context.push(Routes.skinType);
                  onProfileChanged();
                },
                child: const Text('생활 상태 설정'),
              ),
            ),
        ],
      ),
    );
  }
}

class _LifestyleRow extends StatelessWidget {
  const _LifestyleRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final selected = value != null;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textOnCard, height: 1)),
        ),
        Text(
          value ?? '미설정',
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _Card(
      cream: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textOnCard, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item, required this.emphasized});

  final SkinInsightItem item;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return _Card(
      cream: emphasized,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 모르는 카테고리면 중립 아이콘이다. 억지 기본값은 엉뚱한 그림을 붙인다.
              Icon(item.category?.icon ?? Icons.spa_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textOnCard, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderOnWhite),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textOnCard, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 깊이는 그림자가 아니라 면색 + 테두리다. (DESIGN.md)
class _Card extends StatelessWidget {
  const _Card({required this.child, this.cream = false});

  final Widget child;
  final bool cream;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cream ? AppColors.surfaceCard : AppColors.background,
        border: Border.all(
            color: cream ? AppColors.borderOnCream : AppColors.borderOnWhite),
        borderRadius: BorderRadius.circular(cream ? 16 : 9),
      ),
      child: child,
    );
  }
}
