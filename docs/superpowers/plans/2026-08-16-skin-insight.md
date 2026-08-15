# 개인화 피부 인사이트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 피부 분석 결과에서 이어지는 개인화 인사이트 화면을 만들고, 그 화면이 쓸 생활 습관 데이터를 기기 저장소에서 서버로 옮긴다.

**Architecture:** 프로필의 단일 원천을 `Authenticated.user` 로 바꾼다 (`PATCH /auth/me` 확장, `SkinProfileStore` 삭제). 인사이트는 `features/skin_analysis/` 안에 DTO → 엔티티 → Repository → `FutureProvider.autoDispose.family` → 화면 순으로 기존 추천 화면과 같은 계층을 그대로 복제한다. 백엔드는 `ExerciseHabit` 에 값 하나를 더하는 것 외에 건드리지 않는다.

**Tech Stack:** Flutter 3.24+ / Riverpod (수동 Provider 선언) / go_router / Dio / freezed. 백엔드는 Spring Boot 3.3.5 / Java 21.

**설계 문서:** `docs/superpowers/specs/2026-08-16-skin-insight-design.md` — 계약 실측값과 결정 근거가 전부 여기 있다.

## Global Constraints

- 생성 코드 `.freezed.dart` / `.g.dart` 를 **커밋한다.** `*_dtos.dart` 를 고쳤으면 반드시 `dart run build_runner build --delete-conflicting-outputs`
- 서버는 `default-property-inclusion: non_null` — 생략 가능 필드에 `required` 금지. `@Default` 또는 nullable
- **DTO 필드에 enum 을 쓰지 않는다.** `String` 으로 받고 도메인 변환에서 파서를 태운다 (기존 `HighlightDto.status` 패턴)
- enum 파서의 기본값: `HighlightStatus` → `warn` · `SkinType`/`SkinConcern`/습관 4종/`InsightCategory` → **`null`**
- `validateStatus` 를 건드리지 않는다. 401 인터셉터의 `/auth/` 예외를 제거하지 않는다
- 서버가 준 점수·우선순위·변화량을 앱에서 다시 계산하지 않는다
- 색 리터럴 금지 — `AppColors` 가 유일한 출처. 점수 → 색은 반드시 `ScoreGrade` 를 지난다
- 곡률: 컨트롤 8 · 카드 9 · 강조 카드 16 · 배지 10. `pagePadding = 32`. elevation 전부 0
- 커밋 메시지: Conventional Commits + 한국어. `{type}({scope}): 내용`. Claude 표기 넣지 않는다
- 커밋 전 `flutter analyze && flutter test` 둘 다 통과

---

## Task 1: 백엔드 `ExerciseHabit` 4종 확장

**저장소:** `../Skinpick-backend` (브랜치 `feat/skin-insight-api` 위에 커밋 추가)

**Files:**
- Modify: `src/main/java/com/skinplate/api/domain/user/entity/ExerciseHabit.java`
- Modify: `SkinPlate_DTO_Domain.md`, `SkinPlate_PRD.md` (운동 enum 표기 지점)
- Test: `src/test/java/com/skinplate/api/domain/insight/InsightTopicsTest.java`

**Interfaces:**
- Produces: `ExerciseHabit` 값 4종 `NONE` `LIGHT` `REGULAR` `FREQUENT` — Task 2 의 앱 wire 값이 이것과 1:1로 맞아야 한다

- [ ] **Step 1: 실패하는 테스트를 먼저 쓴다**

`InsightTopicsTest.java` 에 추가. 기존 테스트가 쓰는 `profile` 픽스처 이름을 그대로 따른다.

```java
@Test
@DisplayName("운동을 자주 하면 EXERCISE 주제가 잡히지 않는다")
void frequentExerciseIsNotATopic() {
    profile.changeExerciseHabit(ExerciseHabit.FREQUENT);

    List<Topic> topics = InsightTopics.select(healthyMetrics(), profile);

    assertThat(topics).extracting(Topic::category).doesNotContain(InsightCategory.EXERCISE);
}
```

`healthyMetrics()` 가 기존 테스트에 없으면 파일 안의 다른 테스트가 쓰는 정상 지표 생성 방식을 그대로 복사해 쓴다.

- [ ] **Step 2: 컴파일 실패를 확인한다**

Run: `cd ../Skinpick-backend && ./gradlew test --tests '*InsightTopicsTest*'`
Expected: FAIL — `FREQUENT` 심볼을 찾을 수 없다

- [ ] **Step 3: enum 에 값을 더한다**

`ExerciseHabit.java` 전체를 아래로 바꾼다.

```java
package com.skinplate.api.domain.user.entity;

/** 운동 습관 (자가 신고). NULL = 미선택. */
public enum ExerciseHabit {

    NONE    ("거의 안 함"),
    LIGHT   ("주 1-2회"),
    REGULAR ("주 3-4회"),
    FREQUENT("주 5회 이상");

    private final String label;

    ExerciseHabit(String label) { this.label = label; }

    public String getLabel() { return label; }
}
```

`REGULAR` 의 라벨이 "주 3회 이상" 에서 "주 3-4회" 로 바뀐다. `FREQUENT` 가 생겨 의미가 좁아졌기 때문이다.
라벨은 AI 프롬프트(`SkinInsightPrompt`)와 `InsightTopics` 에만 들어간다.

**마이그레이션을 만들지 않는다.** `app_user.exercise_habit` 과 `skin_insight.snapshot_exercise_habit` 둘 다
`VARCHAR(20)` 이고 CHECK 제약이 없다. 트리거 조건 `== ExerciseHabit.NONE` 도 그대로 둔다.

- [ ] **Step 4: 테스트가 통과하는지 본다**

Run: `cd ../Skinpick-backend && ./gradlew test`
Expected: PASS. 기존 `RecommendationServiceTest` · `InsightTopicsTest` 가 쓰는 `NONE` · `REGULAR` 는 그대로 유효하다

- [ ] **Step 5: 문서를 같이 고친다**

`SkinPlate_DTO_Domain.md` 와 `SkinPlate_PRD.md` 에서 `ExerciseHabit` 이 나오는 곳을 찾아 4종으로 고친다.

Run: `cd ../Skinpick-backend && grep -n "ExerciseHabit\|REGULAR\|주 3회 이상" SkinPlate_DTO_Domain.md SkinPlate_PRD.md`

백엔드 CLAUDE.md 규칙이다 — "코드가 문서와 어긋나면 그 자리에서 문서를 고친다."

- [ ] **Step 6: 커밋**

```bash
cd ../Skinpick-backend
git add src/main/java/com/skinplate/api/domain/user/entity/ExerciseHabit.java \
        src/test/java/com/skinplate/api/domain/insight/InsightTopicsTest.java \
        SkinPlate_DTO_Domain.md SkinPlate_PRD.md
git commit -m "feat(user): 운동 습관을 4종으로 확장 — 앱과 wire 값 1:1"
```

---

## Task 2: 앱 enum wire 교정 · `WaterIntake` 신설

**Files:**
- Modify: `lib/features/auth/domain/entities/skin_profile.dart`
- Modify: `lib/features/auth/presentation/pages/skin_type_page.dart:224,230` (`StressLevel.medium` 참조)
- Test: `test/skin_profile_enum_test.dart` (신규)

**Interfaces:**
- Consumes: Task 1 의 `ExerciseHabit` 4종
- Produces: `SkinConcern.wire` · `SleepPattern` · `StressLevel` · `ExerciseHabit` · `WaterIntake` — 전부 `(wire, label, description)` 과 `static T? fromWire(String)`. Task 3·4·5 가 쓴다

- [ ] **Step 1: 실패하는 테스트를 먼저 쓴다**

Create `test/skin_profile_enum_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';

/// wire 값이 서버 enum 과 1:1 이어야 왕복이 성립한다.
/// 하나라도 어긋나면 PATCH 는 400 이고, GET 은 조용히 null 이 된다 — 후자가 더 나쁘다.
void main() {
  test('서버 enum 이름과 1:1', () {
    expect(SkinConcern.values.map((c) => c.wire).toSet(), {
      'ACNE', 'REDNESS', 'DARK_CIRCLE', 'DRYNESS', 'OILINESS',
      'TEXTURE', 'PIGMENTATION', 'ELASTICITY', 'PUFFINESS',
    });
    expect(SleepPattern.values.map((s) => s.wire).toList(),
        ['LACKING', 'NORMAL', 'ENOUGH']);
    expect(StressLevel.values.map((s) => s.wire).toList(),
        ['LOW', 'NORMAL', 'HIGH']);
    expect(ExerciseHabit.values.map((e) => e.wire).toList(),
        ['NONE', 'LIGHT', 'REGULAR', 'FREQUENT']);
    expect(WaterIntake.values.map((w) => w.wire).toList(),
        ['LACKING', 'NORMAL', 'ENOUGH']);
  });

  test('모르는 값은 null 로 떨어진다 — 미선택과 섞이지 않게', () {
    expect(WaterIntake.fromWire('SPARKLING'), isNull);
    expect(ExerciseHabit.fromWire('STEADY'), isNull); // 옛 앱 전용 값
    expect(SkinConcern.fromWire('TROUBLE'), isNull);  // InsightCategory 값이지 고민이 아니다
  });

  test('왕복', () {
    for (final habit in ExerciseHabit.values) {
      expect(ExerciseHabit.fromWire(habit.wire), habit);
    }
    for (final intake in WaterIntake.values) {
      expect(WaterIntake.fromWire(intake.wire), intake);
    }
  });
}
```

