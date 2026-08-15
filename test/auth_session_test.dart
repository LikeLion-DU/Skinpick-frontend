import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:skinplate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';

/// 로그인 세션에 프로필이 실리는지 본다.
///
/// 서버 `AuthResponse` 는 id·이메일·닉네임뿐이고 고민·습관은 `/auth/me` 에만 있다.
/// Repository 가 둘을 합치지 않으면 로그인으로 시작한 세션은 앱을 껐다 켜기 전까지
/// "프로필이 빈 사용자"로 남는다. 그 상태로 설문에 들어가면 빈 화면이 뜨고,
/// 거기서 제출하면 서버가 고민 컬렉션을 갈아 끼워 이전 고민이 영구히 사라진다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues(<String, String>{}));

  Map<String, dynamic> fixture(String name) =>
      jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>;

  AuthRepositoryImpl repository(_RouteAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter;
    return AuthRepositoryImpl(
        AuthRemoteDataSource(dio), const TokenStorage());
  }

  test('로그인 세션이 /auth/me 의 고민·습관을 함께 싣는다', () async {
    final adapter = _RouteAdapter({
      '/auth/login': fixture('auth_login'),
      '/auth/me': fixture('auth_me'),
    });

    final result = await repository(adapter).login(
      email: 'test@skinplate.app',
      password: 'test1234!',
    );

    final user = result.dataOrNull!.user;
    expect(user.skinConcerns, {SkinConcern.acne, SkinConcern.sebumOil});
    expect(user.sleepPattern, SleepPattern.lacking);
    expect(user.waterIntake, WaterIntake.lacking);
    expect(user.declaredSkinType, isNotNull);

    // /auth/me 를 실제로 태웠는지. 로그인 응답만 읽으면 위 단언이 통과할 수 없다.
    expect(adapter.visited, containsAll(<String>['/auth/login', '/auth/me']));
  });

  test('테스트 계정 로그인도 같은 경로를 탄다 — 시연 계정의 시드 프로필이 살아 있어야 한다', () async {
    final adapter = _RouteAdapter({
      '/auth/test-login': fixture('auth_login'),
      '/auth/me': fixture('auth_me'),
    });

    final result = await repository(adapter).loginWithTestAccount();

    expect(result.dataOrNull!.user.skinConcerns, isNotEmpty);
  });

  test('프로필이 빈 계정도 정상 세션이다 — 키가 없는 응답에서 죽지 않는다', () async {
    final adapter = _RouteAdapter({
      '/auth/login': fixture('auth_login'),
      '/auth/me': fixture('auth_me_no_profile'),
    });

    final result = await repository(adapter).login(
      email: 'fresh@skinplate.app',
      password: 'test1234!',
    );

    final AuthUser user = result.dataOrNull!.user;
    expect(user.skinConcerns, isEmpty);
    expect(user.hasIncompleteLifestyle, isTrue);
  });
}

/// 경로별로 다른 픽스처를 돌려준다.
class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter(this.responses);

  final Map<String, Map<String, dynamic>> responses;
  final List<String> visited = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    visited.add(options.path);
    final body = responses[options.path];
    if (body == null) {
      throw StateError('픽스처가 없는 경로: ${options.path}');
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
