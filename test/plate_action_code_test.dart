import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/shared/enums/plate_action_code.dart';

/// 이 표는 서버 `PlateActionCode.relatedRuleCode()` 와 쌍이다.
/// 한쪽만 고치면 버튼이 엉뚱한 카드에 붙거나 아예 안 뜨는데,
/// 화면은 멀쩡해 보여서 시연 직전까지 아무도 모른다.
void main() {
  test('룰 코드에 맞는 행동 버튼이 붙는다', () {
    expect(PlateActionCode.forRuleCode('R04'), PlateActionCode.halveSoup);
    expect(PlateActionCode.forRuleCode('R02'), PlateActionCode.lessSpicy);
    expect(PlateActionCode.forRuleCode('R03'), PlateActionCode.noSugarDrink);
    expect(PlateActionCode.forRuleCode('R07'), PlateActionCode.removeBatter);
    expect(PlateActionCode.forRuleCode('R10'), PlateActionCode.lessRice);
  });

  test('버튼이 없는 룰과 null 은 조용히 비운다 — 앱이 죽지 않는다', () {
    expect(PlateActionCode.forRuleCode('R05'), isNull); // 가점 룰이라 행동이 없다
    expect(PlateActionCode.forRuleCode('R99'), isNull); // 아직 없는 룰
    expect(PlateActionCode.forRuleCode(null), isNull);
  });

  test('서버로 보내는 값은 서버 enum 이름과 같아야 한다 — 다르면 400이다', () {
    expect(PlateActionCode.halveSoup.wire, 'HALVE_SOUP');
    expect(PlateActionCode.lessSpicy.wire, 'LESS_SPICY');
    expect(PlateActionCode.noSugarDrink.wire, 'NO_SUGAR_DRINK');
    expect(PlateActionCode.removeBatter.wire, 'REMOVE_BATTER');
    expect(PlateActionCode.lessRice.wire, 'LESS_RICE');
  });

  test('모르는 액션이 와도 null 로 흘려보낸다', () {
    expect(PlateActionCode.fromJson('SKIP_DESSERT'), isNull);
  });
}
