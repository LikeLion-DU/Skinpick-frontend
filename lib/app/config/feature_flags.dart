/// 만들어 뒀지만 지금은 내보내지 않는 기능들.
///
/// 확정된 시안에 행동 제안·시뮬레이션·추천 화면이 없다. 그렇다고 코드를 지우면
/// 서버의 룰 엔진·`/plates/simulate`·`/recommendations` 와 짝이 끊기고, 나중에
/// 되살릴 때 계약을 처음부터 다시 맞춰야 한다. 그래서 **코드는 두고 진입점만 막는다.**
///
/// 되살리는 방법은 여기 값을 `true` 로 바꾸는 것 하나다. 화면 코드에 `if` 를
/// 흩어 놓지 않는 이유가 그것이다 — 흩어 두면 어디를 켜야 하는지 아무도 모른다.
///
/// 관련 코드는 지우지 말 것:
/// - `PlateNotifier.simulate` · `clearSimulation`
/// - `PlateActionCode` 와 `plate_action_code_test.dart`
/// - `features/recommendation/**` 전체와 `Routes.recommendations`
class FeatureFlags {
  const FeatureFlags._();

  /// 행동 제안 버튼과 60 → 68 시뮬레이션.
  /// 시안의 결과 화면은 이 자리에 "AI 맞춤 TIP" 문장 하나를 둔다.
  static const bool actionSimulation = false;

  /// 추천/주의 음식 화면(S08). 시안에 해당 화면이 없다.
  static const bool recommendationScreen = false;
}
