import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 점수를 사람이 읽는 등급으로 바꾼다.
///
/// 시안이 등급 어휘를 한 벌로 쓰지 않는다 — 같은 뜻인데 화면마다
/// `GOOD` / `BAD` 와 `보통` / `주의` 가 섞여 있다. 그대로 옮기면 사용자가
/// 두 체계를 동시에 배우게 되므로 여기서 한 벌로 고정하고, 화면은 전부
/// 이 enum 만 쓴다. 문구를 바꿀 일이 생기면 이 파일만 고친다.
///
/// 경계값은 시안에 적힌 예시에서 역산했다 — 92·78 이 좋음, 72 가 보통,
/// 58 이 주의다. 디자이너가 의도한 정확한 경계는 확인이 필요하다.
enum ScoreGrade {
  good('GOOD', '좋음'),
  normal('보통', '보통'),
  caution('주의', '주의');

  const ScoreGrade(this.badgeLabel, this.plainLabel);

  /// 배지에 찍히는 짧은 말. 시안의 기록 카드가 이 표기를 쓴다.
  final String badgeLabel;

  /// 문장 안에 섞여 들어갈 때 쓰는 말.
  final String plainLabel;

  static ScoreGrade fromScore(int score) {
    if (score >= _goodCut) return ScoreGrade.good;
    if (score >= _normalCut) return ScoreGrade.normal;
    return ScoreGrade.caution;
  }

  static const _goodCut = 75;
  static const _normalCut = 60;

  /// 진한 채움 배지의 배경. 기록 카드처럼 점수 옆에 붙는 자리다.
  Color get solidColor => switch (this) {
        ScoreGrade.good => AppColors.good,
        ScoreGrade.normal => AppColors.primary,
        ScoreGrade.caution => AppColors.primary,
      };

  /// 옅은 틴트 배지의 배경. 홈·결과 화면의 큰 점수 옆에 붙는 자리다.
  Color get tintColor => switch (this) {
        ScoreGrade.good => const Color(0xFFDCF0D2),
        ScoreGrade.normal => const Color(0xFFFCDEC0),
        ScoreGrade.caution => const Color(0xFFFCC0C0),
      };

  /// 틴트 배지 위에 얹는 글자색, 그리고 큰 점수 숫자의 색.
  Color get accentColor => switch (this) {
        ScoreGrade.good => AppColors.good,
        ScoreGrade.normal => AppColors.primary,
        ScoreGrade.caution => AppColors.bad,
      };
}
