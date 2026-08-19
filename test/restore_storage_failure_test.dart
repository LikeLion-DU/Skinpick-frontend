import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/storage/token_storage.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';

/// 보안 저장소 읽기가 던져도 스플래시에 갇히지 않는다.
///
/// `restore()` 가 예외로 빠져나가면 `state` 를 영영 못 쓴다. 라우터는 `AuthInitial`
/// 을 스플래시로 고정하므로 사용자는 오렌지 화면에 갇히고, 재설치 말고는 빠져나갈
/// 길이 없다. 스피너도 에러도 재시도 버튼도 없다.
///
/// 하필 눈에도 안 띈다 — `restore` 는 관측되지 않는 마이크로태스크로 시작해서
/// 예외가 로그에도 안 남고, 최소 노출 3초(#63)가 정상 동작이라 멈춘 화면과
/// 기다리는 화면이 똑같이 보인다.
///
/// 재현 조건은 기기 쪽이라 흔하지는 않다. 안드로이드 키스토어가 리셋되면
/// (기기 초기화·백업 복원·일부 OEM 업데이트) 암호화된 값을 못 풀어
/// `PlatformException` 이 오고, iOS 도 기기 복원 직후 첫 잠금 해제 전에는
/// 키체인이 막힌다. 한 번 걸리면 그 사용자는 영구히 못 들어온다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer withStorage(TokenStorage storage) {
    final made = ProviderContainer(overrides: [
      splashMinimumHoldProvider.overrideWithValue(Duration.zero),
      tokenStorageProvider.overrideWithValue(storage),
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

  test('저장소 읽기가 던지면 로그인으로 보낸다 — 스플래시에 갇히지 않는다', () async {
    final made = withStorage(_ThrowingStorage());

    final state = await settled(made);

    expect(
      state,
      isA<Unauthenticated>(),
      reason: 'AuthInitial 로 남으면 라우터가 스플래시에 고정해 재설치 말고는 길이 없다',
    );
  });

  test('만료 안내는 띄우지 않는다 — 만료가 아니라 읽기 실패다', () async {
    final made = withStorage(_ThrowingStorage());

    final state = await settled(made);

    // 저장소를 못 읽은 것과 토큰이 만료된 것은 다르다. 여기서 만료로 세우면
    // 기기 문제로 밀려난 사용자에게 "로그인이 만료되었습니다" 라고 말하게 된다.
    expect((state as Unauthenticated).expired, isFalse);
  });
}

/// 키스토어가 리셋된 기기. 읽기만 던지고 나머지는 쓰지 않는다.
class _ThrowingStorage extends TokenStorage {
  @override
  Future<String?> read() => throw PlatformException(
        code: 'BadPaddingException',
        message: 'Could not decrypt value',
      );
}
