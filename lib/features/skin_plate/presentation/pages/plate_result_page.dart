import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../domain/entities/skin_plate.dart';
import '../providers/plate_notifier.dart';

/// S07 — Skin Plate 결과.
///
/// 이 화면의 주인공은 점수가 아니라 **행동**이다. "국물을 절반만 남기면 오릅니다"라는
/// 문장과, 버튼을 눌러 60 → 68 이 실제로 오르는 경험은 다른 제품이다. (PRD §6 · §21)
///
/// 여기 보이는 결과는 **아직 기록이 아니다.** [기록에 저장하기] 를 눌러야 히스토리와
/// 리포트에 들어간다. 그냥 나가면 서버에 아무것도 남지 않는다 — 앱이 지울 것도 없다.
class PlateResultPage extends ConsumerStatefulWidget {
  const PlateResultPage({super.key});

  @override
  ConsumerState<PlateResultPage> createState() => _PlateResultPageState();
}

class _PlateResultPageState extends ConsumerState<PlateResultPage> {
  final Set<PlateActionCode> _applied = <PlateActionCode>{};

  Future<void> _toggle(PlateActionCode action) async {
    setState(() {
      if (!_applied.remove(action)) _applied.add(action);
    });

    final notifier = ref.read(plateNotifierProvider.notifier);
    if (_applied.isEmpty) {
      notifier.clearSimulation();
      return;
    }
    await notifier.simulate(_applied.toList());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plateNotifierProvider);
    final view = state.view;

    return Scaffold(
      appBar: AppBar(title: const Text('Skin Plate')),
      body: switch (state) {
        // 분석 자체가 실패했다. 만료·미인식은 FailureView 가 "다시 촬영하기"로 낸다.
        PlateState(status: PlateRecordStatus.analyzing, failure: final Failure error) =>
          FailureView(failure: error, onRetry: () => context.pop()),
        PlateState(status: PlateRecordStatus.analyzing) =>
          const Center(child: CircularProgressIndicator()),
        _ when view != null => _Content(
            plate: view,
            state: state,
            applied: _applied,
            onToggle: _toggle,
            onSave: () => ref.read(plateNotifierProvider.notifier).saveRecord(),
            onRetake: () => context.pop(),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.plate,
    required this.state,
    required this.applied,
    required this.onToggle,
    required this.onSave,
    required this.onRetake,
  });

  /// 임시 분석이든 저장된 기록이든 화면은 같은 것을 그린다.
  final PlateView plate;

  final PlateState state;
  final Set<PlateActionCode> applied;
  final Future<void> Function(PlateActionCode) onToggle;
  final VoidCallback onSave;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final score = state.displayedScore ?? plate.plateScore;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(state.imageBytes!, height: 180, fit: BoxFit.cover),
          ),
        const SizedBox(height: 16),
        Text(plate.food.foodName, style: Theme.of(context).textTheme.titleLarge),
        Text('${plate.food.foodCategory ?? ''} · ${plate.food.cookingMethod.label}'),
        const SizedBox(height: 24),

        // end 가 바뀌면 현재 값에서 새 값으로 이어서 움직인다. 시뮬레이션 버튼을
        // 누르는 순간 숫자가 눈앞에서 올라가는 게 이 화면의 클라이맥스다.
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, value, _) =>
                ScoreGauge(score: value.round(), label: 'Skin Plate'),
          ),
        ),
        if (FeatureFlags.actionSimulation && state.simulating)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: LinearProgressIndicator()),
          ),
        if (FeatureFlags.actionSimulation && state.simulation != null) ...[
          const SizedBox(height: 12),
          Text(
            '${state.simulation!.beforeScore}점 → ${state.simulation!.afterScore}점',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(state.simulation!.summary, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 16),
        if (plate.summary.isNotEmpty) Text(plate.summary, textAlign: TextAlign.center),
        const SizedBox(height: 24),

        _SaveSection(state: state, onSave: onSave, onRetake: onRetake),
        const SizedBox(height: 24),

        _FeedbackSection(title: '좋은 점', items: plate.good, positive: true),
        _FeedbackSection(title: '주의사항', items: plate.caution, positive: false),

        if (FeatureFlags.actionSimulation && plate.actions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('추천 행동', style: Theme.of(context).textTheme.titleMedium),
          for (final action in plate.actions)
            _ActionCard(
              action: action,
              applied: applied.contains(PlateActionCode.forRuleCode(action.ruleCode)),
              onToggle: onToggle,
            ),
        ],

        const SizedBox(height: 16),
        _ScoreBreakdown(plate: plate),

        const SizedBox(height: 16),
        // 서버가 이 Plate 의 기준이 된 skinAnalysisId 를 실어 준다.
        // "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때 엉뚱한 추천이 뜬다.
        if (FeatureFlags.recommendationScreen)
          FilledButton.tonalIcon(
            onPressed: () =>
                context.push('${Routes.recommendations}/${plate.skinAnalysisId}'),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('오늘의 추천 음식 보기'),
          ),
        const SafetyNotice(),
      ],
    );
  }
}

