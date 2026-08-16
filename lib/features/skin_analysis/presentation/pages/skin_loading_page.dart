
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/skin_analysis_notifier.dart';

/// S04 — 분석 로딩.
///
/// 빈 스피너 대신 단계를 순차로 보여준다. AI 응답에 5~8초가 걸리는데,
/// 그 시간에 아무것도 안 움직이면 실제보다 길게 느껴진다. (PRD §6 화면 설계 원칙 1)
class SkinLoadingPage extends ConsumerWidget {
  const SkinLoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(skinAnalysisNotifierProvider, (previous, next) {
      if (next.analysis.value == null) return;

      // **습관이 비어 있어도 결과로 바로 보낸다.** 예전에는 여기서 생활 습관 4종을
      // 강제했는데, 그 근거였던 "인사이트가 습관 없이 굳는다" 가 성립하지 않는다 —
      // 인사이트는 분석 시점이 아니라 사용자가 S10 에 **들어갈 때** 서버가 처음
      // 만든다(GET /skin-insights 가 get-or-create).
      //
      // 그래서 게이트는 습관이 실제로 필요한 S10 이 쥔다. 여기서 막으면 점수·지표만
      // 보려는 사용자까지 설문 앞에 세우고, 그 화면에서 이탈하면 5~8초 기다린 분석을
      // 다시 볼 길이 없어진다(홈에 결과 진입점이 없다).
      //
      // pushReplacement 라 뒤로가기가 로딩 화면으로 돌아오지 않는다.
      context.pushReplacement(Routes.skinResult);
    });

    final analysis = ref.watch(skinAnalysisNotifierProvider).analysis;

    return Scaffold(
      body: switch (analysis) {
        // 촬영 화면은 이미 교체돼 스택에 없다. pop 하면 촬영 이전 화면으로 나가
        // 버리므로, 재촬영은 카메라로 명시적으로 다시 들어간다.
        AsyncError(:final Failure error) => FailureView(
            failure: error,
            onRetry: () => context.pushReplacement(Routes.skinCapture),
          ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const LoadingSteps(
            steps: [
              '사진을 준비하고 있어요',
              '피부 특징을 추출하는 중이에요',
              '수분·유분·홍조를 살펴보는 중이에요',
              '오늘의 Skin Score를 계산하고 있어요',
            ],
          ),
      },
    );
  }
}
