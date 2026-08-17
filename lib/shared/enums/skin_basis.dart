/// 이 음식 점수가 **언제 찍은 피부**를 기준으로 계산됐는지. 서버가 판정해서 준다.
///
/// 앱이 `skinMeasuredAt` 과 오늘 날짜를 비교해 다시 정하지 않는다 — 서버는 KST
/// 기준이고 앱은 기기 시간대라, 자정 근처에서 두 판정이 갈린다.
///
/// **모르는 값은 `null` 이다.** 기본값을 두면 "최근 측정"이 조용히 "오늘"로 둔갑해서,
/// 사흘 전 피부로 계산된 점수를 사용자가 오늘 측정값으로 읽는다.
enum SkinBasis {
  today,
  recent;

  static SkinBasis? fromJson(String? value) => switch (value) {
        'TODAY' => today,
        'RECENT' => recent,
        _ => null,
      };
}
