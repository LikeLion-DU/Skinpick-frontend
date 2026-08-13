import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/recommendation_provider.dart';

/// S08 — AI 추천.
///
/// 후보 음식은 서버가 코드 테이블에서 고르고 이유 문장만 AI 가 쓴다.
/// 그래서 데모마다 같은 음식이 나오고, AI 문장 생성이 실패해도 화면이 비지 않는다.
/// (PRD §18.9)
class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(recommendationProvider(skinAnalysisId));

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 추천')),
      body: recommendation.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (result) => result.when(
          failure: (failure) => FailureView(
            failure: failure,
            onRetry: () => ref.invalidate(recommendationProvider(skinAnalysisId)),
          ),
          success: (daily) => daily.isEmpty
              ? const Center(child: Text('아직 추천이 준비되지 않았어요.'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _FoodSection(
                      title: '오늘 추천하는 음식',
                      icon: Icons.thumb_up,
                      color: Colors.green,
                      foods: daily.recommend,
                    ),
                    _FoodSection(
                      title: '오늘 주의할 음식',
                      icon: Icons.thumb_down,
                      color: Colors.red,
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
    required this.icon,
    required this.color,
    required this.foods,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RecommendedFood> foods;

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final food in foods)
            Card(
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(food.foodName),
                subtitle: food.reason.isEmpty ? null : Text(food.reason),
              ),
            ),
        ],
      ),
    );
  }
}
