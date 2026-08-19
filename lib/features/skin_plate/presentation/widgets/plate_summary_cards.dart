import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/pill.dart';

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

/// AI 가 사진에서 읽은 음식 특성 칩 — 매운 정도 · 기름기 · 예상 섭취량.
///
/// 값이 없는 항목은 칩을 안 그리고, 셋 다 없으면 영역째 사라진다 — 빈 칩보다
/// 없는 편이 낫다. 서버 프롬프트가 "확실하지 않으면 UNKNOWN" 을 강제하고
/// 안 매움·담백도 안 그리므로(모순 방지, [Spiciness.label] 참고) 실제로 자주 빈다.
///
/// **제목이 "이 음식의 특징"이다.** 시안은 이 줄 위에 "오늘의 피부 기준"이라고
/// 적었는데, 칩 내용은 전부 음식 쪽 관찰값이라 그 제목이 가리키는 것과 다르다.
/// 언제 잰 피부를 기준 삼았는지는 [SkinBasisLine] 이 따로 말한다.
class FoodTraitChips extends StatelessWidget {
  const FoodTraitChips({super.key, required this.food});

  final FoodAnalysis food;

  @override
  Widget build(BuildContext context) {
    final traits = <(String, String)>[
      if (food.spiciness.label case final value?) ('매운 정도', value),
      if (food.oiliness.label case final value?) ('기름기', value),
      if (food.portionSize.label case final value?) ('예상 섭취량', value),
    ];

    if (traits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 음식의 특징',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (name, value) in traits)
                Pill(
                  // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
                  // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
                  minHeight: 25,
                  horizontalPadding: 10,
                  borderRadius: 4,
                  color: const Color(0xFFFEF6EE),
                  border: Border.all(color: const Color(0xFFFFD6C2)),
                  label: '$name : $value',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "분석 요약" — GOOD / BAD 두 카드를 나란히.
///
/// 서버 피드백(good·caution)을 문장으로 늘어놓는다. 시안은 GOOD 한 단락,
/// BAD 한 단락이지만 서버는 항목 단위로 주므로 항목마다 한 줄씩 쓴다.
/// 점수 델타는 여기 쓰지 않는다 — 시안이 숫자를 지웠고, "왜 이 점수인가"는
/// 점수 줄이 이미 말하고 있다.
///
/// 확정 시안이 한 장을 **두 장으로 갈랐다**. 위아래로 쌓으면 GOOD 을 읽고 나서
/// BAD 를 만나기까지 스크롤이 끼는데, 이 화면의 요점은 둘을 한눈에 견주는 것이다.
///
/// 한쪽이 비어도 카드를 남긴다 — 두 칸이 한 칸으로 줄면 "분석이 덜 됐다"로 읽힌다.
class PlateSummaryCard extends StatelessWidget {
  const PlateSummaryCard({
    super.key,
    required this.good,
    required this.caution,
    required this.summary,
  });

  final List<PlateFeedback> good;
  final List<PlateFeedback> caution;

  /// 그릴 것이 있는가. 제목("분석 요약")을 함께 접기 위해 호출부가 먼저 묻는다 —
  /// 카드만 접으면 제목이 홀로 남는다.
  static bool hasContent({
    required List<PlateFeedback> good,
    required List<PlateFeedback> caution,
    required String summary,
  }) =>
      good.isNotEmpty || caution.isNotEmpty || summary.isNotEmpty;

  /// 룰이 하나도 안 걸린 한 끼에 **서버가 붙여 주는 한 줄**.
  /// 앱이 같은 뜻의 문장을 따로 쓰지 않는다 — 룰 엔진이 그 문장의 주인이다.
  final String summary;

  @override
  Widget build(BuildContext context) {
    // 룰이 하나도 안 걸렸는데 서버 문장까지 없으면 그릴 것이 없다. 테두리만 남은
    // 빈 상자는 앱이 지어낸 문장보다 더 고장처럼 보인다.
    if (good.isEmpty && caution.isEmpty && summary.isEmpty) {
      return const SizedBox.shrink();
    }

    // 둘 다 비면 룰이 하나도 안 걸린 평범한 식사다. 실제로 있다 —
    // 그때 빈 카드 두 장을 그리면 고장으로 읽히므로 한 줄로 대신한다.
    if (good.isEmpty && caution.isEmpty) {

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.disabled),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Text(
          summary,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnCard,
            height: 1.5,
          ),
        ),
      );
    }

    // 두 카드의 높이를 맞춘다. 글자 수가 달라 한쪽이 짧으면 나란한 두 칸이
    // 어긋난 계단처럼 보인다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _VerdictColumn(
              title: 'GOOD',
              titleColor: AppColors.good,
              background: const Color(0xFFF7F9F3),
              items: good,
              emptyMessage: '이 끼니에서 특별히 좋았던 항목은 없어요.',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _VerdictColumn(
              title: 'BAD',
              titleColor: AppColors.bad,
              background: const Color(0xFFFFEDED),
              items: caution,
              emptyMessage: '걸리는 항목이 없어요.',
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictColumn extends StatelessWidget {
  const _VerdictColumn({
    required this.title,
    required this.titleColor,
    required this.background,
    required this.items,
    required this.emptyMessage,
  });

  final String title;
  final Color titleColor;
  final Color background;
  final List<PlateFeedback> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: AppColors.disabled),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.1,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            _line(emptyMessage, color: AppColors.textSecondary)
          else
            for (final item in items) _item(item),
        ],
      ),
    );
  }

  /// 제목 한 줄 + 설명 한 줄. 설명(reason)은 V8 이전 기록에 없으므로 그때는
  /// 제목만 그린다 — 빈 줄을 남기면 카드에 구멍이 생긴다.
  Widget _item(PlateFeedback feedback) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(feedback.message, weight: FontWeight.w600),
            if (feedback.reason case final reason? when reason.isNotEmpty)
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

