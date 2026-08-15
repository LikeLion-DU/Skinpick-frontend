import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/skin_plate.dart';

/// "분석 요약" — GOOD / BAD 카드.
///
/// 서버 피드백(good·caution)을 문장으로 늘어놓는다. 시안은 GOOD 한 단락,
/// BAD 한 단락이지만 서버는 항목 단위로 주므로 항목마다 한 줄씩 쓴다.
/// 점수 델타는 여기 쓰지 않는다 — 시안이 숫자를 지웠고, "왜 이 점수인가"는
/// 점수 카드가 이미 말하고 있다.
class PlateSummaryCard extends StatelessWidget {
  const PlateSummaryCard({
    super.key,
    required this.good,
    required this.caution,
  });

  final List<PlateFeedback> good;
  final List<PlateFeedback> caution;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.disabled),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (good.isNotEmpty) ...[
            const Text('GOOD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.good,
                )),
            const SizedBox(height: 4),
            for (final item in good) _line(item.message),
          ],
          if (good.isNotEmpty && caution.isNotEmpty) const SizedBox(height: 14),
          if (caution.isNotEmpty) ...[
            const Text('BAD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bad,
                )),
            const SizedBox(height: 4),
            for (final item in caution) _line(item.message),
          ],
          // 둘 다 비면 카드가 빈 껍데기로 남는다. 룰이 하나도 안 걸린 평범한
          // 식사가 실제로 있다 — 그때도 침묵보다는 한 줄이 낫다.
          if (good.isEmpty && caution.isEmpty)
            _line('특별히 걸리는 항목 없이 무난한 식사예요.'),
        ],
      ),
    );
  }

  Widget _line(String message) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnCard,
            height: 1.5,
          ),
        ),
      );
}

/// "AI 맞춤 TIP" 크림 카드.
class PlateTipCard extends StatelessWidget {
  const PlateTipCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI 맞춤 TIP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF272727),
              )),
          const SizedBox(height: 8),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnCard,
              height: 1.47,
            ),
          ),
        ],
      ),
    );
  }
}

/// "주요 영양 성분 (1인분 기준)" — 타일 4개.
class NutrientTiles extends StatelessWidget {
  const NutrientTiles({
    super.key,
    required this.caloriesKcal,
    required this.sodiumMg,
    required this.sugarG,
    required this.fatG,
  });

  final int caloriesKcal;
  final double sodiumMg;
  final double sugarG;
  final double fatG;

  /// 1,280 처럼 천 단위 쉼표. intl 을 들이지 않고 이 한 곳에서 해결한다.
  static String _comma(num value) {
    final text = value.round().toString();
    return text.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (Icons.local_fire_department_outlined, '칼로리', '${_comma(caloriesKcal)} kcal'),
      (Icons.water_drop_outlined, '나트륨', '${_comma(sodiumMg)} mg'),
      (Icons.icecream_outlined, '당류', '${_comma(sugarG)} g'),
      (Icons.opacity_outlined, '지방', '${_comma(fatG)} g'),
    ];

    return Row(
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.disabled),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tile.$1, size: 26, color: AppColors.textOnCard),
                  const SizedBox(height: 6),
                  Text(tile.$2,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textOnCard,
                      )),
                  const SizedBox(height: 2),
                  Text(tile.$3,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textOnCard,
                      )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
