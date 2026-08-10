import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/network/dio_client.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

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
