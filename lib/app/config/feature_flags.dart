/// 만들어 뒀지만 지금은 내보내지 않는 기능들.
///
/// 코드를 지우면 서버의 룰 엔진·`/plates/simulate` 와 짝이 끊기고, 나중에
/// 되살릴 때 계약을 처음부터 다시 맞춰야 한다. 그래서 **코드는 두고 진입점만 막는다.**
///
/// 되살리는 방법은 여기 값을 `true` 로 바꾸는 것 하나다. 화면 코드에 `if` 를
/// 흩어 놓지 않는 이유가 그것이다 — 흩어 두면 어디를 켜야 하는지 아무도 모른다.
///
/// 관련 코드는 지우지 말 것:
/// - `PlateNotifier.simulate` · `clearSimulation`
/// - `PlateActionCode` 와 `plate_action_code_test.dart`
class FeatureFlags {
  const FeatureFlags._();

  /// 행동 제안 버튼과 60 → 68 시뮬레이션.
  ///
  /// 꺼 둔다. 결과 화면의 그 자리는 "AI 맞춤 TIP" 문장이 쓰고, 행동 카드까지
  /// 얹으면 일반 사용자가 매 끼니 결정을 두 번 하게 된다.
  ///
  /// **데모에서 60 → 68 을 보일 때는 이 값만 `true` 로 바꾼다.** 화면·서버 계약은
  /// 이미 이어져 있어서 다른 손댈 곳이 없다.
  static const bool actionSimulation = false;

  /// 추천/주의 음식 화면(S08). "이 음식 먹어도 돼?" 다음 질문이 "그럼 뭘 먹어?" 라
  /// 음식 Loop 의 일부다. 결과 화면 하단 진입점으로 내보낸다.
  static const bool recommendationScreen = true;
}
