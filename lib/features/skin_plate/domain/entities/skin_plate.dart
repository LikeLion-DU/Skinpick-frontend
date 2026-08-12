import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/plate_action_code.dart';

class SkinPlate {
  const SkinPlate({
    required this.id,
    required this.skinAnalysisId,
    required this.plateScore,
    this.baseScore = 70,
    required this.summary,
    required this.food,
    required this.good,
    required this.caution,
    required this.actions,
    required this.appliedRules,
    required this.createdAt,
  });

  final int id;

  /// 이 Plate 가 어떤 피부 분석을 기준으로 계산됐는지. S08 추천 조회에 쓴다.
  final int skinAnalysisId;

  final int plateScore;

  /// 계산 내역 카드의 첫 줄("기본 70"). 앱이 하드코딩하면 클램프된 점수에서 역산이 틀린다.
  final int baseScore;

  final String summary;
  final FoodAnalysis food;

  final List<PlateFeedback> good;
  final List<PlateFeedback> caution;

  /// 화면에서 가장 강조되는 카드. 이 제품의 존재 이유다.
  final List<PlateAction> actions;

  final List<String> appliedRules;
  final DateTime createdAt;

  /// 여기에 potentialScore(= plateScore + expectedGain 합산) 같은 게터를 만들지 마라.
  /// 합산은 실제 재계산과 일치하지 않는다.
  ///
  ///   예시 A 합산: 60 + 8 + 6 = 74   ← 어디에도 없는 숫자
  ///   실제 재계산: 국물만 절반 → 68  (나트륨 925mg이 되어 R04가 아예 미발동)
  ///                둘 다 실행  → 80
  ///
  /// "실행하면 몇 점"은 POST /plates/{id}/simulate 로 서버에 물어본다.
}

class PlateFeedback {
  const PlateFeedback({
    required this.message,
    required this.scoreDelta,
    required this.ruleCode,
  });

  final String message;
  final int scoreDelta;
  final String? ruleCode;
}

class PlateAction {
  const PlateAction({
    required this.message,
    required this.expectedGain,
    required this.ruleCode,
  });

  final String message;
  final int expectedGain;
  final String? ruleCode;
}

class FoodAnalysis {
  const FoodAnalysis({
    required this.id,
    required this.foodName,
    required this.foodCategory,
    required this.cookingMethod,
    required this.spicy,
    required this.ingredients,
    required this.nutrition,
  });

  final int id;
  final String foodName;
  final String? foodCategory;
  final CookingMethod cookingMethod;
  final bool spicy;
  final List<Ingredient> ingredients;
  final Nutrition nutrition;
}

class Ingredient {
  const Ingredient({required this.name, required this.tag});

  final String name;
  final IngredientTag tag;
}

class Nutrition {
  const Nutrition({
    required this.caloriesKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.sodiumMg,
    required this.sugarG,
  });

  final int caloriesKcal;
  final double proteinG;
  final double fatG;
  final double carbG;
  final int sodiumMg;
  final double sugarG;
}

/// 추천 행동 실행 시뮬레이션 결과. POST /plates/{id}/simulate 응답.
class PlateSimulation {
  const PlateSimulation({
    required this.plateId,
    required this.beforeScore,
    required this.afterScore,
    required this.appliedActions,
    required this.removedRules,
    required this.summary,
  });

  final int plateId;
  final int beforeScore;
  final int afterScore;
  final List<PlateActionCode> appliedActions;
  final List<String> removedRules;
  final String summary;

  int get gain => afterScore - beforeScore;
}
