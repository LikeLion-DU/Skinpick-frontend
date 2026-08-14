import 'package:dio/dio.dart';

import '../config/env.dart';
import '../error/failure.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'unauthorized_interceptor.dart';

class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    required void Function() onUnauthorized,
  }) : dio = Dio(BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: Env.connectTimeout,
          receiveTimeout: Env.receiveTimeout,
          contentType: 'application/json',
          // validateStatus는 건드리지 않는다. Dio 기본값(2xx만 성공)이어야
          // 4xx가 DioException으로 흘러 UnauthorizedInterceptor와
          // mapToFailure의 에러 코드 분기가 동작한다.
        )) {
    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      UnauthorizedInterceptor(tokenStorage, onUnauthorized),
    ]);
  }

  final Dio dio;
}

/// DioException과 서버 error 본문을 화면이 이해하는 Failure로 번역한다.
/// 이 매핑이 한 곳에 있어야 에러 처리 UX가 화면마다 달라지지 않는다.
Failure mapToFailure(Object error) {
  if (error is! DioException) return const UnknownFailure();

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const AnalysisFailure('AI_TIMEOUT', '분석이 지연되고 있습니다. 다시 시도해 주세요.');
    default:
      break;
  }

  final body = error.response?.data;
  if (body is Map<String, dynamic>) {
    final errorBody = body['error'];
    if (errorBody is Map<String, dynamic>) {
      final code = errorBody['code'] as String? ?? 'INTERNAL_ERROR';
      final message = errorBody['message'] as String? ?? '일시적인 오류가 발생했습니다.';

      return switch (code) {
        'TOKEN_EXPIRED' => AuthFailure(message, expired: true),
        'UNAUTHORIZED' || 'INVALID_CREDENTIALS' => AuthFailure(message),
        'FACE_NOT_DETECTED' ||
        'FOOD_NOT_DETECTED' ||
        'AI_ANALYSIS_FAILED' ||
        'AI_TIMEOUT' ||
        // 저장 토큰 만료(422). ServerFailure 로 떨어뜨리면 메시지는 뜨는데
        // 재촬영 경로를 안 탄다.
        'ANALYSIS_EXPIRED' =>
          AnalysisFailure(code, message),
        _ => ServerFailure(code, message),
      };
    }
  }
  return const UnknownFailure();
}
