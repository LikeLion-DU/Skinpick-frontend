/// 일일·주간이 같이 쓰는 조각들.
///
/// 두 화면이 그리는 것은 대부분 같다 — 점수 카드, 영양, 고민, AI 문장, 끼니 줄.
/// 각자 그리면 한쪽만 고쳐지고, 같은 뜻의 카드가 탭을 넘길 때마다 달라 보인다.
///
/// 확정 시안이 리포트를 **흰 카드 여러 장**으로 재구성했다. 옛 시안은 제목 +
/// 내용이 배경 위에 바로 놓이는 구조였는데, 리포트는 구역이 여섯 개라 그렇게
/// 두면 어디서 어디까지가 한 덩이인지 읽히지 않는다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/score_gauge.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../../../shared/widgets/verdict_badge.dart';
import '../../../skin_plate/data/datasources/plate_image_store.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';
import '../../domain/entities/report.dart';

/// 시안의 흰 카드. 세로 막대 마크 + 제목 + (선택) 단서 한 줄.
///
/// 마크가 잎사귀가 아니라 막대인 것은 시안 그대로다 — 리포트는 표가 많아
/// 둥근 마크가 숫자 사이에서 얼룩처럼 보인다.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    this.note,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 20),
    required this.child,
  });

  final String title;

  /// 제목 아래 작은 단서. "기록한 날의 하루 평균" 같은 것 —
  /// 이 한 줄이 없으면 사용자가 주간 영양을 주간 **합계**로 읽는다.
  final String? note;

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.disabled, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BarMark(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(
              note!,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// `‹ 2026년 8월 16일 (일) ›`. 일일은 하루, 주간은 한 주를 넘긴다.
///
/// 두 탭이 같은 자리·같은 크기를 쓰게 한다 — 탭을 넘길 때 이 줄이 움직이면
/// 화면이 통째로 다시 그려지는 것처럼 보인다.
class ReportDateNav extends StatelessWidget {
  const ReportDateNav({
    super.key,
    required this.label,
    required this.canGoBack,
    required this.canGoForward,
    required this.onShift,
    this.backTooltip = '이전',
    this.forwardTooltip = '다음',
  });

  final String label;
  final bool canGoBack;
  final bool canGoForward;

  /// +1 이면 다음, -1 이면 이전.
  final ValueChanged<int> onShift;

  final String backTooltip;
  final String forwardTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canGoBack ? () => onShift(-1) : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          color: AppColors.textPrimary,
          tooltip: backTooltip,
        ),
        // 폭을 고정한다. 날짜 문자열 길이에 따라 화살표가 좌우로 움직이면
        // 연달아 누를 때 손가락이 빗나간다.
        SizedBox(
          width: 150,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          // 미래는 잠근다. 열어 두면 빈 리포트가 뜨는데, 그건
          // "기록이 없다"와 구분되지 않는다.
          onPressed: canGoForward ? () => onShift(1) : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          color: AppColors.textPrimary,
          tooltip: forwardTooltip,
        ),
      ],
    );
  }
}

/// 화면 맨 위의 종합 점수 카드. 원형 게이지 + 등급 한 줄 + 기록 수.
///
/// 점수가 없으면 `OO점` 이다 — **0 점을 그리지 않는다.** 0 은 "아주 나쁘게 먹었다"고
/// 이건 "아직 안 찍었다"라서, 같은 자리에 같은 숫자로 쓰면 안 된다.
///
/// 시안은 게이지 옆에 두 문장("오늘은 전반적으로 …" + "균형 잡힌 식단이 …")을
/// 두는데, 서버에 그런 필드가 없다. 등급에 붙는 고정 문구는 이미 하나
/// ([SkinLevel.summary]) 있으므로 그것만 쓰고 두 번째 문장은 만들지 않는다 —
/// 등급마다 문장을 하나 더 지어내면 그게 곧 앱이 쓴 카피다.
class ReportScoreCard extends StatelessWidget {
  const ReportScoreCard({
    super.key,
    required this.score,
    required this.grade,
    this.footnote,
  });

