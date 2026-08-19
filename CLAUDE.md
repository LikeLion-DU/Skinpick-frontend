# CLAUDE.md — skinplate (Flutter)

Skin Plate 모바일 앱. **내 피부에 맞는 음식, 사진 한 장으로 확인한다.**
Flutter 3.24+ / Riverpod / go_router / Dio / freezed. 백엔드는 별도 저장소(`Skinpick-backend`).

피부 분석은 주인공이 아니라 **음식 개인화의 기준값**이다. 화면의 시각적 우선순위도
음식 → 피부 식단 점수 → 추천 이유 → 음식 기록 → 주간 리포트 → 피부 진단 → 생활습관 순이다.

## 일정 (PRD §19 · 2026-08-14 정정 반영)

| | |
|---|---|
| 개발 | 2026-08-08 ~ **08-21** |
| GitHub 업로드 마감 | **08-21** — 이날 저장소가 닫힌다 |
| 발표 | **08-25** |

- **기능 동결은 날짜가 아니라 게이트다.** G5(배포본 E2E 1회 완주 — APK 1회)를 통과한
  뒤에는 기능을 더 넣지 않는다. "Day 8 동결"은 08-17 마감 전제의 옛 규칙이라 무효다
- Day 표의 **작업 순서와 의존 관계는 그대로 유효**하다. Day N 을 달력 날짜로 읽지 마라
- 우선순위는 **PRD §19.1(P0/P1/P2)이 단일 기준**이다. 이 저장소에서 별도 번호 체계를
  만들지 않는다 — 같은 "P0"가 문서마다 다른 목록을 가리키면 팀에서 사고가 난다

## 기준 문서

문서 원본은 **백엔드 저장소**에 있다. 형제 디렉터리로 두고 참조한다.

| 파일 | 범위 |
|---|---|
| `../Skinpick-backend/SkinPlate_PRD.md` | 화면 정의 §6 · API 명세 §14.3 · 얼굴 게이트 §9.5 · 배포 §9.6 · 일정 §19 |
| `../Skinpick-backend/SkinPlate_DTO_Domain.md` | Part 2 앱 코드 · **Part 3 계약 대조표** |

- **작업 전 문서 버전 헤더를 확인한다.** 오래된 사본으로 작업하면 이미 고친 것을 다시 만난다
- 두 문서가 어긋나면 **설계서(`_DTO_Domain`)를 따른다**
- 설계서에 이미 있는 클래스는 새로 쓰지 말고 **그대로 옮긴다.** 개선하지 마라

## 시작 전

- 요청이 모호하면 먼저 질문한다
- 수정할 파일은 반드시 읽고 기존 패턴(폴더 구조, 네이밍, import 순서)을 파악한 뒤 작업한다
- 솔루션 로직을 스스로 검토한 후 제시한다

## 코드 작성

- 요청된 작업 범위만 수정한다 (불필요한 리팩토링 금지)
- 완전히 실행 가능한 코드만 제공한다 (의사코드 금지)
- 변수명은 역할이 드러나도록 작성한다 — `dto` `r` `e` `data` `res` 같은 모호한 축약 금지
- 시크릿/키 하드코딩 절대 금지 — `--dart-define` 으로만 주입

## 이 프로젝트에서만 지켜야 할 것

**생성 코드** — `.freezed.dart` / `.g.dart` 를 **커밋한다**(팀원이 build_runner 없이 받는다).
- `*_dtos.dart` 를 고쳤으면 **반드시** `dart run build_runner build --delete-conflicting-outputs`
- 안 돌리면 커밋된 생성물이 조용히 낡는다. **컴파일은 되고 파싱만 틀린다**

**서버 계약** — 서버는 `default-property-inclusion: non_null` 이라 **null 필드의 키 자체를 지운다.**
- 서버가 생략할 수 있는 필드에 `required` 를 쓰지 마라 → `@Default` 또는 nullable
- 숫자는 `num` 으로 받고 `.toDouble()`. 서버가 `28.5` 대신 `28` 을 보내면 `double` 은 캐스팅 예외다
- 필드를 바꾸면 **설계서 Part 3 계약 대조표도 같이** 고친다

**enum 파서** — 모르는 값에 기본값을 두되, **무엇으로 떨어뜨리는지가 중요하다.**
- `HighlightStatus` → `warn`. `good` 으로 떨어뜨리면 경고가 초록 뱃지가 된다
- `SkinType` · `PlateActionCode` → **`null`.** 기본값을 두면 "미선택"과 "잘 모르겠어요"가 섞인다

