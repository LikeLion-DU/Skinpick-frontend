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
  /// 실측(에뮬레이터 + 맥북 웹캠, 화면에 띄운 음식 사진):
  ///
  /// | 대상 | 상위 라벨 | 판정 |
  /// |---|---|---|
  /// | 떡볶이 | `Food 0.80` · Flesh 0.66 · Vegetable 0.62 · Bird 0.52 | foodDetected |
  /// | 얼굴 | Hair 0.98 · Cool 0.91 · Ear 0.81 · Bangs 0.71 | notFood |
  /// | 손 | Hand 0.95 · Nail 0.77 · Mobile phone 0.53 | notFood |
  ///
  /// `Food` 가 실제로 존재하고 0.80~0.95 로 나온다는 것까지 확인했다.
  ///
  /// **`Flesh` 는 일부러 넣지 않았다.** 음식에서 0.66 으로 뜨지만 살·과육을
  /// 가리키는 라벨이라 사람 피부에서도 뜬다. 넣으면 얼굴·손을 비췄을 때 음식으로
  /// 오탐하고, 그건 이 게이트가 만들 수 있는 가장 나쁜 실패다.
  ///
  /// ⚠️ 아직 다 못 본 것 — 김치찌개·밥·치킨·햄버거·여러 음식이 놓인 식탁,
  /// 풍경·자동차·건물·문서·빈 테이블·메뉴판, 그리고 경계 케이스(작은 음식,
  /// 일부만 보임, 어두움, 흔들림, 음식+사람). 디버그 오버레이가 상위 라벨을
  /// 그대로 보여주므로(§12) 비춰 보고 목록을 조정한다.
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
