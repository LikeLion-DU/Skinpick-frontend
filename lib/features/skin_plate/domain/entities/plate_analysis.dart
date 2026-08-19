import '../../../../shared/enums/skin_basis.dart';
import 'skin_plate.dart';
import '../../../../shared/enums/skin_level.dart';

/// 저장 전 **임시** 분석 결과. 서버에 아무것도 남지 않은 상태다.
///
/// [SkinPlate] 를 재사용하지 않는 이유 — 그러려면 `id` 와 `createdAt` 을 null 로
/// 채워야 하고, 그 순간 "저장된 기록"과 "아직 저장 안 된 결과"를 타입으로 구분할
/// 수 없게 된다. 화면 어딘가에서 `plate.id!` 한 줄이면 런타임에 터진다.
///
/// 이 클래스에는 [analysisToken] 이 있고 `id` 가 없다. 저장된 것에는 그 반대다.
/// 헷갈릴 수 없는 형태로 둔다.
class PlateAnalysis implements PlateView {
  const PlateAnalysis({
    required this.analysisToken,
    required this.skinAnalysisId,
    this.skinBasis,
    this.skinMeasuredAt,
    required this.plateScore,
    this.grade,
    this.baseScore,
    required this.summary,
    required this.food,
    required this.good,
    required this.caution,
    required this.actions,
    required this.appliedRules,
  });

  /// 서명된 토큰. 안에 AI 원본이 들어 있어서 서버가 저장할 때 점수를 다시 계산한다.
  /// TTL 30분. 저장 요청이 실패해도 **버리지 않는다** — 같은 토큰으로 재시도한다.
  /// 서버가 토큰 안의 jti 로 멱등을 보장하므로 몇 번 보내도 기록은 하나다.
  final String analysisToken;

  @override
  final int skinAnalysisId;

  /// 아직 저장 전이라 **기준일이 오늘**이다. [SkinBasis.today] 를 "오늘 피부 기준"
  /// 으로 그대로 써도 된다 — 저장된 기록([SkinPlate])과 갈리는 지점이다.
  @override
  final SkinBasis? skinBasis;
  @override
  final DateTime? skinMeasuredAt;

  @override
  final int plateScore;

  @override
  final SkinLevel? grade;
  @override
  /// 룰 적용 전 기준 점수. **서버 `RuleConstants.BASE_SCORE` 가 주인이다.**
  ///
  /// 확정 시안이 계산 내역 카드를 지워서 지금 이 값을 그리는 화면은 없다.
  /// 계약에는 남아 있으므로 필드도 남긴다 — 지웠다 되살리면 그때 계약을
  /// 처음부터 다시 맞춰야 한다(시뮬레이션 코드와 같은 이유).
  final int? baseScore;
  @override
  final String summary;
  @override
  final FoodAnalysis food;
  @override
  final List<PlateFeedback> good;
  @override
  final List<PlateFeedback> caution;
  @override
  final List<PlateAction> actions;
  @override
  final List<String> appliedRules;
}
