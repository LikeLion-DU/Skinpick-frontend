/// 서버 PlateActionCode enum과 이름이 정확히 같아야 한다.
/// 앱이 이 이름을 그대로 보내므로 한쪽만 바꾸면 400이 난다.
enum PlateActionCode {
  halveSoup('HALVE_SOUP', '국물을 절반만 남기기'),
  lessSpicy('LESS_SPICY', '매운 양념 덜어내기'),
  noSugarDrink('NO_SUGAR_DRINK', '단 음료 대신 물'),
  removeBatter('REMOVE_BATTER', '튀김옷 일부 제거'),
  // R10 은 고열량(900kcal 초과)이라 면·튀김에도 걸린다. 서버 라벨이 "밥·면" 인
  // 이유고, 나머지 넷과 마찬가지로 글자까지 서버와 같게 둔다.
  lessRice('LESS_RICE', '밥·면 조금 줄이기');

  const PlateActionCode(this.wire, this.label);

  /// 서버로 보내는 값
  final String wire;

  /// 버튼에 표시할 문구
  final String label;

  static PlateActionCode? fromJson(String value) {
    for (final code in PlateActionCode.values) {
      if (code.wire == value) return code;
    }
    return null; // 서버가 새 액션을 추가해도 앱이 죽지 않는다
  }

  /// 어느 감점 카드에 이 버튼을 붙일지 결정한다.
  /// 서버 `PlateActionCode.relatedRuleCode()` 와 같은 표다 — 한쪽만 고치면
  /// 버튼이 엉뚱한 카드에 붙거나 아예 안 뜬다.
  static PlateActionCode? forRuleCode(String? ruleCode) => switch (ruleCode) {
        'R04' => halveSoup,
        'R02' => lessSpicy,
        'R03' => noSugarDrink,
        'R07' => removeBatter,
        'R10' => lessRice, // 고열량(900kcal 초과)
        _ => null,
      };
}