  final int? score;
  final SkinLevel? grade;

  /// 점수 아래 작은 줄. "오늘 3개 기록했어요" · "7일 중 5일 기록" 같은 것.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final grade = this.grade;
    final score = this.score;
    final accent = grade?.accentColor ?? AppColors.outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 19, 18, 19),
      decoration: BoxDecoration(
        // 등급 색을 아주 옅게 깐다. 시안의 초록 카드(#F7F9F3)가 "좋음"일 때의
        // 모습이고, 주의인 날에 그 초록을 그대로 두면 카드가 점수를 부정한다.
        color: Color.lerp(accent, Colors.white, 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.borderOnCream, blurRadius: 3),
        ],
      ),
      child: Row(
        children: [
          if (grade == null || score == null)
            _EmptyRing(score: score)
          else
            ScoreGauge(
              score: score,
              grade: grade,
              size: 108,
              trackColor: Color.lerp(accent, Colors.white, 0.82)!,
              // 링 지름(108)은 고정 그래픽이다. 글자 크기 2.0 을 그대로 따르면
              // "60점"이 링을 49px 넘겨 나간다. 배율은 1.3 까지만 따라가고,
              // 그래도 안 들어가면(세 자리 점수) 링 안에서 줄인다 — 1.3 은 두 자리
              // 기준으로 고른 값이라 100 점에서 36px 넘쳤다.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _RingLabel(score: '$score', grade: grade),
                ),
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 등급에 붙는 고정 문구다. AI 가 쓴 문장은 아래 AI 카드에 따로
                // 있다 — 두 자리를 섞으면 "AI 가 점수를 매겼다"로 읽힌다.
                //
                // **점수가 있는데 등급만 없으면 아무 말도 하지 않는다.** "기록이
                // 없다"는 거짓이고, 빈 문자열을 넘기면 20px 짜리 빈 줄이 남는다.
                if (grade != null || score == null)
                  Text(
                    grade?.summary ?? '아직 채점할 기록이 없어요',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                if (footnote != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    footnote!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      height: 1.4,
                      color: AppColors.bodyInk,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingLabel extends StatelessWidget {
  const _RingLabel({required this.score, required this.grade});

  final String score;
  final SkinLevel grade;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                height: 1,
                color: grade.accentColor,
              ),
            ),
            const Text(
              '점',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
                color: AppColors.bodyInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 시안은 여기에 `GOOD` 을 적는데, 그러면 5단 등급이 좋음/그 외 두 단으로
        // 접힌다. 앱은 이미 3단 어휘(좋음·보통·주의)를 홈·기록에서 쓰고 있으므로
        // 그것을 그대로 쓴다 — 같은 68점이 화면마다 다른 말로 불리지 않는다.
        Text(
          grade.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: grade.accentColor,
          ),
        ),
      ],
    );
  }
}

