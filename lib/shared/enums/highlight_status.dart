/// 피부 결과 화면(S05)의 요약 뱃지 색상.
enum HighlightStatus {
  good, // 초록
  warn, // 노랑
  caution; // 빨강

  static HighlightStatus fromJson(String value) => switch (value) {
        'GOOD' => HighlightStatus.good,
        'WARN' => HighlightStatus.warn,
        'CAUTION' => HighlightStatus.caution,
        // 모르는 값을 good으로 떨어뜨리면 사용자에게 잘못된 안심을 준다.
        // 피부 상태 문구라 더 민감하다. 중립인 warn으로 보낸다.
        _ => HighlightStatus.warn,
      };
}
