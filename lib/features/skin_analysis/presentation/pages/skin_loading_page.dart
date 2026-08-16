
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
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

      // 생활 습관이 하나라도 비어 있으면 결과로 바로 보내지 않는다. 인사이트가
      // 서버 DB 의 습관을 읽어 주제를 고르는데, 비어 있으면 생활 관련 인사이트가
      // 하나도 안 뜬 채로 그 분석에 굳는다 — 나중에 채워도 늦다.
      //
      // 이미 다 채운 사용자는 이 단계를 보지 않는다.
      final auth = ref.read(authNotifierProvider);
      final needsLifestyle =
          auth is Authenticated && auth.user.hasIncompleteLifestyle;

      // pushReplacement 라 뒤로가기가 로딩 화면으로 돌아오지 않는다.
      context.pushReplacement(
          needsLifestyle ? Routes.lifestyle : Routes.skinResult);
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
