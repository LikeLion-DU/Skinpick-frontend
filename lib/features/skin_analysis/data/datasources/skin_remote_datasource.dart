import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_call.dart';
import '../models/skin_dtos.dart';

class SkinRemoteDataSource {
  const SkinRemoteDataSource(this._dio);

  final Dio _dio;

  /// 파트 이름은 반드시 `image` 다. 다른 이름으로 보내면 서버가 400(INVALID_INPUT)을
  /// 돌려주는데, 화면에는 "요청 값이 올바르지 않습니다"만 떠서 원인이 안 보인다.
  ///
  /// fromFile 이 아니라 fromBytes 를 쓴다. 웹에는 파일 경로가 없다.
  /// 서버는 Content-Type 헤더가 아니라 실제 바이트로 형식을 판별하므로
  /// 파일명·타입을 정확히 맞출 필요는 없다.
  Future<SkinAnalysisDto> analyze(XFile image) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'image': MultipartFile.fromBytes(await image.readAsBytes(), filename: 'skin.jpg'),
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
}
