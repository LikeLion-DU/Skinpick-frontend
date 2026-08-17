import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_basis.dart';
import '../../domain/entities/skin_plate.dart';

/// "오늘 피부 상태 기준" · "최근 피부 상태 기준 · 8/15" 한 줄.
///
/// **화면에서 채점 기준을 말하는 문구는 이것 하나다.** 자가신고 피부 타입을
/// 기준으로 쓰지 않는다 — 음식 판정은 실제 측정 지표(수분·유분·홍조…)로 하는데
/// "잘 모르겠어요 피부 기준" 같은 문구가 붙으면 화면이 채점 근거를 잘못 말한다.
///
/// [SkinBasisCard]("내 피부 상태" 지표 카드)와 헷갈리지 마라. 저쪽은 **무엇을**
/// 기준 삼았는지(수분 38, 홍조 64…), 이쪽은 **언제 잰 것**을 기준 삼았는지다.
///
/// 판정은 서버 [SkinBasis] 를 그대로 쓴다. `skinMeasuredAt` 과 오늘을 앱에서
/// 비교해 다시 정하면 서버(KST)와 기기 시간대가 자정 근처에서 갈린다.
///
/// [SkinBasis.recent] 는 "오늘 잰 피부로 분석된 것이 아니다" 를 사용자가
/// 알아채야 하는 상태다. 다만 정상 동작이라 경고색을 쓰지 않는다.
class SkinBasisLine extends StatelessWidget {
  const SkinBasisLine({
    super.key,
    required this.basis,
    required this.measuredAt,
    this.pastRecord = false,
  });

  final SkinBasis? basis;
  final DateTime? measuredAt;

  /// 저장된 기록을 **나중에** 여는 화면인가.
  ///
  /// 서버는 기록을 저장한 날로 기준을 굳혀 주므로, 8/15 기록을 8/17 에 열어도
  /// [SkinBasis.today] 가 온다. 그걸 "오늘 피부 기준"이라고 쓰면 거짓말이다.
  final bool pastRecord;

  @override
  Widget build(BuildContext context) {
    final text = switch (basis) {
      SkinBasis.today => pastRecord ? '기록 당일 피부 상태 기준' : '오늘 피부 상태 기준',
      SkinBasis.recent when measuredAt != null =>
        '최근 피부 상태 기준 · ${measuredAt!.month}/${measuredAt!.day}',
      SkinBasis.recent => '최근 피부 상태 기준',
      // 옛 기록에는 필드가 없다. 지어내지 않고 자리째 비운다.
      null => null,
    };

    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 매운 정도 · 기름기 칩.
///
/// 값이 없는 항목은 칩을 안 그리고, 둘 다 없으면 영역째 사라진다 — 빈 칩보다
/// 없는 편이 낫다. 서버 프롬프트가 "확실하지 않으면 UNKNOWN" 을 강제하고
/// 안 매움·담백도 안 그리므로(모순 방지, [Spiciness.label] 참고) 실제로 자주 빈다.
///
/// **예상 섭취량(portionSize)은 여기 없다.** 서버는 저장·리포트 환산에 계속 쓰지만
/// 화면에는 내지 않는다 — 척도를 정의한 기준이 없는 AI 관찰값이라, 칩으로 얹으면
/// 사용자가 자기 식사량의 근거로 읽는다.
class FoodTraitChips extends StatelessWidget {
  const FoodTraitChips({super.key, required this.food});

  final FoodAnalysis food;

  @override
  Widget build(BuildContext context) {
    final traits = <(String, String)>[
      if (food.spiciness.label case final value?) ('매운 정도', value),
      if (food.oiliness.label case final value?) ('기름기', value),
    ];

    if (traits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final (name, value) in traits)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.borderOnCream),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$name · $value',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textOnCard,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
            for (final item in good) _item(item),
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
            for (final item in caution) _item(item),
          ],
          // 둘 다 비면 카드가 빈 껍데기로 남는다. 룰이 하나도 안 걸린 평범한
          // 식사가 실제로 있다 — 그때도 침묵보다는 한 줄이 낫다.
          if (good.isEmpty && caution.isEmpty)
            _line('특별히 걸리는 항목 없이 무난한 식사예요.'),
        ],
      ),
    );
  }

  /// 제목 한 줄 + 설명 한 줄. 설명(reason)은 V8 이전 기록에 없으므로 그때는
  /// 제목만 그린다 — 빈 줄을 남기면 카드에 구멍이 생긴다.
  Widget _item(PlateFeedback feedback) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(feedback.message, weight: FontWeight.w600),
            if (feedback.reason case final reason?
                when reason.isNotEmpty)
              _line(reason, color: AppColors.textSecondary),
          ],
        ),
      );

  Widget _line(
    String message, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textOnCard,
  }) =>
      Text(
        message,
        style: TextStyle(
          fontSize: 10,
          fontWeight: weight,
          color: color,
          height: 1.5,
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
