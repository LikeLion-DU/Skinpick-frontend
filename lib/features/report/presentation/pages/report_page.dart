import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/kst_date.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/top_wash.dart';
import '../widgets/daily_report_view.dart';
import '../widgets/weekly_report_view.dart';

/// 리포트 탭. 하단 네비의 오른쪽 자리가 여기로 온다.
///
/// **탭을 목록으로 둔다.** 월간을 붙일 때 [ReportTab] 에 한 줄과 화면 하나를
/// 더하면 끝나도록 — 탭 개수를 코드 곳곳에 박으면 그때 세 군데를 고쳐야 한다.
/// 서버도 같은 엔드포인트 하나로 월간을 낸다(기간만 넓히면 된다).
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

enum ReportTab {
  daily('오늘의 리포트'),
  weekly('주간 리포트');

  const ReportTab(this.label);

  final String label;
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  /// 화면을 여는 순간의 KST 오늘. **build 마다 다시 세지 않는다** —
  /// `todayKst()` 를 build 에서 부르면 매번 새 DateTime 이 나와 프로바이더
  /// family 키가 달라지고, 그때마다 조회가 다시 나간다.
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = todayKst();
    // 초기 선택은 오늘의 리포트다.
    _controller = TabController(length: ReportTab.values.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 를 두지 않는다. 시안은 이 화면의 맨 위를 오렌지 물 + 탭 알약으로
      // 채우는데, AppBar 를 두면 그 위에 흰 띠가 하나 더 얹혀 물이 잘린다.
      // 리포트는 하단 네비의 탭이라 뒤로가기 버튼도 필요 없다.
      body: Stack(
        children: [
          const TopWash(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TabSelector(controller: _controller),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      for (final tab in ReportTab.values)
                        switch (tab) {
                          ReportTab.daily => DailyReportView(date: _today),
                          ReportTab.weekly => const WeeklyReportView(),
                        },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.report,
        onCapture: () => context.push(Routes.foodCapture),
        onTabSelected: (tab) {
          // 홈에서 push 로 들어오면 pop 이 맞다. 저장 직후처럼 go 로 와서
          // 이 화면이 스택의 유일한 페이지일 때 pop 하면 go_router 가
          // "There is nothing to pop" 을 던지고 나갈 문이 사라진다.
          if (tab == AppTab.home) {
            context.canPop() ? context.pop() : context.go(Routes.home);
          }
        },
      ),
    );
  }
}

/// 시안의 탭 선택기. Material 기본 밑줄 인디케이터는 이 앱 어디에도 없어서
/// 혼자 튄다.
///
/// 확정 시안이 알약(radius 100)을 **모난 사각(radius 10)** 으로 바꾸고 트랙을
/// 크림에서 회색(#F3F3F3)으로 내렸다. 오렌지 물 위에 크림 트랙을 두면 배경과
/// 같은 계열이라 트랙이 안 보이고, 선택된 흰 칸만 떠 있는 것으로 읽힌다.
class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 8, 21, 4),
      // 탭 라벨이 잘린 원인은 높이가 아니라 **폭**이었다. 402 폭을 반으로 나눈
      // 칸에 16px 라벨을 2.0 으로 키우면 224 를 요구하는데 칸은 143 이고, Tab 은
      // overflow: fade 라 예외 없이 "오늘의 리…" 로 페이드된다. 높이를 풀었더니
      // 기본 크기에서 시안 44 가 58 로 커지기만 했다(Tab 의 기본 높이는 46 이다).
      //
      // 그래서 높이는 시안대로 두고 배율만 1.2 까지 따라간다 — 글자는 커지고
      // 두 탭은 계속 구별된다.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.2,
        child: Container(
        height: 44,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 6.7),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFFC5C5C5),
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          splashBorderRadius: BorderRadius.circular(10),
          tabs: [
            // 배율 상한(1.2)만으로는 320dp 기기에서 라벨이 여전히 페이드로
            // 잘린다(가용폭 102 < 필요 120). 링과 같은 백스톱을 둔다 — 들어갈
            // 만큼만 줄이고, 잘리지는 않는다.
            for (final tab in ReportTab.values)
              Tab(
                height: 34,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(tab.label),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
