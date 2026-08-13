import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_plate/domain/entities/food_detection.dart';
import 'package:skinplate/features/skin_plate/domain/food_gate_config.dart';
import 'package:skinplate/features/skin_plate/domain/food_gate_rules.dart';

/// 안정화 로직만 검증한다. ML Kit 도 카메라도 필요 없다 — 그러라고 순수 로직으로 갈랐다.
void main() {
  const pass = FoodGateConfig.confidenceThreshold + 0.1;
  const fail = FoodGateConfig.confidenceThreshold - 0.1;

  group('안정화 — 한 프레임으로 판정하지 않는다', () {
    test('시작은 checking', () {
      expect(FoodDetectionWindow().state, FoodDetectionState.checking);
    });

    test('통과 프레임이 모자라는 동안은 checking', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.requiredPositiveFrames - 1; i++) {
        window.add(pass);
        expect(window.state, FoodDetectionState.checking);
      }
    });

    test('통과가 기준을 채우면 foodDetected', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.requiredPositiveFrames; i++) {
        window.add(pass);
      }
      expect(window.state, FoodDetectionState.foodDetected);
    });

    test('섞여 있어도 기준을 채우면 foodDetected (지시서 예시)', () {
      final window = FoodDetectionWindow();
      for (final c in [0.82, 0.79, 0.84, 0.76, 0.81]) {
        window.add(c);
      }
      expect(window.state, FoodDetectionState.foodDetected);
    });

    test('창이 다 차기 전에는 notFood 를 내지 않는다 — 첫 순간마다 경고가 번쩍이면 안 된다', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.windowSize - 1; i++) {
        window.add(fail);
        expect(window.state, FoodDetectionState.checking);
      }
    });

    test('창이 다 찼는데 통과가 모자라면 notFood', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.windowSize; i++) {
        window.add(fail);
      }
      expect(window.state, FoodDetectionState.notFood);
    });

    test('임계값 미만과 라벨 없음(null)은 같이 취급한다', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.windowSize; i++) {
        window.add(null);
      }
      expect(window.state, FoodDetectionState.notFood);
    });

    test('창은 최근 것만 남긴다 — 오래된 통과가 계속 붙들지 않는다', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.requiredPositiveFrames; i++) {
        window.add(pass);
      }
      expect(window.state, FoodDetectionState.foodDetected);

      // 창 크기만큼 실패를 밀어 넣으면 통과 표가 전부 밀려난다.
      for (var i = 0; i < FoodGateConfig.windowSize; i++) {
        window.add(fail);
      }
      expect(window.samples, FoodGateConfig.windowSize);
      expect(window.positives, 0);
      expect(window.state, FoodDetectionState.notFood);
    });

    test('clear 하면 처음 상태로 돌아간다', () {
      final window = FoodDetectionWindow();
      for (var i = 0; i < FoodGateConfig.windowSize; i++) {
        window.add(pass);
      }
      window.clear();
      expect(window.state, FoodDetectionState.checking);
    });
  });

  group('라벨 해석', () {
    test('음식 후보 중 최고 신뢰도를 고른다', () {
      final observation = observeFood([('Dish', 0.61), ('Food', 0.88), ('Table', 0.95)]);
      expect(observation.topLabel, 'Food');
      expect(observation.confidence, 0.88);
    });

    test('대소문자를 가리지 않는다 — ML Kit 라벨 표기가 기기마다 흔들린다', () {
      expect(observeFood([('FOOD', 0.9)]).confidence, 0.9);
      expect(observeFood([('food', 0.9)]).confidence, 0.9);
    });

    test('음식 후보가 없으면 confidence 가 null 이다', () {
      final observation = observeFood([('Person', 0.97), ('Building', 0.8)]);
      expect(observation.topLabel, isNull);
      expect(observation.confidence, isNull);
    });

    test('후보에 없는 라벨도 디버그 목록에는 남는다 — 후보 집합을 다듬는 근거다', () {
      final observation = observeFood([('Person', 0.97)]);
      expect(observation.allLabels.single, startsWith('Person'));
    });
  });
}
