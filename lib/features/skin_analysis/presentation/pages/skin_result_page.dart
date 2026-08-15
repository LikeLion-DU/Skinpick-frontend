import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../providers/skin_analysis_notifier.dart';

/// S05 — 분석 완료. 확정 시안 구성이다:
/// 체크 아이콘 · 타입 카드(점수·지표 4종·요약·하이라이트) · "앞으로 이런 기준으로"
/// 카드 · 시작 버튼.
///
/// 시안이 지표를 4개만 보여주는 것은 확인받은 의도다(서버는 5개를 준다).
/// trouble 은 화면에 안 그리지만 점수 계산에는 그대로 들어가 있다.
///
/// **점수와 하이라이트는 반드시 화면에 있어야 한다.** 산식이 공개돼 있어
/// 심사위원이 직접 검산할 수 있다는 게 이 기능의 근거다(PRD §4.1). 시안이 이
/// 자리를 그리지 않았을 뿐이라, 타입 카드 안에 넣어 화면을 새로 만들지 않는다.
class SkinResultPage extends ConsumerWidget {
  const SkinResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skinAnalysisNotifierProvider);

    // 방금 찍고 들어온 경우와 홈에서 들어온 경우가 다르다.
    // 후자는 Notifier 가 비어 있으므로 최신 기록으로 떨어뜨린다.
    final analysis = state.analysis.value ??
        ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;

    if (analysis == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 카드 제목의 타입. 오늘 측정(observed)이 있으면 그쪽이 맞다 —
    // 이 화면은 방금 한 분석의 결과지, 자기 소개가 아니다.
    final declaredType = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };
    final headlineType = analysis.skinTypeGap?.observed ?? declaredType;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 0, AppTheme.pagePadding, 32),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child:
                  const Icon(Icons.check, size: 38, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text('분석이 완료됐어요',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              '설정한 프로필을 바탕으로\n사용자의 피부 상태를 분석했어요 : )',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF494949), height: 1.5),
            ),
          ),
          const SizedBox(height: 36),

          _TypeCard(analysis: analysis, headlineType: headlineType),
          const SizedBox(height: 22),
          const _CriteriaCard(),

          const SizedBox(height: 22),
          if (analysis.skinTypeGap != null)
            _GapCard(gap: analysis.skinTypeGap!)
          else
            _SkinTypePrompt(analysisId: analysis.id),

          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: () => context.push(Routes.foodCapture),
            child: const Text('음식 분석 시작하기'),
          ),
          // S10 진입점. 방금 분석의 id 로 물어야 오늘 결과와 짝이 맞는다.
          // FeatureFlags 로 감싸지 않는다 — 켜 놓을 화면이라 항상 true 인 플래그는
          // 스위치가 아니라 "여기 스위치가 있다"는 착각만 남긴다.
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.push('${Routes.skinInsight}/${analysis.id}'),
            child: const Text('내 생활 상태와 함께 분석하기'),
          ),
          // S08 진입점. 방금 분석의 id 로 추천을 물어야 오늘 결과와 짝이 맞는다.
          if (FeatureFlags.recommendationScreen) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  context.push('${Routes.recommendations}/${analysis.id}'),
              child: const Text('오늘의 추천 음식 보기'),
            ),
          ],
          const SafetyNotice(),
        ],
      ),
    );
  }
}

/// 지표 하나의 화면 표기 — 상태 어휘와 색은 시안 값이다.
class _MetricBand {
  const _MetricBand(this.label, this.color);

  final String label;
  final Color color;

  static const _blue = Color(0xFF3A85E2);
  static const _red = Color(0xFFFA6154);

  /// 높을수록 좋은 지표(수분·피부결). 낮으면 "부족"이다.
  static _MetricBand higherIsBetter(int value) {
    if (value < 40) return const _MetricBand('부족', _blue);
    if (value < 60) return const _MetricBand('보통', AppColors.primary);
    return const _MetricBand('좋음', AppColors.good);
  }

  /// 높을수록 나쁜 지표(유분·붉어짐). 높으면 "주의"다.
  static _MetricBand higherIsWorse(int value) {
    if (value >= 60) return const _MetricBand('주의', _red);
    if (value >= 40) return const _MetricBand('보통', AppColors.primary);
    return const _MetricBand('좋음', AppColors.good);
  }
}

