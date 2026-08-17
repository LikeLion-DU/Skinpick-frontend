import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// **앱의 유일한 총점 등급.** 서버 `SkinLevel` 과 이름·경계가 같다.
///
/// 서버가 등급을 보내는 자리(리포트의 `grade`·`status`)에서는 [fromJson] 으로 그
/// 값을 그대로 쓰고, 서버가 점수만 보내는 자리(홈 카드·기록 카드·결과 화면)에서만
/// [fromScore] 로 같은 경계를 적용한다. **경계표는 이 파일 한 곳뿐이다** —
/// 화면마다 다른 임계값을 두면 같은 68점이 홈에서는 "보통", 리포트에서는 "좋음"이
/// 된다. 실제로 그랬다.
///
/// 표시는 3단계(좋음·보통·주의)로 접는다. 판정은 서버의 5단계 그대로 두고 **말만**
/// 줄이는 것이라, 등급을 앱이 다시 매기는 것이 아니다. 접는 규칙이 [label] 이다.
enum SkinLevel {
  severe('SEVERE'),
  caution('CAUTION'),
  normal('NORMAL'),
  good('GOOD'),
  excellent('EXCELLENT');

  const SkinLevel(this.wire);

  final String wire;

  /// 모르는 값은 null 이다. 기본값을 두면 서버가 등급을 하나 늘린 날
  /// 그 등급이 조용히 다른 등급으로 표시된다. (`MealType` 과 같은 규칙)
  static SkinLevel? fromJson(String? value) {
    for (final level in values) {
      if (level.wire == value) return level;
    }
    return null;
  }

  /// 점수에서 등급을 낸다. **서버 `SkinLevel.of(int)` 과 한 글자도 다르면 안 된다** —
  /// 리포트는 서버가 매긴 등급을 그리고 홈·기록은 이 함수가 매긴 등급을 그리므로,
  /// 두 식이 갈리는 순간 같은 점수가 화면마다 다른 등급으로 보인다.
  ///
  /// 경계는 서버가 정한 것을 옮겨 온 것이지 앱이 새로 만든 것이 아니다
  /// (0~20 SEVERE · 21~40 CAUTION · 41~60 NORMAL · 61~80 GOOD · 81~100 EXCELLENT).
  ///
  /// 히스토리 응답에 `grade` 필드가 생기면 이 함수를 쓰는 자리를 [fromJson] 으로
  /// 옮기고 여기를 지우는 것이 맞다.
  static SkinLevel fromScore(int score) {
    if (score <= 20) return SkinLevel.severe;
    if (score <= 40) return SkinLevel.caution;
    if (score <= 60) return SkinLevel.normal;
    if (score <= 80) return SkinLevel.good;
    return SkinLevel.excellent;
  }

  /// 좋음 구간인지. 시안이 "좋음일 때만 초록"으로 칠하는 자리가 몇 군데 있다.
  bool get isGood => this == SkinLevel.good || this == SkinLevel.excellent;

  /// 배지와 문장에 찍히는 말. 서버의 5단계를 화면의 3단계로 접는다.
  String get label => switch (this) {
        SkinLevel.excellent || SkinLevel.good => '좋음',
        SkinLevel.normal => '보통',
        SkinLevel.caution || SkinLevel.severe => '주의',
      };

  /// 점수 숫자와 옅은 배지 위 글자의 색.
  Color get accentColor => switch (this) {
        SkinLevel.excellent || SkinLevel.good => AppColors.good,
        SkinLevel.normal => AppColors.primary,
        SkinLevel.caution || SkinLevel.severe => AppColors.bad,
      };

  /// 진한 채움 배지의 배경. 기록 카드처럼 점수 옆에 붙는 자리다.
  ///
  /// 주의가 빨강이 아니라 오렌지인 것은 시안 그대로다 — 빨강은 BAD 라벨 전용이다.
  Color get solidColor => isGood ? AppColors.good : AppColors.primary;

  /// 옅은 틴트 배지의 배경. 홈·결과 화면의 큰 점수 옆에 붙는 자리다.
  Color get tintColor => switch (this) {
        SkinLevel.excellent || SkinLevel.good => const Color(0xFFDCF0D2),
        SkinLevel.normal => const Color(0xFFFCDEC0),
        SkinLevel.caution || SkinLevel.severe => const Color(0xFFFCC0C0),
      };

  /// 등급 표정. 기록 카드와 결과 게이지가 같은 얼굴을 쓴다 —
  /// 화면마다 switch 를 따로 쓰면 등급이 늘었을 때 한쪽만 고쳐진다.
  IconData get faceIcon => switch (this) {
        SkinLevel.excellent || SkinLevel.good => Icons.sentiment_satisfied_alt,
        SkinLevel.normal => Icons.sentiment_neutral,
        SkinLevel.caution || SkinLevel.severe => Icons.sentiment_dissatisfied,
      };

  /// 리포트의 점수 아래 한 줄 설명. **AI 문장이 아니라 등급에 붙는 고정 UI 문구다** —
  /// 서버가 정한 등급을 사람 말로 옮길 뿐이고 숫자를 언급하지 않는다.
  String get summary => switch (this) {
        SkinLevel.excellent || SkinLevel.good => '피부에 잘 맞는 선택이 많았어요',
        SkinLevel.normal => '나쁘지 않아요. 조금만 더 챙겨볼까요',
        SkinLevel.caution || SkinLevel.severe => '피부에 부담이 되는 선택이 있었어요',
      };
}
