import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/network/dio_client.dart';
import 'package:skinplate/core/network/unauthorized_signal.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';

/// 401 을 지우는 요청과 지우면 안 되는 요청을 가른다.
///
/// `/auth/` 를 통째로 제외하던 시절, `/auth/me` 의 401 도 같이 빠져서 만료 토큰이
/// 기기에 남았다. 로그인 화면까지는 갔지만 토큰이 그대로라 앱을 다시 켤 때마다
/// 같은 만료 토큰으로 `/auth/me` 를 두드렸다 — 매번 실패하는 왕복이 영구히 반복됐다.
///
/// 반대로 `/auth/login` 의 401 은 "비밀번호가 틀렸다" 지 "세션이 죽었다" 가 아니다.
/// 여기서 토큰을 지우고 리다이렉트하면 입력하던 폼과 에러 메시지가 함께 사라진다.
///
/// 즉 기준은 경로 접두사가 아니라 **401 의 의미**다: 자격 증명을 보내는 요청이면
/// 자격 증명 오류, 세션을 들고 보내는 요청이면 세션 사망. 이 테스트가 그 경계를 고정한다.
const _user = AuthUser(userId: 1, email: 'a@b.c', nickname: 'n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = TokenStorage();

  /// 실제 배선(AuthInterceptor + UnauthorizedInterceptor)을 그대로 태우고
  /// HTTP 만 401 로 막는다. 인터셉터를 직접 만들면 배선이 바뀌어도 통과한다.
  Dio unauthorizedDio(void Function() onUnauthorized) =>
      DioClient(tokenStorage: storage, onUnauthorized: onUnauthorized).dio
        ..httpClientAdapter = _Unauthorized();

  /// 요청 하나를 401 로 흘리고, 토큰이 남았는지와 신호가 떴는지를 돌려준다.
  Future<({String? token, bool signalled})> fire(
    Future<void> Function(Dio dio) request,
  ) async {
    FlutterSecureStorage.setMockInitialValues(
        <String, String>{'access_token': 'expired-jwt'});

    var signalled = false;
    final dio = unauthorizedDio(() => signalled = true);

    await expectLater(
      request(dio),
      throwsA(isA<DioException>().having(
          (error) => error.response?.statusCode, 'statusCode', 401)),
    );

    return (token: await storage.read(), signalled: signalled);
  }

  group('세션을 들고 보내는 요청의 401 — 토큰을 지운다', () {
    test('GET /auth/me', () async {
      final result = await fire((dio) => dio.get<dynamic>('/auth/me'));

      expect(result.token, isNull);
      expect(result.signalled, isTrue);
    });

    test('PATCH /auth/me — 프로필 저장도 같은 경로다', () async {
      final result = await fire(
          (dio) => dio.patch<dynamic>('/auth/me', data: <String, dynamic>{}));

      expect(result.token, isNull);
      expect(result.signalled, isTrue);
    });

    test('자격 증명 경로를 이름에 품은 세션 요청도 지운다', () async {
      // `contains` 로 보면 `/auth/login` 에 걸려 조용히 빠져나간다.
      // 그러면 이 파일이 막은 누수가 이름만 다른 엔드포인트로 그대로 다시 열린다.
      final result = await fire((dio) => dio.get<dynamic>('/auth/login-history'));

      expect(result.token, isNull);
      expect(result.signalled, isTrue);
    });

    test('baseUrl 이 앞에 붙어도 자격 증명 요청은 그대로 제외된다', () async {
      final result =
          await fire((dio) => dio.post<dynamic>('/api/v1/auth/login'));

      expect(result.token, 'expired-jwt');
      expect(result.signalled, isFalse);
    });

    test('일반 API 도 그대로다', () async {
      final result = await fire((dio) => dio.get<dynamic>('/skin/analyses'));

      expect(result.token, isNull);
      expect(result.signalled, isTrue);
    });
  });

  group('자격 증명을 보내는 요청의 401 — 토큰을 건드리지 않는다', () {
    test('POST /auth/login — 비밀번호 오답도 401 이다', () async {
      final result = await fire((dio) => dio.post<dynamic>('/auth/login'));

      expect(result.token, 'expired-jwt');
      expect(result.signalled, isFalse);
    });

    test('POST /auth/signup', () async {
      final result = await fire((dio) => dio.post<dynamic>('/auth/signup'));

      expect(result.token, 'expired-jwt');
      expect(result.signalled, isFalse);
    });

    test('POST /auth/test-login — 시연용 슬롯도 자격 증명 요청이다', () async {
      final result = await fire((dio) => dio.post<dynamic>('/auth/test-login'));

      expect(result.token, 'expired-jwt');
      expect(result.signalled, isFalse);
    });
  });

  group('만료 토큰 콜드 스타트', () {
    /// 저장소부터 인터셉터까지 실제 배선을 태운다. 레포지토리를 스텁으로 바꾸면
    /// 인터셉터를 건너뛰어, 정작 고친 곳을 지나지 않는 테스트가 된다.
    ProviderContainer coldStart({required Duration hold}) {
      FlutterSecureStorage.setMockInitialValues(
          <String, String>{'access_token': 'expired-jwt'});

      final made = ProviderContainer(overrides: [
        splashMinimumHoldProvider.overrideWithValue(hold),
        dioProvider.overrideWith((ref) => unauthorizedDio(
            () => ref.read(unauthorizedSignalProvider.notifier).fire())),
      ]);
      addTearDown(made.dispose);
      made.listen(authNotifierProvider, (_, __) {});
      return made;
    }

    Future<void> settled(ProviderContainer made) async {
      for (var i = 0; i < 300; i++) {
        if (made.read(authNotifierProvider) is! AuthInitial) return;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    test('다음 실행에 쓸 만료 토큰이 남지 않는다', () async {
      final made = coldStart(hold: Duration.zero);

      await settled(made);

      final state = made.read(authNotifierProvider);
      expect(state, isA<Unauthenticated>());
      expect(
        await storage.read(),
        isNull,
        reason: '남으면 다음 콜드 스타트가 같은 만료 토큰으로 /auth/me 를 다시 부른다',
      );
      expect(
        (state as Unauthenticated).expired,
        isTrue,
        reason: '만료를 버리면 사용자가 설명 없는 빈 로그인 폼 앞에 떨어진다',
      );
    });

    test('#63 스플래시 최소 노출은 401 이 먼저 와도 줄지 않는다', () async {
      const hold = Duration(milliseconds: 400);
      final elapsed = Stopwatch()..start();
      final made = coldStart(hold: hold);

      await settled(made);
      elapsed.stop();

      // **시각을 찍어 보지 않고 걸린 시간을 잰다.** 특정 시점에 AuthInitial 인지
      // 확인하는 식이면, 테스트를 몰아 돌릴 때 그 확인이 노출 시간을 넘겨 깨어나
      // 코드와 무관하게 빨간불이 뜬다. 늦게 깨어나도 "언제 바뀌었나" 는 안 변한다.
      //
      // 401 은 스텁이라 즉시 온다. 그 401 이 상태를 앞질러 쓰면 전환이 곧바로
      // 일어나 라우터가 스플래시를 일찍 떠난다.
      expect(
        elapsed.elapsed,
        greaterThanOrEqualTo(hold),
        reason: '401 이 먼저 와도 최소 노출을 채운 뒤에 전환한다',
      );
      expect(made.read(authNotifierProvider), isA<Unauthenticated>());
    });

    test('세션이 살아 있을 때 온 PATCH /auth/me 401 은 만료로 밀어낸다', () async {
      final made = coldStart(hold: Duration.zero);
      await settled(made);

      // 복원 중 가드가 넓어지면(예: `state is! Authenticated`) 로그인한 사용자의
      // 프로필 저장이 만료돼도 화면이 그대로 남는다. 그 경계를 여기서 잡는다.
      made.read(authNotifierProvider.notifier).state =
          const Authenticated(_user);
      await expectLater(
        made.read(dioProvider).patch<dynamic>('/auth/me'),
        throwsA(isA<DioException>()),
      );

      final state = made.read(authNotifierProvider);
      expect(state, isA<Unauthenticated>());
      expect((state as Unauthenticated).expired, isTrue);
    });
  });
}

/// 네트워크를 타지 않고 401 만 돌려준다.
class _Unauthorized implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
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
