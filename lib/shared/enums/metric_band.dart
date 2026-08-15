import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 피부 지표 하나를 상태어 + 색으로 바꾼다.
///
/// `ScoreGrade` 와 헷갈리지 말 것. 저쪽은 **총점**(0~100 합산 점수) 전용이고 경계가
/// 75/60 이다. 여기는 **개별 지표** 전용이고 경계가 60/40 이다 — 시안이 두 축을
/// 다르게 잡았다. 지표에 ScoreGrade 를 쓰면 홍조 50 같은 평범한 값이 빨강이 된다.
///
/// 방향이 반드시 필요하다 — 수분 30 은 나쁘고 홍조 30 은 좋다.
class MetricBand {
  const MetricBand(this.label, this.color);

  final String label;
  final Color color;

  static const _blue = Color(0xFF3A85E2);
  static const _red = Color(0xFFFA6154);

  /// 높을수록 좋은 지표(수분·장벽). 낮으면 "부족"이다.
  static MetricBand higherIsBetter(int value) {
    if (value < 40) return const MetricBand('부족', _blue);
    if (value < 60) return const MetricBand('보통', AppColors.primary);
    return const MetricBand('좋음', AppColors.good);
  }

  /// 높을수록 나쁜 지표(유분·홍조·트러블). 높으면 "주의"다.
  static MetricBand higherIsWorse(int value) {
    if (value >= 60) return const MetricBand('주의', _red);
    if (value >= 40) return const MetricBand('보통', AppColors.primary);
    return const MetricBand('좋음', AppColors.good);
  }

  /// `SkinMetrics.toBars()` 가 주는 방향 플래그로 고른다.
  static MetricBand of(int value, {required bool higherIsBetterMetric}) =>
      higherIsBetterMetric ? higherIsBetter(value) : higherIsWorse(value);
}
