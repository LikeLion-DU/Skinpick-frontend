import 'package:dio/dio.dart';

import '../../../../core/network/api_call.dart';
import '../../../../core/utils/kst_date.dart';
import '../models/report_dtos.dart';

class ReportRemoteDataSource {
  const ReportRemoteDataSource(this._dio);

  final Dio _dio;

  /// 일일 리포트. **AI 를 부르지 않아 즉시 온다** — 저장된 기록을 다시 셀 뿐이다.
  ///
  /// [date] 를 생략하면 서버가 자기 오늘(KST)로 조회한다. 앱이 날짜를 안 보내는
  /// 쪽이 항상 옳지만, 화면이 날짜를 넘겨 볼 수 있어야 해서 인자로 받는다.
  Future<DailyReportDto> daily({DateTime? date}) async {
    final response = await _dio.get<dynamic>(
      '/reports/daily',
      queryParameters: date == null
          ? null
          : <String, dynamic>{'date': isoDate(date)},
    );
    return DailyReportDto.fromJson(requireEnvelopeData(response));
  }

  /// 주간 리포트. from·to 는 둘 다 포함하는 달력일이고, **하나만 보내면 400** 이다.
  /// 둘 다 생략하면 서버가 오늘 포함 7일로 정한다.
  ///
  /// 기록이 있으면 서버가 AI 문장을 함께 만들어 붙이므로 **최대 ~27초** 걸린다.
  /// `Env.receiveTimeout` 이 32초라 앱이 먼저 포기하지 않는다.
  Future<WeeklyReportDto> weekly({DateTime? from, DateTime? to}) async {
    final response = await _dio.get<dynamic>(
      '/reports/weekly',
      queryParameters: (from == null || to == null)
          ? null
          : <String, dynamic>{'from': isoDate(from), 'to': isoDate(to)},
    );
    return WeeklyReportDto.fromJson(requireEnvelopeData(response));
  }
}