/// 기록이 없는 날의 게이지 자리. 호를 그리지 않고 `OO점` 만 남긴다 —
/// 4% 짜리 호라도 그리면 "아주 낮은 점수"로 읽힌다.
class _EmptyRing extends StatelessWidget {
  const _EmptyRing({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderEmptySlot, width: 8),
      ),
      // 링 지름이 고정이라 글자가 안쪽(92px)을 넘으면 줄인다. 글자 크기 2.0 에서
      // 'OO' 가 120px 이 되어 링을 57px 터뜨렸다 — 점수가 있는 링과 같은 방식으로
      // 막는다(둘 다 안에서만 줄인다).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score?.toString() ?? 'OO',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.outline,
            ),
          ),
          const Text(
            '점',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.outline,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// 영양 항목의 색. 서버가 준 위치와 방향만 본다 — 앱이 임계값을 세우지 않는다.
///
/// 상태를 모르면 색을 입히지 않는다. 모르는 값을 초록으로 칠하면 서버가
/// 새 상태를 보낸 날 경고가 조용히 "정상"이 된다.
Color _nutritionColor(NutritionItem item) => switch (item) {
      // 위치나 방향 하나만 있어도 색을 입히지 않는다 — 방향 없이 칠하면
      // 나트륨 463% 가 초록이 된다.
      _ when !item.isKnown => AppColors.outline,
      _ when item.isWarning => AppColors.accentStrong,
      _ => AppColors.good,
    };

String _nutritionLabel(NutritionItem item) =>
    item.isKnown
        ? item.status!.label(higherIsWorse: item.higherIsWorse!)
        : '알 수 없음';

/// 일일 리포트의 영양 타일. 3열 격자다.
///
/// **항목 목록을 앱이 갖지 않는다.** 서버가 보낸 순서와 개수를 그대로 그리므로,
/// 서버가 항목을 늘려도 이 위젯은 손댈 필요가 없다.
///
/// 절대량(`1,560 / 2,000kcal`)은 타일에 넣지 않는다 — 3열 격자의 한 칸이 85px
/// 라 8px 글자가 되어야 들어간다. 시안이 일일을 훑는 화면, 주간을 따져 보는
/// 화면으로 나눠 놓았고 절대량은 주간 줄([NutritionRows])에 그대로 있다.
class NutritionTiles extends StatelessWidget {
  const NutritionTiles({super.key, required this.items});

  final List<NutritionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ReportEmpty(message: '기록이 없어 영양을 계산할 수 없어요');
    }

    // 시스템 글자 크기만큼 칸을 높인다. 비율을 고정해 두면 2.0 에서 이름·상태어·
    // 비율 세 줄이 칸 아래로 19px 넘쳤다 — 3열이라 폭은 늘릴 수 없으니 높이로 받는다.
    final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // 시안 타일은 85.4 × 130.4 다. 폭은 기기마다 달라지므로 비율로 잡는다.
        childAspectRatio: 85.4 / (130.4 * textScale.clamp(1.0, 2.0)),
      ),
      itemBuilder: (context, index) => _NutritionTile(item: items[index]),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({required this.item});

  final NutritionItem item;

  @override
  Widget build(BuildContext context) {
    final color = _nutritionColor(item);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.7),
        boxShadow: const [
          BoxShadow(color: Color(0xFFE8E7E6), blurRadius: 2.1, spreadRadius: 0.7),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(_iconFor(item.nutrient), size: 28, color: color),
          Column(
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _nutritionLabel(item),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              // **못 잰 항목은 비율도 막대도 그리지 않는다.** 서버가 status 를
              // 비워 보낸 항목은 amount·percent 가 0 인데, 그 0 은 "안 먹었다"가
              // 아니라 자리를 채운 값이다. "알 수 없음" 옆에 0% 를 적으면 방금
              // 한 말을 되돌린다.
              //
              // **자리는 남긴다.** 지우기만 했더니 세 칸 중 한 칸만 값이 있는 날
              // (실서버의 흔한 경우다) 라벨이 47px 씩 어긋났다 — spaceBetween 이
              // 자식 수에 따라 위치를 다시 잡기 때문이다.
              const SizedBox(height: 2),
              Visibility(
                visible: item.isKnown,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(
                  '${item.percent}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: item.isKnown,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.6),
              child: LinearProgressIndicator(
                // 기준을 넘긴 항목은 막대가 꽉 찬다. clamp 를 빼면 1.0 을 넘겨
                // 렌더가 죽는다 — 나트륨은 한 끼로도 200% 가 나온다.
                value: (item.percent / 100).clamp(0.0, 1.0),
                minHeight: 4.7,
                backgroundColor: Color.lerp(color, Colors.white, 0.85),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 서버 enum 이름으로 아이콘을 고른다. **표시는 `label` 로 한다** — 앱이
  /// 항목 목록을 갖지 않기 위해서다. 모르는 항목은 접시 아이콘으로 떨어진다.
  static IconData _iconFor(String nutrient) => switch (nutrient) {
        'CALORIES' => Icons.local_fire_department,
        'CARB' => Icons.rice_bowl,
        'PROTEIN' => Icons.set_meal,
        'FAT' => Icons.water_drop,
        'SODIUM' => Icons.grain,
        'SUGAR' => Icons.cake,
        // 피부 영양 포인트 3종. 이 셋이 없으면 접시 아이콘 세 개가 나란히 뜬다 —
        // 같은 카드 안에서 세 항목이 구분되지 않는다.
        'VITAMIN_C' => Icons.emoji_food_beverage,
        'OMEGA3' => Icons.set_meal_outlined,
        'ZINC' => Icons.shield_outlined,
        _ => Icons.restaurant,
      };
}

/// 주간 리포트의 영양 줄. 절대량·기준·비율을 한 줄에 다 보여준다.
///
/// 왼쪽 70px 만 그라디언트가 드러나고 나머지는 흰 판이다 — 시안이 항목명을
/// 색 위에, 숫자를 흰 바탕에 둔다. 숫자가 색 위에 있으면 읽기 어렵다.
class NutritionRows extends StatelessWidget {
  const NutritionRows({super.key, required this.items});

  final List<NutritionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ReportEmpty(message: '기록이 없어 영양을 계산할 수 없어요');
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: item == items.last ? 0 : 7),
            child: _NutritionRow(item: item),
          ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.item});

  final NutritionItem item;

  @override
  Widget build(BuildContext context) {
    final color = _nutritionColor(item);

    // 지표 막대와 같은 이유로 높이를 고정하지 않는다 — 시스템 글자 크기를
    // 키우면 항목명과 숫자가 알약 밖으로 넘친다.
    return Container(
      constraints: const BoxConstraints(minHeight: 49),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.95)!,
            Color.lerp(color, Colors.white, 0.55)!,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyInk,
                ),
              ),
            ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 1.7, 3, 1.7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 못 잰 항목은 숫자도 막대도 그리지 않는다 — 일일 타일과 같은
                  // 이유다(0 은 "안 먹었다"가 아니라 자리를 채운 값이다).
                  // 지금 주간에는 매크로 6종만 와서 도달하지 않지만, 한 항목의
                  // status 가 빠지는 날 두 탭이 같은 값을 반대로 설명하게 된다.
                  if (item.isKnown) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatAmount(item.amount)} / '
                            '${formatAmount(item.target.toDouble())}${item.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9C9C9C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.percent}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: LinearProgressIndicator(
                        value: (item.percent / 100).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.disabled,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ] else
                    const Text(
                      '알 수 없음',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// 고민별 식단 점수. 시안의 옅은 카드 한 장씩이다.
///
/// 설명 문장(`message`)과 태그(`tags`)는 **서버가 준다** — 룰이 판정할 때 만들어
/// 저장해 둔 `reason` 을 그대로 고른 것이라, 이 카드의 문장과 음식 결과 화면의
/// 문장이 같은 말을 한다. 앱이 조합하지 않는다.
///
/// 둘 다 없을 수 있다. V8 이전 기록이면 문장이 없고, 그 고민에 걸린 룰이 하나도
/// 없으면 태그도 비어 있다 — 그때는 점수와 상태 칩만 남는다.
class ConcernList extends StatelessWidget {
  const ConcernList({super.key, required this.items, required this.hasRecords});

  final List<ConcernScore> items;

  /// 그 기간에 기록이 하나라도 있는가. **빈 목록의 원인이 이것으로 갈린다.**
  ///
  /// 기록이 없으면 서버는 고민을 셀 대상이 없어 빈 배열을 준다. 그때 "프로필에서
  /// 고민을 골라 보세요" 라고 하면 이미 고민을 고른 사용자에게 틀린 원인을
  /// 말하는 것이고, 시키는 대로 해도 화면이 그대로다.
  final bool hasRecords;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      if (!hasRecords) {
        // 같은 카드의 영양 밸런스와 같은 이유·같은 말투로 적는다.
        return const ReportEmpty(message: '기록이 없어 고민별 점수를 낼 수 없어요');
      }

      // 기록은 있는데 비었다 — 고민을 안 골랐거나, 고른 고민이 전부 식단으로
      // 설명할 수 없는 것(다크서클)이다. 서버는 둘을 같은 빈 배열로 주므로
      // 앱이 원인을 단정하지 않고 두 경우를 다 덮는 문구를 쓴다.
      return const ReportEmpty(
        message: '식단으로 볼 수 있는 피부 고민이 없어요.\n프로필에서 고민을 골라 보세요.',
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: item == items.last ? 0 : 12),
            child: _ConcernCard(item: item),
          ),
      ],
    );
  }
}

