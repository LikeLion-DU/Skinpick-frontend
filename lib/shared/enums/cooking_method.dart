enum CookingMethod {
  fried,
  boiled,
  grilled,
  raw,
  steamed,
  etc;

  static CookingMethod fromJson(String value) => switch (value) {
        'FRIED' => CookingMethod.fried,
        'BOILED' => CookingMethod.boiled,
        'GRILLED' => CookingMethod.grilled,
        'RAW' => CookingMethod.raw,
        'STEAMED' => CookingMethod.steamed,
        _ => CookingMethod.etc,
      };

  String get label => switch (this) {
        CookingMethod.fried => '튀김',
        CookingMethod.boiled => '국물',
        CookingMethod.grilled => '구이',
        CookingMethod.raw => '생식',
        CookingMethod.steamed => '찜',
        CookingMethod.etc => '기타',
      };
}
