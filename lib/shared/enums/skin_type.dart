/// 서버 SkinType enum과 이름이 정확히 같아야 한다.
enum SkinType {
  dry('DRY', '건성'),
  oily('OILY', '지성'),
  combination('COMBINATION', '복합성'),
  sensitive('SENSITIVE', '민감성'),
  normal('NORMAL', '보통'),
  unknown('UNKNOWN', '잘 모르겠어요');

  const SkinType(this.wire, this.label);

  final String wire;
  final String label;

  /// S01c 선택 화면에 노출할 칩. normal 은 관찰 전용이라 뺀다.
  static const selectable = [dry, oily, combination, sensitive, unknown];

  /// null / 미지원 값은 null 로 흘려보낸다.
  /// "아직 안 정함"과 "잘 모르겠어요(unknown)"는 다르므로 기본값을 두지 않는다.
  static SkinType? fromJson(String? value) {
    if (value == null) return null;
    for (final type in SkinType.values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}
