/// 서버 PlateActionCode enum과 이름이 정확히 같아야 한다.
/// 앱이 이 이름을 그대로 보내므로 한쪽만 바꾸면 400이 난다.
enum PlateActionCode {
  halveSoup('HALVE_SOUP', '국물을 절반만 남기기'),
  lessSpicy('LESS_SPICY', '매운 양념 덜어내기'),
  noSugarDrink('NO_SUGAR_DRINK', '단 음료 대신 물'),
  removeBatter('REMOVE_BATTER', '튀김옷 일부 제거');

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
}
