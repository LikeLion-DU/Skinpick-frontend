import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_plate.dart';
import '../widgets/plate_score_card.dart';
import '../widgets/plate_summary_cards.dart';
import '../widgets/skin_basis_card.dart';

/// 저장된 기록 하나. `GET /plates/{id}`.
///
/// 분석 직후 화면(S07)과 같은 카드들을 그리지만 저장 버튼이 없다 —
/// 이미 기록이니까. 화면을 공유하지 않고 따로 두는 이유는 상태다.
/// S07 은 저장 생명주기(saving·saveFailed…)를 쥔 Notifier 위에 서 있고,
/// 여기는 id 로 읽어 오면 끝이다. 섞으면 S07 의 상태 기계가 흐려진다.
final plateDetailProvider = FutureProvider.autoDispose
    .family<Result<SkinPlate>, int>(
        (ref, plateId) => ref.watch(plateRepositoryProvider).getById(plateId));

class PlateDetailPage extends ConsumerWidget {
  const PlateDetailPage({super.key, required this.plateId});

  final int plateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(plateDetailProvider(plateId));

    return Scaffold(
      appBar: AppBar(title: const Text('분석 결과')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('불러오지 못했습니다: $error')),
        data: (result) => result.when(
          failure: (failure) => FailureView(
            failure: failure,
            onRetry: () => ref.invalidate(plateDetailProvider(plateId)),
          ),
          success: (plate) => _Body(plate: plate),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.plate});

  final SkinPlate plate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final declaredType = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
      children: [
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
          score: plate.plateScore,
          basisLabel:
              declaredType == null ? null : '${declaredType.label} 피부 기준',
        ),
        const SizedBox(height: 26),
        // 저장된 기록도 같은 근거를 보여준다. 그때 채점에 쓰인 분석 id 로 읽으므로
        // 그 뒤에 피부를 다시 분석했어도 이 기록의 기준은 바뀌지 않는다.
        SkinBasisCard(skinAnalysisId: plate.skinAnalysisId),
        Text('분석 요약', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        PlateSummaryCard(good: plate.good, caution: plate.caution),
        const SizedBox(height: 12),
        // AI 문장이 있으면 그걸, 없으면(생성 실패) 룰 요약으로 대신한다.
        if ((plate.aiTip ?? plate.summary).isNotEmpty)
          PlateTipCard(tip: plate.aiTip ?? plate.summary),
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
        const SafetyNotice(),
      ],
    );
  }
}
