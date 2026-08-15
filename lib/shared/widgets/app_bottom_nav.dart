import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

/// 어느 탭에 있는지. 알약 배경이 어디로 갈지를 이 값이 정한다.
enum AppTab { home, records }

/// 시안의 하단 네비. 떠 있는 흰 알약 위에 촬영 버튼이 걸쳐 있다.
///
/// 촬영 버튼이 막대 위로 19 만큼 솟아 있어서 `BottomNavigationBar` 로는 만들 수
/// 없다. 넘치는 부분이 잘리기 때문이다. 그래서 Stack 에 직접 얹고,
/// `clipBehavior: none` 으로 벗어난 영역을 살린다.
///
/// 수치는 시안 프레임(402×874)에서 읽은 값이다. 화면 폭이 402 가 아닐 때를
/// 대비해 좌우는 여백으로, 가운데 버튼은 중앙 정렬로 잡았다 — 402 기준의
/// 절대 좌표를 그대로 쓰면 좁은 기기에서 아이콘이 겹친다.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.onCapture,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onCapture;

  /// 막대 높이. 솟은 버튼까지 합친 전체 높이는 아래 [totalHeight] 다.
  static const _barHeight = 62.0;

  static const _fabSize = 72.0;

  /// 버튼이 막대 위로 솟은 만큼. 시안에서 막대는 788, 버튼은 769 에 있다.
  static const _fabOverhang = 19.0;

  /// 화면 아래 여백. 시안 프레임 874 에서 막대 아래로 24 가 남는다.
  static const _bottomInset = 24.0;

  /// 이 위젯이 화면 아래에서 차지하는 높이. 스크롤 뷰가 마지막 항목을
  /// 이만큼 띄워야 버튼에 가려지지 않는다.
  static const totalHeight = _barHeight + _fabOverhang + _bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, _bottomInset),
      child: SizedBox(
        height: _barHeight + _fabOverhang,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: _barHeight,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000), // rgba(0,0,0,0.1)
                    blurRadius: 29.9,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Tab(
                      asset: 'assets/icons/nav_home.svg',
                      size: 38,
                      selected: current == AppTab.home,
                      onTap: () => onTabSelected(AppTab.home),
                    ),
                  ),
                  // 가운데는 촬영 버튼 자리다. 비워 두지 않으면 아이콘이 버튼 밑에 깔린다.
                  const SizedBox(width: _fabSize),
                  Expanded(
                    child: _Tab(
                      asset: 'assets/icons/nav_records.svg',
                      size: 32,
                      selected: current == AppTab.records,
                      onTap: () => onTabSelected(AppTab.records),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: _barHeight - _fabSize + _fabOverhang,
              child: _CaptureButton(onTap: onCapture),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.asset,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // 아이콘만 탭 대상이면 손가락이 자주 빗나간다. 투명 영역까지 받는다.
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          height: 53,
          width: 95,
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: size,
              height: size,
              // 파일에 박힌 색을 그대로 두면 선택 상태를 표현할 수 없다.
              colorFilter: ColorFilter.mode(
                selected ? AppColors.primary : AppColors.disabled,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 주 동작. 이 화면에서 색이 가장 강한 요소이고, 그건 의도다.
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppBottomNav._fabSize,
        height: AppBottomNav._fabSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.fabGradientTop, AppColors.fabGradientBottom],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/nav_camera.svg',
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }
}
