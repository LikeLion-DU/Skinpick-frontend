import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../data/datasources/plate_image_store.dart';
import '../../domain/entities/plate_history.dart';

/// S09 히스토리 — 최근 7일. 서버가 from·to 를 둘 다 요구한다(없으면 한 번의 호출이
/// 사용자의 전체 기록을 끌어온다).
///
/// autoDispose 인 이유 — 기록을 저장하고 히스토리로 들어오면 방금 저장한 것이
/// 보여야 한다. 저장 쪽에서 invalidate 를 호출하는 대신 화면을 나갈 때 버린다.
///
/// Result 를 그대로 실어 보낸다. Failure 를 throw 로 바꿔 AsyncError 에 담으면
/// 화면이 `error as Failure` 캐스팅을 하게 되고, 그 캐스팅이 틀리는 날 앱이 죽는다.
final plateHistoryProvider =
    FutureProvider.autoDispose<Result<List<PlateHistoryDay>>>((ref) {
  // 기기 시간대가 아니라 **KST 달력일**이다. 서버는 저장 시각을 실행 환경과 무관하게
  // KST 벽시계로 고정하고(설계서 §3) from·to 도 KST 로 읽는다. `DateTime.now()` 를
  // 그대로 쓰면 UTC 기기에서 09시 이전에 저장한 기록이 조회 범위 밖으로 빠진다 —
  // 방금 저장한 끼니가 히스토리에 없는 것으로 보인다.
  final today = DateTime.now().toUtc().add(const Duration(hours: 9));
  return ref
      .watch(plateRepositoryProvider)
      .history(today.subtract(const Duration(days: 6)), today);
});

/// 기록 사진이 들어 있는 디렉터리. 경로를 항목마다 다시 물어볼 이유가 없다.
/// 실패하면 null 이고, 화면은 전부 음식 아이콘으로 떨어진다.
final plateImageDirectoryProvider = FutureProvider<Directory?>((ref) async {
  try {
    return await PlateImageStore.directory();
  } on Object catch (_) {
    return null;
  }
});
