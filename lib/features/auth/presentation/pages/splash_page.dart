import 'package:flutter/material.dart';

/// S00 — 저장된 토큰을 확인하는 동안만 떠 있다.
/// 화면 전환은 이 페이지가 하지 않는다. AuthState 가 바뀌면 라우터가 옮긴다.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skin Plate', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('오늘의 피부를 위한 오늘의 한 끼'),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
