import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/plate_action_code.dart';

/// 결과 화면이 실제로 그리는 면(面)만 모은 것.
///
/// 저장 전 임시 분석([PlateAnalysis])과 저장된 기록([SkinPlate])은 **다른 것**이지만
/// 화면에 그려지는 내용은 같다. 위젯을 두 벌 만들지 않으려고 이 인터페이스를 공유한다.
///
/// 여기에 `id` 나 `createdAt` 을 넣지 마라. 그 둘이 있으면 "저장됨"이라는 뜻이고,
/// 임시 분석은 그걸 가질 수 없다. 화면이 저장 여부를 알아야 한다면 이 타입이 아니라
/// PlateState 의 recordStatus 를 봐야 한다.
abstract interface class PlateView {
  int get skinAnalysisId;
  int get plateScore;
  int get baseScore;
  String get summary;
  FoodAnalysis get food;
  List<PlateFeedback> get good;
  List<PlateFeedback> get caution;
  List<PlateAction> get actions;
  List<String> get appliedRules;
}

/// 저장이 확정된 기록. `id` 와 `createdAt` 이 있다는 것이 곧 "서버에 남았다"는 뜻이다.
class SkinPlate implements PlateView {
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
    this.aiTip,
    required this.createdAt,
  });

  final int id;

  /// 이 Plate 가 어떤 피부 분석을 기준으로 계산됐는지. S08 추천 조회에 쓴다.
  @override
  final int skinAnalysisId;

  @override
  final int plateScore;

  /// 계산 내역 카드의 첫 줄("기본 70"). 앱이 하드코딩하면 클램프된 점수에서 역산이 틀린다.
  @override
  final int baseScore;

  @override
  final String summary;

  /// "AI 맞춤 TIP". 서버 생성이 실패한 기록은 null 이고, 화면은 룰 요약으로 대신한다.
  final String? aiTip;

  @override
  final FoodAnalysis food;

  @override
  final List<PlateFeedback> good;
  @override
  final List<PlateFeedback> caution;

  /// 화면에서 가장 강조되는 카드. 이 제품의 존재 이유다.
  @override
  final List<PlateAction> actions;

  @override
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
    this.id,
    required this.foodName,
    required this.foodCategory,
    required this.cookingMethod,
    required this.spicy,
    required this.ingredients,
    required this.nutrition,
  });

  /// 저장 전에는 없다 — 행이 아직 없으므로 서버가 키 자체를 뺀다.
  /// 기록(`POST /plates/records` 201) 이후 응답에만 들어 있다.
  final int? id;
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

/// 추천 행동 실행 시뮬레이션 결과.
///
/// 저장 전에는 `POST /plates/simulate`(analysisToken), 저장 후에는
/// `POST /plates/{id}/simulate`(plateId) 가 같은 모양으로 준다.
/// 어느 쪽으로 물었는지는 결과에 남지 않는다 — 화면이 알 필요가 없다.
class PlateSimulation {
  const PlateSimulation({
    required this.beforeScore,
    required this.afterScore,
    required this.appliedActions,
    required this.removedRules,
    required this.summary,
  });

  final int beforeScore;
  final int afterScore;
  final List<PlateActionCode> appliedActions;
  final List<String> removedRules;
  final String summary;

  int get gain => afterScore - beforeScore;
}
