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

    // 가입 직후에는 기준값이 될 피부 분석이 없다. 설문(S01c)보다 촬영 안내(S01d)가
    // 먼저다 — 자가 신고 타입은 결과 화면의 갭 카드에만 쓰이므로, 진단을 보여준
    // 뒤에 물어야 "AI 진단이 정확하지 않을 수 있다"는 부탁에 근거가 생긴다.
    context.go(Routes.onboardingCapture);
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
