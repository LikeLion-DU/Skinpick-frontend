import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/router/app_router.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 라우터는 AuthState 의 **종류**가 바뀔 때만 흔들려야 한다.
///
/// 값이 바뀔 때마다 알리면 go_router 가 라우트를 다시 세우고, 그 순간 열려 있던
/// 화면이 통째로 새로 만들어진다. 프로필 설문에서 저장을 누르면 서버에는 잘 들어가는데
/// 화면이 닫히지 않고 설문이 처음부터 다시 뜨던 것이 이 경로였다 — 화면이 헐리면서
/// 뒤이어 실행될 "닫고 돌아가기"가 영영 실행되지 않았다.
void main() {
  const user = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
    declaredSkinType: SkinType.oily,
  );

  /// 프로필만 바뀐 같은 종류의 상태.
  const updated = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
    declaredSkinType: SkinType.oily,
    skinConcerns: {SkinConcern.acne},
    sleepPattern: SleepPattern.lacking,
  );

  testWidgets('프로필만 바뀌면 라우터를 흔들지 않는다', (tester) async {
    final container = ProviderContainer(overrides: [
      // 스플래시 최소 노출(3초) 타이머가 테스트 종료 후까지 살아 !timersPending 에 걸린다.
      splashMinimumHoldProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    var rebuilds = 0;
    router.routerDelegate.addListener(() => rebuilds++);

    final notifier = container.read(authNotifierProvider.notifier);
    notifier.state = const Authenticated(user);
    await tester.pump();
    final afterLogin = rebuilds;

    // 저장 직후와 같은 전이다 — 같은 Authenticated 안에서 값만 달라진다.
    notifier.state = const Authenticated(updated);
    await tester.pump();

    expect(rebuilds, afterLogin,
        reason: '프로필 저장이 라우트를 다시 세우면 열려 있던 화면이 헐린다');
  });

  testWidgets('로그아웃은 여전히 로그인 화면으로 밀어낸다', (tester) async {
    // 알림 횟수가 아니라 실제 결과를 본다 — 흔들지 않게 만든 김에 흔들려야 할 때까지
    // 조용해지면, 로그아웃한 사용자가 홈에 남는다.
    final container = ProviderContainer(overrides: [
      // 스플래시 최소 노출(3초) 타이머가 테스트 종료 후까지 살아 !timersPending 에 걸린다.
      splashMinimumHoldProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    final notifier = container.read(authNotifierProvider.notifier);

    notifier.state = const Authenticated(user);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    router.go(Routes.home);
    // **pumpAndSettle 을 쓰지 않는다.** 이 테스트는 저장소를 스텁하지 않아서 홈의
    // 히스토리 조회가 끝나지 않고, 그동안 기록 카드가 스피너를 돌린다 — 애니메이션이
    // 멈추지 않으니 settle 이 영원히 안 온다. 라우팅만 보는 테스트라 프레임 몇 장이면
    // 충분하다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(router.routerDelegate.currentConfiguration.uri.path, Routes.home);

    notifier.state = const Unauthenticated();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(router.routerDelegate.currentConfiguration.uri.path, Routes.login);
  });
}
