import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

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
    // 못 읽어도 요청은 보낸다. 여기서 예외를 흘리면 Dio 가 요청을 거절해서
    // **로그인 요청까지 실패한다** — 키스토어가 깨진 기기에서 다시 로그인해
    // 빠져나올 길이 막힌다. 헤더 없이 나간 요청의 401 은 세션이 죽었다는 뜻이
    // 아니고, UnauthorizedInterceptor 가 그 경우를 정리 대상에서 뺀다.
    //
    // **읽은 값을 그대로 쓴다.** 못 읽었을 때 아무 문자열이나 채우지 않는다 —
    // flutter_secure_storage 의 `resetOnError` 가 실패를 "Data has been reset"
    // 이라는 문자열 성공으로 바꿔 놓는 바람에 그 값이 토큰 자리에 앉은 적이 있다.
    String? token;
    try {
      token = await _tokenStorage.read();
    } catch (error) {
      if (kDebugMode) debugPrint('토큰 읽기 실패 — 헤더 없이 보낸다: $error');
    }

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
