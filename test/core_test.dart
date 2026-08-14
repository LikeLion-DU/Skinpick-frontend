import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/network/dio_client.dart';
import 'package:skinplate/core/network/unauthorized_interceptor.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 네트워크를 타지 않고 정해진 상태 코드만 돌려준다.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.code);

  final int statusCode;
  final String code;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'error': {'code': code, 'message': '서버 메시지'},
        }),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// 에러 번역과 enum 파서만 검증한다.
/// 이 둘이 조용히 틀리면 화면에는 "일시적인 오류"만 뜨고 원인이 안 보인다.
void main() {
  DioException dioError({
    DioExceptionType type = DioExceptionType.badResponse,
    int? status,
    String? code,
  }) {
    final options = RequestOptions(path: '/skin/analyses');
    return DioException(
      requestOptions: options,
      type: type,
      response: status == null
          ? null
          : Response(
              requestOptions: options,
              statusCode: status,
              data: {
                'success': false,
                'data': null,
                'error': {'code': code, 'message': '서버 메시지'},
              },
            ),
    );
  }

  test('연결 실패는 NetworkFailure', () {
    expect(
      mapToFailure(dioError(type: DioExceptionType.connectionError)),
      isA<NetworkFailure>(),
    );
  });

  test('얼굴 미인식은 재촬영을 유도한다', () {
    final failure = mapToFailure(dioError(status: 422, code: 'FACE_NOT_DETECTED'));
    expect(failure, isA<AnalysisFailure>());
    expect((failure as AnalysisFailure).shouldRetakePhoto, isTrue);
    expect(failure.message, '서버 메시지');
  });

  test('분석 만료는 422이고 재촬영을 유도한다', () {
    // 401 로 내리면 UnauthorizedInterceptor 가 토큰을 지운다. 분석이 만료됐을 뿐인데
    // 로그인 세션이 날아가지 않도록 서버가 422 로 내리고, 앱은 재촬영으로 보낸다.
    final failure = mapToFailure(dioError(status: 422, code: 'ANALYSIS_EXPIRED'));

    expect(failure, isA<AnalysisFailure>());
    expect(failure, isNot(isA<AuthFailure>()));
    expect((failure as AnalysisFailure).shouldRetakePhoto, isTrue);
  });

  test('422 는 인터셉터를 타지 않아 로그아웃이 일어나지 않는다', () async {
    var loggedOut = false;
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(422, 'ANALYSIS_EXPIRED')
      ..interceptors.add(
        UnauthorizedInterceptor(const TokenStorage(), () => loggedOut = true),
      );

    // 422 가 실제로 인터셉터까지 흘렀는지 확인한다. 상태 코드를 안 보면 URI 해석
    // 실패 같은 다른 이유로 던져도 통과해서, 아무것도 증명하지 못하는 테스트가 된다.
    await expectLater(
      dio.post<dynamic>('http://localhost/plates/records'),
      throwsA(isA<DioException>().having(
          (error) => error.response?.statusCode, 'statusCode', 422)),
    );
    // 토큰 저장소도 건드리지 않는다 — clear() 를 탔다면 여기까지 오지 못한다.
    expect(loggedOut, isFalse);
  });

  test('토큰 만료는 expired 플래그가 선다', () {
    final failure = mapToFailure(dioError(status: 401, code: 'TOKEN_EXPIRED'));
    expect((failure as AuthFailure).expired, isTrue);
  });

  test('모르는 에러 코드는 ServerFailure로 흘려보낸다', () {
    expect(mapToFailure(dioError(status: 409, code: 'NEW_CODE_FROM_SERVER')),
        isA<ServerFailure>());
  });

  test('Dio가 아닌 예외는 UnknownFailure', () {
    expect(mapToFailure(StateError('boom')), isA<UnknownFailure>());
  });

  test('SkinType은 미선택(null)과 UNKNOWN을 구분한다', () {
    expect(SkinType.fromJson(null), isNull);
    expect(SkinType.fromJson('UNKNOWN'), SkinType.unknown);
    expect(SkinType.fromJson('SOMETHING_NEW'), isNull);
    expect(SkinType.oily.wire, 'OILY'); // 서버 enum 이름과 일치해야 400이 안 난다
  });

  test('모르는 HighlightStatus는 good이 아니라 warn으로 떨어진다', () {
    expect(HighlightStatus.fromJson('SOMETHING_NEW'), HighlightStatus.warn);
  });
}