class _ConcernCard extends StatelessWidget {
  const _ConcernCard({required this.item});

  final ConcernScore item;

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final good = status?.isGood ?? false;
    final accent = status?.accentColor ?? AppColors.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Color.lerp(accent, Colors.white, 0.93),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: AppColors.borderOnCream, blurRadius: 3),
        ],
      ),
      child: Row(
        // 문장과 태그가 붙으면 카드가 높아진다. 가운데 정렬로 두면 아이콘이
        // 문장 중간에 떠서 줄과 어긋난다.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              good ? Icons.local_florist : Icons.water_drop,
              size: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시안(383:332/336)은 칩을 카드 오른쪽 끝이 아니라 **고민 이름
                // 바로 옆**에 둔다. 오른쪽 끝에 두면 배율을 키웠을 때 칩이
                // 가져간 폭만큼 본문이 좁아져 넘친다.
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyInk,
                        ),
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      _StatusPill(grade: status),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${item.score}점',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.bodyInk,
                      ),
                    ),
                    // 변화량은 주간에서만 온다. 없으면 아무것도 그리지 않는다 —
                    // 앱이 계산하면 비교할 기준이 없는 주에 거짓 숫자가 뜬다.
                    if (item.change != null) ...[
                      const SizedBox(width: 8),
                      _ChangeLabel(change: item.change!),
                    ],
                  ],
                ),
                // 서버가 고른 룰의 이유 문장. 없으면 줄을 만들지 않는다.
                if (item.message case final message? when message.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: AppColors.bodyInk,
                    ),
                  ),
                ],
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in item.tags) _ConcernTag(label: tag),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 고민 카드의 근거 칩. **`#` 을 붙이지 않는다** — 서버가 보낸 문구는 "당류 과다"
/// 이고, 앞에 글자를 더하면 그건 앱이 문장을 고친 것이다(식단 포인트 칩과 같은 규칙).
///
/// **색을 입히지 않는다.** 예전에는 고민의 등급색을 썼는데, 부기 점수가 GOOD 이면
/// 그 근거인 "나트륨 과다" 가 초록으로 칠해졌다 — 바로 옆 문장은 "부담이 될 수
/// 있어요" 다. 서버는 태그가 좋은 근거인지 나쁜 근거인지 알려 주지 않으므로,
/// 앱이 색으로 그것을 단정하면 그게 곧 앱의 판정이다.
class _ConcernTag extends StatelessWidget {
  const _ConcernTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Pill(
      // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
      // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
      minHeight: 21,
      horizontalPadding: 10,
      borderRadius: 16,
      color: AppColors.borderOnWhite,
      label: label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnCard,
      ),
    );
  }
}

