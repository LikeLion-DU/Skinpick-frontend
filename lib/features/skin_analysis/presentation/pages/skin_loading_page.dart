import 'dart:async';

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
        _ => const _LoadingSteps(
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

class _LoadingSteps extends StatefulWidget {
  const _LoadingSteps({required this.steps});

  final List<String> steps;

  @override
  State<_LoadingSteps> createState() => _LoadingStepsState();
}

class _LoadingStepsState extends State<_LoadingSteps> {
  static const _interval = Duration(milliseconds: 1800);

  late final Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) {
      // 마지막 단계에서 멈춘다. 순환시키면 8초가 넘어갔을 때
      // "사진을 준비하고 있어요"로 되돌아가 진행이 없어 보인다.
      if (_index < widget.steps.length - 1) setState(() => _index++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.steps[_index],
              key: ValueKey<int>(_index),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
