import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

/// 시안의 마스코트. 홈·마이페이지·피부 결과·온보딩이 같은 그림을 쓴다.
///
/// 원본 SVG 를 그대로 넣는다. 손으로 다시 그리면 눈·볼점의 위치가 미묘하게
/// 달라지고, 화면마다 다른 얼굴이 된다 — 브랜드 마크는 옮기는 것이지
/// 개선하는 것이 아니다.
class SkinMascot extends StatelessWidget {
  const SkinMascot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/mascot.svg',
      width: size,
      height: size,
    );
  }
}

/// 마스코트 뒤에 깔리는 흐린 후광 한 장.
///
/// 원본은 `feGaussianBlur` 가 걸린 SVG 인데 `flutter_svg` 는 그 필터를 그리지
/// 않는다 — 그대로 넣으면 후광이 **경계가 뚜렷한 살구색 원**으로 나와 마스코트를
/// 가린다. 그래서 원만 코드로 그리고 흐림은 Flutter 가 건다. 시안의
/// `stdDeviation` 6.4 를 그대로 sigma 로 쓴다.
class MascotGlow extends StatelessWidget {
  const MascotGlow({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 6.4, sigmaY: 6.4),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.mascotGlow,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 히어로에 흩어진 장식 방울. 크기만 다르고 색은 하나다.
class MascotBubble extends StatelessWidget {
  const MascotBubble({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.bubble,
        shape: BoxShape.circle,
      ),
    );
  }
}
