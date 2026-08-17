import '../../../../core/result/result.dart';
import '../entities/report.dart';

abstract interface class ReportRepository {
  /// 하루치 리포트. [date] 를 생략하면 서버의 오늘(KST)이다.
  Future<Result<DailyReport>> daily({DateTime? date});

  /// 기간 집계. [from]·[to] 는 둘 다 주거나 둘 다 생략해야 한다 —
  /// 하나만 주면 서버가 400 으로 막는다. 생략하면 오늘 포함 7일이다.
  ///
  /// 기간을 넓히면 그대로 월간이 된다. 그래서 메서드가 하나뿐이다.
  Future<Result<WeeklyReport>> weekly({DateTime? from, DateTime? to});
}
