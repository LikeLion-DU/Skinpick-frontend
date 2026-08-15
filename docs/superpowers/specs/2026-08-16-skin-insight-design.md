# 개인화 피부 인사이트 — 설계

작성 2026-08-16 · 대상 `Skinpick-frontend` (일부 `Skinpick-backend`)

## 목표

피부 분석 결과에서 한 번 더 눌러 들어가면, 방금 측정한 피부 지표와 사용자가 설정해 둔
생활 습관을 함께 본 인사이트가 나온다. 사용자가 3초 안에 이해해야 하는 것은 네 가지다 —
내 피부가 지금 어떤지, 최근 생활이 어떤지, AI가 무엇을 중요하게 보는지, 오늘 무엇을 하면 되는지.

문장·우선순위·변화량은 전부 백엔드가 소유한다. 앱은 계약을 정확히 소비하고 화면을 만든다.

## 확정된 백엔드 계약 (실측)

`GET /api/v1/skin-insights?skinAnalysisId={id}` · 인증 필요 · get-or-create

```json
{ "success": true, "data": {
  "skinAnalysisId": 12,
  "summary": "...",
  "changes": { "hydration": 5, "oil": -3, "redness": 2, "trouble": -7, "barrier": 4, "skinScore": 2 },
  "insights": [{ "category": "SLEEP", "priority": "HIGH", "title": "수면 관리", "description": "..." }],
  "todayActions": [{ "category": "SLEEP", "title": "..." }],
  "generatedAt": "2026-08-16T10:00:00"
}}
```

- `changes` 는 **직전 분석이 없으면 키 자체가 사라진다.** 6번째 필드 `skinScore` 는 기존
  `SkinAnalysis.skinScore` (엔티티 필드, 0~100 clamp) 의 델타로 실존한다 — 유지한다.
- `insights` · `todayActions` 는 **최대 3개이고, 길이가 항상 같고, `[]` 가 정상 응답이다.**
  지표가 전부 양호하고 고민·나쁜 습관이 없으면 AI 호출 자체를 건너뛰고 고정 summary 만 온다.
- **빈 인사이트는 저장되지 않는다** (`SkinInsightService.getOrCreate` → `topics.isEmpty()` 분기).
  1회 고정 정책의 족쇄를 피하려는 것이다. 앱 입장에서 중요한 결과: 생활 상태가 비어서 빈 인사이트를
  받았더라도, **습관을 채우고 같은 분석으로 다시 들어오면 인사이트가 새로 생성된다.**
  반대로 토픽이 하나라도 있어 저장된 인사이트는 그 분석에 고정된다.
- `todayActions` 항목은 `{category, title}` 뿐이다. `type` 도 `description` 도 없다.
- **`insights[i]` 와 `todayActions[i]` 는 같은 주제다.** 둘 다 같은 `items` 스트림에서 나오므로
  길이·순서·`category` 가 항상 일치한다. 독립된 두 목록이 아니라 같은 1~3개 주제를 두 각도로
  보여주는 것이다 — "무엇을 볼 것인가" 와 "그래서 오늘 무엇을 할 것인가".
- `insights[].title` 과 `todayActions[].title` 은 **카테고리별 고정 문구**다.
  AI가 쓰는 문장은 `summary` 와 `insights[].description` 둘뿐이다.
- `priority` 는 enum이 아니라 `String` 이고, 배열 순서에서 파생된 값이다 (0/1/2 → HIGH/MEDIUM/LOW).
- `category` 는 `InsightCategory` 13종:
  `DRY OILY REDNESS TROUBLE BARRIER_WEAK` (측정) ·
  `DARK_CIRCLE PIGMENTATION ELASTICITY PUFFINESS` (자가 신고 고민) ·
  `SLEEP STRESS EXERCISE WATER` (습관)
- 첫 호출은 **최대 ~27초** 블로킹이다 (AI 25초 타임아웃 + 429 1회 재시도). 두 번째부터는 DB 읽기다.
- 동시 첫 호출은 서버가 락 + 유니크 제약으로 직렬화한다. 앱의 재시도는 안전하다.
- 실패: `AI_TIMEOUT` 504 · `AI_ANALYSIS_FAILED` 502. 실패하면 저장되지 않으므로 같은 GET을 다시 부르면 재시도가 된다.
- 타인/없는 분석 ID: 404 `SKIN_ANALYSIS_NOT_FOUND` "분석 결과를 찾을 수 없습니다." (존재 여부를 구분해 주지 않는다)

