import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';

/// S02 — 홈.
///
/// 두 동작은 서로 독립이다. 피부 분석은 **사용자가 하고 싶을 때 아무 때나** 누르는
/// 버튼이고, 음식 촬영은 찍으면 곧바로 상극 분석 결과(S07)로 이어진다.
/// 순서를 강제하는 마법사가 아니다.
///
/// 다만 상극 분석은 비교할 피부 기준이 있어야 성립한다. 그래서 피부 기록이 하나도
/// 없을 때만 음식 버튼이 안내를 띄운다 — 숨기지는 않는다. 버튼이 사라지면
/// 사용자는 그 기능이 없는 줄 안다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.nickname,
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Plate'),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(latestSkinAnalysisProvider),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('안녕하세요, $nickname님',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('오늘도 피부에 좋은 선택을 해봐요'),
            const SizedBox(height: 24),
            const _SkinCard(),
            const SizedBox(height: 24),
            const _Actions(),
          ],
        ),
      ),
    );
  }
}

/// 오늘의 Skin Score. 기록이 없어도 카드 자리는 유지한다.
class _SkinCard extends ConsumerWidget {
  const _SkinCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestSkinAnalysisProvider);

    return latest.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      // 여기의 error 는 Failure 가 아니라 예상 못 한 예외다.
      // Repository 가 만드는 실패는 아래 Result 쪽으로 온다.
      error: (error, _) => Text('불러오지 못했습니다: $error'),
      data: (result) => result.when(
        failure: (failure) => FailureView(
          failure: failure,
          onRetry: () => ref.invalidate(latestSkinAnalysisProvider),
        ),
        success: (analysis) => Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: analysis == null
                ? const Center(child: Text('아직 오늘의 피부 기록이 없어요'))
                : Column(
                    children: [
                      const Text('오늘의 Skin Score'),
                      const SizedBox(height: 16),
                      ScoreGauge(score: analysis.skinScore),
                      if (analysis.summary.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(analysis.summary, textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push(Routes.skinResult),
                        child: const Text('자세히 보기'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions();

  /// 피부 기록이 없을 때만 뜬다. 막지 않고 어디로 가면 되는지 알려준다.
  Future<void> _explainSkinFirst(BuildContext context) async {
    final goToSkin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          '음식이 내 피부에 맞는지 보려면 비교할 기준이 필요해요.\n'
          '피부를 한 번만 분석하면 그 다음부터는 바로 음식만 찍으면 됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('피부 분석하기'),
          ),
        ],
      ),
    );

    if ((goToSkin ?? false) && context.mounted) context.push(Routes.skinCapture);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;
    final hasSkinRecord = analysis != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 주 액션. 찍으면 곧바로 상극 분석 결과로 이어진다.
        FilledButton.icon(
          onPressed: () => hasSkinRecord
              ? context.push(Routes.foodCapture)
              : _explainSkinFirst(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('음식 사진 분석하기'),
        ),
        const SizedBox(height: 8),

        // 언제든 다시 잴 수 있다. 기록 유무와 상관없이 항상 자리에 있는다.
        OutlinedButton.icon(
          onPressed: () => context.push(Routes.skinCapture),
          icon: const Icon(Icons.face_retouching_natural),
          label: Text(hasSkinRecord ? '피부 다시 분석하기' : '피부 분석하기'),
        ),

        if (hasSkinRecord) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('${Routes.recommendations}/${analysis.id}'),
            child: const Text('오늘의 추천 음식 보기'),
          ),
        ],

        // 피부 기록과 무관하게 항상 열려 있다. 저장한 식단만 들어 있다.
        TextButton(
          onPressed: () => context.push(Routes.plateHistory),
          child: const Text('내 기록 보기'),
        ),
      ],
    );
  }
}
