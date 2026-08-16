import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_plate/domain/entities/food_detection.dart';

/// 게이트 상태와 화면 문구가 1:1 이어야 한다.
///
/// 예전에는 화면이 notFood 만 상태 문구를 쓰고 나머지는 고정 문구를 썼다. 그래서
/// 음식을 잡은 순간에도 "잘 보이도록 촬영해 주세요"가 남아, AI 가 알아봤는지
/// 사용자가 알 수 없었다. 문구가 세 갈래로 갈리는 것을 여기서 고정한다.
void main() {
  test('세 상태가 서로 다른 문구를 가진다', () {
    final guides =
        FoodDetectionState.values.map((state) => state.guide).toList();

    expect(guides.toSet(), hasLength(FoodDetectionState.values.length),
        reason: '두 상태가 같은 문구면 사용자는 상태가 바뀐 것을 알 수 없다');
    expect(guides.every((guide) => guide.isNotEmpty), isTrue);
  });

  test('음식을 잡으면 조정하라고 하지 않는다', () {
    // 이 문장이 감지 상태에 남아 있던 것이 신고된 증상이다.
    expect(FoodDetectionState.foodDetected.guide, isNot(contains('조정')));
    expect(FoodDetectionState.foodDetected.guide, contains('감지'));
  });

  test('못 잡았을 때만 카메라를 조정하라고 한다', () {
    expect(FoodDetectionState.notFood.guide, contains('조정'));
    expect(FoodDetectionState.checking.guide, isNot(contains('조정')));
  });
}
