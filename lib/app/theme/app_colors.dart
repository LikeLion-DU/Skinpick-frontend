import 'package:flutter/material.dart';

/// 피그마 시안에서 가져온 색.
///
/// 디자이너가 Figma **변수(Variables)** 를 만들지 않아서(조회하면 빈 객체가
/// 온다) 토큰 원본이 없다. 그래서 값의 출처가 둘로 갈린다 —
/// 프레임 사양을 직접 읽어 확인한 것과, 시안 렌더에서 색을 읽어 옮긴 것이다.
/// 후자는 주석에 "샘플링"이라고 적어 두었으니 다른 화면 사양을 읽을 때
/// 우선 확인할 것.
///
/// 나중에 디자이너가 변수를 만들면 이 파일만 교체하면 된다. 화면 코드는
/// 전부 이 클래스만 참조하므로 교체 비용이 여기서 끝난다.
/// 그러라고 색 리터럴을 화면에 직접 쓰지 않는다.
class AppColors {
  const AppColors._();

  /// 브랜드 오렌지. 버튼·FAB·선택된 칩·강조 배지가 전부 이 한 색이다.
  static const primary = Color(0xFFFF7D40);

  /// 카드 배경 크림. 흰 배경 위에 얹혀 영역을 구분한다.
  static const surfaceCard = Color(0xFFFEF7F0);

  /// 촬영 버튼(FAB)만 단색이 아니라 위아래 그라디언트다. 화면에서 이 하나뿐이라
  /// 시선이 여기로 간다 — 시안이 주 동작을 그렇게 지목하고 있다.
  static const fabGradientTop = Color(0xFFFF5404);
  static const fabGradientBottom = Color(0xFFFFD240);

  static const background = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF000000);

  /// 제목 아래 안내 문구. 시안의 "오늘도 피부에 좋은 선택을 해봐요!" 가 이 색이다.
  static const textSecondary = Color(0xFF6D6D6D);

  /// 카드 안쪽 본문. 위 회색보다 아주 조금 진하다 — 시안이 둘을 구분해서 쓴다.
  static const textOnCard = Color(0xFF505050);

  /// 흰 배경 위 본문 문장. 피부 요약·하이라이트 줄이 이 색이다. (샘플링)
  ///
  /// [textOnCard] 와 한 끗 차이(505050)라 합치고 싶어지는데, 시안이 실제로 두 값을
  /// 쓰고 있어 두 토큰으로 둔다. 합치려면 디자이너에게 확인받고 한 번에 바꿀 것.
  static const textBody = Color(0xFF494949);

  /// 테두리와 미선택 칩의 윤곽. (샘플링)
  static const outline = Color(0xFF898888);

  // ── 테두리 3종 ────────────────────────────────────────────
  // 카드마다 테두리 색이 다르다. 하나로 합치면 크림 카드의 따뜻한 윤곽이
  // 회색으로 죽는다.
  static const borderOnCream = Color(0xFFFFDFD1);
  static const borderOnWhite = Color(0xFFE6E6E6);

  /// 기록이 없을 때의 빈 슬롯 테두리.
  static const borderEmptySlot = Color(0xFFDADADA);

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
