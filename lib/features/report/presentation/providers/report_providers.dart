import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/report.dart';

/// 날짜를 키로 받는다. 화면이 날짜를 넘겨도 이미 본 날은 다시 부르지 않고,
/// **다른 날의 응답이 서로 덮어쓰지 않는다** — 하나의 프로바이더에 담으면
/// 느린 응답이 뒤늦게 도착해 사용자가 보고 있는 날짜를 갈아치운다.
///
/// AI 를 부르지 않는 조회라 빠르다. `autoDispose` 로 두고 화면을 나가면 버린다.
final dailyReportProvider =
    FutureProvider.autoDispose.family<Result<DailyReport>, DateTime>(
  (ref, date) => ref.watch(reportRepositoryProvider).daily(date: date),
);

/// 조회 구간 전체가 키다. 주간이든 월간이든 같은 프로바이더를 쓴다 —
/// 서버도 같은 엔드포인트 하나이고 다른 것은 폭뿐이다.
///
/// **기록이 있으면 서버가 AI 문장을 만들어 붙이느라 최대 ~27초 걸린다.** 그래서
/// 홈처럼 항상 떠 있는 화면에서 이것을 watch 하면 안 된다 — 리포트 화면에
/// 들어왔을 때만 부른다.
final weeklyReportProvider = FutureProvider.autoDispose
    .family<Result<WeeklyReport>, ({DateTime from, DateTime to})>(
  (ref, range) =>
      ref.watch(reportRepositoryProvider).weekly(from: range.from, to: range.to),
);
