import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../providers/auth_notifier.dart';

/// S01b — 회원가입.
///
/// 필수 입력은 4개를 넘지 않는다. 성별·나이는 받지 않는다 — 피부 사진이 대신한다.
/// 이메일·비밀번호·닉네임 형식 검증은 서버가 하고 한국어 문구까지 만들어 준다.
/// 여기서 다시 만들면 규칙이 두 곳에 생겨 언젠가 어긋난다. (PRD §6 · §14.3 ①)
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _nickname = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 비밀번호 확인만 앱이 검사한다. 서버는 이 필드를 아예 받지 않기 때문이다.
    if (_password.text != _passwordConfirm.text) {
      setState(() => _error = '비밀번호가 서로 다릅니다.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final failure = await ref.read(authNotifierProvider.notifier).signup(
          email: _email.text.trim(),
          password: _password.text,
          nickname: _nickname.text.trim(),
        );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
      return;
    }

    // 가입 직후에는 피부 타입을 아직 안 골랐다. 홈이 아니라 S01c 로 보낸다.
    context.go(Routes.skinType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                helperText: '영문과 숫자를 포함해 8자 이상',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordConfirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nickname,
              decoration: const InputDecoration(
                labelText: '닉네임',
                helperText: '2자 이상 10자 이하',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: const Text('가입하고 시작하기'),
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
