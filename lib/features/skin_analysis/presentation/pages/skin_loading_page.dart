
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
      if (next.analysis.value != null) {
        // pushReplacement 라 뒤로가기가 로딩 화면으로 돌아오지 않는다.
        context.pushReplacement(Routes.skinResult);
      }
    });

    final analysis = ref.watch(skinAnalysisNotifierProvider).analysis;

    return Scaffold(
      body: switch (analysis) {
        AsyncError(:final Failure error) => FailureView(
            failure: error,
            onRetry: () => context.pop(),
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
