import 'package:dio/dio.dart';

import '../result/result.dart';
import 'dio_client.dart';

/// DataSource 호출을 감싸 예외를 Result 로 바꾼다.
///
/// try-catch 를 각 Repository 메서드마다 쓰면 언젠가 한 곳을 빠뜨리고,
/// 그 한 곳만 예외가 화면까지 올라가 앱이 죽는다. 통로를 하나로 둔다.
Future<Result<T>> callApi<T>(Future<T> Function() request) async {
  try {
    return Success(await request());
  } catch (error) {
    return FailureResult(mapToFailure(error));
  }
}

/// 공통 래퍼 { success, data, error } 에서 data 를 꺼낸다.
///
/// 서버는 `default-property-inclusion: non_null` 이라 값이 없으면 키 자체가 사라진다.
/// 그래서 "data 가 null" 과 "data 키가 없음" 을 같게 다뤄야 한다.
Map<String, dynamic>? envelopeData(Response<dynamic> response) {
  final body = response.data;
  if (body is! Map<String, dynamic>) {
    throw const FormatException('공통 응답 래퍼가 아닌 본문을 받았습니다.');
  }

  final data = body['data'];
  if (data == null) return null;
  if (data is! Map<String, dynamic>) {
    throw const FormatException('data 가 객체가 아닙니다.');
  }
  return data;
}

/// data 가 반드시 있어야 하는 응답용. 비어 있으면 UnknownFailure 로 흘러간다.
Map<String, dynamic> requireEnvelopeData(Response<dynamic> response) {
  final data = envelopeData(response);
  if (data == null) {
    throw const FormatException('응답에 data 가 없습니다.');
  }
  return data;
}
