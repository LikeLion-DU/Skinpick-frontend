import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../../../shared/widgets/verdict_badge.dart';
import '../../../skin_plate/data/datasources/plate_image_store.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';

/// 홈의 "오늘의 기록" 카드. 오렌지 히어로 위에 떠 있는 크림 카드다.
///
/// 기록이 없을 때 빈 카드를 두지 않고 예시 한 줄과 빈 슬롯을 보여준다.
/// 무엇을 찍으면 되는지 말로 설명하는 대신 결과물을 미리 보여 주는 쪽이다.
///
/// 예시 줄에 `ex)` 를 붙이는 것은 시안에 없는 한 글자다. 시안은 예시를 진짜
/// 기록과 똑같이 그리는데, 그러면 첫 사용자가 자기가 찍지 않은 "그릭요거트,
/// 블루베리"를 자기 기록으로 읽는다. 없는 데이터를 있는 것처럼 보이게 하는
/// 것이라 이 한 글자는 남긴다.
class TodayRecordsCard extends StatelessWidget {
  const TodayRecordsCard({
    super.key,
    required this.items,
    required this.imageDirectory,
    required this.onCapture,
    required this.onItemTap,
    required this.onSeeAll,
    this.loading = false,
    this.failureMessage,
    this.onRetry,
  });

  final List<PlateHistoryItem> items;

  /// 기록 사진이 든 로컬 디렉터리. 못 얻으면 null 이고 썸네일이 회색으로 남는다.
  final Directory? imageDirectory;

  final VoidCallback onCapture;

  /// 아직 응답을 못 받았다. 빈 날과 다르게 그린다.
  final bool loading;

  /// 불러오지 못했다. 문구는 `Failure.message` 다 — 네트워크·알 수 없는 오류는
  /// `core/error/failure.dart` 가 번역한 앱 문구이고, 서버가 이유를 말해 준
  /// 경우(`ServerFailure`)만 서버 문장이다. 앱이 여기서 새로 쓰지는 않는다.
  final String? failureMessage;

  /// 실패했을 때 다시 시도. 실패가 아니면 쓰이지 않는다.
  final VoidCallback? onRetry;
  final ValueChanged<PlateHistoryItem> onItemTap;

  /// 기록 화면으로 가는 **유일한 문**이다. 하단 네비에서 기록 자리를 리포트에
  /// 내주었으므로, 이 화살표가 없으면 날짜별 기록에 닿을 방법이 사라진다.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 23, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardWarm,
        borderRadius: BorderRadius.circular(AppTheme.floatingCardRadius),
        boxShadow: const [AppTheme.floatingCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onSeeAll: onSeeAll),
          const SizedBox(height: 20),
          // **세 상태를 한 화면으로 접지 않는다.** 예전에는 불러오는 중·실패·정말
          // 안 먹은 날이 모두 같은 예시 카드로 보여서, 네트워크가 흔들린 것을
          // "오늘 아직 안 먹었다"로 읽었다.
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (failureMessage != null)
            _Failed(message: failureMessage!, onRetry: onRetry)
          else if (items.isEmpty)
            _Empty(onCapture: onCapture)
          else
            for (final item in items)
              Padding(
                padding: EdgeInsets.only(bottom: item == items.last ? 0 : 15),
                child: _Row(
                  item: item,
                  imageDirectory: imageDirectory,
                  onTap: () => onItemTap(item),
                ),
              ),
        ],
      ),
    );
  }
}

/// 불러오지 못한 상태. 빈 날과 섞이지 않게 이유와 재시도를 함께 둔다.
class _Failed extends StatelessWidget {
  const _Failed({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSeeAll,
      behavior: HitTestBehavior.opaque,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: LeafMark(),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 기록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentStrong,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '기록을 함께 만들어가요!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCapture});

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ex)', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        const _SampleRow(),
        const SizedBox(height: 18),

        // 시안의 빈 슬롯. 눌러서 바로 촬영으로 갈 수 있게 했다 — 시안에는 +
        // 표시만 있지만, 보이는 곳을 눌렀는데 아무 일도 없으면 고장으로 읽힌다.
        GestureDetector(
          onTap: onCapture,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 157,
            decoration: BoxDecoration(
              color: AppColors.surfaceCardWarm,
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 20, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// 실제 기록이 아니라 예시다. 위의 `ex)` 와 짝이다.
class _SampleRow extends StatelessWidget {
  const _SampleRow();

  @override
  Widget build(BuildContext context) {
    return const _RowLayout(
      thumbnail: _ThumbnailFallback(),
      mealLabel: '아침',
      foodName: '그릭요거트, 블루베리',
      grade: SkinLevel.good,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.imageDirectory,
    required this.onTap,
  });

  final PlateHistoryItem item;
  final Directory? imageDirectory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _RowLayout(
        thumbnail: _Thumbnail(
          plateId: item.plateId,
          directory: imageDirectory,
        ),
        // 끼니를 모르면(서버가 새 값을 보냈다면) 라벨을 비운다.
        // 아무 끼니로나 떨어뜨리면 사용자가 자기 기록을 못 믿는다.
        mealLabel: item.mealType?.label,
        foodName: item.foodName,
        // 서버가 매긴 등급이다 — 앱에 경계표를 두지 않는다.
        grade: item.grade,
      ),
    );
  }
}

/// 예시 줄과 실제 줄이 한 픽셀도 다르지 않아야 한다 — 두 벌로 그리면
/// 한쪽만 고쳐지고, 예시가 실물과 다르면 예시로서 쓸모가 없다.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.thumbnail,
    required this.mealLabel,
    required this.foodName,
    required this.grade,
  });

  final Widget thumbnail;
  final String? mealLabel;
  final String foodName;

  /// 서버가 매긴 등급. 모르면(옛 서버) 라벨을 그리지 않는다.
  final SkinLevel? grade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        thumbnail,
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mealLabel != null)
                Text(
                  mealLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                foodName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (grade != null) ...[
          const SizedBox(width: 8),
          // 숫자가 아니라 라벨이다. 카드 안에 숫자가 셋(점수·목표·적합도)이면
          // 어느 것이 오늘의 점수인지 흐려진다 — 숫자는 눌러서 들어간 결과
          // 화면에 있다.
          VerdictBadge(grade: grade!),
        ],
      ],
    );
  }
}

/// 저장 직후 앱이 남긴 로컬 사진. 서버에는 이미지가 없다(PRD §9.6).
///
/// `existsSync()` 를 미리 부르지 않는다 — build 마다 UI 스레드에서 stat() 을
/// 막는 데다, 파일이 없는 경우와 읽기 실패를 따로 다룰 이유가 없다.
/// `errorBuilder` 가 두 경우를 다 받아낸다(기록 화면 썸네일과 같은 규칙).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.plateId, required this.directory});

  final int plateId;
  final Directory? directory;

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    final directory = this.directory;
    if (directory == null) return const _ThumbnailFallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.file(
        PlateImageStore.fileFor(directory, plateId),
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        // 원본을 그대로 디코드하면 52px 칸에 수 MB 를 쓴다. 배율만큼만 디코드한다.
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
      ),
    );
  }
}

/// 파일이 없어도 줄이 깨지지 않게 같은 크기의 자리를 남긴다.
class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _Thumbnail._size,
      height: _Thumbnail._size,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Icon(Icons.restaurant,
          size: 20, color: AppColors.textSecondary),
    );
  }
}
