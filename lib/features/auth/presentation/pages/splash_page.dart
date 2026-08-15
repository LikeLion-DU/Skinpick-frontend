import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

/// S00 — 저장된 토큰을 확인하는 동안만 떠 있다.
/// 화면 전환은 이 페이지가 하지 않는다. AuthState 가 바뀌면 라우터가 옮긴다.
///
/// 시안은 흰 배경 가운데에 로고 하나다. 스피너를 그리지 않는다 — 토큰 확인은
/// 수백 ms 라 스피너가 오히려 "뭔가 오래 걸린다"는 인상만 남긴다.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        // 로고는 검정+오렌지 2색이다. srcIn 필터를 씌우면 오렌지 포인트까지
        // 단색이 되므로 SVG 원본 색을 그대로 쓴다.
        child: SvgPicture.asset(
          'assets/icons/logo_skinpick.svg',
          width: 247,
        ),
      ),
    );
  }
}
