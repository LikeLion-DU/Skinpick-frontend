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

  /// 오렌지 히어로 위에 얹히는 카드 크림. [surfaceCard] 보다 반 톤 노랗다.
  ///
  /// 두 크림을 합치고 싶어지는데, 합치면 오렌지 위 카드가 배경에 잠긴다 —
  /// 시안이 흰 배경 위(`FEF7F0`)와 오렌지 위(`FEF5EB`)에 다른 값을 쓴다.
  static const surfaceCardWarm = Color(0xFFFEF5EB);

  /// 히어로의 강한 오렌지. 그라디언트 아래끝·구역 제목·AI 라벨이 이 색이다.
  ///
  /// [primary] 보다 붉고 진하다. 오렌지 배경 위에서 [primary] 로 글자를 쓰면
  /// 배경과 붙어 읽히지 않아, 시안이 강조 자리를 따로 이 색으로 잡았다.
  static const accentStrong = Color(0xFFFF4D00);

  /// 히어로 진행 막대의 채움. 흰 트랙 위에서만 쓰인다.
  static const progressFill = Color(0xFFFE6828);

  /// 등급 배지(보통)의 살구색 배경. 히어로의 흰 글씨 옆에 놓인다.
  static const badgeNeutralBg = Color(0xFFFDDEC0);


  /// 마스코트 뒤에 깔리는 후광. 원본 SVG 의 흐림 필터를 코드에서 그린다.
  static const mascotGlow = Color(0xFFFFCCB4);

  /// 히어로에 흩어진 장식 방울.
  static const bubble = Color(0xFFFFECE3);

  /// 카드 안쪽 본문(오렌지 히어로 위 카드). [textOnCard] 보다 진하다.
  static const bodyInk = Color(0xFF353535);


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

  /// 트러블 한 벌. 확정 시안이 마이페이지 지표를 4개에서 **5개**로 늘리면서 생겼다 —
  /// 나머지 넷은 예전 시안에도 있던 값이고 이 보라 한 벌만 새로 들어왔다.
  static const troubleFg = Color(0xFF9499FF);
  static const troubleBg = Color(0xFFEAEBFF);

  // ── 피부 지표 막대 5종 ────────────────────────────────────
  // 확정 시안이 결과 화면의 지표를 원 4개에서 **막대 5개**로 바꿨다. 막대 색은
  // 위 원 색과 다른 한 벌이고, 여기서 색은 **지표의 이름표**다 — 상태(좋음·주의)를
  // 뜻하지 않는다. 판정은 `MetricBand` 의 상태어가 말한다.
  //
  // 색으로 상태를 말하게 하면 홍조 막대가 길수록 빨개져 "많을수록 좋다"로
  // 읽히는데, 홍조는 반대다. 길이는 값, 색은 지표, 말은 판정으로 나눈다.
  static const metricBarHydration = Color(0xFF94C1FF);
  static const metricBarOil = Color(0xFFFFD394);
  static const metricBarRedness = Color(0xFFFF9494);
  static const metricBarTrouble = Color(0xFFD894FF);
  static const metricBarBarrier = Color(0xFF90C74D);

  /// 지표 막대의 트랙과 결과 화면 카드 배경. 크림보다 노랗다.
  static const surfaceCardSand = Color(0xFFFEF4EA);

  // ── 회색 계단 5종 ─────────────────────────────────────────
  // **시안에서 이름이 붙어 있는 유일한 색 묶음이다.** 로그인 프레임이
  // `Gray/Gray-baseDarkest` 처럼 스타일로 정의해 두었으므로 이름을 그대로 옮긴다 —
  // 디자이너가 나중에 변수를 만들면 이 다섯 줄이 첫 대응 지점이 된다.
  //
  // 기존 회색들(textSecondary·outline·disabled)과 겹쳐 보이지만 값이 다르고,
  // 시안이 입력창·링크·구분선에 이 계단을 쓴다. 합치려면 디자이너 확인이 필요하다.
  static const grayBaseDarkest = Color(0xFF323234);
  static const grayBaseExtraDark = Color(0xFF565659);
  static const grayBase = Color(0xFF929399);
  static const grayMid = Color(0xFFBABBBF);
  static const grayLight = Color(0xFFE1E2E4);
}
