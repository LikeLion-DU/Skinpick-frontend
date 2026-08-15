import 'dart:async';

import 'package:flutter/material.dart';

import '../error/failure.dart';

/// 화면 공용 위젯(실패 안내·안전 고지).
///
/// 껍데기 시절의 ScoreGauge·MetricBar 는 확정 시안이 들어오며 지웠다.
/// 점수 게이지는 이제 plate_score_card.dart 의 ScoreGauge 하나다 — 같은 이름을
/// 여기 남겨 두면 두 파일을 같이 import 하는 화면에서 ambiguous import 가 난다.

/// 실패 안내 + 재시도. 화면마다 다른 문구를 짓지 않도록 통로를 하나로 둔다.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retakePhoto = failure is AnalysisFailure &&
        (failure as AnalysisFailure).shouldRetakePhoto;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(failure.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton(
                onPressed: onRetry,
                child: Text(retakePhoto ? '다시 촬영하기' : '다시 시도'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 모든 결과 화면 하단에 고정한다. (PRD §20 · R3)
class SafetyNotice extends StatelessWidget {
  const SafetyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '본 서비스는 의료 진단이나 치료를 목적으로 하지 않으며, 제공되는 분석 결과와 '
        '식품 정보는 참고용입니다. 피부 질환이 의심되는 경우 전문의와 상담하시기 바랍니다.',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 단계 문구가 넘어가는 로딩 화면.
///
/// 오래 걸리는 호출에서 스피너만 돌면 화면이 멈춘 것처럼 보인다. 피부 분석(S04)과
/// 인사이트 첫 조회(S10, 최대 ~27초)가 둘 다 그 부류라 위젯을 공유한다.
class LoadingSteps extends StatefulWidget {
  const LoadingSteps({super.key, required this.steps});

  final List<String> steps;

  @override
  State<LoadingSteps> createState() => _LoadingStepsState();
}

class _LoadingStepsState extends State<LoadingSteps> {
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