## 이번 작업의 근본 문제

백엔드 인사이트 생성기(`InsightTopics`)는 **서버 DB의 습관·고민 값**을 읽어 토픽을 고른다.
그런데 앱은 수면·스트레스·운동·피부고민을 기기 secure storage(`SkinProfileStore`)에만 저장하고,
`PATCH /auth/me` 로는 `declaredSkinType` 한 필드만 보낸다. 서버의 해당 컬럼은 전부 null이다.

그대로 두면 습관 토픽(SLEEP/STRESS/EXERCISE/WATER)과 고민 토픽이 하나도 뜨지 않고,
측정 지표 5종만 나온다. "내 생활이 추천에 쓰인다"는 기능의 핵심이 죽는다.

그래서 이번 작업의 절반은 화면이 아니라 **프로필의 원천을 서버로 옮기는 일**이다.

## 결정

| # | 결정 | 근거 |
|---|---|---|
| 1 | 프로필 단일 원천 = 서버 (`Authenticated.user`) | 두 원천은 반드시 어긋난다 |
| 2 | `SkinProfileStore` · `SkinProfile` 삭제, 마이그레이션 없음 | 팀원 몇 명이 프로필을 한 번 다시 고르면 되는 일에 1회용 코드를 남기지 않는다 |
| 3 | enum 이름은 **서버 기준으로 통일** | 왕복이 이름 매핑표를 지나면 언젠가 한 칸 어긋난다 |
| 4 | 운동은 **백엔드를 4종으로 확장** | 4→3 압축은 lossy다. 운동 빈도 자체가 인사이트 입력값이라 의미를 보존해야 한다 |
| 5 | 인사이트는 `features/skin_analysis/` 안에 | 분석에 딸린 화면이다. feature 폴더를 새로 파지 않는다 |
| 6 | `FutureProvider.autoDispose.family` | 기존 `recommendationProvider` 와 같은 패턴. rebuild 재호출이 막히고, 재진입은 서버 캐시라 빠르다 |
| 7 | FeatureFlag 없음 | 데모에 켤 화면이다. 항상 true인 플래그는 스위치가 아니라 잡음이다 |
| 8 | 인사이트 화면은 지표 5개 | `changes` 가 5개 전부의 델타를 주고, TROUBLE 인사이트가 뜰 때 근거 지표가 화면에 있어야 한다 |
| 9 | 물 섭취 설정은 온보딩 습관 섹션 4번째 줄 | 기존 `_HabitSection` 재사용. 저장 경로가 두 곳으로 갈리지 않는다 |

## 변경 1 — 백엔드: `ExerciseHabit` 4종

```java
NONE    ("거의 안 함"),
LIGHT   ("주 1-2회"),
REGULAR ("주 3-4회"),      // "주 3회 이상" 에서 변경 — FREQUENT 가 생겨 의미가 좁아졌다
FREQUENT("주 5회 이상");    // 신규
```

- **마이그레이션 불필요.** `app_user.exercise_habit` 과 `skin_insight.snapshot_exercise_habit`
  둘 다 `VARCHAR(20)` 이고 CHECK 제약이 없다.
- 라벨은 AI 프롬프트에만 쓰인다 (`SkinInsightPrompt`, `InsightTopics`). 화면 문구는 앱이 따로 가진다.
- 트리거는 그대로 `== ExerciseHabit.NONE` 이다 (`InsightTopics`, `RecommendationService`).
  `FREQUENT` 는 어느 쪽도 트리거하지 않는다 — 운동을 잘 하는 사람에게 운동 인사이트를 줄 이유가 없다.
- 같이 고칠 것: `SkinPlate_DTO_Domain.md` 의 enum 정의와 Part 3 계약 대조표, `SkinPlate_PRD.md` 에
  운동 enum 표가 있으면 그것도. (백엔드 CLAUDE.md: "코드가 문서와 어긋나면 그 자리에서 문서를 고친다")
- 테스트: `FREQUENT` 가 EXERCISE 토픽을 트리거하지 않는다는 케이스를 `InsightTopicsTest` 에 추가.

