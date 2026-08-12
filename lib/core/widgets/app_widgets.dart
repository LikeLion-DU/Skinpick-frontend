import 'package:flutter/material.dart';

import '../error/failure.dart';

/// 껍데기 단계의 공용 위젯.
///
/// 디자인이 확정되면 이 파일만 갈아끼우면 된다 — 화면들은 의미(점수 게이지,
/// 지표 바, 실패 안내)로만 부르고 색·모양을 직접 그리지 않는다.

/// 원형 점수 게이지. 0~100.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, this.label, this.size = 140});

  final int score;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              strokeWidth: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: Theme.of(context).textTheme.displaySmall),
              if (label != null)
                Text(label!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// 지표 막대 1줄.
///
/// [higherIsBetter] 가 반드시 필요하다 — 수분 30 은 나쁘고 홍조 30 은 좋다.
/// 이 정보 없이 색을 칠하면 홍조가 심할수록 초록으로 표시된다.
class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.higherIsBetter,
  });

  final String label;
  final int value;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final aligned = higherIsBetter ? value : 100 - value;
    final color = switch (aligned) {
      >= 60 => Colors.green,
      >= 40 => Colors.orange,
      _ => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              color: color,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

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
