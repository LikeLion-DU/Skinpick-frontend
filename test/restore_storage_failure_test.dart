import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/network/dio_client.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';

/// 보안 저장소 읽기가 던져도 앱이 갇히지 않는다.
///
/// 재현 조건은 기기 쪽이다. 안드로이드 키스토어가 리셋되면(기기 초기화·백업
/// 복원·일부 OEM 업데이트) 암호화된 값을 못 풀고, iOS 도 기기 복원 직후 첫 잠금
/// 해제 전에는 키체인이 막힌다. 흔하지 않지만 한 번 걸리면 그 사용자는 영구히
/// 못 들어온다.
///
/// **막는 자리는 `TokenStorage.read()` 한 곳이다.** 부르는 곳이 셋이라
/// (복원 · 요청 인터셉터 · hasToken) 복원에서만 막으면 반쪽이다 — 로그인
/// 화면까지는 가는데 로그인 요청이 인터셉터에서 같은 예외로 실패해서, 다시
/// 로그인해 빠져나올 수도 없다. 그 반쪽 상태를 여기서 잡는다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 읽기만 던지는 기기. 나머지 호출은 실제 플러그인으로 새지 않게 막아 둔다.
  const unreadable = TokenStorage(_UnreadableSecureStorage());

  setUp(() => FlutterSecureStorage.setMockInitialValues(<String, String>{}));

  test('읽기가 던지면 없는 토큰과 같게 다룬다 — 예외를 흘리지 않는다', () async {
    expect(await unreadable.read(), isNull);
  });

  test('hasToken 도 같이 산다 — 같은 read 를 지난다', () async {
    expect(await unreadable.hasToken, isFalse);
  });

  group('콜드 스타트', () {
    ProviderContainer container() {
      final made = ProviderContainer(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
        tokenStorageProvider.overrideWithValue(unreadable),
      ]);
      addTearDown(made.dispose);
      made.listen(authNotifierProvider, (_, __) {});
      return made;
    }

    Future<AuthState> settled(ProviderContainer made) async {
      for (var i = 0; i < 200; i++) {
        final state = made.read(authNotifierProvider);
        if (state is! AuthInitial) return state;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      return made.read(authNotifierProvider);
    }

    test('스플래시에 갇히지 않고 로그인으로 간다', () async {
      final state = await settled(container());

      expect(
        state,
        isA<Unauthenticated>(),
        reason: 'AuthInitial 로 남으면 라우터가 스플래시에 고정해 재설치 말고는 길이 없다',
      );
      // 저장소를 못 읽은 것과 토큰이 만료된 것은 다르다. 만료로 세우면 기기
      // 문제로 밀려난 사용자에게 "로그인이 만료되었습니다" 라고 말하게 된다.
      expect((state as Unauthenticated).expired, isFalse);
    });

    test('로그인 요청이 인터셉터에서 죽지 않는다 — 여기가 유일한 출구다', () async {
      // 복원만 막으면 반쪽이다. 로그인 화면까지 가 놓고 로그인 요청이 같은
      // 예외로 실패하면 사용자는 여전히 못 들어온다.
      final dio = DioClient(
        tokenStorage: unreadable,
        onUnauthorized: () {},
      ).dio
        ..httpClientAdapter = _OkAdapter();

      final response = await dio.post<dynamic>('/auth/login');

      expect(response.statusCode, 200);
      expect(
        response.requestOptions.headers['Authorization'],
        isNull,
        reason: '못 읽은 토큰을 헤더에 붙이면 서버가 401 로 답한다',
      );
    });
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

/// 네트워크를 타지 않고 200 만 돌려준다.
class _OkAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
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
