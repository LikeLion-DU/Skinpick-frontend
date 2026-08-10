/// 서버 IngredientTag enum과 값이 일치해야 한다.
/// 서버가 새 태그를 추가해도 앱이 죽지 않도록 기본값을 etc로 둔다.
enum IngredientTag {
  vitaminC,
  vitaminA,
  omega3,
  antioxidant,
  probiotic,
  dairy,
  gluten,
  capsaicin,
  caffeine,
  alcohol,
  highGi,
  etc;

  static IngredientTag fromJson(String value) => switch (value) {
        'VITAMIN_C' => IngredientTag.vitaminC,
        'VITAMIN_A' => IngredientTag.vitaminA,
        'OMEGA3' => IngredientTag.omega3,
        'ANTIOXIDANT' => IngredientTag.antioxidant,
        'PROBIOTIC' => IngredientTag.probiotic,
        'DAIRY' => IngredientTag.dairy,
        'GLUTEN' => IngredientTag.gluten,
        'CAPSAICIN' => IngredientTag.capsaicin,
        'CAFFEINE' => IngredientTag.caffeine,
        'ALCOHOL' => IngredientTag.alcohol,
        'HIGH_GI' => IngredientTag.highGi,
        _ => IngredientTag.etc,
      };
}