## 변경 2 — 앱: 프로필 원천을 서버로

### enum 값 교정 (`features/auth/domain/entities/skin_profile.dart`)

| enum | 지금 | 바뀔 값 |
|---|---|---|
| `SkinConcern` | `SEBUM` | `OILINESS` |
| `StressLevel` | `LOW` / `MEDIUM` / `HIGH` | `LOW` / `NORMAL` / `HIGH` |
| `ExerciseHabit` | `RARELY` `LIGHT` `STEADY` `FREQUENT` | `NONE` `LIGHT` `REGULAR` `FREQUENT` |
| `SleepPattern` | `LACKING` `NORMAL` `ENOUGH` | 그대로 |

라벨과 설명 문구는 **앱 것을 유지한다** (시안 문구다). wire 값만 바꾼다.
Dart 식별자도 wire를 따라간다 (`rarely` → `none`, `steady` → `regular`, `medium` → `normal`).

`WaterIntake` 를 같은 `(wire, label, description)` 패턴으로 신설한다 —
`LACKING` '부족해요' · `NORMAL` '보통이에요' · `ENOUGH` '충분해요'.
모르는 값은 기존 `fromWire` 와 같이 **null** 로 떨어뜨린다.

### DTO / 엔티티

`MeResponseDto` 와 `AuthUser` 에 5개 필드를 더한다. 서버가 `non_null` 이라 미선택이면 키가 없다.

```dart
@Default(<String>[]) List<String> skinConcerns,
String? sleepPattern,
String? stressLevel,
String? exerciseHabit,
String? waterIntake,
```

기존 관례대로 **DTO는 String으로 받고 도메인 변환에서 파서를 태운다.** DTO 필드에 enum을 쓰지 않는다.

### 저장 경로

`AuthRemoteDataSource.updateSkinType` → `updateProfile(...)` 로 넓힌다.
서버가 부분 업데이트라 **null 이 아닌 필드만 담아 보낸다** (지금 `updateSkinType` 이 하는 것과 같은 규칙).

**`skinConcerns` 만은 예외다 — 프로필을 제출하면 선택이 하나도 없어도 `[]` 를 보낸다.**
서버가 `null`(변경 없음)과 `[]`(전부 해제)를 구분하도록 만들어져 있다:
`hasSkinConcerns()` 가 `!= null` 이고 `updateSkinConcerns` 가 `clear()` 후 `addAll` 이며
`@NotEmpty` 제약도 없다. null 여부로 판단하면 **전부 해제가 조용히 무시된다.**
습관 4종은 UI에 해제 개념이 없으므로 null = 변경 없음 규칙 그대로 둔다.

고민 wire 값 주의: 서버 `SkinConcern` 에 **`TROUBLE` 은 없다.** 여드름은 `ACNE`,
피지/유분은 `OILINESS` 다 (`TROUBLE` 은 `InsightCategory` 쪽 값이다).
모르는 값을 보내면 Jackson 이 400 `INVALID_INPUT` 을 낸다.

- `skin_type_page._submit()` — `_store.save(...)` 를 지우고 `updateProfile` 한 번으로 전부 보낸다.
- `skin_type_page.initState()` — 프리필을 `_store.load()` 에서 `auth.user` 로 바꾼다.
  (재진입 시 프리필이 없으면 제출이 이전 답을 덮어쓴다. 실제로 났던 버그다.)
- `skin_result_page._SkinTypePromptState._select()` — `updateProfile(declaredSkinType: ...)` 로.
- `skin_profile_store.dart` 와 `SkinProfile` 클래스 삭제. enum들은 남는다 (DESIGN.md src:22 가 참조).

### 온보딩 습관 섹션

`_HabitSection` 에 "물 섭취" 4번째 줄을 추가한다.

선택지는 **`_CardOptions<WaterIntake>`** 로 그린다. 수면·스트레스가 쓰는 그 위젯이고 이미 제네릭이라
아이콘 `switch` 3줄만 더하면 끝난다. 운동이 쓰는 `_RowOptions` 는 `ExerciseHabit` 이 박혀 있어
재사용하려면 제네릭화가 필요한데, 물 섭취는 수면과 똑같은 3단계 척도라 카드형이 더 맞다.

