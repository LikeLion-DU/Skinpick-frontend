import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_call.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../models/plate_dtos.dart';

class PlateRemoteDataSource {
  const PlateRemoteDataSource(this._dio);

  final Dio _dio;

  /// 분석만 한다. **서버에 아무것도 저장되지 않는다**(200, 201 이 아니다).
  ///
  /// [skinAnalysisId] 를 생략하면 서버가 그 사용자의 최신 피부 분석을 자동으로 쓴다.
  Future<PlateAnalysisDto> analyze(Uint8List image, {int? skinAnalysisId}) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'image': MultipartFile.fromBytes(image, filename: 'food.jpg'),
      if (skinAnalysisId != null) 'skinAnalysisId': skinAnalysisId,
    });

    final response = await _dio.post<dynamic>(
      '/plates/analyze',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return PlateAnalysisDto.fromJson(requireEnvelopeData(response));
  }

  /// 기록을 확정한다(201). 본문은 토큰 하나뿐이다 —
  /// 음식·영양·점수를 다시 조립해 보내지 마라. 서버가 받지 않고, 점수는 서버가
  /// 토큰 안의 AI 원본으로 다시 계산한다.
  ///
  /// AI 를 다시 부르지 않으므로 1초 안에 끝난다.
  /// 토큰의 jti 로 멱등이라 같은 토큰을 여러 번 보내도 기록은 하나다.
  Future<SkinPlateDto> saveRecord(String analysisToken) async {
    final response = await _dio.post<dynamic>(
      '/plates/records',
      data: <String, dynamic>{'analysisToken': analysisToken},
    );
    return SkinPlateDto.fromJson(requireEnvelopeData(response));
  }

  Future<SkinPlateDto> getById(int id) async {
    final response = await _dio.get<dynamic>('/plates/$id');
    return SkinPlateDto.fromJson(requireEnvelopeData(response));
  }

  /// from·to 는 둘 다 필수이고 to 도 포함하는 달력일이다(서버가 KST 로 해석한다).
  Future<PlateHistoryDto> history(DateTime from, DateTime to) async {
    final response = await _dio.get<dynamic>(
      '/plates',
      queryParameters: <String, dynamic>{
        'from': _isoDate(from),
        'to': _isoDate(to),
      },
    );
    return PlateHistoryDto.fromJson(requireEnvelopeData(response));
  }

  /// `toIso8601String()` 은 시각까지 붙어서 서버의 `ISO.DATE` 바인딩이 400 을 낸다.
  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// 저장 전 임시 분석을 대상으로 점수를 다시 계산한다. 경로에 id 가 없다.
  ///
  /// 토큰 TTL 이 30분이라 만료되면 422 ANALYSIS_EXPIRED 다. 저장된 뒤에는
  /// 만료가 없는 [simulate] 를 쓴다.
  Future<PlateSimulationDto> simulateAnalysis(
      String analysisToken, List<PlateActionCode> actions) async {
    final response = await _dio.post<dynamic>(
      '/plates/simulate',
      data: <String, dynamic>{
        'analysisToken': analysisToken,
        'actions': actions.map((action) => action.wire).toList(),
      },
    );
    return PlateSimulationDto.fromJson(requireEnvelopeData(response));
  }

  /// 저장된 기록을 대상으로 다시 계산한다. 히스토리 상세도 이쪽을 쓴다.
  ///
  /// 서버 enum 이름을 그대로 보낸다. 한쪽만 이름을 바꾸면 400 이다.
  Future<PlateSimulationDto> simulate(int plateId, List<PlateActionCode> actions) async {
    final response = await _dio.post<dynamic>(
      '/plates/$plateId/simulate',
      data: <String, dynamic>{
        'actions': actions.map((action) => action.wire).toList(),
      },
    );
    return PlateSimulationDto.fromJson(requireEnvelopeData(response));
  }
}
