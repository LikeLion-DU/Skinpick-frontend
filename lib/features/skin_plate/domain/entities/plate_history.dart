/// S09 히스토리 — `GET /plates?from=&to=` 응답.
///
/// 목록은 요약만 담는다(음식명·점수·시각). 상세는 `GET /plates/{id}` 다.
/// 사진 필드가 없는 것은 의도다 — 서버에 이미지를 올리지 않고, 앱이 저장 성공
/// 직후 `<documents>/plates/{plateId}.jpg` 에 로컬로 남긴 파일을 쓴다.
class PlateHistoryDay {
  const PlateHistoryDay({
    required this.date,
    required this.skinScore,
    required this.plates,
  });

  final DateTime date;

  /// 그날의 피부 점수. 기록이 있으면 서버가 반드시 채워 주지만, 계약상 optional 이다.
  final int? skinScore;

  final List<PlateHistoryItem> plates;
}

class PlateHistoryItem {
  const PlateHistoryItem({
    required this.plateId,
    required this.foodName,
    required this.plateScore,
    required this.recordedAt,
  });

  /// 로컬 이미지 파일명이기도 하다 — `{plateId}.jpg`.
  final int plateId;

  final String foodName;
  final int plateScore;
  final DateTime recordedAt;
}