진행 점 `_progress` 는 한 줄 고쳐야 한다 — 지금 `(_sleep ?? _stress ?? _exercise) != null` 이라
물 섭취만 고른 사용자는 점이 차지 않는다. `?? _water` 를 더한다.

## 변경 3 — 앱: 인사이트

### 계약

`features/skin_analysis/data/models/skin_insight_dtos.dart` (freezed)

```dart
required int skinAnalysisId,
required String summary,
SkinInsightChangesDto? changes,                            // 첫 분석이면 키가 없다
@Default(<SkinInsightItemDto>[]) List<SkinInsightItemDto> insights,
@Default(<SkinTodayActionDto>[]) List<SkinTodayActionDto> todayActions,
DateTime? generatedAt,
```

`changes` 는 6필드 전부 `required int` (서버가 primitive int라 항상 온다 — 기존 `SkinMetricsDto` 와 같은 형태).
`category` · `priority` 는 `String` 으로 받는다.

`lib/shared/enums/insight_category.dart` 신설 — 13종 파서와 **아이콘만** 가진다.
라벨은 서버가 `title` 로 주므로 앱이 따로 갖지 않는다.
모르는 값은 **null** → 중립 아이콘. 아이콘을 고르는 값이라 억지 기본값은 엉뚱한 그림을 붙일 뿐이다.

`SkinRepository.getInsight(int skinAnalysisId)` 를 더한다. 나머지는 기존 `callApi` 흐름 그대로.

### 프로바이더 · 라우팅

```dart
// core/di/providers.dart
final skinInsightProvider =
    FutureProvider.autoDispose.family<Result<SkinInsight>, int>((ref, skinAnalysisId) => ...);
```

```dart
// Routes.skinInsight = '/skin/insight'  ·  '${Routes.skinInsight}/:skinAnalysisId'
```

기존 `recommendations` 라우트를 그대로 복제한다. path param만 쓰고 `extra` 는 쓰지 않는다.

### 진입점

`skin_result_page` 의 주 버튼 아래에 `TextButton` "내 생활 상태와 함께 분석하기" →
`context.push('${Routes.skinInsight}/${analysis.id}')`.
`analysis.id` 는 이미 화면이 들고 있다 (추천 진입에 쓰던 것과 같은 값).

피부 분석 히스토리 화면이 앱에 없으므로 인사이트는 사실상 최신 분석에만 열린다.
그게 지금 앱이 제공하는 전부이므로 진입점을 더 만들지 않는다.

### 화면

섹션 순서 — 현재 피부 상태 → 최근 생활 상태 → AI 인사이트 → 오늘의 우선 관리 → 오늘의 행동.

DESIGN.md 를 따른다: 강조 카드는 크림 `#FEF7F0` + `border-on-cream` + radius 16,
중립 카드는 흰색 + `border-on-white` + radius 9, `pagePadding` 32, elevation 0.
점수 → 색은 반드시 `ScoreGrade` 를 지난다.

- **현재 피부 상태** — `SkinMetrics.toBars()` 를 쓴다. 5지표 + `higherIsBetter` 를 이미 주는데
  호출처가 없던 함수다. 이 화면이 첫 소비자다. `changes` 가 있으면 각 줄에 델타를 붙인다.
- **현재 설정된 생활 상태** — 수면·스트레스·운동·물 섭취를 `auth.user` 에서 읽어 각 enum의 `label` 로.
  제목에 "현재 설정된" 을 넣는다. 인사이트가 본 것은 분석 당시의 스냅샷이라 지금 값과 다를 수 있고,
  제목이 "최근 생활 상태" 면 사용자는 이게 인사이트의 근거라고 읽는다.
- **AI 인사이트** — `summary` 를 강조 카드에 그대로. 앱이 문장을 짓거나 고치지 않는다.
- **오늘의 우선 관리** — `insights` 를 **배열 순서 그대로**. 정렬·재계산 금지.
  `priority` 는 텍스트로 노출하지 않고 첫 항목만 강조 카드로 시각 구분한다.
- **오늘의 행동** — `todayActions` 를 순서 그대로.
- 하단에 기존 `SafetyNotice` 와 "측정 환경에 따라 결과가 달라질 수 있어요" 를 작게.

