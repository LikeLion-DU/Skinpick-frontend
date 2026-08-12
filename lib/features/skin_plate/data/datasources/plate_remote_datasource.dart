import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_call.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../models/plate_dtos.dart';

class PlateRemoteDataSource {
  const PlateRemoteDataSource(this._dio);

  final Dio _dio;

  /// [skinAnalysisId] 를 생략하면 서버가 그 사용자의 최신 피부 분석을 자동으로 쓴다.
  Future<SkinPlateDto> create(File image, {int? skinAnalysisId}) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'image': await MultipartFile.fromFile(image.path, filename: 'food.jpg'),
      if (skinAnalysisId != null) 'skinAnalysisId': skinAnalysisId,
    });

    final response = await _dio.post<dynamic>(
      '/plates',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return SkinPlateDto.fromJson(requireEnvelopeData(response));
  }

  Future<SkinPlateDto> getById(int id) async {
    final response = await _dio.get<dynamic>('/plates/$id');
    return SkinPlateDto.fromJson(requireEnvelopeData(response));
  }

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
