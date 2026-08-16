import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_plate.dart';
import '../providers/plate_notifier.dart';
import '../widgets/plate_score_card.dart';
import '../widgets/plate_summary_cards.dart';
import '../widgets/skin_basis_card.dart';

/// S07 — 분석 결과.
///
/// 여기 보이는 결과는 **아직 기록이 아니다.** [기록에 저장하기] 를 눌러야
/// 히스토리에 들어간다. 그냥 나가면 서버에 아무것도 남지 않는다.
///
/// 행동 제안·시뮬레이션 UI 는 확정 시안에 없어 [FeatureFlags] 뒤로 물렸다.
/// 코드는 남긴다 — 서버 룰 엔진과의 계약이 거기 걸려 있다.
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
      appBar: AppBar(title: const Text('분석 결과')),
      body: switch (state) {
        // 분석 자체가 실패했다. 만료·미인식은 FailureView 가 "다시 촬영하기"로 낸다.
        PlateState(status: PlateRecordStatus.analyzing, failure: final Failure error) =>
          // 촬영 화면은 이미 교체돼 스택에 없다. pop 하면 촬영 이전 화면으로 나가
          // 버리므로, 재촬영은 카메라로 명시적으로 다시 들어간다.
          FailureView(
              failure: error,
              onRetry: () => context.pushReplacement(Routes.foodCapture)),
        PlateState(status: PlateRecordStatus.analyzing) =>
          const Center(child: CircularProgressIndicator()),
        _ when view != null => _Content(
            plate: view,
            state: state,
            applied: _applied,
            onToggle: _toggle,
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },

      // 저장 CTA 를 스크롤 밖에 고정한다. 목록 맨 아래에 두었더니 근거 카드가
      // 붙으면서 화면 밖으로 밀렸다 — 저장하고 나서도 "저장됐어요" 확인과
      // 나갈 버튼이 안 보였다. 이 화면의 존재 이유가 기록 확정이라 그건 곧
      // 화면이 제 일을 못 한다는 뜻이다.
      bottomNavigationBar: view == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                  AppTheme.pagePadding, 0, AppTheme.pagePadding, 12),
              child: _SaveSection(
                state: state,
                onSave: () =>
                    ref.read(plateNotifierProvider.notifier).saveRecord(),
                onRetake: () => context.pushReplacement(Routes.foodCapture),
              ),
            ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.plate,
    required this.state,
    required this.applied,
    required this.onToggle,
  });

  /// 임시 분석이든 저장된 기록이든 화면은 같은 것을 그린다.
  final PlateView plate;

  final PlateState state;
  final Set<PlateActionCode> applied;
  final Future<void> Function(PlateActionCode) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = state.displayedScore ?? plate.plateScore;

    // "민감성 피부 기준" — 채점에 실제로 쓰인 기준을 말해 주는 문구다.
    // 자가신고 타입이 없으면 문구를 비운다. 지어내서 채우지 않는다.
    final declaredType = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
      children: [
        // 음식명 칩. 시안이 제목 아래 왼쪽에 오렌지 사각 칩으로 박아 두었다.
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              plate.food.foodName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        PlateScoreCard(
          score: score,
          basisLabel:
              declaredType == null ? null : '${declaredType.label} 피부 기준',
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

        const SizedBox(height: 26),
        // 점수의 왼쪽 항. 아래 분석 요약(음식 쪽)과 짝이다.
        SkinBasisCard(skinAnalysisId: plate.skinAnalysisId),
        Text('분석 요약', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        PlateSummaryCard(good: plate.good, caution: plate.caution),

        const SizedBox(height: 12),
        // 저장 전에는 룰 요약(summary)뿐이지만, 저장되면 서버가 AI 문장을 만들어
        // 붙인다. 여기서 안 읽으면 같은 기록이 이 화면에서는 룰 요약, 상세
        // 화면에서는 AI 문장으로 갈린다 — 상세(plate_detail_page)와 같은 우선순위다.
        if (_tipOf(plate).isNotEmpty) PlateTipCard(tip: _tipOf(plate)),

        if (FeatureFlags.actionSimulation && plate.actions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('추천 행동', style: Theme.of(context).textTheme.titleMedium),
          for (final action in plate.actions)
            _ActionCard(
              action: action,
              applied: applied.contains(PlateActionCode.forRuleCode(action.ruleCode)),
              onToggle: onToggle,
            ),
        ],

        const SizedBox(height: 26),
        Text.rich(
          TextSpan(
            text: '주요 영양 성분 ',
            style: Theme.of(context).textTheme.titleMedium,
            children: const [
              TextSpan(
                text: '(1인분 기준)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NutrientTiles(
          caloriesKcal: plate.food.nutrition.caloriesKcal,
          sodiumMg: plate.food.nutrition.sodiumMg.toDouble(),
          sugarG: plate.food.nutrition.sugarG.toDouble(),
          fatG: plate.food.nutrition.fatG.toDouble(),
        ),

        // S08 진입점. 시뮬레이션과 달리 이 화면의 피부 분석 id 가 필요해서
        // 진입점이 여기다. "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때
        // 엉뚱한 추천이 뜬다.
        if (FeatureFlags.recommendationScreen) ...[
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => context
                .push('${Routes.recommendations}/${plate.skinAnalysisId}'),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('오늘의 추천 음식 보기'),
          ),
        ],

        const SafetyNotice(),
      ],
    );
  }

  /// AI 문장은 저장된 기록에만 있다(서버가 저장 때 만든다). PlateView 에
  /// aiTip 을 올리지 않는 건 의도라([PlateView] 주석), 여기서만 내려본다.
  static String _tipOf(PlateView plate) =>
      plate is SkinPlate ? plate.aiTip ?? plate.summary : plate.summary;
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
      // 저장으로 이 화면의 일은 끝났다. 다음에 갈 곳을 주지 않으면 사용자가
      // 뒤로가기 말고는 나갈 방법이 없고, 방금 만든 기록도 보러 갈 수 없다.
      //
      // 둘 다 go 다 — 흐름이 끝났으니 촬영·결과를 스택에 남길 이유가 없다.
      // **mainAxisSize 를 반드시 min 으로 둔다.** bottomNavigationBar 슬롯은
      // 높이가 loose(0~화면높이) 로 내려온다. Column 기본값인 max 로 두면 하단
      // 바가 화면 전체(852)를 차지하고, Scaffold 는 body 를 높이 0 으로 밀어낸다 —
      // 본문이 통째로 사라지고 이 영역이 AppBar·상태바 위에 겹쳐 그려진다.
      // 저장 전에는 자식이 버튼 하나(고유 높이)라 드러나지 않고, saved·saveFailed
      // 로 바뀌는 순간에만 터진다. 실기기(iPhone 14 Pro)에서 렌더 트리로 확인했다.
      PlateRecordStatus.saved => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.good),
                const SizedBox(width: 8),
                Text('오늘의 기록에 저장됐어요',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('홈으로'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.go(Routes.plateHistory),
              child: const Text('기록 보러 가기'),
            ),
          ],
        ),

      // 진행 중에는 눌리지 않는다. onPressed: null 이 곧 중복 클릭 차단이다.
      PlateRecordStatus.saving => const ElevatedButton(
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

      _ => ElevatedButton(
          onPressed: onSave,
          child: const Text('기록에 저장하기'),
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
    // 저장 완료 분기와 같은 이유로 min 이다 — 하단 바가 화면을 다 먹으면 안 된다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          failure?.message ?? '기록을 저장하지 못했습니다.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.bad),
        ),
        const SizedBox(height: 12),
        // 재시도할 수 없는 실패는 전부 재촬영으로 보낸다. 400·404 처럼 어느 쪽도
        // 아닌 코드에서 버튼을 아예 안 그리면 저장 버튼까지 사라진 화면에
        // 오류 문구만 남아 사용자가 나갈 곳이 없다.
        if (onRetry != null)
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도'))
        else
          ElevatedButton(onPressed: onRetake, child: const Text('다시 촬영하기')),
      ],
    );
  }
}

/// 행동 제안 카드. [FeatureFlags.actionSimulation] 이 꺼져 있는 동안 화면에
/// 나오지 않지만, 룰 엔진 계약(PlateActionCode)과 짝이라 지우지 않는다.
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
            Text('실행하면 약 +${action.expectedGain}점',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (code == null)
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
