import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'skin_level.dart';

/// 지표 하나의 **상태어 + 색**. 서버가 그 지표에 매긴 등급을 화면 말로 접는다.
///
/// **경계는 앱에 없다.** 예전에는 여기에 60/40 표가 있었고, 서버는 같은 지표를
/// `ScoredItemDto.of` 에서 방향을 맞춘 뒤 `SkinLevel.of` 로 매겼다 — 표가 두 벌이라
/// 값이 딱 40·60 인 날 두 곳이 갈렸다. 이제 서버 `metricDetails[].level` 만 읽는다.
///
/// 방향은 여전히 필요하다. **단어를 고르는 데만** 쓴다 — 수분이 낮으면 "부족"이고
/// 홍조가 높으면 "주의"다. 서버는 둘 다 CAUTION 으로 보내므로(방향을 이미 맞춰
/// 매긴다) 어느 쪽 말로 옮길지는 화면이 정한다. 판정이 아니라 어휘다.
class MetricBand {
  const MetricBand(this.label, this.color);

  final String label;
  final Color color;

  static const _blue = Color(0xFF3A85E2);
  static const _red = Color(0xFFFA6154);

  /// 서버가 준 지표 등급을 상태어로 바꾼다.
  ///
  /// 등급을 모르면 null 이고, 그러면 화면이 상태어 자리를 비운다 — 틀린 판정보다
  /// 없는 판정이 낫다. (`SkinLevel.fromJson` 과 같은 규칙)
  static MetricBand? of(SkinLevel? level,
      {required bool higherIsBetterMetric}) {
    return switch (level) {
      null => null,
      SkinLevel.excellent || SkinLevel.good =>
        const MetricBand('좋음', AppColors.good),
      SkinLevel.normal => const MetricBand('보통', AppColors.primary),
      SkinLevel.caution || SkinLevel.severe => higherIsBetterMetric
          ? const MetricBand('부족', _blue)
          : const MetricBand('주의', _red),
    };
  }
}