/// 고민 상태 칩. 시안 383:336~340.
///
/// **한때 지웠다가 되살렸다.** 없애면 등급이 카드 바탕색으로만 남는데, 그 바탕은
/// `Color.lerp(accentColor, white, 0.93)` 이라 좋음 #F6FAF3 · 보통 #FFF6F1 ·
/// 주의 ≈#FDF2F2 로 셋 다 흰색에 가깝다 — 서로 구분되지 않는다. 스크린리더는
/// 색을 못 읽어 등급을 아예 전달받지 못했다. 이 칩이 상태를 **글자로** 들고
/// 있는 유일한 자리다.
///
/// 색은 [SkinLevel] 이 소유한 것을 그대로 쓴다. 시안은 GOOD·CHECK 두 벌만
/// 정의하는데 서버 등급은 셋으로 접히므로, 두 벌로 접으면 보통과 주의가 완전히
/// 같은 칩이 된다 — 구분하려고 되살린 칩이 구분을 못 하게 된다.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.grade});

  final SkinLevel grade;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // 태그들 뒤에 등급 낱말만 읽히면 또 하나의 태그로 들린다.
      //
      // `excludeSemantics` 가 없으면 안쪽 Text 의 노드가 그대로 합쳐져
      // "상태 보통 / 보통" 이 된다 — 스크린리더가 같은 말을 두 번 읽는다.
      //
      // **`container` 를 켜지 마라.** 켜면 칩이 고민 카드의 병합 노드에서 떨어져
      // 나와, 카드는 등급 없이 읽히고 "상태 보통" 만 어느 고민 것인지 모른 채
      // 따로 뜬다. 등급은 그 고민 옆에서 읽혀야 한다.
      excludeSemantics: true,
      label: '상태 ${grade.label}',
      child: Pill(
        minHeight: 24,
        horizontalPadding: 12,
        borderRadius: 16,
        color: grade.tintColor,
        label: grade.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: grade.chipTextColor,
        ),
      ),
    );
  }
}