- [ ] **Step 2: 실패를 확인한다**

Run: `flutter test test/skin_profile_enum_test.dart`
Expected: FAIL — `WaterIntake` 가 정의되지 않았고 wire 값이 어긋난다

- [ ] **Step 3: enum 을 고친다**

`skin_profile.dart` 의 파일 상단 주석(1~7행)을 바꾼다. "아직 서버에 컬럼이 없다" 는 이제 거짓이다.

```dart
/// 피부 프로필 설문의 나머지 절반 — 고민·생활 습관.
///
/// 전부 서버가 소유한다(`GET/PATCH /auth/me`). wire 이름은 서버 enum 과 1:1 이다 —
/// 매핑표를 사이에 두면 언젠가 한 칸 어긋나고, 그때 증상은 400 이 아니라
/// "값이 저장은 됐는데 화면에는 미선택으로 뜬다" 쪽이라 찾기 어렵다.
library;
```

`SkinConcern.sebumOil` 의 wire 만 바꾼다. 식별자는 그대로 둔다 — `rednessSensitive`(REDNESS)처럼
이 enum 은 원래 식별자와 wire 가 1:1이 아니다.

```dart
  sebumOil('OILINESS', '피지/유분'),
```

`StressLevel.medium` → `normal`, wire `MEDIUM` → `NORMAL`:

```dart
  normal('NORMAL', '보통', '보통 수준의\n스트레스를 느껴요'),
```

`ExerciseHabit` 을 4종으로. 라벨·설명은 시안 문구 그대로 두고 식별자와 wire만 서버에 맞춘다:

```dart
enum ExerciseHabit {
  none('NONE', '거의 안 해요', '운동을 거의 하지 않아요'),
  light('LIGHT', '주 1-2회', '가벼운 운동을 주 1-2회 해요'),
  regular('REGULAR', '주 3-4회', '꾸준한 운동을 주 3-4회 해요'),
  frequent('FREQUENT', '주 5회 이상', '주 5회 이상 규칙적으로 해요');
```

`ExerciseHabit` 다음에 `WaterIntake` 를 더한다:

```dart
/// 수분 섭취. 수면과 같은 3단계 척도다.
enum WaterIntake {
  lacking('LACKING', '부족해요', '하루 4잔 미만\n자주 잊는 편이에요'),
  normal('NORMAL', '보통이에요', '하루 5~7잔 정도\n적당히 마셔요'),
  enough('ENOUGH', '충분해요', '하루 8잔 이상\n꾸준히 마셔요');

  const WaterIntake(this.wire, this.label, this.description);

  final String wire;
  final String label;
  final String description;

  static WaterIntake? fromWire(String value) {
    for (final intake in values) {
      if (intake.wire == value) return intake;
    }
    return null;
  }
}
```

`SkinProfile` 클래스(93~124행)는 **아직 지우지 않는다.** Task 5 에서 호출처와 함께 지운다.

- [ ] **Step 4: 깨진 참조를 고친다**

`skin_type_page.dart` 224행과 230행의 `StressLevel.medium` → `StressLevel.normal`.

Run: `flutter analyze`
Expected: 오류 없음

- [ ] **Step 5: 테스트가 통과하는지 본다**

Run: `flutter test test/skin_profile_enum_test.dart`
Expected: PASS

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/domain/entities/skin_profile.dart \
        lib/features/auth/presentation/pages/skin_type_page.dart \
        test/skin_profile_enum_test.dart
git commit -m "feat(auth): 생활 습관 enum wire 를 서버와 1:1 로 맞추고 WaterIntake 추가"
```

---

## Task 3: `MeResponseDto` · `AuthUser` 에 고민·습관 싣기

**Files:**
- Modify: `lib/features/auth/data/models/auth_dtos.dart:70-83` (DTO), `:99-108` (변환)
- Modify: `lib/features/auth/domain/entities/auth_user.dart`
- Modify: `test/fixtures/auth_me.json`
- Create: `test/fixtures/auth_me_no_profile.json`
- Test: `test/contract_test.dart`

**Interfaces:**
- Consumes: Task 2 의 enum 들
- Produces: `AuthUser.skinConcerns` (`Set<SkinConcern>`) · `.sleepPattern` (`SleepPattern?`) · `.stressLevel` (`StressLevel?`) · `.exerciseHabit` (`ExerciseHabit?`) · `.waterIntake` (`WaterIntake?`). Task 5 가 프리필에, Task 8 이 생활 상태 섹션에 쓴다

- [ ] **Step 1: 픽스처 두 개를 만든다**

`test/fixtures/auth_me.json` 을 프로필이 채워진 응답으로 바꾼다:

```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "test@skinplate.app",
    "nickname": "테스트유저",
    "declaredSkinType": "OILY",
    "skinConcerns": ["ACNE", "OILINESS"],
    "sleepPattern": "LACKING",
    "stressLevel": "HIGH",
    "exerciseHabit": "NONE",
    "waterIntake": "LACKING",
    "isTestAccount": true,
    "joinedAt": "2026-08-08T10:00:00"
  }
}
```

`test/fixtures/auth_me_no_profile.json` 은 **미선택이라 서버가 키를 지운** 응답이다:

```json
{
  "success": true,
  "data": {
    "userId": 2,
    "email": "fresh@skinplate.app",
    "nickname": "새사용자",
    "skinConcerns": [],
    "isTestAccount": false,
    "joinedAt": "2026-08-16T09:00:00"
  }
}
```

- [ ] **Step 2: 실패하는 테스트를 쓴다**

`test/contract_test.dart` 의 `GET /auth/me` 테스트 아래에 추가. import 에
`package:skinplate/features/auth/domain/entities/skin_profile.dart` 를 더한다.

```dart
  test('GET /auth/me — 고민·습관 4종을 읽는다', () {
    final user = MeResponseDto.fromJson(data('auth_me')).toEntity();

    expect(user.skinConcerns, {SkinConcern.acne, SkinConcern.sebumOil});
    expect(user.sleepPattern, SleepPattern.lacking);
    expect(user.stressLevel, StressLevel.high);
    expect(user.exerciseHabit, ExerciseHabit.none);
    expect(user.waterIntake, WaterIntake.lacking);
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
  });
```

- [ ] **Step 3: 실패를 확인한다**

Run: `flutter test test/contract_test.dart`
Expected: FAIL — `skinConcerns` 게터가 없다

- [ ] **Step 4: `AuthUser` 를 넓힌다**

`auth_user.dart` 의 `AuthUser` 를 아래로 바꾼다. import 에 `skin_profile.dart` 를 더한다.

```dart
import '../../../../shared/enums/skin_type.dart';
import 'skin_profile.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
    this.declaredSkinType,
    this.skinConcerns = const <SkinConcern>{},
    this.sleepPattern,
    this.stressLevel,
    this.exerciseHabit,
    this.waterIntake,
    this.isTestAccount = false,
    this.joinedAt,
  });

  final int userId;
  final String email;
  final String nickname;

  /// null = 아직 안 정함(건너뜀). SkinType.unknown 과 다르다.
  final SkinType? declaredSkinType;

  /// 빈 집합 = 고민 없음. 서버는 이 필드만 null(변경 없음)과 []( 전부 해제)를 구분한다.
  final Set<SkinConcern> skinConcerns;

  /// 습관 4종. null = 미선택. UI 에 해제 개념이 없어 null 로 되돌릴 길이 없다.
  final SleepPattern? sleepPattern;
  final StressLevel? stressLevel;
  final ExerciseHabit? exerciseHabit;
  final WaterIntake? waterIntake;

  final bool isTestAccount;
  final DateTime? joinedAt;

  bool get needsSkinTypePrompt => declaredSkinType == null;

  /// 인사이트 화면의 "생활 상태 설정" 안내를 띄울지 결정한다.
  bool get hasIncompleteLifestyle =>
      sleepPattern == null ||
      stressLevel == null ||
      exerciseHabit == null ||
      waterIntake == null;
}
```

- [ ] **Step 5: DTO 를 넓히고 변환을 잇는다**

`auth_dtos.dart` 의 `MeResponseDto` 에 필드 5개를 더한다. **전부 String/List\<String\> 이다** —
DTO 에 enum 을 쓰면 모르는 값이 파싱 예외가 되고, 그 예외는 로그인 직후에 터진다.

```dart
@freezed
class MeResponseDto with _$MeResponseDto {
  const factory MeResponseDto({
    required int userId,
    required String email,
    required String nickname,
    String? declaredSkinType,          // 미선택이면 서버가 키를 생략한다
    @Default(<String>[]) List<String> skinConcerns,
    String? sleepPattern,
    String? stressLevel,
    String? exerciseHabit,
    String? waterIntake,
    @JsonKey(name: 'isTestAccount') @Default(false) bool isTestAccount,
    DateTime? joinedAt,
  }) = _MeResponseDto;