/// "AI 맞춤 TIP" 카드. 기록 화면의 AI 코멘트와 같은 그라디언트다 —
/// 둘 다 서버가 저장할 때 만들어 둔 문장이라 같은 껍데기를 쓴다.
class PlateTipCard extends StatelessWidget {
  const PlateTipCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFEF7F0), Color(0xFFFFF2E4)],
        ),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/ai_sparkle.svg',
                  width: 17, height: 17),
              const SizedBox(width: 5),
              const Text('AI 맞춤 TIP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentStrong,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Color(0xFF411B09),
              // 시안 행간 1.9. 좁게 두면 두 줄이 한 덩이로 뭉쳐 읽힌다.
              height: 1.9,
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
    // 순서는 시안 그대로다 — 칼로리 · 지방 · 당류 · 나트륨.
    final tiles = [
      (Icons.monitor_heart_outlined, '칼로리', '${_comma(caloriesKcal)} kcal'),
      (Icons.cloud_outlined, '지방', '${_comma(fatG)} g'),
      (Icons.icecream_outlined, '당류', '${_comma(sugarG)} g'),
      (Icons.grain, '나트륨', '${_comma(sodiumMg)} mg'),
    ];

    // 네 칸의 높이를 서로 맞춘다. 최소 높이만 두면 한 칸의 값이 두 줄로 접히는
    // 순간(2.0 배율의 "1,280 mg") 그 칸만 커지고 나머지 셋이 가운데 떠서 테두리
    // 네 개가 어긋난다. 같은 파일의 GOOD/BAD 카드가 쓰는 방식이다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(width: 16),
          Expanded(
            child: Container(
              // 네 칸을 나눠 쓰는 70px 짜리 칸이다. 높이를 92 로 박아 두면 글자
              // 크기를 키운 기기에서 "1,280 mg" 이 두 줄로 접히며 62px 넘친다.
              //
              // 세로 여백은 6 이다. 10 을 주면 기본 글자 크기에서 칸이 100 이 되어
              // 시안 높이(92)를 넘긴다 — 최소 높이를 92 로 지키려면 이 값이어야 한다.
              constraints: const BoxConstraints(minHeight: 92),
              padding: const EdgeInsets.symmetric(vertical: 6),
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
                        fontSize: 11,
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
      ),
    );
  }
}
