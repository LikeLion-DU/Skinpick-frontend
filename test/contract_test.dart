import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/data/models/auth_dtos.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/recommendation/data/models/recommendation_dtos.dart';
import 'package:skinplate/features/report/data/models/report_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_insight_dtos.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/shared/enums/cooking_method.dart';
import 'package:skinplate/shared/enums/food_traits.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/ingredient_tag.dart';
import 'package:skinplate/shared/enums/insight_category.dart';
import 'package:skinplate/shared/enums/meal_type.dart';
import 'package:skinplate/shared/enums/metric_band.dart';
import 'package:skinplate/shared/enums/nutrient_status.dart';
import 'package:skinplate/shared/enums/plate_action_code.dart';
import 'package:skinplate/shared/enums/skin_basis.dart';
import 'package:skinplate/shared/enums/skin_level.dart';
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
    // 로그인 응답은 요약 사용자만 싣는다. 프로필(고민·습관)은 /auth/me 가 준다 —
    // Repository 가 두 응답을 합쳐 세션을 만든다.
    expect(dto.user.nickname, '테스트유저');
  });

  test('GET /auth/me — isTestAccount 키가 흔들리지 않는다', () {
    final dto = MeResponseDto.fromJson(data('auth_me'));

    // Jackson 네이밍 전략이 바뀌면 testAccount 로 흔들릴 수 있어 서버가
    // @JsonProperty 로 고정해 뒀다. 키가 어긋나도 앱은 안 죽고 조용히 false 가 된다.
    expect(dto.isTestAccount, isTrue);
    expect(dto.toEntity().declaredSkinType, SkinType.oily);
  });

  test('GET /auth/me — 고민·습관 4종을 읽는다', () {
    final user = MeResponseDto.fromJson(data('auth_me')).toEntity();

    expect(user.skinConcerns, {SkinConcern.acne, SkinConcern.sebumOil});
    expect(user.sleepPattern, SleepPattern.lacking);
    expect(user.stressLevel, StressLevel.high);
    expect(user.exerciseHabit, ExerciseHabit.none);
    expect(user.waterIntake, WaterIntake.lacking);
    expect(user.hasIncompleteLifestyle, isFalse);
  });

  test('GET /auth/me — 미선택이면 서버가 키를 지운다', () {
    // non_null 직렬화라 null 필드는 키 자체가 없다. required 를 쓰면 여기서 죽는다.
    final user = MeResponseDto.fromJson(data('auth_me_no_profile')).toEntity();

    expect(user.skinConcerns, isEmpty);
    expect(user.sleepPattern, isNull);
    expect(user.stressLevel, isNull);
    expect(user.exerciseHabit, isNull);
    expect(user.waterIntake, isNull);
    expect(user.declaredSkinType, isNull);
    expect(user.hasIncompleteLifestyle, isTrue);
  });

  test('GET /skin-insights — 요약·변화량·주제', () {
    final insight = SkinInsightDto.fromJson(data('skin_insight')).toEntity();

    expect(insight.summary, isNotEmpty);
    expect(insight.changes!.trouble, -7);
    expect(insight.changes!.skinScore, 2);
    expect(insight.changes!.byKey('hydration'), 5);

    // 배열 순서가 곧 우선순위다. 앱이 정렬하지 않는다.
    expect(insight.insights.map((item) => item.category).toList(),
        [InsightCategory.sleep, InsightCategory.trouble]);

    // 두 배열은 같은 주제를 두 각도로 본 것이다 — 길이도 순서도 항상 같다.
    expect(insight.todayActions.length, insight.insights.length);
    expect(insight.todayActions.first.category, InsightCategory.sleep);
  });

  test('GET /skin-insights — 첫 분석이면 changes 키가 없다', () {
    // 0 으로 채우면 "변화 없음"과 구분이 사라진다. null 이어야 한다.
    final insight =
        SkinInsightDto.fromJson(data('skin_insight_first')).toEntity();

    expect(insight.changes, isNull);
    expect(insight.insights, hasLength(1));
  });

  test('GET /skin-insights — 다룰 주제가 없으면 빈 배열이 온다', () {
    // 서버가 이 응답을 저장하지 않는다. 습관을 채우고 다시 오면 새로 만들어진다.
    final insight =
        SkinInsightDto.fromJson(data('skin_insight_healthy')).toEntity();

    expect(insight.insights, isEmpty);
    expect(insight.todayActions, isEmpty);
    expect(insight.summary, isNotEmpty); // 빈 배열이어도 할 말은 있다
  });

  test('모르는 category 는 null 로 떨어진다 — 엉뚱한 아이콘을 붙이지 않는다', () {
    expect(InsightCategory.fromJson('TELEPORTATION'), isNull);
    expect(InsightCategory.fromJson('WATER'), InsightCategory.water);
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

    // 지표 5개에 서버 등급과 근거가 붙어 온다. **상태어의 유일한 출처다** —
    // 이 값이 유실되면 세 화면의 상태어가 한꺼번에 사라진다.
    expect(analysis.metricDetails.map((d) => d.key).toList(),
        ['hydration', 'oil', 'redness', 'trouble', 'barrier']);
    expect(analysis.metricDetails.first.score, 38);
    // 방향을 맞춘 뒤 매긴 값이라 유분 52 는 정렬 48 로 NORMAL 이다.
    expect(analysis.levelOf('oil'), SkinLevel.normal);
    expect(analysis.metricDetails.map((d) => d.level),
        everyElement(isNotNull));
    // 수분 38 은 낮아서 나쁜 쪽이고, 홍조 64 는 높아서 나쁜 쪽이다 — 서버는 둘 다
    // CAUTION 으로 보낸다(방향을 이미 맞췄다). 화면은 같은 등급을 다른 말로 옮긴다.
    expect(analysis.levelOf('hydration'), SkinLevel.caution);
    expect(analysis.levelOf('redness'), SkinLevel.caution);
    expect(MetricBand.of(analysis.levelOf('hydration'),
            higherIsBetterMetric: true)!.label, '부족');
    expect(MetricBand.of(analysis.levelOf('redness'),
            higherIsBetterMetric: false)!.label, '주의');
    expect(analysis.metricDetails.first.evidence, isNotEmpty);

    // 오늘의 타입 + 상태. 위 skinTypeGap.observed 와 **같은 값**이어야 한다 —
    // 서버가 둘을 같은 규칙으로 내므로, 갈리면 계약이 어긋난 것이다.
    expect(analysis.skinType!.primary, SkinType.dry);
    expect(analysis.skinType!.primary, analysis.skinTypeGap!.observed);
    // 화면 문구는 서버가 조합해 준다 — 앱이 타입과 상태를 이어 붙이지 않는다.
    expect(analysis.skinType!.label, '건성 · 붉은기');

    // 피부 나이 축은 7개다. 붉은기는 지표 쪽에 이미 있어 서버가 응답에서 뺀다 —
    // 8개가 오면 계약이 어긋난 것이다.
    expect(analysis.skinAge!.estimatedSkinAge, inInclusiveRange(18, 80));
    expect(analysis.skinAge!.axes.map((a) => a.key).toList(), [
      'skinTexture', 'elasticity', 'wrinkles', 'skinTone',
      'pores', 'pigmentation', 'blemishMarks',
    ]);
    expect(analysis.skinAge!.assessment, isNotEmpty);
  });

  test('GET /skin/analyses/latest — 확장 필드가 없던 시절의 기록도 파싱된다', () {
    // **실제로 오는 응답이 아니라 방어 테스트다.** `skinType` 은 저장된 지표에서
    // 매번 다시 만들어져 옛 기록에도 오고(서버 `SkinAnalysisResponse`: "항상 채워진다"),
    // 지금 세 키가 다 빠지는 응답은 없다. 그래도 셋 다 없는 모양을 여기서 태운다 —
    // required 를 걸면 계약이 바뀌는 날 옛 기록을 여는 순간 앱이 멎는다.
    final analysis = SkinAnalysisDto.fromJson({
      'skinAnalysisId': 1,
      'skinScore': 55,
      'metrics': {
        'hydration': 38, 'oil': 52, 'redness': 64, 'trouble': 25, 'barrier': 78,
      },
      'summary': '요약',
      'highlights': <Map<String, dynamic>>[],
      'analyzedAt': '2026-08-12T13:45:26.097264',
    }).toEntity();

    expect(analysis.skinScore, 55);
    expect(analysis.metricDetails, isEmpty);
    expect(analysis.skinType, isNull);
    expect(analysis.skinAge, isNull);
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

  test('POST /plates/analyze — 피부 기준·음식 특성·판정 이유가 함께 온다', () {
    final json = data('plate_analyze_v8');

    // 키가 실제로 이 이름인지부터 못 박는다. 파서는 모르는 키를 조용히 null 로
    // 두므로, 손으로 쓴 fixture 는 필드명이 틀려도 초록이다.
    expect(json.containsKey('skinBasis'), isTrue);
    expect(json.containsKey('skinMeasuredAt'), isTrue);

    final analysis = PlateAnalysisDto.fromJson(json).toEntity();

    // 오늘 찍은 피부로 계산됐다. 저장 전 화면은 이걸 "오늘 피부 기준"으로 쓴다.
    expect(analysis.skinBasis, SkinBasis.today);
    expect(analysis.skinMeasuredAt, DateTime(2026, 8, 17));

    // 서버가 UNKNOWN 을 안 보낸 정상 케이스. 셋 다 화면에 칩으로 나간다.
    expect(analysis.food.spiciness, Spiciness.medium);
    expect(analysis.food.oiliness, Oiliness.medium);
    expect(analysis.food.portionSize, PortionSize.medium);
    // 화면에 안 내는 두 개도 받아만 둔다 — 나중에 서버 작업 없이 붙는다.
    expect(analysis.food.foodGroup, FoodGroup.soupStew);
    expect(analysis.food.processingLevel, ProcessingLevel.minimallyProcessed);

    // 제목 아래 설명. 제목과 다른 문장이어야 두 줄로 쓸 값이 된다.
    expect(analysis.good.every((item) => item.reason != null), isTrue);
    expect(analysis.caution.every((item) => item.reason != null), isTrue);
    expect(analysis.caution.first.reason, isNot(analysis.caution.first.message));

    // **행동 카드에는 reason 이 없다.** ActionDto 에 필드 자체가 없으므로
    // 파싱을 시도하면 항상 비어 있다 — 키가 없다는 것을 여기서 못 박는다.
    final rawActions =
        (json['feedbacks'] as Map<String, dynamic>)['action'] as List<dynamic>;
    expect((rawActions.first as Map<String, dynamic>).containsKey('reason'),
        isFalse);
  });

  test('GET /plates/{id} — V7·V8 이전 기록: 특성은 UNKNOWN, 이유는 키가 없다', () {
    // 실제로 마이그레이션 전에 저장된 행을 조회한 응답이다. 여기가 이 작업에서
    // 가장 깨지기 쉬운 자리다 — 두 가지가 **서로 다른 방식으로** 비어 있다.
    final json = data('plate_legacy_traits');
    final food = json['food'] as Map<String, dynamic>;

    // 특성은 키가 있고 값이 "UNKNOWN" 이다. null 체크만 하면 화면에 UNKNOWN 이 뜬다.
    expect(food['spiciness'], 'UNKNOWN');
    expect(food['foodGroup'], 'ETC');
    // 이유는 반대로 키 자체가 없다(non_null 직렬화).
    final good = (json['feedbacks'] as Map<String, dynamic>)['good'] as List<dynamic>;
    expect((good.first as Map<String, dynamic>).containsKey('reason'), isFalse);

    final plate = SkinPlateDto.fromJson(json).toEntity();

    // 화면이 칩을 숨기는 판단이 label == null 하나에 걸려 있다.
    expect(plate.food.spiciness.label, isNull);
    expect(plate.food.oiliness.label, isNull);
    // 섭취량은 화면에 안 내지만 파싱은 살아 있어야 한다 — 서버가 저장·리포트
    // 환산에 계속 쓰고, 나중에 표시를 되살릴 때 서버 작업 없이 붙는다.
    expect(plate.food.portionSize, PortionSize.unknown);
    expect(plate.food.foodGroup, FoodGroup.etc);
    expect(plate.good.every((item) => item.reason == null), isTrue);

    // skinBasis 는 컬럼이 아니라 파생값이라 옛 행에도 붙는다. 이 기록은 8/17 에
    // 저장됐는데 기준 피부는 8/15 측정이라 RECENT 다 — 화면이 측정일을 함께 낸다.
    expect(plate.skinBasis, SkinBasis.recent);
    expect(plate.skinMeasuredAt, DateTime(2026, 8, 15));
  });

  test('신규 필드가 없던 시절의 응답도 그대로 파싱된다', () {
    // #49 이전 서버는 이 키들을 아예 만들지 않았다. required 로 받았으면 여기서
    // 죽고, 배포 경계의 구 analysisToken 하나에 앱이 멎는다.
    final json = data('plate_analyze');
    expect(json.containsKey('skinBasis'), isFalse);
    expect((json['food'] as Map<String, dynamic>).containsKey('spiciness'),
        isFalse);

    final analysis = PlateAnalysisDto.fromJson(json).toEntity();

    // null 이어야 화면이 문구를 지어내지 않고 자리째 비운다.
    expect(analysis.skinBasis, isNull);
    expect(analysis.skinMeasuredAt, isNull);
    expect(analysis.good.every((item) => item.reason == null), isTrue);
    // 키가 없을 때도 UNKNOWN 과 같은 자리로 떨어져야 화면 분기가 하나로 끝난다.
    expect(analysis.food.spiciness, Spiciness.unknown);
    expect(analysis.food.portionSize, PortionSize.unknown);
    expect(analysis.food.foodGroup, FoodGroup.etc);
  });

  test('R10 고열량 — 새 룰과 짝 없는 주의(R07)를 함께 처리한다', () {
    // **손으로 쓴 응답이다.** AI_MOCK 픽스처(김치찌개 520kcal)로는 R10(660kcal
    // 초과)도, 튀김이 아닌 기름진 음식의 R07 도 만들 수 없다. 실물이 필요해지면
    // 백엔드에 요청한다.
    final analysis = PlateAnalysisDto.fromJson({
      'analysisToken': 'token',
      'skinAnalysisId': 54,
      'plateScore': 48,
      'food': {
        'foodName': '삼겹살 구이 정식',
        'oiliness': 'HIGH',
        'portionSize': 'LARGE',
        'nutrition': {'caloriesKcal': 980},
      },
      'feedbacks': {
        'caution': [
          {'message': '기름진 음식', 'scoreDelta': -6, 'ruleCode': 'R07'},
          {'message': '고열량', 'scoreDelta': -7, 'ruleCode': 'R10'},
        ],
        'action': [
          // **회복치는 이제 상수가 아니다.** 서버가 행동 후 단계를 계산해서 싣는다
          // (2026-08-18 재캘리브레이션 — 옛 GAIN_LESS_RICE 상수는 없어졌다).
          // 980kcal 은 2단계(-7)고 3/4 로 줄이면 735kcal 이라 1단계(-4)로만 내려간다
          // → 회복 3. 단언하는 값은 아니지만, 손으로 쓴 JSON 에 없는 숫자를 박아 두면
          // 다음 사람이 그걸 계약으로 읽는다.
          {'message': '밥 양을 줄여보세요.', 'expectedGain': 3, 'ruleCode': 'R10'},
        ],
      },
      'appliedRules': ['R07', 'R10'],
    }).toEntity();

    expect(PlateActionCode.forRuleCode('R10'), PlateActionCode.lessRice);

    // **주의 2건에 행동은 1건이다.** R07 이 튀김이 아닌 음식에서 걸리면
    // "튀김옷을 제거하세요"가 성립하지 않아 짝이 없다 — 1:1 을 가정하면 깨진다.
    expect(analysis.caution.length, 2);
    expect(analysis.actions.length, 1);
    expect(analysis.actions.map((a) => a.ruleCode), isNot(contains('R07')));
    expect(analysis.food.oiliness.label, '기름진 편');
  });

  test('모르는 enum 값은 예외 없이 UNKNOWN·ETC 로 떨어진다', () {
    // 서버가 값을 늘려도 앱이 죽지 않는다. 서버와 같은 fallback 이라 화면도 일관된다.
    expect(FoodGroup.fromJson('KOREAN_FOOD'), FoodGroup.etc);
    expect(Spiciness.fromJson('VERY_HOT'), Spiciness.unknown);
    expect(Oiliness.fromJson(null), Oiliness.unknown);
    expect(ProcessingLevel.fromJson('CANNED'), ProcessingLevel.unknown);
    expect(PortionSize.fromJson('HUGE'), PortionSize.unknown);

    // 기준 시점만은 null 이다. unknown 을 today 로 떨어뜨리면 사흘 전 피부로
    // 계산된 점수가 "오늘 피부 기준"으로 둔갑한다.
    expect(SkinBasis.fromJson('YESTERDAY'), isNull);
    expect(SkinBasis.fromJson(null), isNull);
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

  /// **이 픽스처는 손으로 쓴 것이고, 그대로 둔다.** 여기서 지키는 계약(여러 날
  /// 정렬 · 같은 날 2건의 시각 정렬 · 서버가 낸 평균)은 실서버에서 캡처할 수 없다 —
  /// 과거 날짜의 기록을 만들 방법이 없어서 배포 계정에는 하루치 한 건뿐이다.
  ///
  /// 손으로 쓴 픽스처의 위험은 "필드명이 틀려도 파싱만 맞으면 초록"인 것이다.
  /// 그쪽은 아래 실캡처 테스트(`plate_history_live`)가 막는다.
  test('GET /plates?from=&to= — 날짜 내림차순, 같은 날은 시각 내림차순', () {
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

  /// 배포 서버(`https://1-201-116-157.sslip.io`)에서 그대로 받아 저장한 응답.
  /// 2026-08-18 캡처, 테스트 계정 기준.
  ///
  /// **키 이름을 원문 JSON 에서 못 박는 것이 이 테스트의 전부다.** 위 픽스처는 손으로
  /// 쓴 것이라 필드명이 서버와 어긋나도 저 혼자 파싱에 성공한다 — 서버가 키를 바꾸면
  /// json_serializable 이 조용히 null 로 두고 화면만 빈다. 그 부류를 실제 페이로드로
  /// 한 번 대조해 둔다.
  ///
  /// 서버 계약이 바뀌면 이 파일을 다시 떠서 교체한다:
  ///   curl -s "$BASE/plates?from=&to=" -H "Authorization: Bearer $TOKEN"
  test('GET /plates?from=&to= — 실서버 응답이 그대로 파싱된다', () {
    final json = data('plate_history_live');
    final day = (json['days'] as List).first as Map<String, dynamic>;
    final plate = (day['plates'] as List).first as Map<String, dynamic>;

    // 앱이 읽는 키가 실제로 그 이름으로 온다.
    for (final key in ['date', 'skinScore', 'plateScore', 'targetScore',
                       'aiComment', 'plates']) {
      expect(day.containsKey(key), isTrue, reason: 'days[].$key 가 없다');
    }
    for (final key in ['plateId', 'foodName', 'plateScore', 'mealType',
                       'recordedAt']) {
      expect(plate.containsKey(key), isTrue, reason: 'plates[].$key 가 없다');
    }

    // 그 키들이 도메인까지 값으로 올라온다. containsKey 만 보면 타입이 바뀐 것을 놓친다.
    final days = PlateHistoryDto.fromJson(json).toEntity();
    final today = days.single;

    expect(today.skinScore, isNotNull);
    expect(today.plateScore, isNotNull);
    expect(today.targetScore, 80);
    expect(today.aiComment, isNotEmpty);
    expect(today.plates.single.mealType, isNotNull);
    expect(today.plates.single.recordedAt.year, 2026);

    // **이 캡처에는 grade 도 highlightTags 도 없다** — 그 필드가 생기기 전 배포본이다.
    // 앱이 그대로 떠야 한다: 등급 배지와 태그 줄만 사라지고 나머지는 다 나온다.
    // (새 필드를 실은 응답은 아래 '실서버 응답 — 새 계약' 이 본다)
    expect(plate.containsKey('grade'), isFalse);
    expect(plate.containsKey('highlightTags'), isFalse);
    expect(today.grade, isNull);
    expect(today.plates.single.grade, isNull);
    expect(today.plates.single.highlightTags, isEmpty);
  });

  /// 이번에 늘린 계약(등급 · 피부 영양 · 고민 문장 · plateIds · 관리 축)을 **실서버
  /// 응답 원문**으로 못 박는다. 2026-08-19 로컬 서버(AI_MOCK=true) · 테스트 계정.
  ///
  /// 위 픽스처들은 손으로 쓴 것이라 필드명이 서버와 어긋나도 저 혼자 파싱에 성공한다.
  /// 서버가 키를 바꾸면 json_serializable 은 조용히 기본값을 두고 화면만 빈다.
  ///
  /// 다시 뜨는 법:
  ///   curl -s "$BASE/reports/daily?date=YYYY-MM-DD" -H "Authorization: Bearer $TOKEN"
  group('실서버 응답 — 새 계약', () {
    test('GET /reports/daily — skinNutrients · 고민 문장 · 끼니 태그', () {
      final json = data('report_daily_live');

      // 앱이 읽는 키가 실제로 그 이름으로 온다.
      for (final key in ['dailyScore', 'grade', 'nutrition', 'skinNutrients',
                         'concerns', 'meals']) {
        expect(json.containsKey(key), isTrue, reason: '$key 가 없다');
      }

      final report = DailyReportDto.fromJson(json).toEntity();

      // ① 피부 영양 포인트 3종. **표준 음식표에 매칭된 끼니가 없으면 status 키가
      // 아예 없다** — 실제 응답이 그렇게 왔다(비타민C·아연은 status 없음).
      expect(report.skinNutrients.map((item) => item.nutrient),
          ['VITAMIN_C', 'OMEGA3', 'ZINC']);
      final vitaminC = report.skinNutrients.first;
      expect(vitaminC.status, isNull);
      expect(vitaminC.isWarning, isFalse, reason: '못 잰 것을 부족으로 읽으면 안 된다');
      // 오메가3 는 빈도(회)라 0회면 서버가 LOW 를 매긴다 — 재고 있는 값이다.
      final omega3 = report.skinNutrients[1];
      expect(omega3.unit, '회');
      expect(omega3.status, NutrientStatus.low);

      // ② 고민 문장과 태그. 앱이 짓지 않는다.
      final concern = report.concerns.first;
      expect(concern.message, isNotNull);
      expect(concern.tags, isNotEmpty);

      // ③ 끼니 카드의 주요영양 태그 + 서버가 매긴 등급.
      expect(report.meals.first.highlightTags, isNotEmpty);
      expect(report.meals.first.grade, isNotNull);
      expect(report.grade, isNotNull);
    });

    test('GET /reports/weekly — BEST/WORST 에만 plateIds 가 실린다', () {
      final json = data('report_weekly_live');
      final weekly = WeeklyReportDto.fromJson(json).toEntity();

      // ④ 실제 기록 id 다. 앱은 이 id 로 로컬 사진을 찾는다(PRD §9.6).
      expect(weekly.bestDay!.plateIds, isNotEmpty);
      expect(weekly.bestDay!.plateIds.every((id) => id > 0), isTrue);
      // 추이 그래프 칸에는 키가 없다 — 썸네일을 그리지 않는 자리다.
      final trend = (json['dailyScores'] as List).first as Map<String, dynamic>;
      expect(trend.containsKey('plateIds'), isFalse);
      expect(weekly.dailyScores.first.plateIds, isEmpty);
      // 주간 고민에는 문장이 없고 태그만 온다(한 끼 문장이 한 주 옆에 붙으면 안 된다).
      final concern = (json['concerns'] as List).first as Map<String, dynamic>;
      expect(concern.containsKey('message'), isFalse);
      expect(weekly.concerns.first.tags, isNotEmpty);
    });

    test('GET /skin/analyses/latest — 등급 · 지표 등급 · 관리 축', () {
      final json = data('skin_latest_live');

      for (final key in ['grade', 'metricDetails', 'careFocus', 'careMessage']) {
        expect(json.containsKey(key), isTrue, reason: '$key 가 없다');
      }

      final analysis = SkinAnalysisDto.fromJson(json).toEntity();

      // 총점 등급과 지표별 등급을 서버가 매긴다 — 앱에 경계표가 없다.
      expect(analysis.grade, isNotNull);
      expect(analysis.metricDetails.map((detail) => detail.level),
          everyElement(isNotNull));
      // ⑥ 관리 축과 문단. 라벨은 서버 문구를 그대로 쓴다.
      expect(analysis.careFocus, isNotEmpty);
      expect(analysis.careFocus.first.label, isNotEmpty);
      expect(analysis.careMessage, isNotNull);
    });
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

    // 저장 시 1회 생성된 AI 문장. 생성이 실패한 기록은 서버가 키를 빼므로
    // nullable 이고, 그때 앱은 "AI 맞춤 TIP" 카드를 아예 그리지 않는다 —
    // 룰 요약으로 메우면 AI 가 만들지 않은 문장에 AI 제목이 붙는다.
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

  test('GET /reports/daily — 점수·영양·고민·끼니가 한 벌로 온다', () {
    final report = DailyReportDto.fromJson(data('report_daily')).toEntity();

    expect(report.dailyScore, 60);
    // 등급은 서버가 정한다. 앱이 60 점에서 다시 계산하지 않는다 —
    // 서버는 60 을 NORMAL 로 보고, 앱의 ScoreGrade 는 60 을 '보통'으로 본다.
    expect(report.grade, SkinLevel.normal);
    expect(report.recordCount, 3);

    // 영양 항목을 앱이 고르지 않는다 — 서버가 준 순서와 개수를 그대로 쓴다.
    expect(report.nutrition.length, 6);
    expect(report.nutrition.first.label, '칼로리');
    expect(report.nutrition.first.unit, 'kcal');
    expect(report.nutrition.first.amount, 1560.0);

    // 방향이 반대인 항목. 단백질만 부족이 문제라 155% 여도 경고가 아니고,
    // 나트륨은 초과가 문제라 278% 가 경고다. 둘을 같은 색으로 칠하면
    // 화면이 거짓말을 한다.
    final protein = report.nutrition[2];
    expect(protein.higherIsWorse, isFalse);
    expect(protein.status, NutrientStatus.high);
    expect(protein.isWarning, isFalse);

    final sodium = report.nutrition[4];
    expect(sodium.higherIsWorse, isTrue);
    expect(sodium.status, NutrientStatus.high);
    expect(sodium.isWarning, isTrue);
    // 기준을 넘긴 항목은 100% 를 넘겨 온다. 막대가 이걸 잘라야 한다.
    expect(sodium.percent, 278);

    // 일일에는 변화량이 없다. 서버가 키를 통째로 뺀다.
    expect(report.concerns.first.change, isNull);
    expect(report.concerns.first.status, SkinLevel.good);
    // 다크서클을 골랐어도 식단 룰이 없어 응답에서 통째로 빠진다.
    expect(report.concerns.any((item) => item.concern == 'DARK_CIRCLE'), isFalse);

    // 끼니는 서버가 정해서 보낸다. 앱이 recordedAt 으로 다시 계산하지 않는다.
    // recordedAt 에 마이크로초가 붙어 있어도 파싱이 깨지면 안 된다.
    expect(report.meals.length, 3);
    expect(report.meals.first.mealType, MealType.lunch);
    expect(report.meals.first.recordedAt.microsecond, isNot(0));

    // 그룹은 앱이 만든다. 같은 끼니는 한 묶음이다.
    expect(report.byMealType.length, 1);
    expect(report.byMealType.first.key, MealType.lunch);
    expect(report.byMealType.first.value.length, 3);

    expect(report.aiComment, isNotNull);
    expect(report.improvePoints, isNotEmpty);
  });

  test('기록이 0건인 날은 dailyScore·grade·aiComment 키가 통째로 빠진다', () {
    final json = data('report_daily_empty');

    // required 로 받으면 파싱이 죽고, @Default(0) 으로 받으면 화면이 "0점"을
    // 그린다 — 0 점은 "아주 나쁘게 먹었다"고 이건 "아직 안 찍었다"다.
    expect(json.containsKey('dailyScore'), isFalse);
    expect(json.containsKey('grade'), isFalse);
    expect(json.containsKey('aiComment'), isFalse);

    final report = DailyReportDto.fromJson(json).toEntity();
    expect(report.dailyScore, isNull);
    expect(report.grade, isNull);
    expect(report.aiComment, isNull);
    expect(report.isEmpty, isTrue);
    expect(report.nutrition, isEmpty);
    expect(report.concerns, isEmpty);
  });

  test('GET /reports/weekly — 하루만 기록한 주는 변화량 키가 빠지고 BEST=WORST 다', () {
    final report = WeeklyReportDto.fromJson(data('report_weekly')).toEntity();

    // 분모는 7이 아니라 기록한 날이다. 안 찍은 날을 0 으로 세지 않는다.
    expect(report.totalDays, 7);
    expect(report.recordedDays, 1);
    expect(report.dailyScores.length, 1);

    // 축은 기간 폭에서 나온다. 월간으로 넓혀도 같은 코드가 돈다.
    expect(report.axis.length, 7);
    expect(report.scoreOn(DateTime(2026, 8, 13)), isNull);

    // 비교할 이전 기록일이 없으면 서버가 change 키를 통째로 뺀다.
    // 앱이 여기서 0 을 만들면 "변화 없음"이라는 없는 사실이 생긴다.
    expect(report.concerns, isNotEmpty);
    expect(report.concerns.every((item) => item.change == null), isTrue);

    // 하루뿐이면 BEST 와 WORST 가 같은 날이다. 서버가 정한 결과 그대로 그린다.
    expect(report.bestDay?.date, report.worstDay?.date);

    expect(report.aiComment?.goodPoint, isNotNull);
    expect(report.aiComment?.nextWeek, isNotNull);
    expect(report.aiComment?.isEmpty, isFalse);
  });

  test('여러 날 기록한 주 — 빈 날은 목록에 없고 변화량이 붙는다', () {
    // 로컬 DB 에 과거 기록이 없어 서버로 만들 수 없는 상태다. 실제 응답에서
    // 날짜·점수·변화량만 늘렸고 필드 모양은 그대로다.
    final report =
        WeeklyReportDto.fromJson(data('report_weekly_multiday')).toEntity();

    expect(report.averageDailyScore, 76);
    expect(report.recordedDays, 5);
    expect(report.dailyScores.length, 5);

    // 기록이 없는 날(8/13·8/16)은 목록에 아예 없다 — 0 점으로 채우지 않는다.
    expect(report.scoreOn(DateTime(2026, 8, 13)), isNull);
    expect(report.scoreOn(DateTime(2026, 8, 14))?.dailyScore, 91);
    expect(report.dailyScores.every((score) => score.dailyScore > 0), isTrue);

    // 동점 처리까지 서버가 정한 결과다. 앱이 다시 고르지 않는다.
    expect(report.bestDay?.dailyScore, 91);
    expect(report.worstDay?.dailyScore, 64);

    // **서버 필드명은 `changeFromFirstDay` 다.** `change` 로 읽으면 파싱이
    // 조용히 null 이 되고 화면은 증감을 영영 안 그린다 — 예외도 경고도 없어서
    // 다일 기록이 쌓이기 전에는 아무도 못 알아챈다. 원시 키를 함께 못 박는다.
    final raw = data('report_weekly_multiday')['concerns'] as List<dynamic>;
    expect((raw.first as Map<String, dynamic>).containsKey('changeFromFirstDay'),
        isTrue);
    expect((raw.first as Map<String, dynamic>).containsKey('change'), isFalse);

    expect(report.concerns.first.change, 8);
    expect(report.concerns[1].change, -3);
    // 기록일이 둘 이상이면 서버가 모든 고민에 균일하게 채운다. 변화가 없는
    // 고민은 키가 빠지는 게 아니라 0 이다 — null 과 0 은 다른 뜻이다.
    expect(report.concerns[2].change, 0);
  });

  test('AI 생성이 실패하면 aiComment 키만 빠진다 — 숫자는 그대로 온다', () {
    final json = data('report_weekly_no_ai');
    expect(json.containsKey('aiComment'), isFalse);

    final report = WeeklyReportDto.fromJson(json).toEntity();

    // 문장 하나 때문에 화면 전체가 비면 안 된다.
    expect(report.aiComment, isNull);
    expect(report.averageDailyScore, isNotNull);
    expect(report.dailyScores, isNotEmpty);
    expect(report.nutrition, isNotEmpty);
    expect(report.bestDay, isNotNull);
  });

  test('기록이 0건인 주는 평균·BEST DAY·aiComment 키가 통째로 빠진다', () {
    final json = data('report_weekly_empty');
    expect(json.containsKey('averageDailyScore'), isFalse);
    expect(json.containsKey('bestDay'), isFalse);
    expect(json.containsKey('aiComment'), isFalse);

    final report = WeeklyReportDto.fromJson(json).toEntity();
    expect(report.averageDailyScore, isNull);
    expect(report.grade, isNull);
    expect(report.bestDay, isNull);
    expect(report.worstDay, isNull);
    expect(report.isEmpty, isTrue);
    // 축은 남아 있어야 한다. 빈 주에도 7칸짜리 그래프 자리가 그려진다.
    expect(report.axis.length, 7);
  });

  test('실패 응답에는 data 키 자체가 없다', () {
    // 서버가 non_null 직렬화라 값이 없으면 키가 사라진다.
    // "data 가 null" 과 "data 키 없음"을 같게 다루지 않으면 여기서 깨진다.
    final body = jsonDecode('{"success":false,"error":{"code":"UNAUTHORIZED","message":"로그인이 필요합니다."}}')
        as Map<String, dynamic>;

    expect(body.containsKey('data'), isFalse);
  });
}