두 섹션의 시각적 역할을 갈라 놓는다. 같은 주제가 연달아 두 번 나오므로(위 계약 참고)
구분이 없으면 같은 카드를 두 번 그린 것처럼 보인다.

| | 답하는 질문 | 형태 |
|---|---|---|
| 오늘의 우선 관리 | 지금 무엇을 중요하게 볼 것인가 | 카테고리 아이콘 + `title` + AI `description` 본문. 세로로 읽는 카드 |
| 오늘의 행동 | 그래서 오늘 무엇을 할 것인가 | `title` 한 줄만. 체크리스트처럼 짧고 납작하게, 아이콘 없이 |

문장은 어느 쪽도 앱이 만들지 않는다. 두 배열을 그대로 쓴다.

### 화면 상태

| 상태 | 처리 |
|---|---|
| 로딩 | 단계 문구 애니메이션. 첫 호출이 ~27초라 정지처럼 보이면 안 된다 (아래 참고) |
| 성공 | 5섹션 |
| 첫 분석 (`changes` 키 없음) | "첫 피부 분석이라 아직 비교할 데이터가 없어요". 0을 그리거나 비워 두지 않는다 |
| 인사이트 없음 (`[]`) | 우선 관리·오늘의 행동 두 섹션을 **숨긴다**. summary가 이미 "지금은 주요 지표가 모두 안정적이에요" 를 말한다 |
| 생활 미설정 | 항목별로 '미설정' 표기. **하나라도** 미설정이면 섹션 하단에 작은 버튼 → `Routes.skinType` |
| AI 실패 (502·504) | `mapToFailure` 가 이미 `AnalysisFailure` 로 번역하고 `shouldRetakePhoto` 가 false다 → `FailureView` 가 "다시 시도" 를 그린다. `onRetry: ref.invalidate(skinInsightProvider(id))` |
| 404 | `ServerFailure` 로 떨어져 서버 메시지만 노출된다. 내부 ID·권한 구조를 드러내지 않는다 |

에러 UI는 새로 만들지 않는다. 기존 `FailureView` 가 두 경우를 다 덮는다.

로딩 문구 위젯은 `skin_loading_page` 의 `_LoadingSteps` 인데 **private 이다.** 복사하지 말고
`core/widgets/app_widgets.dart` 로 옮겨 `LoadingSteps` 로 공개한다 — 이미 `steps` 를 받는 형태라
옮기고 밑줄만 떼면 두 화면이 같은 위젯을 쓴다.

### 저장 여부에 따라 안내 문구가 갈린다

인사이트는 **생성 시점의 습관을 스냅샷으로 굳혀** 저장한다 (`skin_insight.snapshot_*`).
반면 화면의 "최근 생활 상태" 는 `auth.user` 의 **현재 값**을 읽는다. 그래서 저장된 인사이트를
본 뒤 습관을 바꾸면, 생활 상태 칸은 새 값인데 AI 문장은 옛 값 기준인 상태가 된다.

다만 **빈 인사이트는 저장되지 않으므로** 두 경우가 갈린다.

| 지금 화면 | 실제로 일어나는 일 | 안내 문구 |
|---|---|---|
| `insights` 가 비어 있다 | 저장 안 됨. 습관을 채우고 다시 오면 **이 분석의 인사이트가 새로 생성된다** | "생활 상태를 설정하고 다시 보면 인사이트가 채워져요" |
| `insights` 가 있다 | 저장돼 이 분석에 고정. 습관 변경은 반영되지 않는다 | "이 인사이트는 피부 분석 당시 설정한 생활 상태를 기준으로 생성되었어요. 바꾼 내용은 다음 피부 분석부터 반영돼요." |

`insights.isEmpty` 한 줄로 문구를 가른다. 둘 다 사실이고, 사용자를 헛걸음시키지 않는다.

**스냅샷 안내 문구를 빈 경우에도 띄우면 거짓말이 된다** — 저장된 인사이트가 없으니
"분석 당시 기준으로 생성" 된 것도 없고, 그 문구를 읽은 사용자는 지금 설정해도 소용없다고
판단해 생활 상태를 채우지 않는다. 정확히 반대로 행동하게 만드는 안내다.

서버의 스냅샷·get-or-create 구조는 건드리지 않는다. 재생성 API도 만들지 않는다.

