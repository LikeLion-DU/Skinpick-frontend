import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/highlight_row.dart';

/// 음식 결과 화면의 "내 피부 상태" 카드 — **이 점수가 왜 이 점수인가**의 왼쪽 항.
///
///     내 피부  ×  음식 특성  →  피부 식단 점수
///
/// 오른쪽 항(음식에서 주의할 점)은 바로 아래 `분석 요약` 이 맡는다. 둘을 나란히
/// 놓아야 사용자가 62점을 자기 피부와 연결해서 읽는다.
///
/// 서버가 만든 `highlights` 를 그대로 옮긴다. 지표 숫자를 받아서 앱이
/// "트러블 높음" 같은 판정을 새로 만들지 않는다 — 그러면 임계값이 서버와 앱에
/// 두 벌 생기고, 어느 날 조용히 어긋난다.
///
/// **불러오는 중이거나 실패하면 아무것도 그리지 않는다.** 점수·요약·영양은 이미
/// 화면에 있고, 근거 한 겹이 빠졌다고 결과 화면에 오류 상자를 띄울 이유는 없다.
class SkinBasisCard extends ConsumerWidget {
  const SkinBasisCard({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // valueOrNull 이다. `.value` 는 에러 상태에서 예외를 되던져 결과 화면을 통째로
    // 날린다 — 점수도 요약도 멀쩡한데 근거 조회 하나 때문에.
    final analysis = ref
        .watch(skinAnalysisByIdProvider(skinAnalysisId))
        .valueOrNull
        ?.dataOrNull;

    if (analysis == null || analysis.highlights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 피부 상태', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.borderOnCream),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final highlight in analysis.highlights)
                HighlightRow(highlight: highlight),
            ],
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
