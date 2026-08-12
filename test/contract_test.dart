import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/data/models/auth_dtos.dart';
import 'package:skinplate/features/recommendation/data/models/recommendation_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/shared/enums/cooking_method.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/ingredient_tag.dart';
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

  test('POST /plates/{id}/simulate — 60 → 68', () {
    final simulation = PlateSimulationDto.fromJson(data('plate_simulate')).toEntity();

    expect(simulation.beforeScore, 60);
    expect(simulation.afterScore, 68);
    expect(simulation.gain, 8);
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