**데모 순서는 그래도 생활 상태를 먼저 설정하는 쪽이 안전하다.** 지표에 문제가 있는 사용자는
토픽이 생겨 인사이트가 저장되므로, 그 뒤에 습관을 채워도 그 분석에는 반영되지 않는다.

## 작업 분할

CLAUDE.md 가 "1개 단위 = 1 브랜치 = 1 PR (프론트: 화면 단위)" 를 정하고 있다. 세 덩어리로 나눈다.

| 순서 | 저장소 | 브랜치 | 내용 |
|---|---|---|---|
| 1 | backend | `feat/skin-insight-api` 위 | `ExerciseHabit` 4종 + 문서 + 테스트 |
| 2 | frontend | `feat/profile-server-sync` | 프로필 원천 서버 이전 · enum 교정 · WaterIntake · 온보딩 |
| 3 | frontend | `feat/skin-insight-page` | 인사이트 계약 · 화면 · 진입점 |

2가 3의 선행이다 (인사이트 화면이 `auth.user` 의 습관을 읽는다). 둘 다 `develop` 으로 PR 한다.

백엔드 인사이트 API는 커밋이 끝났고(`b8f5ac6` + 리뷰 반영 `cc47d18`) 작업 트리가 깨끗하다.
위 계약은 그 커밋을 실측한 것이다. `ExerciseHabit` 확장은 같은 브랜치 위에 커밋을 하나 더 얹는다.

## 테스트

기존 관례를 따른다 — mock 라이브러리 없이 `_StubAdapter`, fixture는 실서버 응답.

- `test/fixtures/skin_insight*.json` — 로컬 서버(`app.ai.mock=true`)에서 curl로 받아 저장한다.
  서버를 띄울 수 없으면 백엔드 테스트의 기대값으로 구성하고 **그 사실을 fixture 옆에 주석으로 남긴다.**
- `contract_test.dart` — 인사이트 파싱 3케이스: `changes` 있음 / 키 없음 / `insights` 빈 배열.
  `auth_me` 는 습관 4종 포함본과 미포함본 둘 다.
- 온보딩 회귀 — `_StubAdapter` 로 `PATCH /auth/me` 바디를 검증한다. 세 가지를 본다:
  고민·습관 4종이 실리는지 / 미선택 습관 필드가 빠지는지 /
  **고민을 전부 해제하면 `skinConcerns: []` 가 실리는지** (키가 빠지면 서버는 변경 없음으로 읽는다).
- 위젯 — 시안 폭 402에서 인사이트 화면 오버플로. 첫 분석·인사이트 없음 상태도 같이 그린다.
- `flutter analyze && flutter test` 둘 다 통과해야 커밋한다.

## 위험

- **백엔드 인사이트 API는 `develop` 에 머지됐다** (#34 · #35). 운동 4종 확장도 #35 에 함께 들어갔다.
  위 계약은 그 머지본을 실측한 것이고 응답 구조는 변하지 않았다.
  진행 중에 리뷰 반영 커밋이 "빈 인사이트를 저장하지 않는다" 를 바꿔 놓은 적이 있고, 그게 이
  설계의 안내 문구 분기를 만들었다 — 계약을 다시 읽지 않았으면 거짓 안내를 그릴 뻔했다.
- **온보딩 제출 경로 변경이 이번 작업의 최대 회귀 위험이다.** 위젯 테스트로 막는다.
- 기기에 저장된 기존 습관 값은 버려진다. 의도한 결정이다 (#2).
- 오늘은 Day 9이고 프로젝트 규칙은 Day 8 이후 기능 추가를 금지한다. 데모 핵심이라 사용자가 진행을 승인했다.

## 남겨 두는 것

- **지표 라벨이 화면마다 다르다.** S05 결과 화면은 시안 확정 문구('유분 밸런스', '붉어짐')를 쓰고,
  인사이트 화면은 `toBars()` 문구('유분', '홍조')를 쓴다. 같은 값을 다른 이름으로 부르지만
  둘 다 맞는 한국어고, 통일하려면 시안 확정 문구를 건드려야 한다. 통일하려면 `toBars()` 라벨 한 줄이면 된다.
- 피부 분석 히스토리 화면. 서버에 목록 API가 없어 이번 범위 밖이다.
