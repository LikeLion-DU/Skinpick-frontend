import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// 401을 한 곳에서 처리한다.
///
/// 만료 토큰으로 앱을 열었을 때 화면마다 에러 토스트가 뜨는 대신,
/// 토큰을 지우고 조용히 로그인 화면으로 넘어가게 만든다.
/// (실제 화면 전환은 AuthNotifier의 상태 변화를 go_router가 감지해서 수행)
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor(this._tokenStorage, this._onUnauthorized);

  final TokenStorage _tokenStorage;
  final void Function() _onUnauthorized;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // /auth/ 요청은 제외한다.
    // 로그인 실패도 401(INVALID_CREDENTIALS)이라 그대로 두면,
    // 비밀번호를 한 번 틀렸을 뿐인데 토큰이 지워지고 화면이 리다이렉트되어
    // 입력하던 폼과 에러 메시지가 함께 사라진다.
    final isAuthRequest = err.requestOptions.path.contains('/auth/');

    if (err.response?.statusCode == 401 && !isAuthRequest) {
      await _tokenStorage.clear();
      _onUnauthorized();
    }
    handler.next(err);
  }
}
