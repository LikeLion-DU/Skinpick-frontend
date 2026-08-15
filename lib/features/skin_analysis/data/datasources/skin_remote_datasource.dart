import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_call.dart';
import '../../domain/entities/skin_photo_set.dart';
import '../models/skin_dtos.dart';
import '../models/skin_insight_dtos.dart';

class SkinRemoteDataSource {
  const SkinRemoteDataSource(this._dio);

  final Dio _dio;

  /// 파트 이름은 반드시 `front` · `left` · `right` 셋이다. 서버가
  /// `@RequestPart` 로 셋을 다 요구하므로 하나라도 빠지거나 이름이 다르면
  /// 400(INVALID_INPUT)이 돌아오는데, 화면에는 "요청 값이 올바르지 않습니다"만
  /// 떠서 원인이 안 보인다.
  ///
  /// fromFile 이 아니라 fromBytes 를 쓴다. 웹에는 파일 경로가 없다.
  /// 서버는 Content-Type 헤더가 아니라 실제 바이트로 형식을 판별하므로
  /// 파일명·타입을 정확히 맞출 필요는 없다.
  Future<SkinAnalysisDto> analyze(SkinPhotoSet photos) async {
    Future<MultipartFile> part(XFile file, String name) async =>
        MultipartFile.fromBytes(await file.readAsBytes(), filename: '$name.jpg');

    final formData = FormData.fromMap(<String, dynamic>{
      'front': await part(photos.front, 'front'),
      'left': await part(photos.left, 'left'),
      'right': await part(photos.right, 'right'),
    });

    final response = await _dio.post<dynamic>(
      '/skin/analyses',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return SkinAnalysisDto.fromJson(requireEnvelopeData(response));
  }

  /// 아직 한 번도 안 찍은 사용자는 서버가 data 를 비워서 준다 → null.
  Future<SkinAnalysisDto?> getLatest() async {
    final response = await _dio.get<dynamic>('/skin/analyses/latest');
    final data = envelopeData(response);
    return data == null ? null : SkinAnalysisDto.fromJson(data);
  }

  Future<SkinAnalysisDto> getById(int id) async {
    final response = await _dio.get<dynamic>('/skin/analyses/$id');
    return SkinAnalysisDto.fromJson(requireEnvelopeData(response));
  }

  /// get-or-create 다. 처음 부르면 서버가 AI 로 만들어 저장하고 돌려주므로
  /// 최대 ~27초 걸린다(AI 25초 타임아웃 + 429 1회 재시도). 두 번째부터는 DB 읽기다.
  ///
  /// 동시 호출은 서버가 락과 UNIQUE 제약으로 직렬화한다 — 느린 첫 응답에
  /// 재시도를 겹쳐도 인사이트가 두 개 생기지 않는다.
  Future<SkinInsightDto> getInsight(int skinAnalysisId) async {
    final response = await _dio.get<dynamic>(
      '/skin-insights',
      queryParameters: <String, dynamic>{'skinAnalysisId': skinAnalysisId},
    );
    return SkinInsightDto.fromJson(requireEnvelopeData(response));
  }
}