  factory MeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MeResponseDtoFromJson(json);
}
```

변환 extension 을 바꾼다. import 에 `../../domain/entities/skin_profile.dart` 를 더한다.

```dart
extension MeResponseDtoX on MeResponseDto {
  AuthUser toEntity() => AuthUser(
        userId: userId,
        email: email,
        nickname: nickname,
        declaredSkinType: SkinType.fromJson(declaredSkinType),
        skinConcerns: skinConcerns
            .map(SkinConcern.fromWire)
            .whereType<SkinConcern>()
            .toSet(),
        sleepPattern: _parse(sleepPattern, SleepPattern.fromWire),
        stressLevel: _parse(stressLevel, StressLevel.fromWire),
        exerciseHabit: _parse(exerciseHabit, ExerciseHabit.fromWire),
        waterIntake: _parse(waterIntake, WaterIntake.fromWire),
        isTestAccount: isTestAccount,
        joinedAt: joinedAt,
      );
}

/// 키가 없으면 null, 있으면 파서에 넘긴다. 모르는 값도 null 이다 —
/// 습관은 "미선택"이 정상 상태라 억지 기본값을 두면 안 고른 사람과 섞인다.
T? _parse<T>(String? value, T? Function(String) fromWire) =>
    value == null ? null : fromWire(value);
```

- [ ] **Step 6: 생성 코드를 다시 만든다**

Run: `dart run build_runner build --delete-conflicting-outputs`
안 돌리면 컴파일은 되고 파싱만 틀린다.

- [ ] **Step 7: 테스트가 통과하는지 본다**

Run: `flutter analyze && flutter test test/contract_test.dart`
Expected: PASS

- [ ] **Step 8: 커밋**

```bash
git add lib/features/auth/data/models/auth_dtos.dart \
        lib/features/auth/data/models/auth_dtos.freezed.dart \
        lib/features/auth/data/models/auth_dtos.g.dart \
        lib/features/auth/domain/entities/auth_user.dart \
        test/fixtures/auth_me.json test/fixtures/auth_me_no_profile.json \
        test/contract_test.dart
git commit -m "feat(auth): MeResponse 에서 고민·생활 습관 4종을 읽는다"
```

---

## Task 4: `updateProfile` 로 넓히기

**Files:**
- Modify: `lib/features/auth/data/datasources/auth_remote_datasource.dart:38-45`
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Modify: `lib/features/auth/presentation/providers/auth_notifier.dart:117-130`
- Modify: `lib/features/skin_analysis/presentation/pages/skin_result_page.dart` (`_SkinTypePromptState._select`)
- Test: `test/auth_patch_test.dart` (신규)

**Interfaces:**
- Consumes: Task 2 의 enum, Task 3 의 `AuthUser`
- Produces: `AuthNotifier.updateProfile({SkinType? declaredSkinType, Set<SkinConcern>? skinConcerns, SleepPattern? sleepPattern, StressLevel? stressLevel, ExerciseHabit? exerciseHabit, WaterIntake? waterIntake})` → `Future<Failure?>`. Task 5 가 쓴다

- [ ] **Step 1: 실패하는 테스트를 쓴다**

`test/core_test.dart` 의 `_StubAdapter` 구현을 그대로 복사해 온다 (mock 라이브러리를 쓰지 않는 것이 이 저장소 관례다).

Create `test/auth_patch_test.dart`:

```dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// PATCH 본문이 이 계약의 전부다.
/// 키를 빠뜨리면 400 이 아니라 "저장한 줄 알았는데 안 된" 상태가 된다.
void main() {
  late Map<String, dynamic> sentBody;

  AuthRemoteDataSource source() {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = _CaptureAdapter((body) => sentBody = body);
    return AuthRemoteDataSource(dio);
  }

  test('고른 필드만 실린다 — 미선택 습관은 키가 없다', () async {
    await source().updateProfile(
      declaredSkinType: SkinType.oily,
      skinConcerns: {SkinConcern.acne},
      sleepPattern: SleepPattern.lacking,
    );

    expect(sentBody, {
      'declaredSkinType': 'OILY',
      'skinConcerns': ['ACNE'],
      'sleepPattern': 'LACKING',
    });
    expect(sentBody.containsKey('stressLevel'), isFalse);
    expect(sentBody.containsKey('waterIntake'), isFalse);
  });

  test('고민을 전부 해제하면 빈 배열이 실린다', () async {
    // 서버는 skinConcerns 만 null(변경 없음)과 [](전부 해제)를 구분한다.
    // 키를 빼면 해제가 조용히 무시되고 이전 고민이 그대로 남는다.
    await source().updateProfile(skinConcerns: const <SkinConcern>{});

    expect(sentBody, {'skinConcerns': <String>[]});
  });

  test('습관 4종이 모두 실린다', () async {
    await source().updateProfile(
      sleepPattern: SleepPattern.enough,
      stressLevel: StressLevel.normal,
      exerciseHabit: ExerciseHabit.frequent,
      waterIntake: WaterIntake.enough,
    );

    expect(sentBody, {
      'sleepPattern': 'ENOUGH',
      'stressLevel': 'NORMAL',
      'exerciseHabit': 'FREQUENT',
      'waterIntake': 'ENOUGH',
    });
  });
}

class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter(this.onBody);

  final void Function(Map<String, dynamic>) onBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? __) async {
    onBody(options.data as Map<String, dynamic>);
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'userId': 1,
          'email': 'test@skinplate.app',
          'nickname': '테스트유저',
          'skinConcerns': <String>[],
          'isTestAccount': false,
        },
      }),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}
```

`Uint8List` 를 쓰므로 `import 'dart:typed_data';` 를 더한다.

- [ ] **Step 2: 실패를 확인한다**

Run: `flutter test test/auth_patch_test.dart`
Expected: FAIL — `updateProfile` 이 없다

- [ ] **Step 3: DataSource 를 넓힌다**

`auth_remote_datasource.dart` 의 `updateSkinType`(38~45행)을 아래로 **교체**한다.
import 에 `../../domain/entities/skin_profile.dart` 를 더한다.

```dart
  /// 보낸 필드만 바뀐다. 건너뛰기는 이 메서드를 호출하지 않는 것이다.
  ///
  /// skinConcerns 만 예외다 — 서버가 null(변경 없음)과 [](전부 해제)를 구분하므로
  /// 빈 집합도 그대로 실어 보낸다. null 여부로 판단하면 해제가 조용히 무시된다.
  Future<MeResponseDto> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) async {
    final body = <String, dynamic>{
      if (declaredSkinType != null) 'declaredSkinType': declaredSkinType.wire,
      if (skinConcerns != null)
        'skinConcerns': skinConcerns.map((concern) => concern.wire).toList(),
      if (sleepPattern != null) 'sleepPattern': sleepPattern.wire,
      if (stressLevel != null) 'stressLevel': stressLevel.wire,
      if (exerciseHabit != null) 'exerciseHabit': exerciseHabit.wire,
      if (waterIntake != null) 'waterIntake': waterIntake.wire,
    };

    final response = await _dio.patch<dynamic>('/auth/me', data: body);
    return MeResponseDto.fromJson(requireEnvelopeData(response));
  }
```

- [ ] **Step 4: Repository 와 Notifier 를 잇는다**

`auth_repository.dart` 의 `updateSkinType` 선언을 교체한다:

```dart
  /// 프로필 부분 수정. 보낸 필드만 바뀐다.
  ///
  /// 건너뛰기는 이 메서드를 호출하지 않는 것이다.
  /// SkinType.unknown 을 대신 보내면 "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  Future<Result<AuthUser>> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  });
```

`auth_repository_impl.dart`:

```dart
  @override
  Future<Result<AuthUser>> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) =>
      callApi(() async => (await _remote.updateProfile(
            declaredSkinType: declaredSkinType,
            skinConcerns: skinConcerns,
            sleepPattern: sleepPattern,
            stressLevel: stressLevel,
            exerciseHabit: exerciseHabit,
            waterIntake: waterIntake,
          ))
              .toEntity());
