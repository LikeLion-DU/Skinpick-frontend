import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme/app_theme.dart';
import 'core/config/env.dart';

void main() {
  runApp(const ProviderScope(child: SkinPlateApp()));
}

class SkinPlateApp extends StatelessWidget {
  const SkinPlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Plate',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      // Day 3에 go_router + AuthNotifier 로 교체한다 (PRD §10.5).
      home: const _BootCheckPage(),
    );
  }
}

/// Day 2 게이트 확인용 임시 화면 — "앱이 뜬다" 와 주입된 설정을 눈으로 본다.
class _BootCheckPage extends StatelessWidget {
  const _BootCheckPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skin Plate', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('API  ${Env.apiBaseUrl}'),
            const Text('MOCK ${Env.mockMode}'),
          ],
        ),
      ),
    );
  }
}
