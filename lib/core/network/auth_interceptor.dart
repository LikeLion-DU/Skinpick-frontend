import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// 모든 요청에 Authorization 헤더를 자동으로 붙인다.
/// 각 DataSource가 헤더를 챙기면 언젠가 한 곳을 빠뜨린다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
