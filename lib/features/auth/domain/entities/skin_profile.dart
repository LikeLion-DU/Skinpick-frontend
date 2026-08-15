/// 피부 프로필 설문의 나머지 절반 — 고민·생활 습관.
///
/// 피부 타입은 서버(`PATCH /auth/me`)로 가지만 이 값들은 **아직 서버에 컬럼이
/// 없다.** 그래서 기기에 저장한다. wire 이름을 지금부터 서버 enum 규칙(대문자
/// 스네이크)으로 맞춰 두는 이유는, 백엔드가 생기는 날 저장 포맷을 그대로 옮겨
/// 보내기 위해서다 — 그때 매핑표를 새로 만들면 반드시 한 군데 어긋난다.
library;

/// 주요 피부 고민. 시안의 9종 그대로다.
enum SkinConcern {
  acne('ACNE', '여드름'),
  rednessSensitive('REDNESS', '민감/홍조'),
  darkCircle('DARK_CIRCLE', '다크서클'),
  drynessFlaking('DRYNESS', '건조/각질'),
  sebumOil('SEBUM', '피지/유분'),
  texture('TEXTURE', '피부결'),
  pigmentation('PIGMENTATION', '색조침착'),
  elasticity('ELASTICITY', '탄력 저하'),
  puffiness('PUFFINESS', '부기');

  const SkinConcern(this.wire, this.label);

  final String wire;
  final String label;

  static SkinConcern? fromWire(String value) {
    for (final concern in values) {
      if (concern.wire == value) return concern;
    }
    return null; // 모르는 값은 조용히 버린다. 저장본이 앱보다 새로울 수 있다.
  }
}

/// 수면 패턴. 시안 문구를 그대로 옮겼다.
enum SleepPattern {
  lacking('LACKING', '부족해요', '6시간 미만\n숙면이 필요해요'),
  normal('NORMAL', '보통이에요', '6~7시간 정도\n적당히 자는 편이에요'),
  enough('ENOUGH', '충분해요', '7~8시간 이상\n숙면해요');

  const SleepPattern(this.wire, this.label, this.description);

  final String wire;
  final String label;
  final String description;

  static SleepPattern? fromWire(String value) {
    for (final pattern in values) {
      if (pattern.wire == value) return pattern;
    }
    return null;
  }
}

enum StressLevel {
  low('LOW', '낮음', '대체로 여유롭고\n스트레스가 적어요'),
  medium('MEDIUM', '보통', '보통 수준의\n스트레스를 느껴요'),
  high('HIGH', '높음', '스트레스를 많이\n느끼는 편이에요');

  const StressLevel(this.wire, this.label, this.description);

  final String wire;
  final String label;
  final String description;

  static StressLevel? fromWire(String value) {
    for (final level in values) {
      if (level.wire == value) return level;
    }
    return null;
  }
}

enum ExerciseHabit {
  rarely('RARELY', '거의 안 해요', '운동을 거의 하지 않아요'),
  light('LIGHT', '주 1-2회', '가벼운 운동을 주 1-2회 해요'),
  steady('STEADY', '주 3-4회', '꾸준한 운동을 주 3-4회 해요'),
  frequent('FREQUENT', '주 5회 이상', '주 5회 이상 규칙적으로 해요');

  const ExerciseHabit(this.wire, this.label, this.description);

  final String wire;
  final String label;
  final String description;

  static ExerciseHabit? fromWire(String value) {
    for (final habit in values) {
      if (habit.wire == value) return habit;
    }
    return null;
  }
}

/// 설문 결과 묶음. 타입은 서버가 쥐고 있으므로 여기 없다.
class SkinProfile {
  const SkinProfile({
    this.concerns = const <SkinConcern>{},
    this.sleep,
    this.stress,
    this.exercise,
  });

  final Set<SkinConcern> concerns;
  final SleepPattern? sleep;
  final StressLevel? stress;
  final ExerciseHabit? exercise;

  Map<String, Object?> toJson() => {
        'concerns': concerns.map((concern) => concern.wire).toList(),
        'sleep': sleep?.wire,
        'stress': stress?.wire,
        'exercise': exercise?.wire,
      };

  static SkinProfile fromJson(Map<String, Object?> json) => SkinProfile(
        concerns: ((json['concerns'] as List?) ?? const [])
            .whereType<String>()
            .map(SkinConcern.fromWire)
            .whereType<SkinConcern>()
            .toSet(),
        sleep: SleepPattern.fromWire((json['sleep'] as String?) ?? ''),
        stress: StressLevel.fromWire((json['stress'] as String?) ?? ''),
        exercise: ExerciseHabit.fromWire((json['exercise'] as String?) ?? ''),
      );
}
