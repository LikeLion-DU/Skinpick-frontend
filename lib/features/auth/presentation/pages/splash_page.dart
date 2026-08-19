import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// S00 — 저장된 토큰을 확인하는 동안만 떠 있다.
/// 화면 전환은 이 페이지가 하지 않는다. AuthState 가 바뀌면 라우터가 옮긴다.
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

/// 오렌지 판 위에서는 로고가 흰색 한 벌이다.
///
/// 원본 SVG 는 검정+오렌지 2색인데, 여기서는 `srcIn` 으로 통째로 흰색을 입힌다 —
/// 흰 배경용 2색 로고를 오렌지 위에 그대로 올리면 검정 글자가 배경과 부딪히고
/// 오렌지 포인트는 아예 사라진다. 흰 로고 파일을 따로 두지 않는 이유이기도 하다:
/// 파일이 둘이면 마크가 바뀔 때 한쪽만 갈린다.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo_skinpick.svg',
      width: 247,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}
