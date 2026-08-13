import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/unauthorized_signal.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/auth_user.dart';

/// 전역 인증 상태. 라우터가 이 값만 보고 화면을 결정한다. (PRD §10.5)
sealed class AuthState {
  const AuthState();
}

/// 저장된 토큰을 확인하는 중. S00 스플래시가 떠 있다.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AuthUser user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated({this.expired = false});

  /// 토큰이 만료돼 밀려난 경우. 로그인 화면이 안내 문구를 띄운다.
  final bool expired;
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 인터셉터가 이미 토큰을 지웠다. 여기서는 상태만 되돌린다.
    ref.listen(unauthorizedSignalProvider, (_, __) {
      state = const Unauthenticated(expired: true);
    });

    // build 중에 state 를 건드리지 않는다. 복원은 다음 마이크로태스크에서 시작한다.
    Future<void>.microtask(restore);
    return const AuthInitial();
  }

  /// 앱 시작 시 1회. 토큰이 살아 있으면 그대로 홈으로 들어간다.
  Future<void> restore() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      state = const Unauthenticated();
      return;
    }

    final result = await ref.read(authRepositoryProvider).getMe();
    state = result.when(
      success: Authenticated.new,
      // 만료·위조 토큰이면 조용히 로그인으로. 인터셉터가 토큰을 이미 지웠다.
      failure: (_) => const Unauthenticated(),
    );
  }

  /// 성공하면 null. 실패 사유는 화면이 그대로 문구로 쓴다.
  Future<Failure?> login({required String email, required String password}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final result = await ref.read(authRepositoryProvider).signup(
          email: email,
          password: password,
          nickname: nickname,
        );

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  /// 로그인 화면의 "테스트 계정으로 시작하기". 슬롯 1은 발표 시연 전용이다.
  Future<Failure?> loginWithTestAccount({int slot = 1}) async {
    final result =
        await ref.read(authRepositoryProvider).loginWithTestAccount(slot: slot);

    return result.when<Failure?>(
      success: (session) {
        state = Authenticated(session.user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  /// S01c 와 S05 인라인 칩 두 곳에서 부른다.
  /// 건너뛰기는 이 메서드를 호출하지 않는 것이다 — UNKNOWN 을 대신 보내면
  /// "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  Future<Failure?> updateSkinType(SkinType skinType) async {
    final result = await ref.read(authRepositoryProvider).updateSkinType(skinType);

    return result.when<Failure?>(
      success: (user) {
        state = Authenticated(user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const Unauthenticated();
  }
}
