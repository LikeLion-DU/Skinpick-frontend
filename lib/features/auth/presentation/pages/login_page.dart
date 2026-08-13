import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/error/failure.dart';
import '../providers/auth_notifier.dart';

/// S01 — 로그인.
///
/// 로그인이 성공하면 이 화면이 이동시키지 않는다. AuthState 가 Authenticated 로
/// 바뀌면 라우터가 홈으로 옮긴다. 화면마다 이동을 직접 쓰면 언젠가 한 곳이 어긋난다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// 슬롯 1은 발표 시연 전용이다. 팀 테스트는 2·3 으로 해서 기록을 섞지 않는다.
  int _slot = 1;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// 실패 문구는 서버가 만들어 준 한국어를 그대로 쓴다.
  /// 앱이 다시 지으면 "비밀번호는 영문과 숫자를 포함해…" 같은 검증 규칙이 두 곳에 생긴다.
  Future<void> _run(Future<Failure?> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    final failure = await action();

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failure?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expired = switch (ref.watch(authNotifierProvider)) {
      Unauthenticated(:final expired) => expired,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (expired)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('로그인이 만료되었습니다. 다시 로그인해 주세요.'),
              ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(() => ref.read(authNotifierProvider.notifier).login(
                        email: _email.text.trim(),
                        password: _password.text,
                      )),
              child: const Text('로그인'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : () => context.push(Routes.signup),
              child: const Text('회원가입'),
            ),
            const Divider(height: 40),

            // 심사위원이 무대에서 이메일을 타이핑하는 20초를 없애는 버튼이다.
            // 오타 한 번이면 흐름이 끊긴다. (PRD §4.4.2)
            const Text('시연 · 테스트용', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('슬롯 1')),
                ButtonSegment(value: 2, label: Text('슬롯 2')),
                ButtonSegment(value: 3, label: Text('슬롯 3')),
              ],
              selected: {_slot},
              onSelectionChanged: (selected) => setState(() => _slot = selected.first),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() => ref
                      .read(authNotifierProvider.notifier)
                      .loginWithTestAccount(slot: _slot)),
              child: const Text('테스트 계정으로 시작하기'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