**Dio** — `validateStatus` 를 건드리지 마라.
- 기본값(2xx만 성공)이어야 4xx가 `DioException` 으로 흘러 인터셉터와 `mapToFailure` 가 동작한다
- 401 인터셉터는 **`/auth/` 요청을 제외**한다. 로그인 실패도 401이라 폼과 에러 메시지가 함께 사라진다

**호스트** — `API_BASE_URL` 은 에뮬레이터에서 `10.0.2.2`, 배포는 `https`.
- **결과 화면은 서버 `imageUrl` 이 아니라 앱이 방금 찍은 로컬 파일을 쓴다** (PRD §9.6)

**얼굴 게이트** — 게이트와 크롭 **전용**이다. ML Kit 이 주는 확률값으로 피부를 판정하지 마라 (PRD §9.5).

**네이티브 의존성** — `pubspec.yaml` · iOS `Podfile` · Android 설정은 **한 사람이 전담한다.**
둘이 동시에 건드리면 충돌 복구에 반나절이 든다.

## 명령어

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test          # 커밋 전 둘 다 통과해야 한다
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

백엔드 로컬 기동은 `../Skinpick-backend/CLAUDE.md` 참조. 테스트 계정 `test@skinplate.app` / `test1234!`.

## Git / PR

- 브랜치명: `{type}/{설명}` (예: `feat/skin-result-page`). 이슈가 있으면 `{type}/{이슈번호}-{설명}`
- 커밋 메시지: Conventional Commits + 한국어 — `{type}({scope}): 작업 내용`
  - 예: `feat(skin): 피부 결과 화면 구현`, `fix(core): 401 인터셉터가 로그인 실패를 삼키던 문제`
  - type: `feat fix refactor docs test chore ci perf`
  - scope: `auth skin plate recommendation home core shared app` — 여러 파트에 걸치면 생략
- `[#이슈번호] 작업 내용` 형식은 쓰지 않는다
- PR 제목도 커밋과 같은 형식 — `develop` 은 squash 머지라 PR 제목이 그대로 커밋 메시지가 된다
- PR 본문: 🚀 작업 내용 / 🤔 고민했던 내용 / 💬 리뷰 중점사항 — 파일·클래스명 나열 금지
- **1개 단위 = 1 브랜치 = 1 PR** (프론트: 화면 단위)
- 모든 작업 브랜치는 `develop` 에서 분기, `develop` 으로 PR

## 절대 금지

- `build/` · `.dart_tool/` · `.idea/` 커밋
- `validateStatus` 변경, 401 인터셉터에서 `/auth/` 예외 제거
- 서버가 준 점수를 앱에서 다시 계산하기 — 점수는 백엔드가 소유한다
- **앱에서 판정 규칙을 새로 만들기.** 피부 지표의 높음/낮음은 서버 `highlights`,
  음식의 과다/부족은 서버 `feedbacks` 가 이미 판정해서 준다. 앱이 임계값을 세우면
  같은 규칙이 두 곳에 생기고 어느 날 조용히 어긋난다
  - **앱에 점수 경계표가 없다** (2026-08-19). 점수를 보내는 응답은 등급도 같이 보낸다 —
    총점은 `grade`, 지표는 `metricDetails[].level`, 고민은 `concerns[].status` 다
  - `SkinLevel`(총점) · `MetricBand`(개별 지표)는 **그 등급을 화면 말로 접기만 한다.**
    `SkinLevel.fromJson` 으로 받고, 모르는 값은 null 이라 배지가 사라진다 —
    틀린 등급보다 없는 등급이 낫다. 숫자에서 등급을 내는 함수를 다시 만들지 마라
  - 앱이 75/60 경계(옛 `ScoreGrade`)를 따로 쓰던 시절에는 같은 68점이 홈에서
    "보통", 리포트에서 "좋음"으로 떴다. 서버 경계를 옮겨 적어 두는 것도 같은 사고의
    씨앗이다(표가 두 벌이면 한쪽만 따라간다). 화면별 임계값을 다시 만들지 마라
- AI 문장을 앱에서 짓거나 고치기 — 문장과 우선순위는 백엔드가 소유한다
- **G5 통과 후 기능 추가** (§일정 참조)
