import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

/// 어느 탭에 있는지. 알약 배경이 어디로 갈지를 이 값이 정한다.
///
/// 오른쪽 자리는 기록이 아니라 **리포트**다. 기록은 사라지지 않았고 홈의
/// "오늘의 기록" 카드에서 들어간다 — 하루에 한 번 보는 화면(기록)보다
/// 매일 보는 화면(리포트)이 탭 자리를 갖는 편이 맞다.
///
/// 아이콘은 그대로 `nav_records.svg` 를 쓴다. 목록 모양이라 리포트에도 맞고,
/// 아이콘만 바꾸면 사용자가 그 자리를 새 기능으로 읽는다.
enum AppTab { home, report }

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
                // 흰색이 아니라 반투명 살구색이다. 확정 시안이 색을 바꿨다 —
                // 홈 배경이 아래로 흰색까지 풀리기 때문에, 흰 알약은 그 위에서
                // 윤곽이 사라지고 막대가 어디서 시작하는지 보이지 않는다.
                //
                // 알파는 시안 렌더에서 역산한 값이다(0xA3 ≈ 0.64). 원본 SVG 의
                // 그룹 불투명도는 0.4 인데, 시안이 같은 그룹을 두 겹으로
                // 깔아 둔 프레임(기록·리포트·홈 첫 화면)이 실제로는 0.64 로
                // 보인다. 미선택 아이콘이 흰색이라 **더 진한 쪽을 택했다** —
                // 0.4 로 깔면 흰 아이콘이 배경과 구분되지 않는다.
                color: const Color(0xA3FFAF89),
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
                      selected: current == AppTab.report,
                      onTap: () => onTabSelected(AppTab.report),
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
              // 미선택은 회색이 아니라 흰색이다. 알약이 살구색으로 바뀌면서
              // 회색 아이콘이 배경보다 어두워져 오히려 눈에 먼저 걸렸다 —
              // 선택된 자리보다 미선택이 진하면 어디에 있는지 헷갈린다.
              colorFilter: ColorFilter.mode(
                selected ? AppColors.primary : Colors.white,
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
            // 시안이 그라디언트를 바꿨다. 옛 값(#FF5404 → #FFD240)은 아래가
            // 노랑이라 살구색 알약 위에서 버튼이 떠 보이지 않았다. 확정 시안은
            // 위가 진하고 아래가 밝은 오렌지 한 계열이다.
            colors: [AppColors.accentStrong, AppColors.primary],
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
