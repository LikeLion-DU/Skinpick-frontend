import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../data/datasources/plate_image_store.dart';
import '../../domain/entities/plate_history.dart';
import '../providers/plate_history_provider.dart';

/// S09 — 히스토리. 날짜별 식단 기록.
///
/// **저장한 것만 보인다.** 촬영해서 분석만 하고 나간 음식은 여기에 없다 —
/// 그게 분석과 기록을 나눈 이유다.
///
/// 사진은 서버가 주지 않는다. 기록이 확정될 때 앱이 기기에 남긴
/// `<documents>/plates/{plateId}.jpg` 를 읽는다. 없으면 음식 아이콘이다.
class PlateHistoryPage extends ConsumerWidget {
  const PlateHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(plateHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: RefreshIndicator(
        // invalidate 는 void 라 당기자마자 스피너가 접힌다. 요청이 끝날 때까지
        // 붙잡으려면 새 값을 기다려야 한다.
        onRefresh: () => ref.refresh(plateHistoryProvider.future),
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // 여기의 error 는 Failure 가 아니라 예상 못 한 예외다.
          error: (error, _) => Center(child: Text('불러오지 못했습니다: $error')),
          data: (result) => result.when(
            failure: (failure) => FailureView(
              failure: failure,
              onRetry: () => ref.invalidate(plateHistoryProvider),
            ),
            success: (days) => days.isEmpty
                ? ListView(
                    // ListView 여야 당겨서 새로고침이 된다. Center 만 두면 스크롤이
                    // 없어서 RefreshIndicator 가 반응하지 않는다.
                    padding: const EdgeInsets.symmetric(vertical: 120),
                    children: const [
                      Center(child: Text('아직 저장한 기록이 없어요')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      for (final day in days) _DaySection(day: day),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day});

  final PlateHistoryDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${day.date.month}월 ${day.date.day}일',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (day.skinScore != null)
              Text('Skin ${day.skinScore}',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in day.plates) _HistoryTile(item: item),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final PlateHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final time = '${item.recordedAt.hour.toString().padLeft(2, '0')}:'
        '${item.recordedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: _Thumbnail(plateId: item.plateId),
        title: Text(item.foodName),
        subtitle: Text(time),
        trailing: Text('${item.plateScore}점',
            style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

/// 로컬 파일이 있으면 사진, 없으면 음식 아이콘.
///
/// `existsSync()` 를 미리 부르지 않는다 — 파일이 사라진 경우와 읽기가 실패한 경우를
/// 따로 다룰 이유가 없고, `errorBuilder` 가 두 경우를 다 받아낸다.
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.plateId});

  final int plateId;

  static const double _size = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(plateImageDirectoryProvider).valueOrNull;
    if (directory == null) return const _FoodIcon(size: _size);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        PlateImageStore.fileFor(directory, plateId),
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        // 48dp 썸네일에 1024px 원본을 디코드하면 한 장에 5MB 가 넘는다. 일주일치를
        // 한 화면에 그리면 이미지 캐시 예산(100MB)을 넘겨 계속 다시 디코드한다.
        cacheWidth: (_size * 3).round(),
        errorBuilder: (_, __, ___) => const _FoodIcon(size: _size),
      ),
    );
  }
}

class _FoodIcon extends StatelessWidget {
  const _FoodIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant, size: 24),
    );
  }
}