/// 기록 확정 CTA. 이 버튼을 누르기 전까지 서버에는 아무것도 없다.
class _SaveSection extends StatelessWidget {
  const _SaveSection({
    required this.state,
    required this.onSave,
    required this.onRetake,
  });

  final PlateState state;
  final VoidCallback onSave;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      PlateRecordStatus.saved => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('오늘의 기록에 저장됐어요',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),

      // 진행 중에는 눌리지 않는다. onPressed: null 이 곧 중복 클릭 차단이다.
      PlateRecordStatus.saving => const FilledButton(
          onPressed: null,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),

      PlateRecordStatus.saveFailed => _SaveFailed(
          failure: state.failure,
          onRetry: state.canRetrySave ? onSave : null,
          onRetake: onRetake,
        ),

      _ => FilledButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('기록에 저장하기'),
        ),
    };
  }
}

/// 재시도할 수 있는 실패와 그럴 수 없는 실패를 구분해서 낸다.
///
/// 만료(422)는 같은 토큰을 다시 보내도 계속 만료다. "다시 시도"를 주면 사용자가
/// 눌러보다 결국 앱을 닫는다. 재촬영으로 보낸다.
class _SaveFailed extends StatelessWidget {
  const _SaveFailed({
    required this.failure,
    required this.onRetry,
    required this.onRetake,
  });

  final Failure? failure;
  final VoidCallback? onRetry;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          failure?.message ?? '기록을 저장하지 못했습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 12),
        // 재시도할 수 없는 실패는 전부 재촬영으로 보낸다. 400·404 처럼 어느 쪽도
        // 아닌 코드에서 버튼을 아예 안 그리면 저장 버튼까지 사라진 화면에
        // 오류 문구만 남아 사용자가 나갈 곳이 없다.
        if (onRetry != null)
          FilledButton(onPressed: onRetry, child: const Text('다시 시도'))
        else
          FilledButton(onPressed: onRetake, child: const Text('다시 촬영하기')),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.title,
    required this.items,
    required this.positive,
  });

  final String title;
  final List<PlateFeedback> items;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          for (final item in items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                positive ? Icons.check_circle : Icons.warning,
                color: positive ? Colors.green : Colors.orange,
              ),
              title: Text(item.message),
              trailing: Text(
                item.scoreDelta > 0 ? '+${item.scoreDelta}' : '${item.scoreDelta}',
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.action,
    required this.applied,
    required this.onToggle,
  });

  final PlateAction action;
  final bool applied;
  final Future<void> Function(PlateActionCode) onToggle;

  @override
  Widget build(BuildContext context) {
    final code = PlateActionCode.forRuleCode(action.ruleCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action.message),
            const SizedBox(height: 8),
            // expectedGain 은 안내용이다. 실제 점수는 서버가 다시 계산해서 준다.
            // 여기서 plateScore + expectedGain 으로 더하면 실제와 다른 숫자가 나온다.
            Text('실행하면 약 +${action.expectedGain}점',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (code == null)
              // 서버가 액션 버튼이 없는 룰에 행동 문구만 붙인 경우다. 문구는 보여준다.
              const Text('(직접 실천해 보세요)')
            else
              // 저장 전에도 눌린다. 저장을 강제해야 실행해 볼 수 있으면 이 화면의
              // 존재 이유가 기록 뒤로 밀린다 — 서버가 토큰 기반 simulate 를 준다.
              FilledButton.tonal(
                onPressed: () => onToggle(code),
                child: Text(applied ? '되돌리기' : code.label),
              ),
          ],
        ),
      ),
    );
  }
}

/// "왜 60점인가" 접이식 계산 내역.
///
/// baseScore 를 앱이 70 으로 하드코딩하지 않는다. 점수가 0/100 에서 잘렸을 때
/// 역산이 틀리기 때문에 서버가 값을 내려준다. (설계서 §2.10)
class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.plate});

  final PlateView plate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('왜 ${plate.plateScore}점인가요?'),
        children: [
          ListTile(
            dense: true,
            title: const Text('기본 점수'),
            trailing: Text('${plate.baseScore}'),
          ),
          for (final item in [...plate.good, ...plate.caution])
            ListTile(
              dense: true,
              title: Text('${item.message}  (${item.ruleCode ?? '-'})'),
              trailing: Text(
                item.scoreDelta > 0 ? '+${item.scoreDelta}' : '${item.scoreDelta}',
              ),
            ),
          const Divider(),
          ListTile(
            dense: true,
            title: const Text('합계'),
            trailing: Text('${plate.plateScore}'),
          ),
        ],
      ),
    );
  }
}
