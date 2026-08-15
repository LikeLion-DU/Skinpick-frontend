import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';

/// wire 값이 서버 enum 과 1:1 이어야 왕복이 성립한다.
///
/// 하나라도 어긋나면 PATCH 는 400 이고, GET 은 조용히 null 이 된다 — 후자가 더 나쁘다.
/// "저장은 됐는데 다시 들어가면 미선택으로 뜬다"는 증상이라 원인이 안 보인다.
void main() {
  test('서버 enum 이름과 1:1', () {
    expect(SkinConcern.values.map((concern) => concern.wire).toSet(), {
      'ACNE',
      'REDNESS',
      'DARK_CIRCLE',
      'DRYNESS',
      'OILINESS',
      'TEXTURE',
      'PIGMENTATION',
      'ELASTICITY',
      'PUFFINESS',
    });
    expect(SleepPattern.values.map((pattern) => pattern.wire).toList(),
        ['LACKING', 'NORMAL', 'ENOUGH']);
    expect(StressLevel.values.map((level) => level.wire).toList(),
        ['LOW', 'NORMAL', 'HIGH']);
    expect(ExerciseHabit.values.map((habit) => habit.wire).toList(),
        ['NONE', 'LIGHT', 'REGULAR', 'FREQUENT']);
    expect(WaterIntake.values.map((intake) => intake.wire).toList(),
        ['LACKING', 'NORMAL', 'ENOUGH']);
  });

  test('모르는 값은 null 로 떨어진다 — 미선택과 섞이지 않게', () {
    expect(WaterIntake.fromWire('SPARKLING'), isNull);
    // 앱에만 있던 옛 값들. 남아 있으면 서버가 400 을 준다.
    expect(ExerciseHabit.fromWire('STEADY'), isNull);
    expect(ExerciseHabit.fromWire('RARELY'), isNull);
    expect(StressLevel.fromWire('MEDIUM'), isNull);
    expect(SkinConcern.fromWire('SEBUM'), isNull);
    // TROUBLE 은 InsightCategory 쪽 값이지 고민이 아니다.
    expect(SkinConcern.fromWire('TROUBLE'), isNull);
  });

  test('왕복', () {
    for (final habit in ExerciseHabit.values) {
      expect(ExerciseHabit.fromWire(habit.wire), habit);
    }
    for (final intake in WaterIntake.values) {
      expect(WaterIntake.fromWire(intake.wire), intake);
    }
    for (final concern in SkinConcern.values) {
      expect(SkinConcern.fromWire(concern.wire), concern);
    }
  });
}