/// `+8` · `-3`. 0 이면 화살표를 붙이지 않는다 — 0 에 방향을 그리면 거짓말이다.
class _ChangeLabel extends StatelessWidget {
  const _ChangeLabel({required this.change});

  final int change;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (change) {
      > 0 => (Icons.arrow_upward, AppColors.good),
      < 0 => (Icons.arrow_downward, AppColors.bad),
      _ => (null, AppColors.textSecondary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 12, color: color),
        Text(
          '${change > 0 ? '+' : ''}$change점',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

/// 잘한 점 / 개선할 점 목록. 문장은 기록을 저장할 때 서버가 붙여 둔 것이다.
///
/// 시안의 해시태그 칩과 같은 모양으로 그린다 — 짧은 구절이라 줄로 늘어놓으면
/// 여백만 먹고, 칩으로 두면 한눈에 개수가 보인다.
///
/// **`#` 은 붙이지 않는다.** 시안은 `#당류 섭취 많음` 처럼 적지만 서버가 보낸
/// 문구는 "당류 섭취 많음" 이고, 앞에 글자를 하나 더 붙이면 그건 앱이 문장을
/// 고친 것이다. 모양만 칩으로 가져오고 글자는 받은 그대로 쓴다.
class PointList extends StatelessWidget {
  const PointList({
    super.key,
    required this.points,
    required this.positive,
  });

  final List<String> points;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final accent = positive ? AppColors.good : AppColors.accentStrong;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final point in points)
          Pill(
            // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
            // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
            minHeight: 21,
            horizontalPadding: 10,
            borderRadius: 16,
            color: Color.lerp(accent, Colors.white, 0.82),
            label: point,
            // 여기 색은 호출부가 알려 준다(`positive`) — 서버가 극성을 주지
            // 않는 고민 태그와 달리 잘한 점/개선할 점이 이미 갈려 있다.
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color.lerp(accent, Colors.black, 0.15),
            ),
          ),
      ],
    );
  }
}

/// AI 문장 카드. 시안이 리포트에서는 흰 카드로 바꿨다 — 홈·기록의 크림 카드와
/// 다른 것은 리포트가 이미 흰 카드 여섯 장이라 크림 한 장이 혼자 튀기 때문이다.
///
/// **여기에 숫자를 넣지 않는다.** 점수는 데이터가 낸 결과이고 AI 는 그것을
/// 설명할 뿐이라는 관계가 화면에서도 보여야 한다.
class AiCard extends StatelessWidget {
  const AiCard({super.key, required this.title, required this.entries});

