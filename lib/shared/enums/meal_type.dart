/// 서버 `MealType` 과 이름이 같아야 한다.
///
/// 시각에서 파생한 값이라 서버가 정해서 보낸다. 앱이 `recordedAt` 을 보고 다시
/// 계산하지 않는 이유는 경계 시각 때문이다 — 양쪽 기준이 한 시간만 달라도
/// 같은 기록이 화면마다 다른 끼니로 보인다.
enum MealType {
  breakfast('BREAKFAST', '아침'),
  lunch('LUNCH', '점심'),
  dinner('DINNER', '저녁');

  const MealType(this.wire, this.label);

  final String wire;

  /// 기록 카드에 찍히는 말. 한국어 표기는 앱이 정한다.
  final String label;

  /// 모르는 값은 null 이다. 기본값을 두면 서버가 "야식"을 추가한 날
  /// 모든 야식이 조용히 "아침"으로 표시된다.
  static MealType? fromJson(String? value) {
    for (final type in MealType.values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}
