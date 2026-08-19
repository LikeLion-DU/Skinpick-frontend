/// 서버 SkinType enum과 이름이 정확히 같아야 한다.
enum SkinType {
  dry('DRY', '건성'),
  oily('OILY', '지성'),
  combination('COMBINATION', '복합성'),
  sensitive('SENSITIVE', '민감성'),

  /// 수분은 부족한데 유분은 올라와 있는 상태. 사용자가 부르는 이름이 '수부지' 다.
  ///
  /// **자가 신고 전용이다.** 서버 `observe()` 는 이 값을 내지 않는다 — 관찰 쪽에서
  /// 그 상태를 맡는 것은 `SkinTrait.DEHYDRATED` 이고, 그쪽이 이미 `skinType.label`
  /// 에 '(수부지)' 별칭을 붙인다. `SENSITIVE` 와 같은 부류다.
  dehydratedOily('DEHYDRATED_OILY', '수부지'),
  normal('NORMAL', '보통'),
  unknown('UNKNOWN', '잘 모르겠어요');

  const SkinType(this.wire, this.label);

  final String wire;
  final String label;

  /// S01c 선택 화면에 노출할 칩. normal 은 관찰 전용이라 뺀다.
  ///
  /// 순서가 화면 순서다 — 시안이 2열로 여섯 칸을 그리고, "잘 모르겠어요"가
  /// 마지막이다(목록 중간에 있으면 그 아래 칸을 안 읽는다).
  /// **서버 `SkinType.selectable()` 과 같은 순서여야 한다.**
  static const selectable =
      [dry, oily, combination, sensitive, dehydratedOily, unknown];

  /// 선택 타일에 쓰는 그림. 시안이 타입·고민을 아이콘 시트 한 장에 담아 놨고,
  /// 거기서 글리프만 잘라 낸 파일들이다. 라벨은 그림에 구워져 있던 것을 빼고
  /// 앱이 텍스트로 그린다 — 그러지 않으면 글자 크기 설정이 안 먹는다.
  ///
  /// 한 색(오렌지)으로만 두고 미선택은 `ColorFiltered` 로 회색을 입힌다.
  /// 시트에는 회색 벌도 있지만, 두 벌을 넣으면 색을 바꿀 때 두 파일을 갈아야 한다.
  ///
  /// [sensitive] 는 시트에 타입용 그림이 없어 고민 쪽 "민감(홍조)" 글리프를 쓴다 —
  /// 같은 얼굴 계열이라 나란히 두어도 어색하지 않다. 시트에 있는 "수부지" 는
  /// 서버 `SkinType` 에 대응하는 값이 없어 넣지 않았다.
  String get glyph => switch (this) {
        dry => 'assets/icons/skin_type_dry.png',
        oily => 'assets/icons/skin_type_oily.png',
        combination => 'assets/icons/skin_type_combination.png',
        sensitive => 'assets/icons/skin_concern_redness.png',
        dehydratedOily => 'assets/icons/skin_type_dehydrated_oily.png',
        normal => 'assets/icons/skin_type_unknown.png',
        unknown => 'assets/icons/skin_type_unknown.png',
      };

  /// 타입 한 줄 설명. **서버에 이 필드가 없다** — 시안(마이페이지)이 타입 아래
  /// 설명 줄을 요구하는데 `skinType` 응답은 `primary`·`traits`·`label` 뿐이다.
  ///
  /// AI 문장이 아니라 **enum 에 붙는 고정 UI 문구**라 앱에 둔다([SkinLevel.summary]
  /// 와 같은 부류다). 숫자도 판정도 언급하지 않고, 값이 달라지지도 않는다 —
  /// 서버가 설명 필드를 주기 시작하면 이 게터를 지우고 그 값을 쓰면 된다.
  ///
  /// [unknown] 은 null 이다. "잘 모르겠어요"는 피부 타입이 아니라 미선택 표시라
  /// 설명할 대상이 없다.
  String? get description => switch (this) {
        dry => '수분과 유분이 모두 부족해 당김이 느껴지는 피부 타입이에요.',
        oily => '유분이 많아 번들거림과 모공이 두드러지는 피부 타입이에요.',
        combination => 'T존은 유분이 있고, U존은 건조한 피부 타입이에요.',
        sensitive => '자극에 쉽게 붉어지고 따가움을 느끼는 피부 타입이에요.',
        dehydratedOily => '유분은 있는데 속은 당기는, 수분이 부족한 지성 피부예요.',
        normal => '수분과 유분이 비교적 균형 잡힌 피부 타입이에요.',
        unknown => null,
      };

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
