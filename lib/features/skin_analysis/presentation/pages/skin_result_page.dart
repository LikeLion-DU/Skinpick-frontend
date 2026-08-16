import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../../shared/widgets/highlight_row.dart';
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
/// 프로필 설문은 이 화면 **앞**, 로딩 자리에 있다(S04). 여기 도착했을 때는 갭
/// 카드에 필요한 것이 이미 갖춰져 있다 — 설문보다 분석이 먼저 끝났다면 로딩
/// 화면이 결과를 다시 받아 두고 넘긴다(`_refetchForGap`). 이 화면에서 갭을
/// 채우려고 서버에 다녀오지 않는 이유다.
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
          // 프로필이 이 화면보다 뒤로 옮겨갔다. "설정한 프로필을 바탕으로"는
          // 온보딩 사용자에게 거짓말이고, 자가 신고 값은 원래 점수에 안 들어간다.
          const Center(
            child: Text(
              '방금 촬영한 사진으로\n오늘의 피부 상태를 분석했어요 : )',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ),
          const SizedBox(height: 36),

          _TypeCard(analysis: analysis, headlineType: headlineType),

          // 서버가 못 냈으면(예전 분석이거나 응답을 못 믿을 때) 키 자체가 없다.
          // 그때는 카드를 숨긴다 — 빈 값으로 그리면 없는 데이터를 보여주는 셈이다.
          // 범위도 앱에서 한 번 더 본다. 서버가 막고 있지만, 회귀가 나면
          // "AI 추정 피부 나이 0세" 가 확신에 찬 설명 문장 옆에 그려진다.
          if (analysis.skinAge?.isUsable ?? false) ...[
            const SizedBox(height: 22),
            _SkinAgeCard(skinAge: analysis.skinAge!),
          ],

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

// 지표 밴드는 shared/enums/metric_band.dart 로 옮겼다. 인사이트 화면(S10)이 같은
// 지표를 같은 색으로 칠해야 하는데, 여기 private 으로 두면 그쪽이 다른 기준을
// 쓰게 되고 두 화면에서 같은 값이 다른 색으로 나온다.

/// "복합성 피부" 카드 — 민감도 배지와 지표 4종 원.
class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.analysis, required this.headlineType});

  final SkinAnalysis analysis;
  final SkinType? headlineType;

  @override
  Widget build(BuildContext context) {
    final metrics = analysis.metrics;
    // 서버가 조합해 준 문구. "건성 · 민감 경향" 처럼 경향까지 들어 있다.
    final aiLabel = analysis.aiSkinType?.label ?? '';

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
              // 제목은 규칙 도출 타입 그대로 둔다. 바로 아래 갭 카드가 같은 값에
              // 기대고 있어서, 여기만 AI 관찰값으로 바꾸면 한 화면에서 "지성 피부" 와
              // "오늘 측정 기준 : 건성" 이 같이 보인다. 둘은 갈릴 수 있는 값이다.
              Text(
                headlineType == null ? '오늘의 피부' : '${headlineType!.label} 피부',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 10),
              // AI 가 읽은 타입은 칩으로 따로 단다(설계서 계약 주의표 8번).
              // 서버 문구를 그대로 쓴다 — 뒤에 아무것도 붙이지 않는다. '수부지' 처럼
              // 괄호로 끝나는 문구가 있어서 이어 붙이면 "…(수부지) 피부" 로 깨진다.
              //
              // 예전 분석이면 서버가 키를 생략하므로 기존 민감도 배지로 떨어진다.
              // 둘을 같이 달지 않는 이유는, 서버가 "민감 경향" 이라고 한 옆에서 앱이
              // 홍조 임계로 "민감도 높음" 을 따로 판정하게 되기 때문이다.
              if (aiLabel.isNotEmpty)
                Flexible(child: _Chip(aiLabel))
              else if (metrics.redness >= 60)
                const _Chip('민감도 높음'),
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
                band: MetricBand.higherIsBetter(metrics.hydration),
                icon: Icons.water_drop,
                foreground: AppColors.hydrationFg,
                background: AppColors.hydrationBg,
              ),
              _Metric(
                label: '유분',
                band: MetricBand.higherIsWorse(metrics.oil),
                icon: Icons.opacity,
                foreground: AppColors.oilFg,
                background: AppColors.oilBg,
              ),
              _Metric(
                label: '홍조',
                band: MetricBand.higherIsWorse(metrics.redness),
                icon: Icons.waves,
                foreground: AppColors.rednessFg,
                background: AppColors.rednessBg,
              ),
              _Metric(
                label: '피부결',
                band: MetricBand.higherIsBetter(metrics.barrier),
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
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ],

          if (analysis.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderOnWhite),
            const SizedBox(height: 14),
            for (final highlight in analysis.highlights)
              HighlightRow(highlight: highlight),
          ],
        ],
      ),
    );
  }
}


/// 제목 옆 작은 칩. 서버가 만든 문구를 그대로 담는다.
class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, color: AppColors.primary),
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
  final MetricBand band;
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

/// AI 추정 피부 나이 카드.
///
/// 실제 나이를 맞히는 것이 아니라 사진 기반 외관 추정이라, 보조 문구를 항상 같이
/// 띄운다. 숫자만 크게 놓으면 측정값으로 읽힌다.
///
/// 설명 문장은 서버가 만든다 — 앱이 짓거나 고치지 않는다.
class _SkinAgeCard extends StatelessWidget {
  const _SkinAgeCard({required this.skinAge});

  final SkinAge skinAge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Flexible 이 없으면 시스템 글자 크기를 키웠을 때 하드 오버플로다.
              // 두 자식이 다 고정 크기라 늘어날 자리가 없다.
              const Flexible(
                child: Text(
                  'AI 추정 피부 나이',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${skinAge.estimatedSkinAge}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const TextSpan(
                      text: '세',
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
          if (skinAge.assessment.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              skinAge.assessment,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            '사진 속 피부결, 주름, 탄력, 피부톤 등을 종합한 AI 추정값입니다.',
            style: TextStyle(fontSize: 10, color: AppColors.textBody, height: 1.4),
          ),
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
                  color: AppColors.textBody,
                )),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.textBody,
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
