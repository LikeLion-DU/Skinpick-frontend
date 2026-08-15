import 'package:flutter/material.dart';

/// 피그마 시안에서 뽑은 색. 값의 출처를 남겨 두는 이유가 있다.
///
/// 디자이너가 아직 Figma **변수(Variables)** 로 토큰을 정의하지 않아서,
/// 시안 렌더 이미지에서 영역별 최빈색을 읽어 옮겼다. 즉 이 값들은
/// "디자인 원본"이 아니라 "디자인을 보고 받아적은 것"이다.
///
/// 나중에 디자이너가 변수를 만들면 그때 원본을 읽어 이 파일만 교체하면 된다.
/// 화면 코드는 전부 이 클래스만 참조하므로 교체 비용이 여기서 끝난다.
/// 그러라고 색 리터럴을 화면에 직접 쓰지 않는다.
class AppColors {
  const AppColors._();

  /// 브랜드 오렌지. 버튼·FAB·선택된 칩·강조 배지가 전부 이 한 색이다.
  static const primary = Color(0xFFFF7D40);

  /// 카드 배경 크림. 흰 배경 위에 얹혀 영역을 구분한다.
  static const surfaceCard = Color(0xFFFEF7F0);

  static const background = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF5A5A5A);

  /// 테두리와 미선택 칩의 윤곽.
  static const outline = Color(0xFF898888);

  /// 조건 미충족 버튼. 시안에서 "프로필 설정 완료"가 이 색으로 잠겨 있다.
  static const disabled = Color(0xFFD9D9D9);

  // ── 평가 색 ────────────────────────────────────────────────
  // 주의(caution)가 primary 와 같은 값인 것은 실수가 아니라 시안 그대로다.
  // 배지에서 둘을 같은 오렌지로 칠했다. 의미가 다르므로 이름을 나눠 둔다 —
  // 나중에 디자이너가 주의색만 바꿔도 primary 를 건드리지 않게 된다.
  static const good = Color(0xFF6CBE46);
  static const bad = Color(0xFFDF0011);
  static const caution = Color(0xFFFF7D40);

  // ── 피부 지표 4종 ──────────────────────────────────────────
  // 시안의 "분석이 완료됐어요" 카드에 쓰인 아이콘 색과 원형 배경.
  // 서버 지표는 5개(hydration·oil·redness·trouble·barrier)인데 시안은
  // 4개만 보여준다. 이건 디자인 의도로 확인받았다.
  static const hydrationFg = Color(0xFF7DB7FF);
  static const hydrationBg = Color(0xFFF1F6FC);

  static const oilFg = Color(0xFFFFC373);
  static const oilBg = Color(0xFFFEF5E9);

  static const rednessFg = Color(0xFFFF7171);
  static const rednessBg = Color(0xFFFCF0F0);

  static const textureFg = Color(0xFF9CD582);
  static const textureBg = Color(0xFFEBFBE4);
}
