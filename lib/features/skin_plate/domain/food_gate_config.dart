/// 음식 감지 게이트의 상수를 한 파일에 모은다.
///
/// 실기기에서 실제 음식을 비춰 보면 거의 반드시 손대게 되는 값들이다.
/// 판정 코드 안에 흩어져 있으면 튜닝할 때마다 로직을 읽어야 한다.
class FoodGateConfig {
  const FoodGateConfig._();

  /// 이 신뢰도를 넘어야 그 프레임을 "음식" 쪽 한 표로 센다.
  static const double confidenceThreshold = 0.70;

  /// 최근 몇 개의 분석 결과를 보고 판단하는가.
  static const int windowSize = 5;

  /// 그중 몇 개가 임계값을 넘어야 음식으로 보는가.
  static const int requiredPositiveFrames = 3;

  /// 프레임 분석 최소 간격. 카메라는 30fps 로 들어오지만 전부 ML Kit 에 넘기면
  /// 프리뷰가 끊기고 배터리만 먹는다. 150ms 면 약 6~7fps 로, 손에 든 카메라가
  /// 흔들리는 속도를 따라가기에 충분하다.
  static const Duration analysisInterval = Duration(milliseconds: 150);

  /// 라벨러가 이 값 아래는 아예 돌려주지 않게 한다. 판정 임계값
  /// ([confidenceThreshold])보다 낮게 두어야 디버그 화면에서 "0.6까지 나왔는데
  /// 왜 안 잡히지" 를 눈으로 확인할 수 있다.
  static const double labelerConfidenceFloor = 0.40;

  /// 음식으로 볼 라벨 후보. **소문자로 비교한다.**
  ///
  /// ⚠️ 이 목록은 실기기에서 검증하고 다듬어야 한다. ML Kit 기본 모델이 실제로
  /// 어떤 라벨을 돌려주는지는 기기·모델 버전에 따라 다르고, 여기 없는 이름이
  /// 나오면 음식인데도 잡히지 않는다. 디버그 오버레이가 상위 라벨을 그대로
  /// 보여주므로(§12) 음식 5종·비음식 5종을 비춰 보고 목록을 조정한다.
  ///
  /// 넓게 잡아 둔 이유 — 이 게이트는 촬영을 막지 않는다. 놓치는 쪽(미탐)이
  /// 잘못 잡는 쪽(오탐)보다 사용자에게 더 나쁘다. 실제 음식을 비췄는데
  /// "음식이 잘 보이도록" 이 계속 뜨면 사용자는 앱을 의심한다.
  static const Set<String> foodLabels = {
    'food',
    'dish',
    'cuisine',
    'meal',
    'snack',
    'dessert',
    'fast food',
    'junk food',
    'fried food',
    'baked goods',
    'bread',
    'cake',
    'chocolate',
    'cookies and crackers',
    'salad',
    'soup',
    'stew',
    'noodle',
    'pasta',
    'rice',
    'pizza',
    'hamburger',
    'sandwich',
    'sushi',
    'barbecue',
    'meat',
    'seafood',
    'fish',
    'egg',
    'cheese',
    'vegetable',
    'fruit',
    'produce',
    'ingredient',
    'recipe',
    'breakfast',
    'lunch',
    'supper',
    'drink',
    'juice',
    'coffee',
  };
}
