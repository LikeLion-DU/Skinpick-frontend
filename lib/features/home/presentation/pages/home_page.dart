import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../skin_analysis/domain/entities/skin_analysis.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';

/// S02 — 홈. 오늘의 Skin Score 카드와 다음 단계 CTA.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final nickname = switch (auth) {
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
            _TodayScoreCard(),
          ],
        ),
      ),
    );
  }
}

class _TodayScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestSkinAnalysisProvider);

    return latest.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      // 여기의 error 는 Failure 가 아니라 예상 못 한 예외다.
      // Repository 가 던지는 실패는 아래 Result 쪽으로 온다.
      error: (error, _) => Text('불러오지 못했습니다: $error'),
      data: (result) => result.when(
        success: (analysis) =>
            analysis == null ? const _EmptyCard() : _ScoreCard(analysis: analysis),
        failure: (failure) => FailureView(
          failure: failure,
          onRetry: () => ref.invalidate(latestSkinAnalysisProvider),
        ),
      ),
    );
  }
}

/// 아직 한 번도 안 찍은 사용자. 점수 대신 시작 버튼을 보여준다.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('아직 오늘의 피부 기록이 없어요'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push(Routes.skinCapture),
              icon: const Icon(Icons.camera_alt),
              label: const Text('피부 분석하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('오늘의 Skin Score'),
                const SizedBox(height: 16),
                ScoreGauge(score: analysis.skinScore),
                if (analysis.summary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(analysis.summary, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 결과 화면의 주인공은 점수가 아니라 다음 행동이다.
        FilledButton.icon(
          onPressed: () => context.push(Routes.foodCapture),
          icon: const Icon(Icons.restaurant),
          label: const Text('음식 분석하기'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push(Routes.skinCapture),
          child: const Text('피부 다시 분석하기'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () =>
              context.push('${Routes.recommendations}/${analysis.id}'),
          child: const Text('오늘의 추천 음식 보기'),
        ),
      ],
    );
  }
}
