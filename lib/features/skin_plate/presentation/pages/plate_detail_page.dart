import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../../../core/widgets/app_widgets.dart';
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

/// 자가신고 피부 타입을 채점 기준 문구로 쓰지 않는다 — 결과 화면과 같은 이유고,
/// 그래서 여기도 [ConsumerWidget] 이 아니다.
class _Body extends StatelessWidget {
  const _Body({required this.plate});

  final SkinPlate plate;

  @override
  Widget build(BuildContext context) {
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

        // **pastRecord 다.** 서버는 저장한 날로 기준을 굳혀 주므로 8/15 기록을
        // 8/17 에 열어도 TODAY 가 온다 — 여기서 "오늘 피부 상태 기준"이라고 쓰면 거짓말이다.
        SkinBasisLine(
          basis: plate.skinBasis,
          measuredAt: plate.skinMeasuredAt,
          pastRecord: true,
        ),
        FoodTraitChips(food: plate.food),
        const SizedBox(height: 18),
        PlateScoreCard(score: plate.plateScore),
        const SizedBox(height: 26),
        // 저장된 기록도 같은 근거를 보여준다. 그때 채점에 쓰인 분석 id 로 읽으므로
        // 그 뒤에 피부를 다시 분석했어도 이 기록의 기준은 바뀌지 않는다.
        SkinBasisCard(skinAnalysisId: plate.skinAnalysisId),
        Text('분석 요약', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        PlateSummaryCard(good: plate.good, caution: plate.caution),
        // 생성이 실패한 기록은 서버가 이 키를 뺀다. 룰 요약으로 메우지 않는다 —
        // 결과 화면과 같은 규칙이다. "AI 맞춤 TIP" 은 AI 문장일 때만 뜬다.
        if (plate.aiTip case final aiTip? when aiTip.isNotEmpty) ...[
          const SizedBox(height: 12),
          PlateTipCard(tip: aiTip),
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
        const SafetyNotice(),
      ],
    );
  }
}
