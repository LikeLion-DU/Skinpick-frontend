import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../skin_plate/domain/entities/plate_history.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';

/// 홈이 쓰는 "오늘". 히스토리(최근 7일)에서 오늘 하루만 골라낸다.
///
/// 오늘만 받는 API 를 따로 두지 않는 이유는, 홈과 기록 화면이 같은 응답을 보게
/// 하려는 것이다. 둘이 다른 엔드포인트를 쓰면 같은 날 점수가 서로 다를 수 있다.
///
/// 기록이 없는 날이면 null 이다. 0 점짜리 빈 날을 만들어 돌려주면 화면이
/// "오늘 0점"과 "아직 안 먹음"을 구분할 수 없게 된다.
///
/// **autoDispose 여야 한다.** 그냥 Provider 로 두면 autoDispose 인
/// [plateHistoryProvider] 를 영구 구독해 붙잡아 두고, 히스토리가 기대는
/// "화면을 나갈 때 버린다"가 영영 발동하지 않는다.
final todayRecordProvider = Provider.autoDispose<PlateHistoryDay?>((ref) {
  final history = ref.watch(plateHistoryProvider).value?.dataOrNull;
  if (history == null) return null;

  // 히스토리 provider 와 같은 기준의 KST 달력일이어야 한다. 기기 시간대를 쓰면
  // UTC 기기에서 오늘 아침 기록이 "어제"로 잡혀 홈이 비어 보인다.
  final today = DateTime.now().toUtc().add(const Duration(hours: 9));

  for (final day in history) {
    if (day.date.year == today.year &&
        day.date.month == today.month &&
        day.date.day == today.day) {
      return day;
    }
  }
  return null;
});
