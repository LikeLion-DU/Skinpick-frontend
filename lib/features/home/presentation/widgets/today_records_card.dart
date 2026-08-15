import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/score_grade.dart';
import '../../../skin_plate/data/datasources/plate_image_store.dart';
import '../../../skin_plate/domain/entities/plate_history.dart';

/// 홈의 "오늘의 기록" 카드.
///
/// 기록이 없을 때 빈 카드를 두지 않고 `ex)` 예시 한 줄과 빈 슬롯을 보여준다.
/// 무엇을 찍으면 되는지 말로 설명하는 대신 결과물을 미리 보여 주는 쪽이다.
class TodayRecordsCard extends StatelessWidget {
  const TodayRecordsCard({
    super.key,
    required this.items,
    required this.imageDirectory,
    required this.onCapture,
    required this.onItemTap,
  });

  final List<PlateHistoryItem> items;

  /// 기록 사진이 든 로컬 디렉터리. 못 얻으면 null 이고 썸네일이 회색으로 남는다.
  final Directory? imageDirectory;

  final VoidCallback onCapture;
  final ValueChanged<PlateHistoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderOnWhite),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 7.2),
        ],
      ),
      child: items.isEmpty ? _Empty(onCapture: onCapture) : _List(
        items: items,
        imageDirectory: imageDirectory,
        onItemTap: onItemTap,
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
        const Text(
          '기록을 함께 만들어가요!',
          style: TextStyle(fontSize: 15, color: AppColors.textOnCard),
        ),
        const SizedBox(height: 20),
        Text('ex)', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),

        // 실제 기록이 아니라 예시다. 진짜 기록과 헷갈리지 않도록 위에 ex) 를 둔다.
        const _SampleRow(),
        const SizedBox(height: 16),

        // 시안의 빈 슬롯. 눌러서 바로 촬영으로 갈 수 있게 했다 — 시안에는 + 표시만
        // 있지만, 보이는 곳을 눌렀는데 아무 일도 없으면 고장으로 읽힌다.
        GestureDetector(
          onTap: onCapture,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 184,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderEmptySlot),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 20, color: AppColors.borderEmptySlot),
            ),
          ),
        ),
      ],
    );
  }
}

class _SampleRow extends StatelessWidget {
  const _SampleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(Icons.ramen_dining,
              size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('아침',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  )),
              SizedBox(height: 4),
              Text('그릭요거트, 블루베리',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
        ),
        const Text('78점',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.good,
            )),
        const SizedBox(width: 6),
        const Icon(Icons.sentiment_satisfied_alt,
            size: 20, color: AppColors.good),
      ],
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.imageDirectory,
    required this.onItemTap,
  });

  final List<PlateHistoryItem> items;
  final Directory? imageDirectory;
  final ValueChanged<PlateHistoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _Row(
              item: item,
              imageDirectory: imageDirectory,
              onTap: () => onItemTap(item),
            ),
          ),
      ],
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
    final grade = ScoreGrade.fromScore(item.plateScore);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _Thumbnail(plateId: item.plateId, directory: imageDirectory),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 끼니를 모르면(서버가 새 값을 보냈다면) 배지를 비운다.
                // 아무 끼니로나 떨어뜨리면 사용자가 자기 기록을 못 믿는다.
                if (item.mealType != null)
                  Text(item.mealType!.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      )),
                const SizedBox(height: 4),
                Text(
                  item.foodName,
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
          Text('${item.plateScore}점',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: grade.accentColor,
              )),
          const SizedBox(width: 6),
          Icon(
            switch (grade) {
              ScoreGrade.good => Icons.sentiment_satisfied_alt,
              ScoreGrade.normal => Icons.sentiment_neutral,
              ScoreGrade.caution => Icons.sentiment_dissatisfied,
            },
            size: 20,
            color: grade.accentColor,
          ),
        ],
      ),
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

  static const double _size = 32;

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
        // 원본을 그대로 디코드하면 32px 칸에 수 MB 를 쓴다. 배율만큼만 디코드한다.
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
      ),
    );
  }
}

/// 파일이 없어도 줄이 깨지지 않게 같은 크기의 회색 자리를 남긴다.
class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: _Thumbnail._size,
        height: _Thumbnail._size,
        color: AppColors.surfaceCard,
        child: const Icon(Icons.restaurant,
            size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
