import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/recommendation_provider.dart';

/// S08 — AI 추천.
///
/// 후보 음식은 서버가 코드 테이블에서 고르고 이유 문장만 AI 가 쓴다.
/// 그래서 데모마다 같은 음식이 나오고, AI 문장 생성이 실패해도 화면이 비지 않는다.
/// (PRD §18.9)
///
/// **확정 시안에 이 화면이 없다.** `FeatureFlags.recommendationScreen` 으로 진입점이
/// 꺼져 있어 지금은 화면에 나오지 않지만, 켜는 순간 앱에서 유일하게 Material 기본
/// `Card`+`ListTile` 과 `Colors.green`/`Colors.red` 를 쓰는 화면이 튀어나온다.
/// 배치를 지어내지 않고 **음식 결과(S07)의 GOOD/BAD 규약을 그대로 가져온다** —
/// 추천도 "이건 좋고 저건 주의" 를 말하는 화면이라 같은 어휘가 맞다.
class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(recommendationProvider(skinAnalysisId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '오늘의 추천',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.accentStrong,
          ),
        ),
      ),
      body: recommendation.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error', textAlign: TextAlign.center),
          ),
        ),
        data: (result) => result.when(
          failure: (failure) => FailureView(
            failure: failure,
            onRetry: () =>
                ref.invalidate(recommendationProvider(skinAnalysisId)),
          ),
          success: (daily) => daily.isEmpty
              ? const Center(child: Text('아직 추천이 준비되지 않았어요.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
                  children: [
                    _FoodSection(
                      title: '오늘 추천하는 음식',
                      verdict: 'GOOD',
                      accent: AppColors.good,
                      background: const Color(0xFFF7F9F3),
                      foods: daily.recommend,
                    ),
                    _FoodSection(
                      title: '오늘 주의할 음식',
                      verdict: 'BAD',
                      accent: AppColors.bad,
                      background: const Color(0xFFFFEDED),
                      foods: daily.avoid,
                    ),
                    const SafetyNotice(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  const _FoodSection({
    required this.title,
    required this.verdict,
    required this.accent,
    required this.background,
    required this.foods,
  });

  final String title;

  /// GOOD / BAD. 음식 결과 화면과 같은 두 낱말이다 — 추천에서만 다른 말을 쓰면
  /// 사용자가 두 화면을 다른 축으로 읽는다.
  final String verdict;

  final Color accent;
  final Color background;
  final List<RecommendedFood> foods;

  @override
  Widget build(BuildContext context) {
    // 한쪽이 비는 경우가 있다 — 서버가 후보를 못 고른 지표 조합이다.
    // 빈 제목만 남기면 "불러오다 만 화면"으로 읽히므로 구역째 접는다.
    if (foods.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LeafMark(),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bodyInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final food in foods)
            Padding(
              padding: EdgeInsets.only(bottom: food == foods.last ? 0 : 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: background,
                  border: Border.all(color: AppColors.disabled),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.foodName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyInk,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          // `VerdictBadge` 와 같은 규칙이다 — 시안 값(53×19)은
                          // 최소 크기로만 쓴다. 고정하면 글자 크기를 키운 기기에서
                          // 알약이 'GOO' 로 잘리는데 예외가 안 나서 안 잡힌다.
                          constraints:
                              const BoxConstraints(minWidth: 53, minHeight: 19),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12.5),
                          ),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              verdict,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 이유는 AI 가 쓴 문장이다. 앱이 고치거나 잘라 붙이지 않는다.
                    // 생성이 실패하면 빈 문자열로 오므로 그때는 줄을 만들지 않는다.
                    if (food.reason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        food.reason,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: AppColors.textOnCard,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