/// "복합성 피부" 카드 — 민감도 배지와 지표 4종 원.
class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.analysis, required this.headlineType});

  final SkinAnalysis analysis;
  final SkinType? headlineType;

  @override
  Widget build(BuildContext context) {
    final metrics = analysis.metrics;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  headlineType == null ? '오늘의 피부' : '${headlineType!.label} 피부',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 민감도 배지. 붉어짐이 높을 때만 단다 — 근거 없이 달면
              // "높음"이 안 뜨는 날 이 배지의 신뢰가 같이 사라진다.
              if (metrics.redness >= 60)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('민감도 높음',
                      style:
                          TextStyle(fontSize: 10, color: AppColors.primary)),
                ),
              const Spacer(),
              // 서버가 준 총점. 앱에서 다시 계산하지 않는다.
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${analysis.skinScore}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const TextSpan(
                      text: '점',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _Metric(
                label: '수분',
                band: _MetricBand.higherIsBetter(metrics.hydration),
                icon: Icons.water_drop,
                foreground: AppColors.hydrationFg,
                background: AppColors.hydrationBg,
              ),
              _Metric(
                label: '유분 밸런스',
                band: _MetricBand.higherIsWorse(metrics.oil),
                icon: Icons.opacity,
                foreground: AppColors.oilFg,
                background: AppColors.oilBg,
              ),
              _Metric(
                label: '붉어짐',
                band: _MetricBand.higherIsWorse(metrics.redness),
                icon: Icons.waves,
                foreground: AppColors.rednessFg,
                background: AppColors.rednessBg,
              ),
              _Metric(
                label: '피부결',
                band: _MetricBand.higherIsBetter(metrics.barrier),
                icon: Icons.auto_awesome,
                foreground: AppColors.textureFg,
                background: AppColors.textureBg,
              ),
            ],
          ),

          // 서버가 만든 한 줄 요약. 앱이 문장을 짓지 않는다.
          if (analysis.summary.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              analysis.summary,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF494949), height: 1.5),
            ),
          ],

          if (analysis.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderOnWhite),
            const SizedBox(height: 14),
            for (final highlight in analysis.highlights)
              _HighlightRow(highlight: highlight),
          ],
        ],
      ),
    );
  }
}

/// 요약 하이라이트 한 줄.
///
/// 모르는 상태값은 파서가 [HighlightStatus.warn] 으로 떨어뜨린다. 여기서 색을
/// 초록으로 주면 그 낙하가 "괜찮다"로 뒤집힌다 — 주의색을 유지한다.
class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.highlight});

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (highlight.status) {
      HighlightStatus.good => (AppColors.good, Icons.check_circle),
      HighlightStatus.warn => (AppColors.caution, Icons.info),
      HighlightStatus.caution => (AppColors.bad, Icons.warning),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              highlight.label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF494949), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.band,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final _MetricBand band;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(shape: BoxShape.circle, color: background),
            child: Icon(icon, size: 24, color: foreground),
          ),
          const SizedBox(height: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text(band.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: band.color,
              )),
        ],
      ),
    );
  }
}

/// "앞으로 음식 분석은 이런 기준으로" — 두 기둥 안내 카드.
class _CriteriaCard extends StatelessWidget {
  const _CriteriaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('앞으로 음식 분석은 이런 기준으로',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                _column(Icons.face_retouching_natural, '피부 고민 맞춤 분석',
                    '민감도, 수분, 피지 밸런스 등\n내 피부 고민을 고려해 분석해요.'),
                const VerticalDivider(
                    width: 1, color: AppColors.borderOnWhite),
                _column(Icons.restaurant_menu, '영양 균형 체크',
                    '음식의 영양 구성을 확인하고\n피부에 어떤 영향을 줄지 알려드려요.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(IconData icon, String title, String description) => Expanded(
        child: Column(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF494949),
                )),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8.5,
                color: Color(0xFF494949),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

/// "알고 계셨던 것과 오늘 측정이 다르다"를 보여주는 카드.
/// 문장은 서버가 만들어 준다 — 앱이 조합하면 규칙이 두 곳에 생긴다.
class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap});

  final SkinTypeGap gap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('평소 생각하신 타입 : ${gap.declared.label}'),
            Text('오늘 측정 기준     : ${gap.observed.label}'),
            const Divider(),
            Text(gap.message),
          ],
        ),
      ),
    );
  }
}

/// 피부 타입을 아직 안 고른 사용자. 갭 카드 자리에 선택 칩이 대신 뜬다.
/// 건너뛴 사용자도 결과를 본 뒤 마음이 바뀌면 그 자리에서 고를 수 있다. (PRD §4.4.1)
class _SkinTypePrompt extends ConsumerStatefulWidget {
  const _SkinTypePrompt({required this.analysisId});

  final int analysisId;

  @override
  ConsumerState<_SkinTypePrompt> createState() => _SkinTypePromptState();
}

class _SkinTypePromptState extends ConsumerState<_SkinTypePrompt> {
  bool _busy = false;

  Future<void> _select(SkinType type) async {
    setState(() => _busy = true);

    final failure =
        await ref.read(authNotifierProvider.notifier)
            .updateProfile(declaredSkinType: type);

    if (failure == null) {
      // 갭 문장은 서버가 만든다. 다시 받아야 카드가 뜬다.
      await ref
          .read(skinAnalysisNotifierProvider.notifier)
          .refresh(widget.analysisId);
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('평소 본인 피부는 어떻다고 생각하세요?'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final type in SkinType.selectable)
                  ActionChip(
                    label: Text(type.label),
                    onPressed: _busy ? null : () => _select(type),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
