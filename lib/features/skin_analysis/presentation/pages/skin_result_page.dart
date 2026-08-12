import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/highlight_status.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../providers/skin_analysis_notifier.dart';

/// S05 — 피부 결과.
///
/// 사진은 **서버가 준 URL 이 아니라 앱이 방금 찍은 로컬 파일**을 쓴다.
/// 서버는 얼굴 사진을 저장하지 않는다. (PRD §9.6)
class SkinResultPage extends ConsumerWidget {
  const SkinResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skinAnalysisNotifierProvider);

    // 방금 찍고 들어온 경우와 홈에서 "자세히 보기"로 들어온 경우가 다르다.
    // 후자는 Notifier 가 비어 있으므로 최신 기록으로 떨어뜨린다.
    // 그 경로에는 로컬 사진이 없다 — 서버가 얼굴 사진을 저장하지 않기 때문이고,
    // 그래서 아래에서 image 가 null 이면 사진 영역을 통째로 뺀다.
    final analysis = state.analysis.value ??
        ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;

    if (analysis == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('피부 분석 결과')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (state.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(state.image!, height: 180, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          Center(child: ScoreGauge(score: analysis.skinScore, label: 'Skin Score')),
          const SizedBox(height: 16),
          if (analysis.summary.isNotEmpty)
            Text(analysis.summary, textAlign: TextAlign.center),
          const SizedBox(height: 24),

          for (final highlight in analysis.highlights) _HighlightRow(highlight: highlight),
          const SizedBox(height: 16),

          // 총점 게이지와 5개 바를 한 화면에 같이 띄운다.
          // 산식이 공개돼 있어 심사위원이 직접 검산할 수 있다. (PRD §4.1)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final bar in analysis.metrics.toBars())
                    MetricBar(
                      label: bar.label,
                      value: bar.value,
                      higherIsBetter: bar.higherIsBetter,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (analysis.skinTypeGap != null)
            _GapCard(gap: analysis.skinTypeGap!)
          else
            _SkinTypePrompt(analysisId: analysis.id),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(Routes.foodCapture),
            icon: const Icon(Icons.restaurant),
            label: const Text('음식 분석하기'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('${Routes.recommendations}/${analysis.id}'),
            child: const Text('오늘의 추천 음식 보기'),
          ),
          const SafetyNotice(),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.highlight});

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (highlight.status) {
      HighlightStatus.good => (Colors.green, Icons.check_circle),
      HighlightStatus.warn => (Colors.orange, Icons.info),
      HighlightStatus.caution => (Colors.red, Icons.warning),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(highlight.label),
        ],
      ),
    );
  }
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
        await ref.read(authNotifierProvider.notifier).updateSkinType(type);

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
