/// 카메라 화면이 지금 음식으로 보이는가.
///
/// **음식 종류·영양성분과는 무관하다.** 떡볶이인지, 칼로리가 얼마인지는 촬영 후
/// 서버의 OpenAI Vision 이 정한다. 여기서 하는 일은 촬영 가이드 하나뿐이다.
enum FoodDetectionState {
  /// 아직 판단할 만큼 프레임이 쌓이지 않았다.
  checking,

  /// 최근 프레임들이 음식으로 보인다.
  foodDetected,

  /// 최근 프레임들이 음식으로 보이지 않는다.
  notFood;

  /// 화면에 그대로 띄우는 문구.
  String get guide => switch (this) {
        FoodDetectionState.checking => '음식을 비춰주세요',
        FoodDetectionState.foodDetected => '음식이 감지됐어요',
        FoodDetectionState.notFood => '음식이 잘 보이도록 카메라를 조정해주세요',
      };
}

/// 한 프레임의 라벨링 결과 중 **음식 후보 라벨의 최고 신뢰도**.
///
/// 라벨 이름을 들고 있는 건 디버그 표시와 임계값 튜닝 때문이다. 판정에는
/// [confidence] 만 쓴다.
class FoodObservation {
  const FoodObservation({this.topLabel, this.confidence, this.allLabels = const []});

  /// 음식 후보 중 가장 신뢰도가 높았던 라벨. 없으면 null.
  final String? topLabel;

  /// 그 라벨의 신뢰도(0~1). 음식 후보가 없으면 null.
  final double? confidence;

  /// 디버그용 상위 라벨 목록. **후보 집합을 실기기에서 다듬을 때 쓴다.**
  /// 릴리즈 화면에는 노출하지 않는다.
  final List<String> allLabels;

  static const empty = FoodObservation();
}