  final String title;

  /// `label` 이 null 이면 문장만 그린다(일일의 한 줄 코멘트).
  final List<({String? label, String text})> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.disabled, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 16, color: AppColors.accentStrong),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentStrong,
                ),
              ),
            ],
          ),
          for (final entry in entries) ...[
            const SizedBox(height: 10),
            if (entry.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  entry.label!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnCard,
                  ),
                ),
              ),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: AppColors.bodyInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 끼니 한 줄. 홈의 오늘 기록 카드와 같은 모양이고, 사진도 같은 로컬 파일을 본다.
///
/// 점수 숫자 대신 GOOD/BAD 라벨을 쓴다 — 시안이 리포트·홈에서 같은 판단을
/// 내렸다. 숫자는 눌러서 들어간 결과 화면에 있다.
class MealRow extends ConsumerWidget {
  const MealRow({super.key, required this.meal, required this.onTap});

  final PlateHistoryItem meal;
  final VoidCallback onTap;

  static const double _size = 38;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(plateImageDirectoryProvider).valueOrNull;
    // 서버가 매긴 등급이다 — 앱에 경계표를 두지 않는다.
    final grade = meal.grade;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: directory == null
                  ? const _MealThumbnailFallback()
                  : Image.file(
                      PlateImageStore.fileFor(directory, meal.plateId),
                      width: _size,
                      height: _size,
                      fit: BoxFit.cover,
                      // 원본을 그대로 디코드하면 38px 칸에 수 MB 를 쓴다.
                      cacheWidth:
                          (_size * MediaQuery.devicePixelRatioOf(context)).round(),
                      // 파일이 없는 경우와 읽기 실패를 따로 다룰 이유가 없다.
                      errorBuilder: (_, __, ___) => const _MealThumbnailFallback(),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 끼니를 모르면(서버가 새 값을 보냈다면) 라벨을 비운다.
                  // 아무 끼니로나 떨어뜨리면 사용자가 자기 기록을 못 믿는다.
                  if (meal.mealType != null)
                    Text(
                      meal.mealType!.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyInk,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    meal.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.bodyInk,
                    ),
                  ),
                ],
              ),
            ),
            if (grade != null) ...[
              const SizedBox(width: 8),
              VerdictBadge(grade: grade),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealThumbnailFallback extends StatelessWidget {
  const _MealThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MealRow._size,
      height: MealRow._size,
      color: AppColors.surfaceCard,
      child: const Icon(Icons.restaurant, size: 18, color: AppColors.textSecondary),
    );
  }
}

/// 섹션 하나가 비었을 때. 화면째 비우지 않고 자리를 지킨다 —
/// 섹션이 통째로 사라지면 사용자가 "불러오다 만 화면"으로 읽는다.
class ReportEmpty extends StatelessWidget {
  const ReportEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderEmptySlot),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// 로딩 중 자리를 잡아 두는 회색 골격.
///
/// 스피너 하나만 두면 화면이 통째로 비어 "안 열렸다"로 읽힌다. 애니메이션은
/// 넣지 않는다 — 반짝임을 위해 패키지를 하나 더 들이거나 컨트롤러를 돌릴
/// 값이 없고, 일일 리포트는 AI 를 안 불러서 금방 끝난다.
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: const [
        _SkeletonBox(height: 145),
        SizedBox(height: 20),
        _SkeletonBox(height: 250),
        SizedBox(height: 20),
        _SkeletonBox(height: 100),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

/// 소수 첫째 자리까지, 정수면 소수점을 떼고, 천 단위에 쉼표.
///
/// 서버가 `1820.0` 을 보내는 날 "1820.0kcal" 이 뜨는 것을 막는다.
String formatAmount(double value) {
  final rounded = (value * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(1);

  final dot = text.indexOf('.');
  final whole = dot == -1 ? text : text.substring(0, dot);
  final rest = dot == -1 ? '' : text.substring(dot);

  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '$buffer$rest';
}
