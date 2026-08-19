import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/network/dio_client.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';

/// 저장소를 못 읽는 기기에서도 앱이 갇히지 않는다.
///
/// 재현 조건은 기기 쪽이다. 안드로이드 키스토어가 리셋되면(기기 초기화·백업
/// 복원·일부 OEM 업데이트) 암호화된 값을 못 풀고, iOS 는 기기 복원 직후나 화면이
/// 잠긴 동안 키체인이 막힌다 — 분석 업로드(25~32초) 중에 화면을 잠그면 바로 그
/// 상황이다. 흔하지 않지만 한 번 걸리면 그 사용자는 영구히 못 들어온다.
///
/// **막는 자리가 넷이다. 하나만 막으면 반쪽이다.**
///
/// - `TokenStorage.read()` 는 던진다 — "없다" 와 "못 읽는다" 는 다른 사실이다
/// - `restore()` 가 받아서 로그인으로 보낸다 — 스플래시에 갇히지 않는다
/// - `AuthInterceptor` 는 헤더 없이 보낸다 — 로그인 요청까지 막히지 않는다
/// - `UnauthorizedInterceptor` 는 헤더 없이 나간 요청의 401 을 무시한다 —
///   자격 증명을 안 보낸 요청의 401 은 세션이 죽었다는 증거가 아니다
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unreadable = TokenStorage(_UnreadableSecureStorage());
  const healthy = TokenStorage();

  setUp(() => FlutterSecureStorage.setMockInitialValues(
      <String, String>{'access_token': 'jwt'}));

  Dio dioWith(TokenStorage storage, HttpClientAdapter adapter,
          {void Function()? onUnauthorized}) =>
      DioClient(tokenStorage: storage, onUnauthorized: onUnauthorized ?? () {})
          .dio
        ..httpClientAdapter = adapter;

  group('1~3. 요청이 나가는가', () {
    test('정상 토큰이면 그대로 헤더에 붙는다', () async {
      final dio = dioWith(healthy, _Ok());

      final response = await dio.get<dynamic>('/skin/analyses');

      expect(response.requestOptions.headers['Authorization'], 'Bearer jwt');
    });

    test('토큰이 없으면 헤더 없이 로그인 요청이 나간다', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final dio = dioWith(healthy, _Ok());

      final response = await dio.post<dynamic>('/auth/login');

      expect(response.statusCode, 200);
      expect(response.requestOptions.headers['Authorization'], isNull);
    });

    test('읽기가 던져도 로그인 요청이 막히지 않는다 — 유일한 출구다', () async {
      final dio = dioWith(unreadable, _Ok());

      final response = await dio.post<dynamic>('/auth/login');

      expect(response.statusCode, 200);
      expect(response.requestOptions.headers['Authorization'], isNull);
    });
  });

  group('4~6. 401 을 만료로 읽는 기준', () {
    test('헤더 없이 나간 요청의 401 은 세션을 지우지 않는다', () async {
      var signalled = false;
      final dio = dioWith(unreadable, _Unauthorized(),
          onUnauthorized: () => signalled = true);

      await expectLater(dio.get<dynamic>('/skin/analyses'),
          throwsA(isA<DioException>()));

      expect(await healthy.read(), 'jwt', reason: '자격 증명을 안 보낸 401 이 세션을 지웠다');
      expect(signalled, isFalse);
    });

    test('헤더를 붙여 보낸 요청의 401 은 그대로 만료다', () async {
      var signalled = false;
      final dio = dioWith(healthy, _Unauthorized(),
          onUnauthorized: () => signalled = true);

      await expectLater(dio.get<dynamic>('/skin/analyses'),
          throwsA(isA<DioException>()));

      expect(await healthy.read(), isNull);
      expect(signalled, isTrue);
    });

    test('화면이 잠긴 동안의 업로드가 세션을 날리지 않는다', () async {
      // iOS 키체인은 잠금 중 막힌다. 그때 헤더 없이 나간 업로드가 401 을 받아도
      // 저장된 토큰은 멀쩡하다 — 지우면 잠금 해제 뒤에 다시 로그인해야 한다.
      final dio = dioWith(unreadable, _Unauthorized());

      await expectLater(dio.post<dynamic>('/skin/analyses'),
          throwsA(isA<DioException>()));

      expect(await healthy.read(), 'jwt');
    });
  });

  group('7~8. 콜드 스타트', () {
    test('키스토어가 깨져도 스플래시에 갇히지 않는다', () async {
      final made = ProviderContainer(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
        tokenStorageProvider.overrideWithValue(unreadable),
      ]);
      addTearDown(made.dispose);
      made.listen(authNotifierProvider, (_, __) {});

      for (var i = 0; i < 200; i++) {
        if (made.read(authNotifierProvider) is! AuthInitial) break;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      final state = made.read(authNotifierProvider);

      expect(state, isA<Unauthenticated>(),
          reason: 'AuthInitial 로 남으면 라우터가 스플래시에 고정한다');
      // 저장소를 못 읽은 것과 토큰이 만료된 것은 다르다.
      expect((state as Unauthenticated).expired, isFalse);
    });

    test('"Data has been reset" 이 토큰으로 쓰이는 경로가 없다', () async {
      // flutter_secure_storage 의 resetOnError 는 실패를 이 문자열 **성공** 으로
      // 바꾼다. 켜져 있으면 read 가 이 값을 돌려주고 그대로 헤더에 앉는다.
      FlutterSecureStorage.setMockInitialValues(
          <String, String>{'access_token': 'Data has been reset'});
      final dio = dioWith(healthy, _Ok());

      final response = await dio.get<dynamic>('/skin/analyses');

      // 저장소가 준 값은 그대로 쓴다 — 앱이 문자열을 검사해 걸러내는 게 아니라,
      // 애초에 그 값이 저장되지 않게 옵션을 끄는 것이 방어다(아래 테스트).
      expect(response.requestOptions.headers['Authorization'],
          'Bearer Data has been reset');
    });
  });

  group('저장소 삭제가 실패해도', () {
    /// 읽기는 되는데 **삭제만** 던지는 저장소. 401 정리 경로가 여기서 막혔다.
    const undeletable = TokenStorage(_UndeletableSecureStorage());

    test('401 이 만료로 그대로 전달된다 — 저장소 오류가 덮어쓰지 않는다', () async {
      var signalled = false;
      final dio =
          DioClient(tokenStorage: undeletable, onUnauthorized: () => signalled = true)
              .dio
            ..httpClientAdapter = _Unauthorized();

      // 인터셉터가 예외를 흘리면 Dio 가 원래 401 을 지우고
      // DioExceptionType.unknown 을 내보낸다 — mapToFailure 가 AuthFailure 를
      // 못 만들어 화면에 "일시적인 오류" 만 뜬다.
      await expectLater(
        dio.get<dynamic>('/skin/analyses'),
        throwsA(isA<DioException>().having(
            (error) => error.response?.statusCode, 'statusCode', 401)),
      );

      // 지우지 못했어도 세션은 끊어야 한다.
      expect(signalled, isTrue, reason: '삭제 실패가 만료 신호까지 삼켰다');
    });

    test('로그아웃이 그래도 비인증으로 전환한다', () async {
      final made = ProviderContainer(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
        tokenStorageProvider.overrideWithValue(undeletable),
        authRepositoryProvider.overrideWithValue(
            const _LogoutFailsRepository()),
      ]);
      addTearDown(made.dispose);
      made.listen(authNotifierProvider, (_, __) {});

      made.read(authNotifierProvider.notifier).state =
          const Authenticated(AuthUser(userId: 1, email: 'a@b.c', nickname: 'n'));

      await made.read(authNotifierProvider.notifier).logout();

      // 상태가 Authenticated 로 남으면 이전 사용자의 사진과 점수가 화면에 남는다.
      expect(made.read(authNotifierProvider), isA<Unauthenticated>(),
          reason: '토큰 삭제 실패가 로그아웃을 통째로 막았다');
    });
  });

  test('9. resetOnError 가 다시 켜지지 않았다', () {
    // 켜면 어떤 예외에서든 저장소 전체를 지우고 "Data has been reset" 을
    // **성공** 으로 답한다(FlutterSecureStoragePlugin.java). read 는 그 문자열을,
    // write 는 성공을 돌려줘서 저장이 실패해도 로그인이 통과한 것처럼 보인다.
    final source = File('lib/core/storage/token_storage.dart').readAsStringSync();

    expect(
      RegExp(r'resetOnError:\s*true').hasMatch(source),
      isFalse,
      reason: '켜면 실패가 성공으로 둔갑하고 그 문자열이 토큰 자리에 앉는다',
    );
  });
}

/// 읽기가 `PlatformException` 을 던지는 저장소. 키스토어가 리셋된 기기다.
class _UnreadableSecureStorage extends FlutterSecureStorage {
  const _UnreadableSecureStorage();

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      throw PlatformException(
        code: 'BadPaddingException',
        message: 'Could not decrypt value',
      );
}

/// 삭제만 던지는 저장소. 읽기는 정상이라 헤더는 붙는다.
class _UndeletableSecureStorage extends FlutterSecureStorage {
  const _UndeletableSecureStorage();

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      throw PlatformException(code: 'KeyStoreException', message: 'delete failed');
}

/// 로그아웃이 저장소 삭제에서 던지는 레포지토리.
class _LogoutFailsRepository implements AuthRepository {
  const _LogoutFailsRepository();

  @override
  Future<void> logout() =>
      throw PlatformException(code: 'KeyStoreException', message: 'delete failed');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Ok implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(
        jsonEncode({'success': true, 'data': <String, dynamic>{}}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _Unauthorized implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'error': {'code': 'TOKEN_EXPIRED', 'message': '서버 메시지'},
        }),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}
