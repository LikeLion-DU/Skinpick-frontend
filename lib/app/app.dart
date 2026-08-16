import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SkinPlateApp extends ConsumerWidget {
  const SkinPlateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // 앱 이름. Android 최근 앱 목록에 이 값이 뜬다 — 홈 화면 이름(매니페스트
      // android:label · iOS CFBundleDisplayName)과 어긋나면 같은 앱이 두 이름으로
      // 보인다.
      title: 'Skinpick',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),

      /// 화면은 모바일 폭 기준으로 짜여 있다. 데스크톱 브라우저에서 그대로 늘리면
      /// 카드 하나가 화면을 가로지른다. 폭만 잡아 주면 모바일 프레임처럼 보인다.
      /// (PRD §19.2 Day 7 · FE-B)
      builder: (context, child) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
    );
  }
}
