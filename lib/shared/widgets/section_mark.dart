import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 구역 제목 앞에 붙는 잎사귀 마크. 겹친 원 두 개다.
///
/// 시안은 이걸 SVG 두 장으로 내보내는데(10px `#FF7D40` + 13px `#FF4D00`),
/// 원 두 개를 파일로 들고 다닐 이유가 없다. 좌표만 옮긴다.
class LeafMark extends StatelessWidget {
  const LeafMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 17,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _Dot(size: 10, color: AppColors.primary)),
          Positioned(left: 3, top: 4, child: _Dot(size: 13, color: AppColors.accentStrong)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 리포트 구역 제목 앞에 붙는 세로 막대.
///
/// 잎사귀와 나눠 둔 것은 시안이 그렇게 쓰기 때문이다 — 리포트는 표가 많아
/// 둥근 마크가 숫자 사이에서 얼룩처럼 보인다.
class BarMark extends StatelessWidget {
  const BarMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.accentStrong,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
