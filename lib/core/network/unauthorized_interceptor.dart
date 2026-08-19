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

  /// 401 이 "자격 증명이 틀렸다" 는 뜻인 요청. 로그인 실패도
  /// 401(INVALID_CREDENTIALS)이라 그대로 두면, 비밀번호를 한 번 틀렸을 뿐인데
  /// 토큰이 지워지고 화면이 리다이렉트되어 입력하던 폼과 에러 메시지가 함께 사라진다.
  ///
  /// **`/auth/` 전체를 빼면 안 된다.** `/auth/me` 는 세션을 들고 보내는 요청이라
  /// 401 이 곧 세션이 죽었다는 뜻이다. 통째로 빼 두었을 때는 만료 토큰이 기기에
  /// 남아, 앱을 다시 켤 때마다 같은 토큰으로 `/auth/me` 를 두드렸다 — 로그인
  /// 화면까지는 갔지만 실패하는 왕복이 영구히 반복됐다.
  ///
  /// 기준은 경로 접두사가 아니라 **401 의 의미**다. 자격 증명을 보내는 요청이면
  /// 자격 증명 오류, 세션을 들고 보내는 요청이면 세션 사망이다. `/auth/` 아래에
  /// 엔드포인트를 추가할 때 어느 쪽인지 보고 여기에 넣을지 정한다.
  static const _credentialPaths = [
    '/auth/login',
    '/auth/signup',
    '/auth/test-login',
  ];

  /// `contains` 가 아니라 `endsWith` 다. 부분 문자열로 보면 나중에 생길
  /// `/auth/login-history` 같은 세션 요청이 `/auth/login` 에 걸려 조용히 빠져나가,
  /// 이 파일이 막은 누수가 그대로 다시 열린다. 끝에서 맞추면 baseUrl 이 붙은
  /// `/api/v1/auth/login` 은 잡고 `/auth/login-history` 는 놓아준다.
  bool _isCredentialRequest(DioException err) {
    final path = err.requestOptions.path;
    return _credentialPaths.any(path.endsWith);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 자격 증명을 **보내지 않은** 요청의 401 은 저장된 세션이 무효라는 증거가
    // 아니다. 토큰을 못 읽어 헤더 없이 나간 요청이 대표적이다(화면이 잠긴 동안의
    // 업로드 등) — 그걸 만료로 읽으면 멀쩡한 세션을 지우고 "로그인이
    // 만료되었습니다" 까지 띄운다.
    final sentCredentials =
        err.requestOptions.headers.containsKey('Authorization');

    if (err.response?.statusCode == 401 &&
        sentCredentials &&
        !_isCredentialRequest(err)) {
      await _tokenStorage.clear();
      _onUnauthorized();
    }
    handler.next(err);
  }
}
