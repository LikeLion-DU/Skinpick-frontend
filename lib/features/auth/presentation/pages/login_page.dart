import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/error/failure.dart';
import '../providers/auth_notifier.dart';

/// S01 — 로그인. 확정 시안 배치다: 로고 · 환영 문구 · 입력 2칸 · 로그인 버튼 ·
/// 찾기/가입 링크 · SNS 줄.
///
/// 로그인이 성공하면 이 화면이 이동시키지 않는다. AuthState 가 Authenticated 로
/// 바뀌면 라우터가 홈으로 옮긴다. 화면마다 이동을 직접 쓰면 언젠가 한 곳이 어긋난다.
///
/// SNS 로그인은 시안에는 있지만 서버 지원이 없다. 눌리면 준비 중이라고
/// 말한다 — 아무 반응이 없는 버튼은 고장으로 읽힌다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

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

  void _notReady() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SNS 로그인은 준비 중이에요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = switch (ref.watch(authNotifierProvider)) {
      Unauthenticated(:final expired) => expired,
      _ => false,
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.pagePadding, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 120),
              Align(
                alignment: Alignment.centerLeft,
                // 로고는 검정+오렌지 2색이라 단색 필터를 씌우지 않는다.
                child: SvgPicture.asset(
                  'assets/icons/logo_skinpick.svg',
                  width: 176,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '스킨픽에 오신 것을 환영합니다!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.21,
                  color: AppColors.grayBaseDarkest,
                ),
              ),
              const SizedBox(height: 28),
              if (expired)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('로그인이 만료되었습니다. 다시 로그인해 주세요.',
                      style: TextStyle(color: AppColors.bad, fontSize: 12)),
                ),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(hintText: '아이디 입력'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 입력'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: AppColors.bad, fontSize: 12)),
              ],
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _busy
                    ? null
                    : () =>
                        _run(() => ref.read(authNotifierProvider.notifier).login(
                              email: _email.text.trim(),
                              password: _password.text,
                            )),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('로그인'),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _link('아이디 찾기', _notReady),
                  _divider(),
                  _link('비밀번호 찾기', _notReady),
                  _divider(),
                  _link('회원가입',
                      _busy ? null : () => context.push(Routes.signup)),
                ],
              ),
              const SizedBox(height: 56),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.grayLight)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('SNS 계정으로 로그인',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.16,
                          color: AppColors.grayBase,
                        )),
                  ),
                  Expanded(child: Divider(color: AppColors.grayLight)),
                ],
              ),
              const SizedBox(height: 26),
              // 다섯 서비스의 원형 아이콘 한 줄. 시안 렌더를 그대로 쓴다 —
              // 브랜드 아이콘을 손으로 다시 그리면 가이드라인 위반이 되기 쉽다.
              GestureDetector(
                onTap: _notReady,
                child: Image.asset('assets/icons/sns_row.png',
                    width: 267, fit: BoxFit.contain),
              ),

              const Divider(height: 48),
              // 심사위원이 무대에서 이메일을 타이핑하는 20초를 없애는 버튼이다.
              // 오타 한 번이면 흐름이 끊긴다. (PRD §4.4.2)
              //
              // 슬롯을 고르고 다시 누르는 2단계였는데 QA 중에 계정을 자주 갈아타므로
              // 한 번 눌러 바로 들어가게 폈다. 슬롯 1은 발표 시연 전용이고
              // 2·3 은 팀 테스트용이다 — 기록을 섞지 않으려고 나눠 둔 것이다.
              const Text('시연 · 테스트용', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final slot in const [1, 2, 3]) ...[
                    Expanded(
                      child: OutlinedButton(
                        // 테마에 outlinedButtonTheme 이 없어 M3 기본값(알약)이 나온다.
                        // 숨겨져 있을 땐 안 보였지만 이제 상시 노출이라, 화면에서 유일하게
                        // 곡률 8을 벗어난 버튼이 로그인 화면 하단에 남는다. 여기서만 맞춘다 —
                        // 테마에 넣으면 촬영 화면의 갤러리 버튼까지 같이 바뀐다.
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: AppColors.borderOnWhite),
                          foregroundColor: AppColors.primary,
                          // 좁은 기기(360dp)에서 라벨이 두 줄로 접히지 않게 좌우를 줄인다.
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: _busy
                            ? null
                            : () => _run(() => ref
                                .read(authNotifierProvider.notifier)
                                .loginWithTestAccount(slot: slot)),
                        child: Text('테스트 $slot'),
                      ),
                    ),
                    if (slot != 3) const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _link(String label, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.16,
                color: AppColors.grayBaseExtraDark,
              )),
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 6,
        color: AppColors.grayLight,
      );
}
