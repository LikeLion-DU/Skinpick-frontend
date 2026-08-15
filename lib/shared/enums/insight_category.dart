import 'package:flutter/material.dart';

/// 인사이트 주제 13종. 서버 `InsightCategory` 와 1:1 이다.
///
/// 라벨을 갖지 않는다 — 서버가 `title` 로 준다. 앱이 라벨을 한 벌 더 들고 있으면
/// 서버가 문구를 고쳤을 때 두 곳이 어긋나고, 사용자는 화면마다 다른 말을 보게 된다.
/// 여기 있는 것은 아이콘뿐이고, 아이콘은 서버가 줄 수 없는 값이다.
enum InsightCategory {
  // 측정 지표에서 온 주제
  dry('DRY', Icons.water_drop_outlined),
  oily('OILY', Icons.opacity),
  redness('REDNESS', Icons.waves),
  trouble('TROUBLE', Icons.blur_on),
  barrierWeak('BARRIER_WEAK', Icons.shield_outlined),

  // 자가 신고 고민에서 온 주제
  darkCircle('DARK_CIRCLE', Icons.dark_mode_outlined),
  pigmentation('PIGMENTATION', Icons.gradient),
  elasticity('ELASTICITY', Icons.trending_up),
  puffiness('PUFFINESS', Icons.bubble_chart_outlined),

  // 생활 습관에서 온 주제
  sleep('SLEEP', Icons.nightlight_outlined),
  stress('STRESS', Icons.sentiment_very_dissatisfied_outlined),
  exercise('EXERCISE', Icons.fitness_center),
  water('WATER', Icons.local_drink_outlined);

  const InsightCategory(this.wire, this.icon);

  final String wire;
  final IconData icon;

  /// 모르는 값은 null 이다. 아이콘을 고르는 값이라 억지 기본값을 두면
  /// 서버에 새 카테고리가 생겼을 때 엉뚱한 그림이 붙는다. 화면이 중립 아이콘을 쓴다.
  static InsightCategory? fromJson(String value) {
    for (final category in values) {
      if (category.wire == value) return category;
    }
    return null;
  }
}
