import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 피부 지표 하나의 **이름표 색과 아이콘**. 서버 metric key 로 고른다.
///
/// **여기서 색은 지표의 신분이지 상태가 아니다.** 수분은 늘 파랑, 홍조는 늘 빨강이다 —
/// 값이 좋아도 나빠도 같은 색이다. 상태는 `MetricBand` 의 상태어와 그 색이 말한다.
///
/// 색으로 상태를 말하게 하면 화면이 거짓말을 한다. 홍조 막대가 길수록 빨개지면
/// "많을수록 좋다"로 읽히는데 홍조는 반대다. 그래서 **길이는 값, 색은 지표,
/// 말은 판정** 셋으로 나눈다.
///
/// 마이페이지의 원형 타일과 피부 결과의 막대가 같은 표를 쓴다 — 두 곳에서 각자
/// 고르면 같은 지표가 화면마다 다른 색이 된다. 실제로 그랬다(마이페이지가 상태색으로
/// 원을 칠하고 있어서, 시안의 파스텔 다섯 색과 어긋났다).
class MetricPalette {
  const MetricPalette._({
    required this.bar,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  /// 피부 결과의 막대 색. 시안이 원형 타일보다 진한 한 벌을 쓴다.
  final Color bar;

  /// 원형 타일의 배경(파스텔).
  final Color background;

  /// 원형 타일의 아이콘 색.
  final Color foreground;

  final IconData icon;

  /// 모르는 key 는 회색으로 떨어진다. 서버가 지표를 늘렸을 때 빈 자리가 생기는
  /// 것보다 낫다 — 이름과 상태어는 그대로 나오므로 정보가 사라지지는 않는다.
  static const _unknown = MetricPalette._(
    bar: AppColors.outline,
    background: AppColors.borderOnWhite,
    foreground: AppColors.outline,
    icon: Icons.help_outline,
  );

  static const _byKey = <String, MetricPalette>{
    'hydration': MetricPalette._(
      bar: AppColors.metricBarHydration,
      background: AppColors.hydrationBg,
      foreground: AppColors.hydrationFg,
      icon: Icons.water_drop,
    ),
    'oil': MetricPalette._(
      bar: AppColors.metricBarOil,
      background: AppColors.oilBg,
      foreground: AppColors.oilFg,
      icon: Icons.opacity,
    ),
    'redness': MetricPalette._(
      bar: AppColors.metricBarRedness,
      background: AppColors.rednessBg,
      foreground: AppColors.rednessFg,
      icon: Icons.waves,
    ),
    'trouble': MetricPalette._(
      bar: AppColors.metricBarTrouble,
      background: AppColors.troubleBg,
      foreground: AppColors.troubleFg,
      icon: Icons.bubble_chart,
    ),
    'barrier': MetricPalette._(
      bar: AppColors.metricBarBarrier,
      background: AppColors.textureBg,
      foreground: AppColors.textureFg,
      icon: Icons.auto_awesome,
    ),
  };

  /// `SkinMetrics.toBars()` 의 key 로 고른다.
  static MetricPalette of(String metricKey) => _byKey[metricKey] ?? _unknown;
}
