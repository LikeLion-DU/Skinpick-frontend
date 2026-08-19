/// 서버 `NutrientType.Status`. 영양 항목 하나가 기준값 대비 어디에 있는지.
///
/// **좋고 나쁨이 아니라 위치다.** 어느 쪽이 나쁜지는 같이 오는 `higherIsWorse` 가
/// 말한다 — 단백질 LOW 와 나트륨 LOW 를 같은 색으로 칠하면 화면이 거짓말을 한다.
enum NutrientStatus {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH');

  const NutrientStatus(this.wire);

  final String wire;

  /// 모르는 값은 null 이다. 서버가 상태를 하나 늘렸을 때 그것이 조용히
  /// `normal` 로 보이면 경고가 사라진 것처럼 읽힌다.
  static NutrientStatus? fromJson(String? value) {
    for (final status in values) {
      if (status.wire == value) return status;
    }
    return null;
  }

  /// 이 항목을 경고색으로 칠할지. **새 임계값을 만들지 않는다** —
  /// 서버가 준 위치([NutrientStatus])와 방향(`higherIsWorse`)을 조합할 뿐이다.
  bool isWarning({required bool higherIsWorse}) => switch (this) {
        NutrientStatus.normal => false,
        NutrientStatus.high => higherIsWorse,
        NutrientStatus.low => !higherIsWorse,
      };

  /// 타일에 찍는 상태어. **위치를 한국어로 옮긴 것이지 판정이 아니다** —
  /// 경계는 서버가 이미 [NutrientStatus] 로 잘라서 보냈고, 어느 쪽이 나쁜지는
  /// `higherIsWorse` 가 말한다. 앱은 그 둘을 읽어 이름만 붙인다.
  ///
  /// 시안은 이 자리에 **적정 · 보통 · 부족 · 주의** 네 단어를 쓰는데, 같은
  /// `NORMAL` 구간에 적정(60%)과 보통(68%)이 섞여 있어 둘을 가르는 규칙이
  /// 없다. 서버가 주는 세 위치에만 이름을 붙인다 — 앱이 네 번째 경계를
  /// 만들면 그게 곧 두 곳에 생긴 판정 규칙이다.
  /// **양쪽 다 방향을 본다.** 예전에는 `high` 만 갈랐는데, 그러면 나트륨·당류가
  /// 기준 아래일 때 "부족"이 초록색으로 떴다 — 줄이라고 말한 항목을 두고 더
  /// 먹으라는 말이 된다. 실서버 응답에 실제로 그런 항목이 둘 있었다
  /// (탄수화물 53% · 당류 62%, 둘 다 `higherIsWorse`).
  String label({required bool higherIsWorse}) => switch (this) {
        NutrientStatus.low => higherIsWorse ? '여유' : '부족',
        NutrientStatus.normal => '적정',
        NutrientStatus.high => higherIsWorse ? '과다' : '충분',
      };
}
