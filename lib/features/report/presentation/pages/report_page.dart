import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/kst_date.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
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
      appBar: AppBar(title: const Text('리포트')),
      body: SafeArea(
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

/// 시안의 알약 모양을 따른 탭 선택기. Material 기본 밑줄 인디케이터는
/// 이 앱 어디에도 없어서 혼자 튄다.
class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 8, AppTheme.pagePadding, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(100),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 6),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          splashBorderRadius: BorderRadius.circular(100),
          tabs: [
            for (final tab in ReportTab.values) Tab(height: 38, text: tab.label),
          ],
        ),
      ),
    );
  }
}