```

`auth_notifier.dart` 의 `updateSkinType`(117~130행)을 교체한다:

```dart
  /// S01c 온보딩과 S05 인라인 칩 두 곳에서 부른다.
  /// 건너뛰기는 이 메서드를 호출하지 않는 것이다 — UNKNOWN 을 대신 보내면
  /// "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  Future<Failure?> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  }) async {
    final result = await ref.read(authRepositoryProvider).updateProfile(
          declaredSkinType: declaredSkinType,
          skinConcerns: skinConcerns,
          sleepPattern: sleepPattern,
          stressLevel: stressLevel,
          exerciseHabit: exerciseHabit,
          waterIntake: waterIntake,
        );

    return result.when<Failure?>(
      success: (user) {
        state = Authenticated(user);
        return null;
      },
      failure: (failure) => failure,
    );
  }
```

세 파일 모두 import 에 `skin_profile.dart` 를 더한다.

- [ ] **Step 5: 남은 호출처를 고친다**

`skin_result_page.dart` 의 `_SkinTypePromptState._select` 안에서
`updateSkinType(type)` → `updateProfile(declaredSkinType: type)`.

Run: `flutter analyze`
Expected: 오류 없음. 남는 오류가 있다면 `skin_type_page.dart` 인데 Task 5 에서 고친다 —
그 파일 오류만 남았다면 이 단계는 통과로 본다

- [ ] **Step 6: 테스트가 통과하는지 본다**

Run: `flutter test test/auth_patch_test.dart`
Expected: PASS (3 케이스)

- [ ] **Step 7: 커밋**

```bash
git add lib/features/auth/data/datasources/auth_remote_datasource.dart \
        lib/features/auth/domain/repositories/auth_repository.dart \
        lib/features/auth/data/repositories/auth_repository_impl.dart \
        lib/features/auth/presentation/providers/auth_notifier.dart \
        lib/features/skin_analysis/presentation/pages/skin_result_page.dart \
        test/auth_patch_test.dart
git commit -m "feat(auth): PATCH /auth/me 로 고민·습관을 함께 보낸다"
```

---

## Task 5: 온보딩을 서버 원천으로 바꾸고 물 섭취 줄 추가

**Files:**
- Modify: `lib/features/auth/presentation/pages/skin_type_page.dart`
- Delete: `lib/features/auth/data/datasources/skin_profile_store.dart`
- Modify: `lib/features/auth/domain/entities/skin_profile.dart` (`SkinProfile` 클래스 삭제)
- Test: `test/onboarding_submit_test.dart` (신규)

**Interfaces:**
- Consumes: Task 4 의 `AuthNotifier.updateProfile`, Task 3 의 `AuthUser` 필드
- Produces: 없음 (화면)

- [ ] **Step 1: 실패하는 위젯 테스트를 쓴다**

Create `test/onboarding_submit_test.dart`. `home_widgets_test.dart` 의 `host()` 헬퍼와
`setSurfaceSize(Size(402, 874))` 패턴을 그대로 복사해 온다.

```dart
// 재진입 프리필이 없으면 제출이 이전 답을 전부 덮어쓴다. 실제로 났던 버그다.
testWidgets('저장된 프로필이 화면에 미리 깔린다', (tester) async {
  await tester.binding.setSurfaceSize(const Size(402, 874));
  await tester.pumpWidget(host(
    const SkinTypePage(),
    auth: Authenticated(AuthUser(
      userId: 1,
      email: 'test@skinplate.app',
      nickname: '테스트유저',
      declaredSkinType: SkinType.oily,
      skinConcerns: {SkinConcern.acne},
      sleepPattern: SleepPattern.lacking,
      waterIntake: WaterIntake.enough,
    )),
  ));
  await tester.pumpAndSettle();

  expect(find.text('부족해요'), findsOneWidget);   // 수면 줄의 현재 값
  expect(find.text('충분해요'), findsOneWidget);   // 물 섭취 줄의 현재 값
});

testWidgets('물 섭취 줄이 있다', (tester) async {
  await tester.binding.setSurfaceSize(const Size(402, 874));
  await tester.pumpWidget(host(const SkinTypePage(), auth: _freshUser));
  await tester.pumpAndSettle();

  expect(find.text('수분 섭취'), findsOneWidget);
});
```

`host()` 가 `AuthState` 를 주입할 수 있어야 한다. 기존 헬퍼가 `ProviderScope(overrides:)` 를
받지 않으면 `authNotifierProvider` 를 override 하는 인자를 더한다.

- [ ] **Step 2: 실패를 확인한다**

Run: `flutter test test/onboarding_submit_test.dart`
Expected: FAIL — "수분 섭취" 줄이 없다

- [ ] **Step 3: 상태 필드와 프리필을 바꾼다**

`skin_type_page.dart` 21행 주석 `/// 고민·습관은 서버에 컬럼이 없어 기기에 저장한다([SkinProfileStore]).`
를 지운다. 42행 `static const _store = SkinProfileStore(FlutterSecureStorage());` 도 지운다.
`flutter_secure_storage` 와 `skin_profile_store.dart` import 도 지운다.

상태 필드에 물 섭취를 더한다:

```dart
  WaterIntake? _water;
```

`initState` 를 통째로 바꾼다:

```dart
  @override
  void initState() {
    super.initState();
    // 홈의 "피부 프로필 수정"으로 다시 들어온 사용자다. 서버가 들고 있는 답을
    // 깔아 두지 않으면 빈 설문이 뜨고, 제출이 이전 답을 전부 덮어쓴다.
    final auth = ref.read(authNotifierProvider);
    if (auth is Authenticated) {
      _type = auth.user.declaredSkinType;
      _concerns.addAll(auth.user.skinConcerns);
      _sleep = auth.user.sleepPattern;
      _stress = auth.user.stressLevel;
      _exercise = auth.user.exerciseHabit;
      _water = auth.user.waterIntake;
    }
  }
```

`_progress` 에 물 섭취를 더한다. 지금 식이면 물만 고른 사용자는 점이 차지 않는다:

```dart
  int get _progress =>
      1 +
      (_type != null ? 1 : 0) +
      (_concerns.isNotEmpty ? 1 : 0) +
      ((_sleep ?? _stress ?? _exercise ?? _water) != null ? 1 : 0);
```

- [ ] **Step 4: 제출을 서버 한 번으로 바꾼다**

`_submit()` 의 `_store.save(...)` + `updateSkinType(type)` 두 줄을 아래 한 번으로 바꾼다:

```dart
    // 고민·습관·타입이 한 요청으로 간다. 두 번에 나눠 보내면 한쪽만 성공한
    // 상태가 생기고, 그때 화면은 성공도 실패도 아닌 것을 보여주게 된다.
    //
    // skinConcerns 는 비어 있어도 보낸다 — 서버가 [] 를 "전부 해제"로 읽는다.
    // 안 보내면 사용자가 방금 지운 고민이 서버에 그대로 남는다.
    final failure = await ref.read(authNotifierProvider.notifier).updateProfile(
          declaredSkinType: type,
          skinConcerns: _concerns,
          sleepPattern: _sleep,
          stressLevel: _stress,
          exerciseHabit: _exercise,
          waterIntake: _water,
        );
```

- [ ] **Step 5: 물 섭취 줄을 더한다**

281행 `enum _HabitRow { sleep, stress, exercise }` → `{ sleep, stress, exercise, water }`.

운동 `_HabitSection` 블록 다음(`const SizedBox(height: 8),` 뒤)에 아래를 넣는다.
수면 줄과 같은 `_CardOptions<T>` 를 쓴다 — `_RowOptions` 는 `ExerciseHabit` 이 박혀 있고,
물 섭취는 수면과 똑같은 3단계 척도라 카드형이 맞다.

```dart
          const SizedBox(height: 8),

          _HabitSection(
            row: _HabitRow.water,
            icon: Icons.water_drop_outlined,
            label: '수분 섭취',
            value: _water?.label,
            expanded: _expanded == _HabitRow.water,
            onToggleExpand: () => setState(() =>
                _expanded = _expanded == _HabitRow.water ? null : _HabitRow.water),
            child: _CardOptions<WaterIntake>(
              options: WaterIntake.values,
              selected: _water,
              labelOf: (option) => option.label,
              descriptionOf: (option) => option.description,
              iconOf: (option) => switch (option) {
                WaterIntake.lacking => Icons.sentiment_dissatisfied,
                WaterIntake.normal => Icons.sentiment_neutral,
                WaterIntake.enough => Icons.sentiment_satisfied_alt,
              },
              iconColorOf: (option, selected) =>
                  selected ? AppColors.primary : AppColors.textSecondary,
              onSelect: (option) => setState(() {
                _water = option;
                _expanded = null;
              }),
            ),
          ),
```

