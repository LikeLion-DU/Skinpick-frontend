import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/result/result.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/ai_comment_card.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import '../../../skin_plate/presentation/providers/plate_history_provider.dart';
import '../providers/today_provider.dart';
import '../widgets/home_hero.dart';
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
/// 피부 분석으로 가는 입구는 우측 상단 프로필 아이콘 → **나의 피부 프로필**이다.
/// 홈 본문에 두지 않는 것은 의도다 — 피부 분석은 주인공이 아니라 음식 점수의
/// 기준값이고, 그 기준을 확인하러 갔을 때 다시 분석하는 흐름이 자연스럽다.
///
/// 확정 시안에서 이 화면의 배경이 흰색에서 **오렌지 그라디언트**로 바뀌었다.
/// 점수가 카드 안이 아니라 배경 위에 직접 얹히므로, 히어로 텍스트는 전부
/// 흰색이고 [AppTheme.heroTextShadow] 를 단다 — 그라디언트가 아래로 밝아지는
/// 구간에서 흰 글자가 배경에 묻히는 것을 막는 장치다.
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
    // 피부 분석 상태는 셋이다 — 있다 · 없다 · 아직 모른다(로딩·실패).
    // 셋을 둘로 접으면 네트워크가 한 번 흔들린 것만으로 이미 분석을 해 둔
    // 사용자에게 "먼저 피부를 분석해야 해요" 라고 말하게 된다.
    final skinState = ref.watch(latestSkinAnalysisProvider);
    final hasSkinRecord = skinState.value?.dataOrNull != null;
    final skinUnknown = !hasSkinRecord &&
        (skinState.isLoading ||
            skinState.hasError ||
            skinState.value is FailureResult);

    final history = ref.watch(plateHistoryProvider);
    final today = ref.watch(todayRecordProvider);
    final historyFailure = switch (history.value) {
      FailureResult(:final error) => error.message,
      _ => history.hasError ? '오늘 기록을 불러오지 못했어요.' : null,
    };
    final imageDirectory = ref.watch(plateImageDirectoryProvider).value;

    void capture() {
      if (hasSkinRecord) {
        context.push(Routes.foodCapture);
      } else if (skinUnknown) {
        // 없다고 단정하지 않는다. 모르는 것은 모른다고 말하고 다시 시도를 준다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('피부 기준을 확인하지 못했어요.'),
            action: SnackBarAction(
              label: '다시 시도',
              onPressed: () => ref.invalidate(latestSkinAnalysisProvider),
            ),
          ),
        );
      } else {
        _explainSkinFirst(context);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // 배경과 마스코트는 스크롤에 참여하지 않는다. 시안에서 이 둘은
          // 프레임에 고정된 판이고, 카드만 그 위에 얹혀 있다.
          const HeroWash(),
          const HeroMascot(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              // invalidate 는 void 라 당기자마자 스피너가 접힌다. 새 값을 기다려야
              // 요청이 끝날 때까지 스피너가 붙어 있다(기록 화면과 같은 이유).
              // 주간 리포트는 여기서 부르지 않는다. 서버가 그 응답에 AI 문장을
              // 같이 만들어 붙이느라 최대 ~27초가 걸리는데, 홈은 촬영을 마치고
              // 매번 돌아오는 화면이라 그 지연이 그대로 홈의 지연이 된다.
              onRefresh: () => Future.wait([
                ref.refresh(latestSkinAnalysisProvider.future),
                ref.refresh(plateHistoryProvider.future),
              ]),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pagePadding,
                  21,
                  AppTheme.pagePadding,
                  // 마지막 카드가 떠 있는 네비 밑으로 숨지 않게 띄운다.
                  AppBottomNav.totalHeight + 16,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      button: true,
                      label: '마이페이지',
                      // 아이콘은 시안대로 28 이지만 **누를 곳은 48 이다.** 이 아이콘이
                      // 피부 프로필로 가는 유일한 문이라 오탭이 곧 막힌 길이 된다.
                      child: GestureDetector(
                        onTap: () => context.push(Routes.skinProfile),
                        behavior: HitTestBehavior.opaque,
                        child: Tooltip(
                          message: '마이페이지',
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SvgPicture.asset(
                                  'assets/icons/profile.svg',
                                  width: 28,
                                  height: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  HomeHero(
                    nickname: nickname,
                    score: today?.plateScore,
                    grade: today?.grade,
                    targetScore: today?.targetScore,
                  ),
                  // 문장은 기록 저장 때 서버가 만들어 둔 것이다. 없으면 카드째 숨긴다 —
                  // 빈 카드를 그리면 "뭔가 로딩 중인가"로 읽힌다.
                  if (today?.aiComment != null) ...[
                    const SizedBox(height: 25),
                    AiCommentCard(
                      title: 'AI 오늘의 한마디',
                      comment: today!.aiComment!,
                    ),
                  ],
                  const SizedBox(height: 19),
                  TodayRecordsCard(
                    items: today?.plates ?? const [],
                    imageDirectory: imageDirectory,
                    // 히스토리를 아직 못 받았으면 "안 먹은 날" 로 그리지 않는다.
                    loading: history.isLoading && !history.hasValue,
                    failureMessage: historyFailure,
                    onRetry: () => ref.invalidate(plateHistoryProvider),
                    onCapture: capture,
                    onSeeAll: () => context.push(Routes.plateHistory),
                    onItemTap: (item) =>
                        context.push('${Routes.plateResult}/${item.plateId}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.home,
        onCapture: capture,
        onTabSelected: (tab) {
          if (tab == AppTab.report) context.push(Routes.report);
        },
      ),
    );
  }
}
