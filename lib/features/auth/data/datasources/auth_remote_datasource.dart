import 'package:dio/dio.dart';

import '../../../../core/network/api_call.dart';
import '../../../../shared/enums/skin_type.dart';
import '../models/auth_dtos.dart';

/// `/auth/*` 5종. 응답 래퍼를 벗기는 것까지만 하고 Failure 변환은 Repository 가 한다.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseDto> signup(SignupRequestDto request) async {
    final response = await _dio.post<dynamic>('/auth/signup', data: request.toJson());
    return AuthResponseDto.fromJson(requireEnvelopeData(response));
  }

  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<dynamic>('/auth/login', data: request.toJson());
    return AuthResponseDto.fromJson(requireEnvelopeData(response));
  }

  /// 본문 전체가 선택 사항이지만 슬롯을 명시해 보낸다.
  /// 발표는 슬롯 1, 팀 테스트는 2·3 으로 기록을 섞지 않는다.
  Future<AuthResponseDto> testLogin(int slot) async {
    final response = await _dio.post<dynamic>(
      '/auth/test-login',
      data: TestLoginRequestDto(slot: slot).toJson(),
    );
    return AuthResponseDto.fromJson(requireEnvelopeData(response));
  }

  Future<MeResponseDto> me() async {
    final response = await _dio.get<dynamic>('/auth/me');
    return MeResponseDto.fromJson(requireEnvelopeData(response));
  }

  /// 보낸 필드만 바뀐다. 건너뛰기는 이 메서드를 호출하지 않는 것이다.
  Future<MeResponseDto> updateSkinType(SkinType skinType) async {
    final response = await _dio.patch<dynamic>(
      '/auth/me',
      data: <String, dynamic>{'declaredSkinType': skinType.wire},
    );
    return MeResponseDto.fromJson(requireEnvelopeData(response));
  }
}
