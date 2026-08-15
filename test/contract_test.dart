import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/data/models/auth_dtos.dart';
import 'package:skinplate/features/recommendation/data/models/recommendation_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/shared/enums/cooking_method.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/ingredient_tag.dart';
import 'package:skinplate/shared/enums/meal_type.dart';
import 'package:skinplate/shared/enums/plate_action_code.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 실제로 돌아가는 서버가 준 응답을 그대로 파싱한다.
///
/// 손으로 쓴 JSON 으로 테스트하면 "내가 상상한 서버"를 검증하게 된다. 통합 첫날에
/// 깨지는 건 상상과 실제가 다른 지점이고, 그건 그때 처음 보인다.
/// fixtures 는 `AI_MOCK=true` 로 띄운 로컬 서버에서 curl 로 받아 그대로 저장했다.
///
/// 서버 DTO 를 고쳤는데 앱을 안 고치면 여기서 먼저 깨진다.
void main() {
  Map<String, dynamic> data(String name) {
    final body = jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(body['success'], isTrue, reason: '$name 이 실패 응답이다');
    return body['data'] as Map<String, dynamic>;
  }

  test('POST /auth/test-login — 토큰과 사용자', () {
    final dto = AuthResponseDto.fromJson(data('auth_login'));

    expect(dto.tokenType, 'Bearer');
    expect(dto.expiresIn, 604800); // 7일. 시연 기간 전체를 덮는다
    expect(dto.toEntity().user.nickname, '테스트유저');
  });

  test('GET /auth/me — isTestAccount 키가 흔들리지 않는다', () {
    final dto = MeResponseDto.fromJson(data('auth_me'));

    // Jackson 네이밍 전략이 바뀌면 testAccount 로 흔들릴 수 있어 서버가
    // @JsonProperty 로 고정해 뒀다. 키가 어긋나도 앱은 안 죽고 조용히 false 가 된다.
    expect(dto.isTestAccount, isTrue);
    expect(dto.toEntity().declaredSkinType, SkinType.oily);
  });

  test('GET /skin/analyses/latest — 점수·하이라이트·갭', () {
    final analysis = SkinAnalysisDto.fromJson(data('skin_latest')).toEntity();

    expect(analysis.skinScore, 55); // (38+78+48+36+75)/5
    expect(analysis.metrics.hydration, 38);
    expect(analysis.metrics.toBars().length, 5);

    expect(analysis.highlights.map((h) => h.status).toList(), [
      HighlightStatus.good, // 피부 장벽 양호
      HighlightStatus.caution, // 건조 주의
      HighlightStatus.caution, // 홍조 주의
    ]);

    // 자가신고와 오늘 측정이 다르다는 것을 보여주는 카드. 문장은 서버가 만든다.
    expect(analysis.skinTypeGap!.declared, SkinType.oily);
    expect(analysis.skinTypeGap!.observed, SkinType.dry);
    expect(analysis.skinTypeGap!.matched, isFalse);
    expect(analysis.skinTypeGap!.message, isNotEmpty);
  });

  test('POST /plates/analyze — 토큰은 있고 plateId 는 없다', () {
    final json = data('plate_analyze');

    // 저장 전이라 서버가 이 세 키를 아예 내려보내지 않는다.
    expect(json.containsKey('plateId'), isFalse);
    expect(json.containsKey('createdAt'), isFalse);
    expect((json['food'] as Map<String, dynamic>).containsKey('foodAnalysisId'),
        isFalse);

    final analysis = PlateAnalysisDto.fromJson(json).toEntity();

    expect(analysis.analysisToken, isNotEmpty);
    expect(analysis.food.id, isNull); // required 였다면 위 fromJson 에서 죽는다
    expect(analysis.plateScore, 60);
    expect(analysis.baseScore, 70);
    expect(analysis.skinAnalysisId, greaterThan(0));
    expect(analysis.actions.map((a) => a.expectedGain), [8, 6]);
    expect(analysis.food.cookingMethod, CookingMethod.boiled);
    expect(analysis.food.nutrition.proteinG, 28.5);

    // 저장된 기록과 같은 화면을 그린다. 위젯을 두 벌 만들지 않기 위한 계약이다.
    expect(analysis, isA<PlateView>());
  });

  test('GET /plates/{id} — 60점과 피드백 3종', () {
    final plate = SkinPlateDto.fromJson(data('plate')).toEntity();

    expect(plate.plateScore, 60);
    expect(plate.baseScore, 70); // 앱이 하드코딩하지 않는다
    expect(plate.skinAnalysisId, greaterThan(0)); // S08 추천으로 넘어갈 때 쓴다

    expect(plate.good.map((f) => f.message), ['단백질 충분', '발효식품 포함']);
    expect(plate.caution.map((f) => f.scoreDelta), [-8, -12]);

    // expectedGain 은 scoreDelta 의 절댓값이 아니다 — 매운맛은 -12 인데 회복은 +6 이다.
    // 합산으로 "실행 후 점수"를 만들면 안 되는 이유가 이것이다.
    expect(plate.actions.map((a) => a.expectedGain), [8, 6]);

    expect(plate.food.cookingMethod, CookingMethod.boiled);
    expect(plate.food.spicy, isTrue);
    expect(plate.food.ingredients.map((i) => i.tag),
        contains(IngredientTag.capsaicin));

    // 서버가 28.5 를 보내든 28 을 보내든 앱이 죽지 않아야 한다(num 으로 받는 이유).
    expect(plate.food.nutrition.proteinG, 28.5);
    expect(plate.food.nutrition.sodiumMg, 1850);
  });

  test('GET /plates?from=&to= — 날짜 내림차순, 같은 날은 시각 내림차순', () {
    // ⚠️ 이 픽스처도 실서버 curl 이 아니다. 백엔드 응답이 오면 교체할 것.
    final days = PlateHistoryDto.fromJson(data('plate_history')).toEntity();

    expect(days.length, 2);
    expect(days.first.date, DateTime(2026, 8, 14));

    // 서버는 createdAt 내림차순으로 주지만, 엔티티는 **시각 오름차순**이다.
    // 시안이 아침→저녁으로 그리고, 홈과 기록 화면이 같은 순서를 봐야 하므로
    // DTO 매퍼가 한 곳에서 세운다 — 여기가 그 계약이다.
    expect(days.first.plates.map((p) => p.recordedAt.hour), [12, 19]);

    // 그날 얼굴을 안 찍었어도 비지 않는다. 서버가 그날 첫 Plate 의 기준 분석 점수로
    // 채운다(설계서 §5). DTO 를 nullable 로 둔 건 방어일 뿐 정상 응답에는 항상 있다.
    expect(days.every((day) => day.skinScore != null), isTrue);

    // 홈이 크게 보여주는 값이다. (60 + 82) / 2 = 71 — 서버가 반올림해서 준다.
    // 앱이 여기서 평균을 다시 내면 반올림이 갈리는 날 두 화면에 다른 숫자가 뜬다.
    expect(days.first.plateScore, 71);
    expect(days.first.targetScore, 80); // 앱에 하드코딩하지 않는다

    // 끼니도 서버가 시각에서 파생해 준다. 12:10 은 점심, 19:45 는 저녁이다.
    expect(days.first.plates.map((p) => p.mealType).toList(),
        [MealType.lunch, MealType.dinner]);

    // 오늘의 AI 코멘트 — 그날 최신 기록이 쥔 문장이다. 없는 날은 키 자체가 없고
    // 앱은 카드를 그리지 않는다(8/13 이 그 경우다).
    expect(days.first.aiComment, isNotEmpty);
    expect(days.last.aiComment, isNull);

    // plateId 가 곧 로컬 사진 파일명이다 — <documents>/plates/{plateId}.jpg
    expect(days.last.plates.single.plateId, 3);
  });

  test('POST /plates/records — 저장되면 plateId·createdAt·foodAnalysisId 가 생긴다', () {
    final json = data('plate_record');

    // analyze 응답과 갈리는 지점이 이 세 키다. 여기가 곧 "저장됐다"는 뜻이다.
    expect(json.containsKey('plateId'), isTrue);
    expect(json.containsKey('createdAt'), isTrue);
    expect((json['food'] as Map<String, dynamic>).containsKey('foodAnalysisId'),
        isTrue);

    final plate = SkinPlateDto.fromJson(json).toEntity();

    expect(plate.id, greaterThan(0));
    expect(plate.food.id, isNotNull);
    // 저장은 AI 를 다시 부르지 않는다. analyze 가 보여준 점수가 그대로 확정된다.
    expect(plate.plateScore, 60);

    // 저장 시 1회 생성된 AI 문장. 생성이 실패한 기록은 키가 없고 앱은
    // 룰 요약(summary)으로 대신한다 — nullable 인 이유가 그것이다.
    expect(plate.aiTip, isNotEmpty);
  });

  test('POST /plates/simulate — 저장 전 60 → 72, 응답에 plateId 가 없다', () {
    final json = data('plate_simulate');
    expect(json.containsKey('plateId'), isFalse);

    final simulation = PlateSimulationDto.fromJson(json).toEntity();

    // analyze 가 보여준 60 과 같아야 한다. 두 경로가 같은 계산을 타는지 보는 값이다.
    expect(simulation.beforeScore, 60);
    expect(simulation.afterScore, 72);
    expect(simulation.gain, 12);
    expect(simulation.appliedActions,
        [PlateActionCode.removeBatter, PlateActionCode.lessSpicy]);
    // afterScore 는 expectedGain 의 합이 아니다. 매운맛 감점이 -12 라 R02 가 빠지며
    // 12 가 돌아온다 — 안내 문구의 "+6" 과 다르다. 합산으로 만들면 안 되는 이유다.
    expect(simulation.removedRules, ['R02']);
  });

  test('POST /plates/{id}/simulate — plateId 가 있어도 같은 DTO 로 읽는다', () {
    // 저장된 기록용 응답에는 plateId 가 있다. 두 엔드포인트에 DTO 를 하나만 두었으니
    // 남는 키를 무시하고 파싱된다는 것이 그 결정의 전제다 — 여기서 그걸 고정한다.
    final json = data('plate_simulate_saved');
    expect(json.containsKey('plateId'), isTrue);

    final simulation = PlateSimulationDto.fromJson(json).toEntity();

    // 설계서 예시 A — 국물만 절반 남기면 68 이다(둘 다 실행하면 80).
    expect(simulation.beforeScore, 60);
    expect(simulation.afterScore, 68);
    expect(simulation.appliedActions, [PlateActionCode.halveSoup]);
    expect(simulation.removedRules, ['R04']); // 나트륨 카드가 사라진다
  });

  test('GET /recommendations — 추천과 주의', () {
    final daily = RecommendationDto.fromJson(data('recommendations')).toEntity();

    expect(daily.isEmpty, isFalse);
    expect(daily.recommend, isNotEmpty);
    expect(daily.avoid, isNotEmpty);
    // 이유 문구가 비면 화면에 음식 이름만 덩그러니 남는다.
    expect(daily.recommend.every((food) => food.reason.isNotEmpty), isTrue);
  });

  test('실패 응답에는 data 키 자체가 없다', () {
    // 서버가 non_null 직렬화라 값이 없으면 키가 사라진다.
    // "data 가 null" 과 "data 키 없음"을 같게 다루지 않으면 여기서 깨진다.
    final body = jsonDecode('{"success":false,"error":{"code":"UNAUTHORIZED","message":"로그인이 필요합니다."}}')
        as Map<String, dynamic>;

    expect(body.containsKey('data'), isFalse);
  });
}