- [ ] **Step 6: 죽은 저장소를 지운다**

```bash
rm lib/features/auth/data/datasources/skin_profile_store.dart
```

`skin_profile.dart` 에서 `SkinProfile` 클래스(93~124행, `toJson`/`fromJson` 포함)를 지운다.
enum 들은 남긴다 — DESIGN.md src:22 가 라벨 출처로 참조한다.

Run: `flutter analyze`
Expected: 오류 없음. 남는 참조가 있으면 여기서 잡힌다

- [ ] **Step 7: 테스트가 통과하는지 본다**

Run: `flutter analyze && flutter test`
Expected: 전부 PASS

- [ ] **Step 8: 커밋**

```bash
git add -A lib/features/auth test/onboarding_submit_test.dart
git commit -m "feat(auth): 프로필을 서버 단일 원천으로 옮기고 수분 섭취 항목 추가"
```

- [ ] **Step 9: PR 을 연다**

```bash
git push -u origin feat/profile-server-sync
gh pr create --base develop --title "feat(auth): 생활 프로필을 서버로 옮기고 수분 섭취 추가"
```

PR 본문은 🚀 작업 내용 / 🤔 고민했던 내용 / 💬 리뷰 중점사항 세 항목. 파일·클래스명 나열 금지.
리뷰 중점사항에 "기기 저장본은 버려지므로 프로필을 한 번 다시 골라야 한다" 를 적는다.

---

## Task 6: `InsightCategory` 와 인사이트 계약

**브랜치:** 여기서부터 `feat/skin-insight-page` (`develop` 에서 분기, Task 5 머지 후)

**Files:**
- Create: `lib/shared/enums/insight_category.dart`
- Create: `lib/features/skin_analysis/data/models/skin_insight_dtos.dart`
- Create: `lib/features/skin_analysis/domain/entities/skin_insight.dart`
- Create: `test/fixtures/skin_insight.json`, `test/fixtures/skin_insight_first.json`, `test/fixtures/skin_insight_healthy.json`
- Test: `test/contract_test.dart`

**Interfaces:**
- Produces: `SkinInsight` (`summary`, `changes` `SkinInsightChanges?`, `insights` `List<SkinInsightItem>`, `todayActions` `List<SkinTodayAction>`) · `InsightCategory` 13종 + `iconOf`. Task 7·8 이 쓴다

- [ ] **Step 1: 픽스처 세 개를 만든다**

가능하면 로컬 서버(`app.ai.mock=true`)에서 curl 로 받아 저장한다. 서버를 띄울 수 없으면
아래를 쓰되 **파일 옆 커밋 메시지에 "손으로 쓴 픽스처" 임을 남긴다.**

`test/fixtures/skin_insight.json`:

```json
{
  "success": true,
  "data": {
    "skinAnalysisId": 12,
    "summary": "지금은 트러블과 수분을 함께 살펴보면 좋아요.",
    "changes": { "hydration": 5, "oil": -3, "redness": 2, "trouble": -7, "barrier": 4, "skinScore": 2 },
    "insights": [
      { "category": "SLEEP", "priority": "HIGH", "title": "수면 관리", "description": "요즘 잠이 부족한 편이라고 하셨어요." },
      { "category": "TROUBLE", "priority": "MEDIUM", "title": "트러블 관리", "description": "오늘 트러블 지표가 높게 나왔어요." }
    ],
    "todayActions": [
      { "category": "SLEEP", "title": "오늘은 평소보다 30분 일찍 누워 보세요" },
      { "category": "TROUBLE", "title": "자극이 적은 순한 세안제를 써 보세요" }
    ],
    "generatedAt": "2026-08-16T10:00:00"
  }
}
```

`test/fixtures/skin_insight_first.json` — 첫 분석이라 **`changes` 키가 통째로 없다**:

```json
{
  "success": true,
  "data": {
    "skinAnalysisId": 1,
    "summary": "오늘 측정한 결과를 기준으로 살펴봤어요.",
    "insights": [
      { "category": "DRY", "priority": "HIGH", "title": "수분 관리", "description": "수분 지표가 낮게 나왔어요." }
    ],
    "todayActions": [
      { "category": "DRY", "title": "보습제를 한 겹 더 발라 보세요" }
    ],
    "generatedAt": "2026-08-16T10:00:00"
  }
}
```

`test/fixtures/skin_insight_healthy.json` — 다룰 주제가 없어 저장도 안 된 응답:

```json
{
  "success": true,
  "data": {
    "skinAnalysisId": 7,
    "summary": "지금은 주요 지표가 모두 안정적이에요. 지금의 관리 습관을 그대로 이어가 보세요.",
    "changes": { "hydration": 0, "oil": 1, "redness": -1, "trouble": 0, "barrier": 2, "skinScore": 1 },
    "insights": [],
    "todayActions": [],
    "generatedAt": "2026-08-16T10:00:00"
  }
}
```

- [ ] **Step 2: 실패하는 테스트를 쓴다**

`test/contract_test.dart` 에 추가:

```dart
  test('GET /skin-insights — 요약·변화량·주제', () {
    final insight = SkinInsightDto.fromJson(data('skin_insight')).toEntity();

    expect(insight.summary, isNotEmpty);
    expect(insight.changes!.trouble, -7);
    expect(insight.changes!.skinScore, 2);
    // 순서가 곧 우선순위다. 앱이 정렬하지 않는다.
    expect(insight.insights.map((item) => item.category).toList(),
        [InsightCategory.sleep, InsightCategory.trouble]);
    // 두 배열은 같은 주제를 두 각도로 보여준다 — 길이와 순서가 항상 같다.
    expect(insight.todayActions.length, insight.insights.length);
  });

  test('GET /skin-insights — 첫 분석이면 changes 키가 없다', () {
    // 0 으로 채우면 "변화 없음"과 구분이 사라진다. null 이어야 한다.
    final insight = SkinInsightDto.fromJson(data('skin_insight_first')).toEntity();

    expect(insight.changes, isNull);
    expect(insight.insights, hasLength(1));
  });

  test('GET /skin-insights — 다룰 주제가 없으면 빈 배열이 온다', () {
    final insight = SkinInsightDto.fromJson(data('skin_insight_healthy')).toEntity();

    expect(insight.insights, isEmpty);
    expect(insight.todayActions, isEmpty);
    expect(insight.summary, isNotEmpty); // 빈 배열이어도 할 말은 있다
  });

  test('모르는 category 는 null 로 떨어진다', () {
    expect(InsightCategory.fromJson('TELEPORTATION'), isNull);
  });
```

- [ ] **Step 3: 실패를 확인한다**

Run: `flutter test test/contract_test.dart`
Expected: FAIL — `SkinInsightDto` 가 없다

- [ ] **Step 4: `InsightCategory` 를 만든다**

Create `lib/shared/enums/insight_category.dart`:

```dart
import 'package:flutter/material.dart';

/// 인사이트 주제 13종. 서버 `InsightCategory` 와 1:1 이다.
///
/// 라벨을 갖지 않는다 — 서버가 `title` 로 주기 때문이다. 앱이 라벨을 한 벌 더
/// 들고 있으면 서버가 문구를 고쳤을 때 두 곳이 어긋난다.
/// 여기 있는 것은 아이콘뿐이고, 아이콘은 서버가 줄 수 없는 값이다.
enum InsightCategory {
  // 측정 지표에서 온 주제
  dry('DRY', Icons.water_drop_outlined),
  oily('OILY', Icons.opacity),
  redness('REDNESS', Icons.waves),
  trouble('TROUBLE', Icons.blur_on),
  barrierWeak('BARRIER_WEAK', Icons.shield_outlined),

  // 자가 신고 고민에서 온 주제
  darkCircle('DARK_CIRCLE', Icons.dark_mode_outlined),
  pigmentation('PIGMENTATION', Icons.gradient),
  elasticity('ELASTICITY', Icons.trending_up),
  puffiness('PUFFINESS', Icons.bubble_chart_outlined),

  // 생활 습관에서 온 주제
  sleep('SLEEP', Icons.nightlight_outlined),
  stress('STRESS', Icons.sentiment_very_dissatisfied_outlined),
  exercise('EXERCISE', Icons.fitness_center),
  water('WATER', Icons.local_drink_outlined);

  const InsightCategory(this.wire, this.icon);

  final String wire;
  final IconData icon;

  /// 모르는 값은 null 이다. 아이콘을 고르는 값이라 억지 기본값을 두면
  /// 새 카테고리가 생겼을 때 엉뚱한 그림이 붙는다. 화면이 중립 아이콘을 쓴다.
  static InsightCategory? fromJson(String value) {
    for (final category in values) {
      if (category.wire == value) return category;
    }
    return null;
  }
}
```

- [ ] **Step 5: 엔티티를 만든다**

