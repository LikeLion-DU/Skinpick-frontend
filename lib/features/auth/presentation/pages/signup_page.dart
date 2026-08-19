import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/auth_notifier.dart';

/// S01b — 회원가입.
///
/// 필수 입력은 4개를 넘지 않는다. 성별·나이는 받지 않는다 — 피부 사진이 대신한다.
/// 이메일·비밀번호·닉네임 형식 검증은 서버가 하고 한국어 문구까지 만들어 준다.
/// 여기서 다시 만들면 규칙이 두 곳에 생겨 언젠가 어긋난다. (PRD §6 · §14.3 ①)
///
/// **시안에 이 화면이 없다.** 확정 시안은 로그인까지만 그렸다. 그래서 배치를
/// 지어내지 않고 **형제 화면인 로그인의 규약을 그대로 따른다** — 같은 여백
/// (`pagePadding`), 같은 입력창(테마), 같은 버튼(높이 50 · 곡률 14).
/// 예전에는 이 화면만 `EdgeInsets.all(24)` · `labelText` · `FilledButton` 을 써서,
/// 로그인에서 넘어오는 순간 여백과 버튼 모양이 바뀌었다.
///
/// 입력창 위에 작은 이름표를 둔다. 로그인은 두 칸이라 힌트만으로 충분하지만,
/// 여기는 네 칸이고 그중 둘이 비밀번호라 값을 채운 뒤에는 어느 칸이 '확인'
/// 이었는지 구분할 방법이 사라진다.
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

    // 가입 직후에는 기준값이 될 피부 분석이 없다. 설문(S01c)보다 촬영이
    // 먼저다 — 자가 신고 타입은 결과 화면의 갭 카드에만 쓰이므로, 진단을 보여준
    // 뒤에 물어야 "AI 진단이 정확하지 않을 수 있다"는 부탁에 근거가 생긴다.
    context.go(Routes.onboardingCapture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              label: '이메일',
              child: TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(hintText: '이메일 입력'),
              ),
            ),
            _Field(
              label: '비밀번호',
              hint: '영문과 숫자를 포함해 8자 이상',
              child: TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 입력'),
              ),
            ),
            _Field(
              label: '비밀번호 확인',
              child: TextField(
                controller: _passwordConfirm,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 다시 입력'),
              ),
            ),
            _Field(
              label: '닉네임',
              hint: '2자 이상 10자 이하',
              child: TextField(
                controller: _nickname,
                decoration: const InputDecoration(hintText: '닉네임 입력'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!,
                  style: const TextStyle(color: AppColors.bad, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: _busy ? null : _submit,
                child: const Text('가입하고 시작하기'),
              ),
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

/// 이름표 + 입력창 + (선택) 형식 안내 한 줄.
///
/// 형식 안내는 **서버가 거절할 조건을 미리 알려 주는 것**이지 앱이 검사하는
/// 규칙이 아니다. 검증은 서버가 하고 실패 문구도 서버가 만든다 — 여기서
/// 정규식을 두면 같은 규칙이 두 곳에 생긴다.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.21,
              color: AppColors.grayBaseDarkest,
            ),
          ),
          const SizedBox(height: 7),
          child,
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              style: const TextStyle(fontSize: 11, color: AppColors.grayBase),
            ),
          ],
        ],
      ),
    );
  }
}
