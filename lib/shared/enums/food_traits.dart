/// AI 가 사진에서 읽은 음식 특성 5종.
///
/// **서버는 "모른다"를 null 이 아니라 문자열로 내려보낸다** — `UNKNOWN`, foodGroup 만
/// `ETC` 다. 키를 빼면 앱이 행마다 다른 모양을 다뤄야 하기 때문이다. 그래서 null
/// 체크만 하면 화면에 UNKNOWN 이 그대로 뜬다. 옛 기록만의 문제도 아니다 — 서버
/// 프롬프트가 "확실하지 않으면 UNKNOWN" 을 강제해서 새로 찍은 사진에도 흔하다.
///
/// 숨김 판단은 [label] 이 한다. `null` 을 돌려주는 값은 화면에 칩을 그리지 않고,
/// [label] 자체가 없는 것(foodGroup·portionSize·processingLevel)은 아예 안 그린다.
/// 화면마다 `!= unknown` 을 다시 쓰면 한 곳을 빠뜨린다.
///
/// 모르는 값은 예외를 던지지 않고 unknown(foodGroup 은 etc)으로 떨어뜨린다.
/// 서버와 같은 규칙이라 값이 늘어도 화면이 일관된다.
library;

/// 음식 분류. **화면에 노출하지 않는다** — 결과 화면에 자리가 없다.
/// 파싱만 해두면 나중에 서버 작업 없이 붙는다.
enum FoodGroup {
  rice,
  noodle,
  soupStew,
  meatDish,
  seafoodDish,
  vegetableDish,
  friedFood,
  dessert,
  beverage,
  snack,
  salad,
  etc;

  static FoodGroup fromJson(String? value) => switch (value) {
        'RICE' => rice,
        'NOODLE' => noodle,
        'SOUP_STEW' => soupStew,
        'MEAT_DISH' => meatDish,
        'SEAFOOD_DISH' => seafoodDish,
        'VEGETABLE_DISH' => vegetableDish,
        'FRIED_FOOD' => friedFood,
        'DESSERT' => dessert,
        'BEVERAGE' => beverage,
        'SNACK' => snack,
        'SALAD' => salad,
        _ => etc,
      };
}

/// 예상 섭취량. **화면에 노출하지 않는다** — 그래서 [label] 이 없다.
///
/// AI 가 사진에서 본 대략의 양이라 사용자가 실제로 먹은 양과 다르고, 척도를
/// 정의한 기준도 없다("사진에서 관찰한 것만" 이 프롬프트 규칙의 전부다).
/// 그 값을 화면에 숫자처럼 얹으면 사용자가 자기 식사량을 되짚는 근거로 읽는다.
///
/// 서버 쪽 쓰임(저장 · 리포트 영양 환산 0.7/1.0/1.3)은 그대로다. 앱은 파싱만 하고
/// 점수도 영양값도 이 값으로 다시 계산하지 않는다.
enum PortionSize {
  small,
  medium,
  large,
  unknown;

  static PortionSize fromJson(String? value) => switch (value) {
        'SMALL' => small,
        'MEDIUM' => medium,
        'LARGE' => large,
        _ => unknown,
      };
}

enum Spiciness {
  none,
  mild,
  medium,
  hot,
  unknown;

  static Spiciness fromJson(String? value) => switch (value) {
        'NONE' => none,
        'MILD' => mild,
        'MEDIUM' => medium,
        'HOT' => hot,
        _ => unknown,
      };

  /// **[none] 도 숨긴다.** 서버 R02(매운맛 자극)는 이 값이 아니라 표준 음식
  /// 테이블의 `spicy` 와 재료의 CAPSAICIN 태그로 발동한다 — 서버 룰이
  /// "NONE(캡사이신으로만 발동)은 강도 1.0" 이라고 명시할 만큼 정상 조합이다.
  /// 그래서 "매운 정도 · 안 매움" 칩과 바로 아래 "매운맛 자극" 경고가 한 화면에
  /// 같이 뜬다. 앱이 자기 말을 뒤집는다.
  ///
  /// 짝이 맞는지를 앱에서 다시 판정하지 않는다(그건 서버 룰을 두 벌로 만드는 것이다).
  /// 정보량이 없는 쪽을 안 그려서 모순을 구조적으로 없앤다.
  String? get label => switch (this) {
        mild => '약간 매움',
        medium => '보통',
        hot => '많이 매움',
        none || unknown => null,
      };
}

enum Oiliness {
  low,
  medium,
  high,
  unknown;

  static Oiliness fromJson(String? value) => switch (value) {
        'LOW' => low,
        'MEDIUM' => medium,
        'HIGH' => high,
        _ => unknown,
      };

  /// **[low] 도 숨긴다.** [Spiciness.none] 과 같은 이유다 — 서버 R07 은
  /// `isFried() || oiliness == HIGH` 라 조리법이 FRIED 이기만 하면 발동한다.
  /// `cookingMethod=FRIED` + `oiliness=LOW` 면 "기름기 · 담백" 칩 아래에
  /// "튀김 조리" 경고가 붙는다.
  String? get label => switch (this) {
        medium => '보통',
        high => '기름진 편',
        low || unknown => null,
      };
}

/// 가공도. **화면에 노출하지 않는다** — 서버도 아직 점수에 쓰지 않는 축적용이다.
enum ProcessingLevel {
  whole,
  minimallyProcessed,
  processed,
  ultraProcessed,
  unknown;

  static ProcessingLevel fromJson(String? value) => switch (value) {
        'WHOLE' => whole,
        'MINIMALLY_PROCESSED' => minimallyProcessed,
        'PROCESSED' => processed,
        'ULTRA_PROCESSED' => ultraProcessed,
        _ => unknown,
      };
}
