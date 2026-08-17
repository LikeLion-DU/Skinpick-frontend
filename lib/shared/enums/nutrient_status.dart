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
}
