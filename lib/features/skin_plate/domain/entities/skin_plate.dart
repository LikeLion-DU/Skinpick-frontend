import '../../../../shared/enums/cooking_method.dart';
import '../../../../shared/enums/food_traits.dart';
import '../../../../shared/enums/ingredient_tag.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../../../shared/enums/skin_basis.dart';

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

  /// 어느 날 피부로 계산됐는지. 옛 기록에는 없어서 null 이고, 그때 화면은
  /// 아무 문구도 그리지 않는다 — 지어내면 그게 거짓말이 된다.
  SkinBasis? get skinBasis;
  DateTime? get skinMeasuredAt;

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
    this.skinBasis,
    this.skinMeasuredAt,
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

  /// **이 기록을 저장한 날** 기준이다. [SkinBasis.today] 라도 "오늘"이 아니라
  /// "기록 당일" 로 읽어야 한다 — 서버가 저장 시점에 굳혀 둔 값이라 시간이
  /// 지나도 안 바뀐다.
  @override
  final SkinBasis? skinBasis;
  @override
  final DateTime? skinMeasuredAt;

  @override
  final int plateScore;

  /// 계산 내역 카드의 첫 줄("기본 70"). 앱이 하드코딩하면 클램프된 점수에서 역산이 틀린다.
  @override
  final int baseScore;

  @override
  final String summary;

  /// "AI 맞춤 TIP". 서버 생성이 실패한 기록은 null 이다. **룰 요약으로 대신하지
  /// 않는다** — 그때 화면은 카드를 아예 그리지 않는다. AI 가 만들지 않은 문장에
  /// AI 제목을 붙이면, 저장 전후로 같은 자리의 문장이 갈린다.
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
    this.reason,
    required this.scoreDelta,
    required this.ruleCode,
  });

  /// 짧은 제목·라벨. "나트륨 과다"
  final String message;

  /// 지금 피부 상태와 음식 특성을 잇는 설명. 없는 기록(V8 이전)이 있으므로
  /// 화면은 제목만으로도 성립해야 한다.
  final String? reason;

  final int scoreDelta;
  final String? ruleCode;
}

/// 행동 제안. **[PlateFeedback.reason] 에 해당하는 필드가 없다** — 문구 자체가
/// 이미 설명이라 서버가 만들지 않는다. 여기에 reason 을 파 보려 하지 마라.
///
/// 주의(caution)와 1:1 이라고 가정하지도 마라. R07(기름기)이 튀김이 아닌 기름진
/// 음식에서 걸리면 "튀김옷을 제거하세요"가 성립하지 않아 짝이 되는 행동이 없다.
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
    this.foodGroup = FoodGroup.etc,
    this.portionSize = PortionSize.unknown,
    this.spiciness = Spiciness.unknown,
    this.oiliness = Oiliness.unknown,
    this.processingLevel = ProcessingLevel.unknown,
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

  /// 화면에 안 낸다 — 받아만 둔다.
  ///
  /// 분류·가공도는 결과 화면에 자리가 없고, 가공도는 서버도 아직 점수에 쓰지 않는
  /// 축적용이다. [portionSize] 는 척도를 정의한 기준이 없는 AI 관찰값이라 뺐다 —
  /// 서버는 저장·리포트 영양 환산에 계속 쓰지만 앱은 파싱만 한다. 이 값으로
  /// 점수도 영양값도 다시 계산하지 않는다.
  final FoodGroup foodGroup;
  final ProcessingLevel processingLevel;
  final PortionSize portionSize;

  /// 결과 화면 칩 2종. 값이 없으면(UNKNOWN, 그리고 서버 경고와 부딪히는
  /// NONE·LOW) 그 칩을 그리지 않는다 — [Spiciness.label] 참고.
  final Spiciness spiciness;
  final Oiliness oiliness;

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
