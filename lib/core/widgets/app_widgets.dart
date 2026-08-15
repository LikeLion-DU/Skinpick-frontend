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
