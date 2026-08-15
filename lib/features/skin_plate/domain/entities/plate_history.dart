import '../../../../shared/enums/meal_type.dart';

/// S09 히스토리 — `GET /plates?from=&to=` 응답.
///
/// 목록은 요약만 담는다(음식명·점수·시각). 상세는 `GET /plates/{id}` 다.
/// 사진 필드가 없는 것은 의도다 — 서버에 이미지를 올리지 않고, 앱이 저장 성공
/// 직후 `<documents>/plates/{plateId}.jpg` 에 로컬로 남긴 파일을 쓴다.
class PlateHistoryDay {
  const PlateHistoryDay({
    required this.date,
    required this.skinScore,
    required this.plateScore,
    required this.targetScore,
    this.aiComment,
    required this.plates,
  });

  final DateTime date;

  /// 그날의 피부 점수. 기록이 있으면 서버가 반드시 채워 주지만, 계약상 optional 이다.
  final int? skinScore;

  /// 그날 기록들의 평균 식단 점수. 홈이 크게 보여주는 값이다.
  /// 앱에서 평균을 내지 않는다 — 반올림이 서버와 조금만 달라도 두 숫자가 생긴다.
  final int plateScore;

  /// 시안의 "목표 80점". 서버가 매 응답에 실어 보낸다.
  final int targetScore;

  /// "오늘의 AI 코멘트". 그날 최신 기록이 쥔 문장. 없으면 카드를 그리지 않는다.
  final String? aiComment;

  final List<PlateHistoryItem> plates;
}

class PlateHistoryItem {
  const PlateHistoryItem({
    required this.plateId,
    required this.foodName,
    required this.plateScore,
    required this.mealType,
    required this.recordedAt,
  });

  /// 로컬 이미지 파일명이기도 하다 — `{plateId}.jpg`.
  final int plateId;

  final String foodName;
  final int plateScore;

  /// 서버가 저장 시각에서 파생해 준다. 모르는 값이면 null 이고 화면은 배지를 비운다.
  final MealType? mealType;

  final DateTime recordedAt;
}
