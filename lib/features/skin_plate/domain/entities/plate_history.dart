import '../../../../shared/enums/meal_type.dart';
import '../../../../shared/enums/skin_level.dart';

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
    this.grade,
  });

  final DateTime date;

  /// 그날의 피부 점수. 기록이 있으면 서버가 반드시 채워 주지만, 계약상 optional 이다.
  final int? skinScore;

  /// 그날 기록들의 평균 식단 점수. 홈이 크게 보여주는 값이다.
  /// 앱에서 평균을 내지 않는다 — 반올림이 서버와 조금만 달라도 두 숫자가 생긴다.
  ///
  /// 서버는 이 값을 늘 채워 준다(기록이 없는 날은 목록에 아예 없다). nullable 은
  /// 방어이고, 그 자리를 0 으로 메우지 않는다 — 0 은 나쁘게 먹은 날이다.
  final int? plateScore;

  /// 시안의 "목표 80점". **서버가 정한 값만 쓴다** — 앱에 80 을 박으면 사용자별
  /// 목표가 생기는 날 앱 배포가 필요해진다. 없으면 목표 막대를 그리지 않는다.
  final int? targetScore;

  /// [plateScore] 의 등급. 서버가 매긴다 — 홈 히어로의 배지가 이 값을 쓴다.
  final SkinLevel? grade;

  /// "오늘의 AI 코멘트". 그날 최신 기록이 쥔 문장. 없으면 카드를 그리지 않는다.
  final String? aiComment;

  final List<PlateHistoryItem> plates;
}

class PlateHistoryItem {
  const PlateHistoryItem({
    required this.plateId,
    required this.foodName,
    required this.plateScore,
    required this.grade,
    required this.mealType,
    required this.recordedAt,
    this.highlightTags = const <String>[],
  });

  /// 로컬 이미지 파일명이기도 하다 — `{plateId}.jpg`.
  final int plateId;

  final String foodName;
  final int plateScore;

  /// [plateScore] 의 등급. **서버가 매긴다** — 앱에 경계표를 두지 않는다.
  /// 모르는 값이면 null 이고 화면은 배지를 비운다.
  final SkinLevel? grade;

  /// 서버가 저장 시각에서 파생해 준다. 모르는 값이면 null 이고 화면은 배지를 비운다.
  final MealType? mealType;

  final DateTime recordedAt;

  /// 서버가 고른 "주요영양" 칩. 비어 있으면 칩 줄을 그리지 않는다 —
  /// 앱이 영양값에서 고르지 않는다(기준이 두 곳에 생긴다).
  final List<String> highlightTags;
}
