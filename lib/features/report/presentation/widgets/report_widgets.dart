/// 일일·주간이 같이 쓰는 조각들.
///
/// 두 화면이 그리는 것은 대부분 같다 — 점수 카드, 영양 막대, 고민 줄, AI 문장.
/// 각자 그리면 한쪽만 고쳐지고, 같은 뜻의 카드가 탭을 넘길 때마다 달라 보인다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/widgets/score_badge.dart';
import '../../../skin_plate/data/datasources/plate_image_store.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';
import '../../domain/entities/report.dart';

/// 구역 제목 + 내용. 제목 스타일을 화면마다 적지 않으려고 둔다.
class ReportSection extends StatelessWidget {
  const ReportSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;

  /// 제목 옆의 작은 단서. "기록한 날의 하루 평균" 같은 것 —
  /// 이 한 줄이 없으면 사용자가 주간 영양을 주간 **합계**로 읽는다.
  final String? subtitle;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// 화면 맨 위의 종합 점수 카드.
///
/// 점수가 없으면 `OO점` 이다 — **0 점을 그리지 않는다.** 0 은 "아주 나쁘게 먹었다"고
/// 이건 "아직 안 찍었다"라서, 같은 자리에 같은 숫자로 쓰면 안 된다.
class ReportScoreCard extends StatelessWidget {
  const ReportScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.grade,
    this.footnote,
  });

  final String title;
  final int? score;
  final SkinLevel? grade;

  /// 점수 아래 작은 줄. "오늘 3끼 기록했어요" · "7일 중 5일 기록" 같은 것.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final grade = this.grade;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnCard,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score?.toString() ?? 'OO',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: grade?.accentColor ?? AppColors.textPrimary,
                ),
              ),
              const Text(
                '점',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: AppColors.textPrimary,
                ),
              ),
              if (grade != null) ...[
                const SizedBox(width: 8),
                ScoreBadge(grade: grade),
              ],
            ],
          ),
          if (grade != null) ...[
            const SizedBox(height: 12),
            // 등급에 붙는 고정 문구다. AI 가 쓴 문장은 아래 AI 카드에 따로 있다 —
            // 두 자리를 섞으면 "AI 가 점수를 매겼다"로 읽힌다.
            Text(
              grade.summary,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnCard,
              ),
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 14),
            Text(footnote!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// 영양 밸런스 막대들.
///
/// **항목 목록을 앱이 갖지 않는다.** 서버가 보낸 순서와 개수를 그대로 그리므로,
/// 서버가 항목을 늘려도 이 위젯은 손댈 필요가 없다.
class NutritionBars extends StatelessWidget {
  const NutritionBars({super.key, required this.items});

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
            padding: const EdgeInsets.only(bottom: 16),
            child: _NutritionBar(item: item),
          ),
      ],
    );
  }
}

class _NutritionBar extends StatelessWidget {
  const _NutritionBar({required this.item});

  final NutritionItem item;

  @override
  Widget build(BuildContext context) {
    // 상태를 모르면 색을 입히지 않는다. 모르는 값을 초록으로 칠하면
    // 서버가 새 상태를 보낸 날 경고가 조용히 "정상"이 된다.
    final color = switch (item.status) {
      null => AppColors.outline,
      _ when item.isWarning => AppColors.primary,
      _ => AppColors.good,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatAmount(item.amount)} / ${formatAmount(item.target.toDouble())}${item.unit}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.percent}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            // 기준을 넘긴 항목은 막대가 꽉 찬다. clamp 를 빼면 1.0 을 넘겨
            // 렌더가 죽는다 — 나트륨은 한 끼로도 200% 가 나온다.
            value: (item.percent / 100).clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppColors.borderOnWhite,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// 고민별 식단 점수 줄.
class ConcernList extends StatelessWidget {
  const ConcernList({super.key, required this.items});

  final List<ConcernScore> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      // 고민을 안 골랐을 수도, 고른 고민이 전부 식단으로 설명할 수 없는
      // 것(다크서클)일 수도 있다. 서버는 둘을 같은 빈 배열로 주므로
      // 앱이 원인을 단정하지 않고 두 경우를 다 덮는 문구를 쓴다.
      return const ReportEmpty(
        message: '식단으로 볼 수 있는 피부 고민이 없어요.\n프로필에서 고민을 골라 보세요.',
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // 변화량은 주간에서만 온다. 없으면 아무것도 그리지 않는다 —
                // 앱이 계산하면 비교할 기준이 없는 주에 거짓 숫자가 뜬다.
                if (item.change != null) ...[
                  _ChangeLabel(change: item.change!),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${item.score}점',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.status != null) ...[
                  const SizedBox(width: 8),
                  ScoreBadge(grade: item.status!, solid: true),
                ],
              ],
            ),
          ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final point in points)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  positive ? Icons.check_circle_outline : Icons.error_outline,
                  size: 16,
                  color: positive ? AppColors.good : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// AI 문장 카드. 기록 화면의 코멘트 카드와 같은 크림 그라디언트다.
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          for (final entry in entries) ...[
            const SizedBox(height: 12),
            if (entry.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  entry.label!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnCard,
                  ),
                ),
              ),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF411B09),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 끼니 한 줄. 홈의 오늘 기록 카드와 같은 모양이고, 사진도 같은 로컬 파일을 본다.
class MealRow extends ConsumerWidget {
  const MealRow({super.key, required this.meal, required this.onTap});

  final PlateHistoryItem meal;
  final VoidCallback onTap;

  static const double _size = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(plateImageDirectoryProvider).valueOrNull;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
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
                      // 원본을 그대로 디코드하면 40px 칸에 수 MB 를 쓴다.
                      cacheWidth:
                          (_size * MediaQuery.devicePixelRatioOf(context)).round(),
                      // 파일이 없는 경우와 읽기 실패를 따로 다룰 이유가 없다.
                      errorBuilder: (_, __, ___) => const _MealThumbnailFallback(),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meal.foodName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${meal.plateScore}점',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.fromLTRB(AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
      children: const [
        _SkeletonBox(height: 160),
        SizedBox(height: 28),
        _SkeletonBox(height: 18, width: 120),
        SizedBox(height: 14),
        _SkeletonBox(height: 90),
        SizedBox(height: 28),
        _SkeletonBox(height: 18, width: 140),
        SizedBox(height: 14),
        _SkeletonBox(height: 90),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
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
