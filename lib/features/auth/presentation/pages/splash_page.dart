import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// S00 — 저장된 토큰을 확인하는 동안 떠 있고, **최소 3초는 채운다**
/// (auth_notifier 의 splashMinimumHoldProvider). 토큰 확인은 수백 ms 라
/// 브랜드 화면이 깜빡이고 사라지는 걸 막는 값이다.
/// 화면 전환은 이 페이지가 하지 않는다. AuthState 가 바뀌면 라우터가 옮긴다 —
/// 그래서 노출 시간도 이 파일이 아니라 상태 쪽에 있다.
///
/// 확정 시안이 흰 배경을 **오렌지 그라디언트 한 판**으로 바꾸고 로고를 흰색으로
/// 뒤집었다. 앱을 켠 첫 화면이 브랜드 색으로 꽉 차면, 뒤이어 오렌지 히어로가
/// 깔린 홈으로 이어질 때 화면이 갈리지 않는다.
///
/// 스피너를 그리지 않는다 — 토큰 확인은 수백 ms 라 스피너가 오히려 "뭔가 오래
/// 걸린다"는 인상만 남긴다.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      // 대각선 그라디언트다. 위아래로만 흘리면 시안의 왼쪽 위가 밝고 오른쪽
      // 아래가 진한 결이 나오지 않는다. 값은 시안 렌더에서 읽었다.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFAD87), Color(0xFFFF5101)],
        ),
      ),
      child: Center(child: _Wordmark()),
    );
  }
}

/// 오렌지 판 위의 로고는 **두 색**이다 — 글자는 흰색, P 만 검정(시안 360-911).
/// 통째로 흰색을 입히면 P 의 개성이 사라져 그냥 흰 글자가 된다.
///
/// `logo_skinpick_splash.svg` 는 본 로고(검정 글자+흰 P)의 색만 맞바꾼 사본이다.
///
/// **마크 파일이 셋이다.** 흰 배경용(검정+오렌지)은 `login_logo.svg`(로그인),
/// 검정+흰은 `logo_skinpick.svg` 다. 마크가 바뀌는 날 셋을 같이 갈아야 한다.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo_skinpick_splash.svg',
      width: 247,
    );
  }
}
