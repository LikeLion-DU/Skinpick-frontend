import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/weekly_report.dart';

/// 주간 피부 식단 리포트. 홈 카드·기록 카드·리포트 화면이 **같은 프로바이더**를 본다.
///
/// 셋이 각각 부르면 한 화면에서 다른 화면으로 넘어가는 사이에 평균이 달라 보일 수
/// 있다. 같은 주를 두 숫자로 보여 주면 사용자는 둘 다 안 믿는다.
///
/// autoDispose 인데도 홈에서 살아 있는 이유는 홈이 스택 바닥에 계속 있기 때문이다.
/// 기록을 저장하거나 지우면 [plate_notifier] 와 기록 화면이 명시적으로 버린다.
final weeklyReportProvider = FutureProvider.autoDispose<Result<WeeklyReport>>(
  (ref) => ref.watch(plateRepositoryProvider).weeklyReport(),
);