Create `lib/features/skin_analysis/domain/entities/skin_insight.dart`:

```dart
import '../../../../shared/enums/insight_category.dart';

/// S10 개인화 인사이트. 문장·순서·변화량은 전부 서버가 만든 것을 그대로 싣는다.
class SkinInsight {
  const SkinInsight({
    required this.skinAnalysisId,
    required this.summary,
    this.changes,
    required this.insights,
    required this.todayActions,
  });

  final int skinAnalysisId;
  final String summary;

  /// null = 직전 분석이 없다. 0 으로 채우면 "변화 없음"과 구분이 사라진다.
  final SkinInsightChanges? changes;

  /// 최대 3개. 배열 순서가 곧 우선순위다 — 앱이 다시 정렬하지 않는다.
  final List<SkinInsightItem> insights;

  /// insights 와 같은 주제를 행동 관점으로 본 것이다. 길이·순서가 항상 같다.
  final List<SkinTodayAction> todayActions;
}

/// 직전 분석 대비 증감. 부호 그대로다 — 방향 해석은 화면이 지표별로 한다.
class SkinInsightChanges {
  const SkinInsightChanges({
    required this.hydration,
    required this.oil,
    required this.redness,
    required this.trouble,
    required this.barrier,
    required this.skinScore,
  });

  final int hydration;
  final int oil;
  final int redness;
  final int trouble;
  final int barrier;
  final int skinScore;

  /// `SkinMetrics.toBars()` 의 key 로 델타를 찾는다. 두 리스트를 인덱스로
  /// 맞추면 지표 순서가 바뀌는 날 조용히 어긋난다.
  int? byKey(String key) => switch (key) {
        'hydration' => hydration,
        'oil' => oil,
        'redness' => redness,
        'trouble' => trouble,
        'barrier' => barrier,
        _ => null,
      };
}

class SkinInsightItem {
  const SkinInsightItem({
    required this.category,
    required this.title,
    required this.description,
  });

  /// null = 앱이 모르는 카테고리. 화면이 중립 아이콘을 쓴다.
  final InsightCategory? category;
  final String title;
  final String description;
}

class SkinTodayAction {
  const SkinTodayAction({required this.category, required this.title});

  final InsightCategory? category;
  final String title;
}
```

`priority` 를 엔티티에 두지 않는다. 화면이 배열 순서로만 강조를 정하므로 들고 있어도 쓰이지 않고,
들고 있으면 언젠가 그걸로 정렬하는 코드가 생긴다.

- [ ] **Step 6: DTO 를 만든다**

Create `lib/features/skin_analysis/data/models/skin_insight_dtos.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/insight_category.dart';
import '../../domain/entities/skin_insight.dart';

part 'skin_insight_dtos.freezed.dart';
part 'skin_insight_dtos.g.dart';

@freezed
class SkinInsightChangesDto with _$SkinInsightChangesDto {
  const factory SkinInsightChangesDto({
    required int hydration,
    required int oil,
    required int redness,
    required int trouble,
    required int barrier,
    required int skinScore,
  }) = _SkinInsightChangesDto;

  factory SkinInsightChangesDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightChangesDtoFromJson(json);
}

@freezed
class SkinInsightItemDto with _$SkinInsightItemDto {
  const factory SkinInsightItemDto({
    required String category,
    @Default('') String priority,   // HIGH / MEDIUM / LOW — 순서에서 파생된 값이다
    @Default('') String title,
    @Default('') String description,
  }) = _SkinInsightItemDto;

  factory SkinInsightItemDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightItemDtoFromJson(json);
}

@freezed
class SkinTodayActionDto with _$SkinTodayActionDto {
  const factory SkinTodayActionDto({
    required String category,
    @Default('') String title,
  }) = _SkinTodayActionDto;

  factory SkinTodayActionDto.fromJson(Map<String, dynamic> json) =>
      _$SkinTodayActionDtoFromJson(json);
}

@freezed
class SkinInsightDto with _$SkinInsightDto {
  const factory SkinInsightDto({
    required int skinAnalysisId,
    @Default('') String summary,
    /// 직전 분석이 없으면 서버가 키를 통째로 지운다.
    SkinInsightChangesDto? changes,
    /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이다.
    @Default(<SkinInsightItemDto>[]) List<SkinInsightItemDto> insights,
    @Default(<SkinTodayActionDto>[]) List<SkinTodayActionDto> todayActions,
    DateTime? generatedAt,
  }) = _SkinInsightDto;

  factory SkinInsightDto.fromJson(Map<String, dynamic> json) =>
      _$SkinInsightDtoFromJson(json);
}

extension SkinInsightDtoX on SkinInsightDto {
  SkinInsight toEntity() => SkinInsight(
        skinAnalysisId: skinAnalysisId,
        summary: summary,
        changes: changes?.toEntity(),
        insights: insights
            .map((item) => SkinInsightItem(
                  category: InsightCategory.fromJson(item.category),
                  title: item.title,
                  description: item.description,
                ))
            .toList(),
        todayActions: todayActions
            .map((action) => SkinTodayAction(
                  category: InsightCategory.fromJson(action.category),
                  title: action.title,
                ))
            .toList(),
      );
}

extension SkinInsightChangesDtoX on SkinInsightChangesDto {
  SkinInsightChanges toEntity() => SkinInsightChanges(
        hydration: hydration,
        oil: oil,
        redness: redness,
        trouble: trouble,
        barrier: barrier,
        skinScore: skinScore,
      );
}
```

- [ ] **Step 7: 생성 코드를 만들고 테스트를 돌린다**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/contract_test.dart`
Expected: PASS (4 케이스)

- [ ] **Step 8: 커밋**

```bash
git add lib/shared/enums/insight_category.dart \
        lib/features/skin_analysis/data/models/skin_insight_dtos.dart \
        lib/features/skin_analysis/data/models/skin_insight_dtos.freezed.dart \
        lib/features/skin_analysis/data/models/skin_insight_dtos.g.dart \
        lib/features/skin_analysis/domain/entities/skin_insight.dart \
        test/fixtures/skin_insight*.json test/contract_test.dart
git commit -m "feat(skin): 개인화 인사이트 응답 계약 추가"
```

---

## Task 7: Repository · Provider · 라우트 배선

**Files:**
- Modify: `lib/features/skin_analysis/data/datasources/skin_remote_datasource.dart`
- Modify: `lib/features/skin_analysis/domain/repositories/skin_repository.dart`
- Modify: `lib/features/skin_analysis/data/repositories/skin_repository_impl.dart`
- Modify: `lib/core/di/providers.dart`
- Modify: `lib/app/router/app_router.dart`

**Interfaces:**
- Consumes: Task 6 의 `SkinInsight`, `SkinInsightDto`
- Produces: `skinInsightProvider` (`FutureProvider.autoDispose.family<Result<SkinInsight>, int>`) · `Routes.skinInsight`. Task 8·9 가 쓴다

- [ ] **Step 1: DataSource 에 메서드를 더한다**

`skin_remote_datasource.dart` 의 `getById` 아래에. import 에 `skin_insight_dtos.dart` 를 더한다.

```dart
  /// get-or-create 다. 처음 부르면 서버가 AI 로 만들어 저장하고 돌려주므로
  /// 최대 ~27초 걸린다(AI 25초 타임아웃 + 429 1회 재시도). 두 번째부터는 DB 읽기다.
  ///
  /// 동시 호출은 서버가 락과 UNIQUE 로 직렬화한다 — 재시도가 중복 생성을 만들지 않는다.
  Future<SkinInsightDto> getInsight(int skinAnalysisId) async {
    final response = await _dio.get<dynamic>(
      '/skin-insights',
      queryParameters: <String, dynamic>{'skinAnalysisId': skinAnalysisId},
    );
    return SkinInsightDto.fromJson(requireEnvelopeData(response));
  }
```

- [ ] **Step 2: Repository 에 잇는다**

`skin_repository.dart`:

```dart
  /// 개인화 인사이트. 없으면 서버가 만들어 준다(get-or-create).
  Future<Result<SkinInsight>> getInsight(int skinAnalysisId);
```

`skin_repository_impl.dart`:

```dart
  @override
  Future<Result<SkinInsight>> getInsight(int skinAnalysisId) =>
      callApi(() async => (await _remote.getInsight(skinAnalysisId)).toEntity());
```

두 파일 모두 import 에 `skin_insight.dart` 를 더한다.

- [ ] **Step 3: Provider 를 더한다**

`providers.dart` 의 `// ---------- skin_analysis ----------` 블록에.
import 에 `Result`, `SkinInsight` 를 더한다.

