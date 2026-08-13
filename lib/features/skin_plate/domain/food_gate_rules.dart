import 'entities/food_detection.dart';
import 'food_gate_config.dart';

/// 최근 분석 결과를 모아 상태를 낸다. **한 프레임으로 판정하지 않는다.**
///
/// 손에 든 카메라는 흔들리고 초점이 오간다. 프레임 하나만 보면 같은 접시를
/// 비추고 있는데도 "음식 감지됨" 과 "음식이 잘 보이도록" 이 번갈아 깜빡인다.
///
/// ML Kit 도 카메라도 모르는 순수 로직이라 그대로 테스트할 수 있다.
class FoodDetectionWindow {
  final List<bool> _recent = [];

  /// 지금까지 본 프레임 중 마지막 [FoodGateConfig.windowSize] 개의 통과 여부.
  int get positives => _recent.where((ok) => ok).length;
  int get samples => _recent.length;

  /// 음식 후보 라벨의 최고 신뢰도를 넣는다. 후보가 없었으면 null.
  void add(double? foodConfidence) {
    _recent.add(
      foodConfidence != null &&
          foodConfidence >= FoodGateConfig.confidenceThreshold,
    );
    if (_recent.length > FoodGateConfig.windowSize) _recent.removeAt(0);
  }

  void clear() => _recent.clear();

  FoodDetectionState get state {
    // 긍정은 빠르게 준다. 창이 다 차기를 기다리면 음식을 비춘 뒤에도
    // 안내가 한 박자 늦게 바뀌어서 반응이 굼떠 보인다.
    if (positives >= FoodGateConfig.requiredPositiveFrames) {
      return FoodDetectionState.foodDetected;
    }
    // 부정은 창이 다 찬 뒤에만 준다. 근거가 모자란 상태에서 "음식이 아니다" 를
    // 띄우면, 카메라를 들이대는 첫 순간마다 경고가 번쩍인다.
    if (samples >= FoodGateConfig.windowSize) {
      return FoodDetectionState.notFood;
    }
    return FoodDetectionState.checking;
  }
}

/// 라벨 목록에서 음식 후보의 최고 신뢰도를 뽑는다.
///
/// [labels] 는 (이름, 신뢰도) 쌍이다. ML Kit 타입을 쓰지 않아 테스트가 가능하다.
FoodObservation observeFood(List<(String, double)> labels) {
  String? topLabel;
  double? topConfidence;

  for (final (name, confidence) in labels) {
    if (!FoodGateConfig.foodLabels.contains(name.toLowerCase())) continue;
    if (topConfidence == null || confidence > topConfidence) {
      topLabel = name;
      topConfidence = confidence;
    }
  }

  return FoodObservation(
    topLabel: topLabel,
    confidence: topConfidence,
    // 후보에 없던 라벨도 그대로 남긴다 — 후보 집합을 실기기에서 다듬는 근거다.
    allLabels: [for (final (name, c) in labels) '$name ${c.toStringAsFixed(2)}'],
  );
}
