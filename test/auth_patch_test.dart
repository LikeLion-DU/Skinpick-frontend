import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// PATCH 본문이 이 계약의 전부다.
///
/// 키를 빠뜨려도 서버는 400 을 주지 않는다 — 부분 업데이트라 "안 보낸 필드"로 읽고
/// 200 을 준다. 그래서 증상은 오류가 아니라 "저장한 줄 알았는데 안 된" 상태다.
void main() {
  late Map<String, dynamic> sentBody;

  AuthRemoteDataSource source() {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = _CaptureAdapter((body) => sentBody = body);
    return AuthRemoteDataSource(dio);
  }

  test('고른 필드만 실린다 — 미선택 습관은 키가 없다', () async {
    await source().updateProfile(
      declaredSkinType: SkinType.oily,
      skinConcerns: {SkinConcern.acne},
      sleepPattern: SleepPattern.lacking,
    );

    expect(sentBody, {
      'declaredSkinType': 'OILY',
      'skinConcerns': ['ACNE'],
      'sleepPattern': 'LACKING',
    });
  });

  test('고민을 전부 해제하면 빈 배열이 실린다', () async {
    // 서버는 skinConcerns 만 null(변경 없음)과 [](전부 해제)를 구분한다.
    // 키를 빼면 해제가 조용히 무시되고 이전 고민이 그대로 남는다.
    await source().updateProfile(skinConcerns: const <SkinConcern>{});

    expect(sentBody, {'skinConcerns': <String>[]});
  });

  test('습관 4종이 모두 실린다', () async {
    await source().updateProfile(
      sleepPattern: SleepPattern.enough,
      stressLevel: StressLevel.normal,
      exerciseHabit: ExerciseHabit.frequent,
      waterIntake: WaterIntake.enough,
    );

    expect(sentBody, {
      'sleepPattern': 'ENOUGH',
      'stressLevel': 'NORMAL',
      'exerciseHabit': 'FREQUENT',
      'waterIntake': 'ENOUGH',
    });
  });

  test('아무것도 안 고르면 빈 본문이다 — 건너뛰기가 값을 지우지 않는다', () async {
    await source().updateProfile();

    expect(sentBody, isEmpty);
  });
}

/// 보낸 본문만 붙잡고 최소 응답을 돌려준다.
class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter(this.onBody);

  final void Function(Map<String, dynamic>) onBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onBody(options.data as Map<String, dynamic>);
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'userId': 1,
          'email': 'test@skinplate.app',
          'nickname': '테스트유저',
          'skinConcerns': <String>[],
          'isTestAccount': false,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