```dart
/// 화면 rebuild 로 다시 부르지 않는다. 재진입 시엔 서버가 캐시된 인사이트를
/// 즉시 돌려주므로 autoDispose 로도 충분하다 — 다시 만드는 것이 아니다.
///
/// 재시도는 `ref.invalidate(skinInsightProvider(id))` 다. 서버가 실패한 인사이트를
/// 저장하지 않으므로 같은 GET 이 그대로 재시도가 된다.
final skinInsightProvider =
    FutureProvider.autoDispose.family<Result<SkinInsight>, int>(
  (ref, skinAnalysisId) =>
      ref.watch(skinRepositoryProvider).getInsight(skinAnalysisId),
);
```

- [ ] **Step 4: 라우트를 더한다**

`app_router.dart` 의 `Routes` 에:

```dart
  static const skinInsight = '/skin/insight'; // S10
```

`recommendations` 라우트 옆에 같은 형태로:

```dart
      GoRoute(
        path: '${Routes.skinInsight}/:skinAnalysisId',
        builder: (_, state) => SkinInsightPage(
          skinAnalysisId: int.parse(state.pathParameters['skinAnalysisId']!),
        ),
      ),
```

import 에 `skin_insight_page.dart` 를 더한다. Task 8 에서 그 파일을 만들기 전까지 컴파일이 깨진다 —
Task 8 과 이어서 진행한다.

- [ ] **Step 5: 분석만 통과시킨다**

Run: `flutter analyze`
Expected: `skin_insight_page.dart` 를 찾을 수 없다는 오류 1건만 남는다. 나머지가 깨끗해야 다음으로 간다

---

## Task 8: 인사이트 화면

**Files:**
- Create: `lib/features/skin_analysis/presentation/pages/skin_insight_page.dart`
- Modify: `lib/core/widgets/app_widgets.dart` (`LoadingSteps` 공개)
- Modify: `lib/features/skin_analysis/presentation/pages/skin_loading_page.dart` (`_LoadingSteps` 제거)

**Interfaces:**
- Consumes: Task 7 의 `skinInsightProvider`, Task 6 의 엔티티, Task 3 의 `AuthUser.hasIncompleteLifestyle`
- Produces: `SkinInsightPage({required int skinAnalysisId})`

- [ ] **Step 1: `LoadingSteps` 를 공용으로 옮긴다**

`skin_loading_page.dart` 의 `_LoadingSteps` 와 `_LoadingStepsState` 를 잘라내
`app_widgets.dart` 로 옮기고 밑줄을 뗀다 (`LoadingSteps`, `_LoadingStepsState` 는 유지).
`const _LoadingSteps(steps: ...)` 호출부를 `const LoadingSteps(steps: ...)` 로 바꾸고,
`skin_loading_page.dart` 의 `dart:async` import 가 더 안 쓰이면 지운다.
`app_widgets.dart` 에 `import 'dart:async';` 를 더한다.

Run: `flutter test test/`
Expected: 기존 테스트가 그대로 통과한다 (동작이 바뀌지 않았다)

- [ ] **Step 2: 화면을 만든다**

Create `lib/features/skin_analysis/presentation/pages/skin_insight_page.dart`.

뼈대는 아래와 같다. 카드·간격·타이포는 DESIGN.md 를 따른다 —
강조 카드 `AppColors.surfaceCard` + `AppColors.borderOnCream` + radius 16,
중립 카드 흰 배경 + `AppColors.borderOnWhite` + radius 9, `pagePadding` 32, elevation 0.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/score_grade.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/entities/skin_insight.dart';

/// S10 개인화 인사이트.
///
/// 문장은 하나도 앱이 만들지 않는다. summary·description·행동 문구 전부 서버가 준
/// 것을 그대로 싣는다 — 앱이 인과관계를 지어내면 의학적 표현 금지 규칙이 두 곳으로 갈린다.
class SkinInsightPage extends ConsumerWidget {
  const SkinInsightPage({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(skinInsightProvider(skinAnalysisId));

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 피부 인사이트')),
      body: insight.when(
        loading: () => const LoadingSteps(
          steps: [
            '피부와 생활 상태를 함께 보고 있어요',
            '오늘 측정한 지표를 살펴보는 중이에요',
            '설정해 둔 생활 습관과 맞춰 보는 중이에요',
            '오늘 신경 쓰면 좋을 것을 고르고 있어요',
          ],
        ),
        error: (error, _) => Center(child: Text('$error')),
        data: (result) => result.when(
          // AI 실패(502·504)는 mapToFailure 가 AnalysisFailure 로 번역하고
          // shouldRetakePhoto 가 false 라 "다시 시도" 버튼이 나온다.
          // 404 는 ServerFailure 로 떨어져 서버 메시지만 보인다.
          failure: (failure) => FailureView(
            failure: failure,
            onRetry: () => ref.invalidate(skinInsightProvider(skinAnalysisId)),
          ),
          success: (data) => _Body(insight: data),
        ),
      ),
    );
  }
}
```

같은 파일에 private 위젯 넷을 만든다. 시그니처를 고정한다 — Task 9 의 테스트가 이 구조를 본다.

```dart
class _Body extends ConsumerWidget {
  const _Body({required this.insight});
  final SkinInsight insight;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.grade,
    this.delta,
  });
  final String label;
  final int value;
  final ScoreGrade grade;
  final int? delta;          // null = 첫 분석이라 비교 대상이 없다
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item, required this.emphasized});
  final SkinInsightItem item;
  final bool emphasized;     // 첫 항목만 true — 크림 카드 + radius 16
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title});
  final String title;
}
```

`_Body` 는 `SingleChildScrollView` + `Padding(EdgeInsets.all(32))` + `Column` 이고 섹션 순서는
**현재 피부 상태 → 현재 설정된 생활 상태 → AI 인사이트 → 오늘의 우선 관리 → 오늘의 행동** 이다.

지표 값은 인사이트 응답에 없다. `latestSkinAnalysisProvider` 에서 읽는다:

```dart
    final analysis = ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;
    if (analysis == null) return const SizedBox.shrink();
```

```
ponytail: 최신 분석 = 이 화면의 분석이라고 가정한다. 피부 히스토리 화면이 없어
지금은 참이다. 과거 분석으로 들어오는 경로가 생기면 analysis.id != skinAnalysisId
일 때 skinRepository.getById(skinAnalysisId) 로 떨어뜨린다.
```

지표는 `analysis.metrics.toBars()` 로 5개를 다 그린다. 지표 값의 색은 `ScoreGrade` 를 지나되
**방향을 먼저 뒤집는다** — `oil`·`redness`·`trouble` 은 높을수록 나쁘다:

```dart
    for (final bar in metrics.toBars())
      _MetricRow(
        label: bar.label,
        value: bar.value,
        // higherIsBetter 가 false 면 뒤집어서 등급을 매긴다.
        // 안 뒤집으면 홍조가 심할수록 초록으로 칠해진다.
        grade: ScoreGrade.fromScore(bar.higherIsBetter ? bar.value : 100 - bar.value),
        delta: insight.changes?.byKey(bar.key),
      ),
```

`_Body` 는 `SkinAnalysis` 도 필요하다 — `ref.watch(latestSkinAnalysisProvider)` 로 읽는다.
`changes` 가 null 이면 지표 줄에 델타를 그리지 않고 카드 하단에 한 줄을 둔다:

```dart
    if (insight.changes == null)
      const Text('첫 피부 분석이라 아직 비교할 데이터가 없어요',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
```

생활 상태 섹션 제목은 **"현재 설정된 생활 상태"** 다. 값은 `auth.user` 의 각 enum `label`,
미선택은 `'미설정'`. 안내 문구는 `insight.insights.isEmpty` 로 가른다:

```dart
    // 빈 인사이트는 서버가 저장하지 않는다 — 지금 설정하면 이 분석에서 다시 만들어진다.
    // 저장된 인사이트라면 반대다. 두 경우에 같은 문구를 쓰면 한쪽은 거짓말이 된다.
    Text(
      insight.insights.isEmpty
          ? '생활 상태를 설정하고 다시 보면 인사이트가 채워져요'
          : '이 인사이트는 피부 분석 당시 설정한 생활 상태를 기준으로 생성되었어요.'
            ' 바꾼 내용은 다음 피부 분석부터 반영돼요.',
      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.35),
    ),
    if (user.hasIncompleteLifestyle)
      TextButton(
        onPressed: () => context.push(Routes.skinType),
        child: const Text('생활 상태 설정'),
      ),
