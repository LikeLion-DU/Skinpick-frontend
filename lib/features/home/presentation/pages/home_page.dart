import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';
import '../providers/today_provider.dart';
import '../widgets/daily_score_card.dart';
import '../widgets/today_records_card.dart';

/// S02 — 홈.
///
/// 두 동작은 서로 독립이다. 피부 분석은 **사용자가 하고 싶을 때 아무 때나** 하는
/// 것이고, 음식 촬영은 찍으면 곧바로 상극 분석 결과(S07)로 이어진다.
/// 순서를 강제하는 마법사가 아니다.
///
/// 다만 상극 분석은 비교할 피부 기준이 있어야 성립한다. 그래서 피부 기록이 하나도
/// 없을 때만 촬영 버튼이 안내를 띄운다 — 숨기지는 않는다. 버튼이 사라지면
/// 사용자는 그 기능이 없는 줄 안다.
///
/// 시안에 피부 분석으로 가는 버튼이 따로 없다. 우측 상단 프로필 메뉴 안에
/// "다시 분석"이 들어가 있어 그대로 옮겼다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 피부 기록이 없을 때만 뜬다. 막지 않고 어디로 가면 되는지 알려준다.
  Future<void> _explainSkinFirst(BuildContext context) async {
    final goToSkin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          '음식이 내 피부에 맞는지 보려면 비교할 기준이 필요해요.\n'
          '피부를 한 번만 분석하면 그 다음부터는 바로 음식만 찍으면 됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('피부 분석하기'),
          ),
        ],
      ),
    );

    if ((goToSkin ?? false) && context.mounted) context.push(Routes.skinCapture);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.nickname,
      _ => '',
    };
    final hasSkinRecord =
        ref.watch(latestSkinAnalysisProvider).value?.dataOrNull != null;
    final today = ref.watch(todayRecordProvider);
    final imageDirectory = ref.watch(plateImageDirectoryProvider).value;

    void capture() => hasSkinRecord
        ? context.push(Routes.foodCapture)
        : _explainSkinFirst(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          // invalidate 는 void 라 당기자마자 스피너가 접힌다. 새 값을 기다려야
          // 요청이 끝날 때까지 스피너가 붙어 있다(기록 화면과 같은 이유).
          onRefresh: () => Future.wait([
            ref.refresh(latestSkinAnalysisProvider.future),
            ref.refresh(plateHistoryProvider.future),
          ]),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding,
              14,
              AppTheme.pagePadding,
              // 마지막 카드가 떠 있는 네비 밑으로 숨지 않게 띄운다.
              AppBottomNav.totalHeight + 16,
            ),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _ProfileMenu(hasSkinRecord: hasSkinRecord),
              ),
              const SizedBox(height: 35),
              Text('안녕하세요, $nickname님',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text('오늘도 피부에 좋은 선택을 해봐요!',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              DailyScoreCard(
                nickname: nickname,
                score: today?.plateScore,
                targetScore: today?.targetScore ?? 80,
              ),
              // 문장은 기록 저장 때 서버가 만들어 둔 것이다. 없으면 카드째 숨긴다 —
              // 빈 카드를 그리면 "뭔가 로딩 중인가"로 읽힌다.
              if (today?.aiComment != null) ...[
                const SizedBox(height: 14),
                _DailyCommentCard(comment: today!.aiComment!),
              ],
              const SizedBox(height: 21),
              Text('오늘의 기록',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TodayRecordsCard(
                items: today?.plates ?? const [],
                imageDirectory: imageDirectory,
                onCapture: capture,
                onItemTap: (item) =>
                    context.push('${Routes.plateResult}/${item.plateId}'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.home,
        onCapture: capture,
        onTabSelected: (tab) {
          if (tab == AppTab.records) context.push(Routes.plateHistory);
        },
      ),
    );
  }
}

/// "오늘의 한 줄 코멘트" — 시안의 크림 카드. 잎사귀 아이콘이 오른쪽에 붙는다.
class _DailyCommentCard extends StatelessWidget {
  const _DailyCommentCard({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('오늘의 한 줄 코멘트',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 6),
                Text(comment,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.eco_outlined, size: 22, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// 우측 상단 프로필. 시안에서 피부 분석으로 가는 유일한 입구다.
class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu({required this.hasSkinRecord});

  final bool hasSkinRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: '내 정보',
      offset: const Offset(0, 36),
      color: AppColors.background,
      icon: SvgPicture.asset('assets/icons/profile.svg', width: 28, height: 28),
      onSelected: (value) => switch (value) {
        'skin-type' => context.push(Routes.skinType),
        'analyze' => context.push(Routes.skinCapture),
        _ => ref.read(authNotifierProvider.notifier).logout(),
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'skin-type', child: Text('피부 프로필 수정')),
        PopupMenuItem(
          value: 'analyze',
          child: Text(hasSkinRecord ? '다시 분석' : '피부 분석하기'),
        ),
        const PopupMenuItem(value: 'logout', child: Text('로그아웃')),
      ],
    );
  }
}
