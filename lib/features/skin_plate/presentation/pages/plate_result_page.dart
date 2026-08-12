import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Skin Plate')),
      body: switch (state.plate) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final Failure error) =>
          FailureView(failure: error, onRetry: () => context.pop()),
        AsyncError(:final error) => Center(child: Text('$error')),
        AsyncData(:final value) when value != null => _Content(
            plate: value,
            state: state,
            applied: _applied,
            onToggle: _toggle,
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
  });

  final SkinPlate plate;
  final PlateState state;
  final Set<PlateActionCode> applied;
  final Future<void> Function(PlateActionCode) onToggle;

  @override
  Widget build(BuildContext context) {
    final score = state.displayedScore ?? plate.plateScore;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(state.image!, height: 180, fit: BoxFit.cover),
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
        if (state.simulating)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: LinearProgressIndicator()),
          ),
        if (state.simulation != null) ...[
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

        _FeedbackSection(title: '좋은 점', items: plate.good, positive: true),
        _FeedbackSection(title: '주의사항', items: plate.caution, positive: false),

        if (plate.actions.isNotEmpty) ...[
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

  final SkinPlate plate;

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