```

우선 관리와 오늘의 행동은 **섹션 자체를 조건부로 그린다.** 비면 숨긴다 —
summary 가 이미 "지금은 주요 지표가 모두 안정적이에요" 를 말하고 있다:

```dart
    if (insight.insights.isNotEmpty) ...[
      const Text('오늘의 우선 관리', style: ...),
      for (final (index, item) in insight.insights.indexed)
        // 첫 항목만 강조 카드다. priority 를 글자로 노출하지 않는다.
        _InsightCard(item: item, emphasized: index == 0),
    ],
    if (insight.todayActions.isNotEmpty) ...[
      const Text('오늘의 행동', style: ...),
      // 우선 관리와 같은 주제가 다시 나온다. 아이콘 없이 한 줄로 납작하게 그려
      // 같은 카드를 두 번 그린 것처럼 보이지 않게 한다.
      for (final action in insight.todayActions) _ActionRow(title: action.title),
    ],
```

카테고리 아이콘은 `item.category?.icon ?? Icons.spa_outlined` — null 이면 중립 아이콘이다.

마지막에 안내 두 줄:

```dart
    const Text('측정 환경에 따라 결과가 달라질 수 있어요',
        style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    const SafetyNotice(),
```

- [ ] **Step 3: 분석을 통과시킨다**

Run: `flutter analyze`
Expected: 오류 없음 (Task 7 의 라우트 오류가 여기서 해소된다)

- [ ] **Step 4: 커밋**

```bash
git add lib/features/skin_analysis/presentation/pages/skin_insight_page.dart \
        lib/core/widgets/app_widgets.dart \
        lib/features/skin_analysis/presentation/pages/skin_loading_page.dart \
        lib/features/skin_analysis/domain/repositories/skin_repository.dart \
        lib/features/skin_analysis/data/repositories/skin_repository_impl.dart \
        lib/features/skin_analysis/data/datasources/skin_remote_datasource.dart \
        lib/core/di/providers.dart lib/app/router/app_router.dart
git commit -m "feat(skin): 개인화 인사이트 화면 추가"
```

---

## Task 9: 진입점과 화면 테스트

**Files:**
- Modify: `lib/features/skin_analysis/presentation/pages/skin_result_page.dart:96-108`
- Test: `test/skin_insight_widgets_test.dart` (신규)

**Interfaces:**
- Consumes: Task 8 의 `SkinInsightPage`, Task 7 의 `Routes.skinInsight`

- [ ] **Step 1: 실패하는 위젯 테스트를 쓴다**

Create `test/skin_insight_widgets_test.dart`. `plate_widgets_test.dart` 의 `host()` 와
`setSurfaceSize` 패턴을 복사해 온다. 세 상태를 시안 폭 402 에서 그린다.

```dart
/// 오버플로는 컴파일도 되고 테스트도 통과하지만 화면에는 노란 줄무늬로 나온다.
/// 시안 폭에서 한 번 그려 보는 것만으로 그 부류를 전부 걸러낸다.
const designSize = Size(402, 874);

testWidgets('인사이트 3개 상태가 402 폭에서 넘치지 않는다', (tester) async {
  for (final fixture in ['skin_insight', 'skin_insight_first', 'skin_insight_healthy']) {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(const SkinInsightPage(skinAnalysisId: 12), fixture));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: '$fixture 에서 오버플로');
  }
});

testWidgets('첫 분석이면 비교 문구가 뜬다', (tester) async {
  await tester.binding.setSurfaceSize(designSize);
  await tester.pumpWidget(host(const SkinInsightPage(skinAnalysisId: 1), 'skin_insight_first'));
  await tester.pumpAndSettle();

  expect(find.text('첫 피부 분석이라 아직 비교할 데이터가 없어요'), findsOneWidget);
});

testWidgets('다룰 주제가 없으면 두 섹션이 사라진다', (tester) async {
  await tester.binding.setSurfaceSize(designSize);
  await tester.pumpWidget(host(const SkinInsightPage(skinAnalysisId: 7), 'skin_insight_healthy'));
  await tester.pumpAndSettle();

  expect(find.text('오늘의 우선 관리'), findsNothing);
  expect(find.text('오늘의 행동'), findsNothing);
  // 빈 화면이 아니다 — 요약은 남아 있다.
  expect(find.textContaining('안정적이에요'), findsOneWidget);
});
```

`host()` 헬퍼는 프로바이더 셋을 픽스처로 채운다. 네트워크를 타지 않는다:

```dart
Widget host(Widget child, String fixture) {
  final insight = SkinInsightDto.fromJson(
    (jsonDecode(File('test/fixtures/$fixture.json').readAsStringSync())
        as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  ).toEntity();

  final analysis =
      SkinAnalysisDto.fromJson((jsonDecode(File('test/fixtures/skin_latest.json')
          .readAsStringSync()) as Map<String, dynamic>)['data']
              as Map<String, dynamic>).toEntity();

  return ProviderScope(
    overrides: [
      skinInsightProvider(insight.skinAnalysisId)
          .overrideWith((ref) async => Success(insight)),
      latestSkinAnalysisProvider.overrideWith((ref) async => Success(analysis)),
      authNotifierProvider.overrideWith(_StubAuth.new),
    ],
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

/// 프로필이 다 채워진 사용자. 미설정 안내가 끼어들면 오버플로 판정이 흐려진다.
class _StubAuth extends AuthNotifier {
  @override
  AuthState build() => Authenticated(const AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
        skinConcerns: {SkinConcern.acne},
        sleepPattern: SleepPattern.lacking,
        stressLevel: StressLevel.high,
        exerciseHabit: ExerciseHabit.none,
        waterIntake: WaterIntake.lacking,
      ));
}
```

`Success<T>(data)` 는 `core/result/result.dart` 의 생성자다 (`Result` 는 sealed, 실패 쪽은 `FailureResult`).
`skinInsightProvider(id)` 를 override 할 때 **테스트가 넘기는 `skinAnalysisId` 와 같은 id** 여야
한다 — family 는 인자별로 다른 프로바이더다.

- [ ] **Step 2: 실패를 확인한다**

Run: `flutter test test/skin_insight_widgets_test.dart`
Expected: FAIL 또는 오버플로 예외

- [ ] **Step 3: 화면 레이아웃을 고친다**

오버플로가 나면 긴 문장을 감싼 `Row` 를 `Expanded` 로 싸거나 `softWrap` 을 켠다.
델타 숫자 칸은 폭을 고정하지 말고 `FittedBox(fit: BoxFit.scaleDown)` 을 쓴다 (기존 점수 조판 관례).

- [ ] **Step 4: 결과 화면에 진입점을 단다**

`skin_result_page.dart` 96~108행. 추천 버튼은 `FeatureFlags` 뒤에 그대로 두고,
인사이트 버튼은 플래그 없이 단다 — 데모에 켤 화면이라 항상 true 인 플래그는 스위치가 아니다.

```dart
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: () => context.push(Routes.foodCapture),
            child: const Text('음식 분석 시작하기'),
          ),
          // S10 진입점. 방금 분석의 id 로 물어야 오늘 결과와 짝이 맞는다.
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.push('${Routes.skinInsight}/${analysis.id}'),
            child: const Text('내 생활 상태와 함께 분석하기'),
          ),
          // S08 진입점. 방금 분석의 id 로 추천을 물어야 오늘 결과와 짝이 맞는다.
          if (FeatureFlags.recommendationScreen) ...[
```

- [ ] **Step 5: 전체 검증**

Run: `flutter analyze && flutter test`
Expected: 전부 PASS

- [ ] **Step 6: 커밋하고 PR 을 연다**

```bash
git add lib/features/skin_analysis/presentation/pages/skin_result_page.dart \
        test/skin_insight_widgets_test.dart
git commit -m "feat(skin): 결과 화면에서 인사이트로 가는 진입점 추가"
git push -u origin feat/skin-insight-page
gh pr create --base develop --title "feat(skin): 개인화 피부 인사이트 화면"
```

---

## 완료 확인

구현이 끝나면 실제 코드 기준으로 확인한다.

- [ ] `flutter analyze` 통과
- [ ] `flutter test` 전부 통과
- [ ] 백엔드 `./gradlew test` 통과
- [ ] 결과 화면 → 인사이트 진입, `skinAnalysisId` 전달 정상
- [ ] 5지표 전부 표시, `changes` 델타 표시, 첫 분석이면 안내 문구
- [ ] `insights`/`todayActions` 순서 유지, 빈 배열이면 섹션 숨김
- [ ] 생활 상태 4종 표시, 미설정 표기, 안내 문구가 `insights.isEmpty` 로 갈림
- [ ] 온보딩에서 물 섭취 선택 → `PATCH` → 재진입 시 선택 유지 (왕복)
- [ ] 고민 전체 해제 → `skinConcerns: []` 전송 → 서버에서 실제로 비워짐
- [ ] `ExerciseHabit.FREQUENT` 왕복 (앱 선택 → PATCH → GET → 같은 값 선택 상태)
- [ ] AI 실패 시 "다시 시도" 동작, 404 시 서버 메시지 노출
- [ ] 기존 회귀: 피부 촬영 · 결과 · 홈 카드 · 음식 분석 · 기록 · 온보딩 재진입
