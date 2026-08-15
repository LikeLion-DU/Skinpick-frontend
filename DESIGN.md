---
name: 스킨픽
design_system_name: Skin Plate UI
slug: skin-plate-ui
category: health
last_updated: "2026-08-15"
created_at: 2026-08-09
sources:
  - lib/app/theme/app_colors.dart
  - lib/app/theme/app_theme.dart
  - lib/app/app.dart
  - lib/app/router/app_router.dart
  - lib/app/config/feature_flags.dart
  - pubspec.yaml
  - lib/shared/enums/score_grade.dart
  - lib/shared/enums/highlight_status.dart
  - lib/shared/enums/skin_type.dart
  - lib/shared/enums/meal_type.dart
  - lib/shared/widgets/score_badge.dart
  - lib/shared/widgets/app_bottom_nav.dart
  - lib/core/widgets/app_widgets.dart
  - lib/core/widgets/camera_preview_box.dart
  - lib/features/home/presentation/pages/home_page.dart
  - lib/features/home/presentation/widgets/daily_score_card.dart
  - lib/features/home/presentation/widgets/today_records_card.dart
  - lib/features/auth/presentation/pages/splash_page.dart
  - lib/features/auth/presentation/pages/login_page.dart
  - lib/features/auth/presentation/pages/signup_page.dart
  - lib/features/auth/presentation/pages/skin_type_page.dart
  - lib/features/auth/domain/entities/skin_profile.dart
  - lib/features/skin_analysis/presentation/pages/skin_capture_page.dart
  - lib/features/skin_analysis/presentation/pages/skin_loading_page.dart
  - lib/features/skin_analysis/presentation/pages/skin_result_page.dart
  - lib/features/skin_plate/presentation/pages/food_capture_page.dart
  - lib/features/skin_plate/presentation/pages/plate_result_page.dart
  - lib/features/skin_plate/presentation/pages/plate_detail_page.dart
  - lib/features/skin_plate/presentation/pages/plate_history_page.dart
  - lib/features/skin_plate/presentation/widgets/plate_score_card.dart
  - lib/features/skin_plate/presentation/widgets/plate_summary_cards.dart
  - lib/features/recommendation/presentation/pages/recommendation_page.dart
  - assets/icons/
  - assets/fonts/OFL.txt
  - ../Skinpick-backend/SkinPlate_PRD.md
  - CLAUDE.md
related_services: []
lang: ko
logo: assets/icons/logo_skinpick.svg
---

# Skin Plate UI — design.md

## Brand & Style

스킨픽은 **오렌지 하나와 크림 한 겹**으로 굴러가는 앱이다. 브랜드 색은 `#FF7D40` 단 하나이고, 버튼·FAB·선택된 칩·강조 배지가 전부 이 색이다 [src:1]. 그 위에 흰 배경(`#FFFFFF`)과 카드용 크림(`#FEF7F0`) 두 겹으로 면을 나눈다 — 그림자가 아니라 **면색과 테두리로** 깊이를 만드는 것이 이 시스템의 1차 수단이다.

이 시스템에는 공식 디자인 시스템 문서가 없다. 대신 규약이 **코드 한 파일에 모여 있다**. `AppColors` 가 색의 유일한 출처이고, 화면 코드는 색 리터럴을 직접 쓰지 않는다 — 디자이너가 Figma 변수를 만들면 그 파일만 교체하면 되도록 교체 비용을 한 곳에 가둔 구조다 [src:1]. 같은 이유로 `fontFamily` 는 `ThemeData` 에 한 번만 적힌다. 화면마다 적으면 하나를 빠뜨린 화면만 시스템 폰트로 떨어지는데, 한글은 그 차이가 크게 보인다 [src:2].

**시안이 최종 심급이다.** PRD §6 화면 설계 원칙은 "결과 화면의 주인공은 점수가 아니라 행동"이라고 적었고 S07에 추천 행동 카드와 `60 → 68` 시뮬레이션을 요구했지만 [src:35], 확정 시안에는 그 자리가 없고 대신 "AI 맞춤 TIP" 문장 하나가 들어갔다. 코드는 지우지 않고 `FeatureFlags` 뒤로 물렸다 — 서버 룰 엔진과의 계약이 거기 걸려 있어 지우면 되살릴 때 계약을 처음부터 다시 맞춰야 하기 때문이다 [src:5]. 즉 **문서와 시안이 어긋나면 시안을 따르되, 코드는 남긴다**가 이 프로젝트의 처리 방식이다.

색의 강약도 의도적으로 편중돼 있다. 화면 안에서 단색이 아닌 요소는 **하단 촬영 버튼 하나뿐**이고(위→아래 `#FF5404` → `#FFD240` 그라디언트), 그래서 시선이 거기로 간다 — 시안이 주 동작을 그렇게 지목하고 있다 [src:1][src:12].

서체는 Pretendard를 앱에 동봉한다. 9종 웨이트 중 시안이 실제로 쓰는 **넷만** 넣었다 — 한글 폰트는 한 벌이 1.5MB라 전부 넣으면 APK가 14MB 늘어난다 [src:6].

## Colors

> **토큰 원본이 없다.** 디자이너가 Figma **변수(Variables)** 를 만들지 않아서 조회하면 빈 객체가 온다. 그래서 값의 출처가 둘로 갈린다 — 프레임 사양을 직접 읽어 확인한 것과, 시안 렌더에서 색을 읽어 옮긴 것(주석에 "샘플링")이다 [src:1]. 아래 OKLCH는 `AppColors` 의 hex에서 역산한 값이고, hex가 원본이다.

라이트 한 벌뿐이다. **다크 테마를 만들지 않는다** — 시안이 라이트만 있어서, 다크를 흉내내면 색 대비를 앱이 지어내게 되고 그건 디자인이 아니다 [src:2].

```yaml
# ── brand (3) ──
primary: oklch(0.730 0.175 44) # #ff7d40
fab-gradient-top: oklch(0.675 0.218 38) # #ff5404
fab-gradient-bottom: oklch(0.879 0.161 91) # #ffd240

# ── surface (2) ──
background: oklch(1.000 0.000 90) # #ffffff
surface-card: oklch(0.980 0.012 68) # #fef7f0

# ── text (4) ──
text-primary: oklch(0.000 0.000 0) # #000000
text-secondary: oklch(0.535 0.000 90) # #6d6d6d
text-on-card: oklch(0.431 0.000 90) # #505050
outline: oklch(0.628 0.001 17) # #898888   (샘플링)

# ── border (3) ──
border-on-cream: oklch(0.926 0.040 45) # #ffdfd1
border-on-white: oklch(0.925 0.000 90) # #e6e6e6
border-empty-slot: oklch(0.888 0.000 90) # #dadada

# ── state (1) ──
disabled: oklch(0.885 0.000 90) # #d9d9d9

# ── verdict (3) ──
good: oklch(0.724 0.175 137) # #6cbe46
bad: oklch(0.568 0.232 28) # #df0011
caution: oklch(0.730 0.175 44) # #ff7d40   (= primary, 의도)

# ── metric (8) ──
hydration-fg: oklch(0.768 0.120 254) # #7db7ff
hydration-bg: oklch(0.971 0.010 253) # #f1f6fc
oil-fg: oklch(0.855 0.119 73) # #ffc373
oil-bg: oklch(0.974 0.019 75) # #fef5e9
redness-fg: oklch(0.721 0.174 22) # #ff7171
redness-bg: oklch(0.965 0.013 17) # #fcf0f0
texture-fg: oklch(0.814 0.126 136) # #9cd582
texture-bg: oklch(0.970 0.035 136) # #ebfbe4
```

**테두리가 세 벌인 것은 실수가 아니다.** 하나로 합치면 크림 카드의 따뜻한 윤곽(`border-on-cream`)이 회색으로 죽는다 — 크림 위에는 크림 계열 테두리, 흰 위에는 회색 테두리, 빈 슬롯에는 그보다 진한 회색을 쓴다 [src:1].

**`caution` 이 `primary` 와 같은 값인 것도 시안 그대로다.** 배지에서 둘을 같은 오렌지로 칠했다. 의미가 다르므로 이름을 나눠 두었다 — 나중에 주의색만 바꿔도 브랜드 색을 건드리지 않게 된다 [src:1].

역할 배치는 별도 토큰 층 없이 위 이름이 곧 역할이다. 실제로 어느 자리에 무엇이 오는지:

| 자리 | 토큰 | 비고 |
| --- | --- | --- |
| 화면 배경 · 입력창 채움 | `background` | `scaffoldBackgroundColor`, `fillColor` [src:2] |
| 카드 배경(강조) | `surface-card` | 크림. 점수·TIP·코멘트 카드 [src:16][src:31] |
| 카드 배경(중립) | `background` | 흰 카드 + 테두리. 기록·요약·영양 타일 [src:17][src:31] |
| 주 버튼 채움 | `primary` | `ElevatedButton` 기본 [src:2] |
| 주 버튼 글자 | `Colors.white` | — |
| 잠긴 버튼 | `disabled` / 글자 흰색 | 조건 미충족 CTA [src:2] |
| 입력창 테두리 | `outline` → 포커스 시 `primary` 1.5px | [src:2] |
| 선택된 칩·타일 | 테두리 `primary` + 배경 `surface-card` | `_Selectable` [src:21] |
| 선택된 고민 칩 | 채움 `primary` + 글자 흰색 | 3열 그리드 [src:21] |
| 선택된 탭 | 배경 `surface-card` + 아이콘 `primary` | 미선택은 `disabled` [src:12] |
| 화면 제목 | `text-primary` | 24px w600 [src:2] |
| 제목 아래 안내 | `text-secondary` | 14px w500 [src:2] |
| 카드 안쪽 본문 | `text-on-card` | 10px w400, `height: 1.35` [src:2] |
| 오류 문구 | `bad` | 로그인·저장 실패 [src:19][src:27] |
| 구분선 | `border-on-white` | 1px `Divider` [src:25][src:29] |

### 등급 램프 — 점수를 색으로 옮기는 유일한 통로

점수는 `ScoreGrade` 를 지나야 색이 된다. 화면이 직접 `if (score > 75)` 를 쓰지 않는다 — 시안이 등급 어휘를 한 벌로 쓰지 않아서(같은 뜻인데 화면마다 `GOOD`/`BAD` 와 `보통`/`주의` 가 섞여 있다) 여기서 한 벌로 고정한다 [src:7].

| 등급 | 경계 | `solidColor` | `tintColor` | `accentColor` |
| --- | --- | --- | --- | --- |
| `good` | ≥ 75 | `good` `#6cbe46` | `oklch(0.932 0.045 135)` `#dcf0d2` | `good` |
| `normal` | ≥ 60 | `primary` `#ff7d40` | `oklch(0.918 0.052 67)` `#fcdec0` | `primary` |
| `caution` | < 60 | `primary` `#ff7d40` | `oklch(0.862 0.069 19)` `#fcc0c0` | `bad` `#df0011` |

세 축의 쓰임이 다르다 — `solid` 는 진한 채움 배지(기록 카드), `tint` 는 옅은 틴트 배지(홈·결과), `accent` 는 틴트 위 글자색과 큰 점수 숫자다 [src:7][src:11].

**주의 등급에서 채움색과 글자색이 갈리는 것에 주의할 것.** 기록 카드의 큰 점수는 주의여도 **오렌지**로 쓴다 — 빨강(`bad`)은 BAD 라벨 전용이라는 것이 시안의 규칙이다 [src:29].

하이라이트 한 줄(`HighlightStatus`)은 별도 3색을 쓴다 — `good` → `good`+체크, `warn` → `caution`+정보, `caution` → `bad`+경고 [src:25]. 파서가 모르는 값을 `warn` 으로 떨어뜨리므로 여기서 색을 초록으로 주면 그 낙하가 "괜찮다"로 뒤집힌다 [src:8].

### 그라디언트 (2)

```yaml
fab-capture: oklch(0.675 0.218 38) 0%, oklch(0.879 0.161 91) 100% # #ff5404 → #ffd240  (세로)
ai-comment-card: oklch(0.980 0.012 68) 0%, oklch(0.968 0.023 70) 100% # #fef7f0 → #fff2e4  (세로)
```

앱 전체에서 그라디언트는 이 둘뿐이다. 하나는 주 동작(촬영 FAB) [src:12], 하나는 기록 화면 맨 아래의 "오늘의 AI 코멘트" 카드다 [src:29].

## Typography

Pretendard 4종을 동봉한다. 라이선스는 SIL OFL 1.1이라 앱 동봉이 허용된다 [src:6][src:34].

```yaml
font-family: Pretendard

weight-regular: 400   # 3회 — 카드 안쪽 본문뿐
weight-medium: 500    # 27회 — 실질 기본값
weight-semibold: 600  # 18회 — 제목·라벨
weight-bold: 700      # 8회  — 점수 숫자·배지

# 크기 사다리 (실제 사용 빈도)
8.5px   # 두 기둥 카드 설명 (1)
9px     # 카드형 선택지 설명 (1)
10px    # 카드 안쪽 본문·보조 (15)
11px    # 배지·소제목 (7)
12px    # 캡션·부제·칩 (28)  ← 최빈
13px    # 선택지 라벨 (4)
14px    # 안내 문구·카드 제목 (12)
15px    # 버튼·구역 제목 (3)
16px    # AppBar·기록 음식명 (5)
20px    # 촬영 오버레이 제목 (1)
24px    # 화면 제목 (1)
25px    # 점수 뒤 "점" (2)
26px    # 피부 총점 (1)
32px    # 기록 카드 점수 (1)
40px    # 큰 점수 (2)

# 줄 높이 (본문에만 명시)
1.3 · 1.32 · 1.35 · 1.4 · 1.47 · 1.5
```

`ThemeData.textTheme` 에는 **네 개만** 정의돼 있다. 나머지는 화면에서 `TextStyle` 을 직접 쓴다 [src:2]:

| 슬롯 | 크기/두께 | 색 | 쓰임 |
| --- | --- | --- | --- |
| `titleLarge` | 24 / w600 | `text-primary` | 화면 제목 — "안녕하세요, 스킨픽님" |
| `titleMedium` | 15 / w600 | `text-primary` | 구역 제목 — "오늘의 기록" |
| `bodyMedium` | 14 / w500 | `text-secondary` | 제목 아래 안내 문구 |
| `bodySmall` | 10 / w400 / `height 1.35` | `text-on-card` | 카드 안쪽 보조 문구 |

**시안은 Bold보다 SemiBold를 훨씬 자주 쓴다 — 제목까지 SemiBold다** [src:2]. Bold(700)가 나오는 곳은 점수 숫자와 배지 라벨, 그리고 AppBar 제목뿐이다.

점수 표기는 고정 조판이다 — 숫자 40px w700 + "점" 25px w500을 **baseline 정렬**로 붙이고 둘 다 `height: 1` 을 준다. 게이지 옆 좁은 칸에서는 세 자리 점수가 넘치지 않도록 줄 전체를 `FittedBox(scaleDown)` 으로 줄인다 [src:16][src:30].

## Spacing

4의 배수를 지키는 사다리는 아니다. 시안 프레임(402×874)에서 읽은 값을 그대로 옮겼기 때문에 2px 단위로 촘촘하다 [src:12].

```yaml
# 세로 간격 (SizedBox height, 사용 횟수)
2 · 4(7) · 5 · 6(5) · 8(13) · 10(8) · 12(22) · 14(7) · 16(7) · 18(3)
20(5) · 21 · 22(5) · 24 · 26(8) · 28(5) · 32(4) · 35 · 36 · 40 · 56 · 120

page-padding: 32          # 화면 좌우 여백 — AppTheme.pagePadding
card-padding-cream: 18~20 # 크림 카드 안쪽
card-padding-white: 16~20 # 흰 카드 안쪽
nav-side-margin: 24       # 하단 네비 좌우
nav-bottom-inset: 24      # 화면 아래 여백
```

**화면 좌우 여백은 32로 통일했다.** 시안은 제목이 32, 카드가 34로 2px 어긋나 있는데 의도로 보기 어려워 32로 맞췄다 — 지적이 나오면 `AppTheme.pagePadding` 한 값만 바꾸면 된다 [src:2].

스크롤 뷰의 아래 패딩은 **`AppBottomNav.totalHeight + 16`** 으로 잡는다. 하단 네비가 떠 있는 구조라 이만큼 띄우지 않으면 마지막 카드가 버튼에 가려진다 [src:15][src:29].

```yaml
bottom-nav-bar-height: 62
bottom-nav-fab-overhang: 19   # 버튼이 막대 위로 솟은 만큼
bottom-nav-bottom-inset: 24
bottom-nav-total-height: 105  # = 62 + 19 + 24
```

## Rounded

곡률은 두 축으로 갈린다 — **컨트롤 8, 카드 9**다. 시안 프레임에서 읽은 값이고, 카드가 버튼보다 아주 조금 더 둥글다 [src:2].

```yaml
r-chip-square: 4      # 음식명 오렌지 칩
r-thumbnail: 5        # 32px 썸네일 · 빈 슬롯
r-debug: 6            # 디버그 오버레이(릴리즈 미노출)
r-control: 8          # 버튼 · 입력창 · 선택 타일 · 습관 줄 — AppTheme._radius
r-card: 9             # 모든 카드 — AppTheme.cardRadius
r-badge: 10           # ScoreBadge
r-meal-chip: 14       # 끼니 배지
r-emphasis: 16        # 타입 카드 · 기준 카드 · AI 코멘트 카드 · 민감도 배지
r-concern-chip: 18    # 고민 칩 (높이 36의 절반에 가까운 알약)
r-pill: 100           # 하단 네비 막대 · 탭 알약 · 진행 막대
```

`16` 은 **강조 카드 전용**이다 — 결과 화면의 타입 카드·기준 카드와 기록 화면의 AI 코멘트 카드가 기본 카드(9)보다 둥근 자리를 차지한다 [src:25][src:29]. 원형은 `BoxShape.circle` 로 따로 그린다(알약 `100` 과 구분).

## Elevation & Depth

**이 시스템의 깊이는 그림자가 아니라 면색과 테두리다.** 테마가 버튼·카드·AppBar의 `elevation` 을 전부 `0` 으로 눕혀 놓았다 [src:2].

층위는 세 겹이다:

```
background (#ffffff)
  └ 흰 카드 + border-on-white   ← 중립 정보 (기록·요약·영양 타일)
  └ 크림 카드 + border-on-cream ← 강조 정보 (점수·TIP·코멘트)
     └ 크림 카드 안의 흰 원/막대 ← 한 겹 더 들어간 자리 (빈 점수 원, 진행 막대 트랙)
```

크림 카드 안에서 배경색이 `background` 로 되돌아가는 것에 주목할 것 — 홈 점수 카드의 빈 원(67px)과 진행 막대의 트랙이 그렇다 [src:16]. 흰 위의 크림, 크림 위의 흰. 두 색만으로 세 층을 만든다.

앱 전체에서 **그림자는 두 개뿐이다**:

```yaml
nav-pill:      0px 0px 29.9px 0px oklch(0 0 0 / 0.1)  # #1a000000 — 떠 있는 하단 네비
today-records: 0px 0px 7.2px 0px oklch(0 0 0 / 0.1)   # #1a000000 — 홈 "오늘의 기록" 카드
```

둘 다 알파 10%로 같고 블러만 다르다. 떠 있는 네비가 4배 넓게 퍼진다 [src:12][src:17].

## Shapes

원이 많다. 점수·지표·아이콘·버튼이 전부 원이고, 각각 크기가 다르다:

```yaml
capture-fab: 72        # 하단 촬영 버튼 (그라디언트)
shutter: 78            # 촬영 셔터 — 링 5px, 안쪽 여백 6
score-gauge: 118       # 원형 게이지 — 궤적 8px, 반지름 = w/2 - 5, 표정 아이콘 44
empty-score: 67        # 기록 없는 날의 빈 원
metric-circle: 57      # 피부 지표 4종 — 아이콘 24
criteria-icon: 37      # 두 기둥 카드 아이콘 원 — 아이콘 20
zoom-chip: 45 / 32     # 현재 배율 / 나머지
progress-dot: 10       # 진행 표시 점 4개
check-circle: 60       # "분석이 완료됐어요" 체크 — 테두리 1.5px primary
```

원형 게이지는 **12시에서 시작해 시계 방향**으로 차고, 0점이어도 `0.04` 만큼 짧은 호를 남긴다 — 완전히 비면 게이지가 아니라 회색 원으로 보여서 "고장났나"가 먼저 떠오른다 [src:30].

카메라 화면에는 두 가지 안내 도형이 있다:

- **얼굴 타원** — 프레임 폭의 76%, 높이의 45%, 세로 중심은 위쪽 47%. 타원 **바깥**만 45% 검게 깔아 "안"이 어디인지 설명 없이 보이게 한다. 방위점 4개(반지름 5.5)를 상·하·좌·우에 찍고, 통과하면 흰색 1.5px → 연두 3px로 굵어진다 [src:23].
- **코너 브래킷** — 308px 사각의 네 모서리에 44px L자, 획 5px에 둥근 끝. 촬영 영역을 안내만 하고 자르지는 않는다 [src:26].

아이콘은 두 계열이 섞여 있다. SVG 5종(로고·홈·기록·카메라·프로필)은 시안 자산을 그대로 쓰고, 나머지는 Material 기본 아이콘이다 [src:6][src:33]. SVG는 `ColorFilter(srcIn)` 으로 상태색을 입히되 **로고만은 예외** — 검정+오렌지 2색이라 단색 필터를 씌우면 오렌지 포인트까지 죽는다 [src:18][src:19].

## Components

### app-bottom-nav

떠 있는 흰 알약 위에 촬영 버튼이 걸쳐 있다 [src:12]. 촬영 버튼이 막대 위로 19만큼 솟아 있어 `BottomNavigationBar` 로는 만들 수 없다 — 넘치는 부분이 잘린다. `Stack` 에 직접 얹고 `clipBehavior: none` 으로 벗어난 영역을 살린다.

탭은 두 개(홈·기록)이고 가운데는 촬영 버튼 자리로 비워 둔다(`SizedBox(width: 72)`) — 비우지 않으면 아이콘이 버튼 밑에 깔린다. 선택된 탭은 53×95 크림 알약에 `primary` 아이콘, 미선택은 `disabled` 아이콘이다. 아이콘만 탭 대상이면 손가락이 자주 빗나가므로 `HitTestBehavior.opaque` 로 투명 영역까지 받는다.

**402 기준의 절대 좌표를 쓰지 않는다** — 좌우는 여백으로, 가운데 버튼은 중앙 정렬로 잡는다. 절대 좌표를 그대로 쓰면 좁은 기기에서 아이콘이 겹친다.

### score-badge

점수 옆에 붙는 등급 배지. 시안에 두 모양이 있다 — 기록 카드는 진한 채움에 흰 글씨, 홈과 결과 화면은 옅은 틴트에 색 글씨다. **위젯을 나누지 않고 `solid` 플래그로만 가른다** — 나누면 한쪽만 고쳐지기 쉽다 [src:11]. 패딩 h8/v3, radius 10, 11px w700.

### score-gauge

점수에 비례해 차는 원호와 등급 표정 [src:30]. 118×118, 궤적과 호 모두 8px 스트로크에 둥근 끝. 궤적은 `background`(흰색), 호는 `grade.accentColor`. 시안이 SVG 호 두 장으로 그려 놓았지만 점수마다 호 길이가 달라져야 해서 `CustomPaint` 로 그린다.

### daily-score-card

홈 맨 위 "오늘의 피부 식단 점수" [src:16]. 높이 156, 패딩 (18,20,18,18), 크림 + `border-on-cream` + radius 9. 왼쪽에 점수와 진행 막대, 오른쪽에 67px 원.

**기록이 없는 날에는 `0점` 이 아니라 `OO점` 을 쓴다.** 0점은 "아주 나쁘게 먹었다"로 읽힌다 — 아직 아무것도 안 먹은 것과 나쁘게 먹은 것은 다르다. 이때 원은 빈 흰 원으로 남긴다. 시안이 자리를 비워 두지 않는다 — 채워질 곳이라는 걸 보여 주는 편이 낫다.

진행 막대는 높이 6, radius 100, 트랙 흰색에 `primary` 채움이며 `(score / target).clamp(0, 1)` 로 자른다 — 100점을 목표 80으로 나눈 1.25를 그대로 넘기면 렌더가 깨진다.

### today-records-card

홈의 "오늘의 기록" [src:17]. 흰 배경 + `border-on-white` + radius 9 + 블러 7.2 그림자.

**빈 상태를 빈 카드로 두지 않는다.** `ex)` 예시 한 줄(그릭요거트·78점)과 184px 빈 슬롯을 보여준다 — 무엇을 찍으면 되는지 말로 설명하는 대신 결과물을 미리 보여 주는 쪽이다. 빈 슬롯은 눌러서 바로 촬영으로 간다. 시안에는 `+` 표시만 있지만, 보이는 곳을 눌렀는데 아무 일도 없으면 고장으로 읽힌다.

기록 줄은 32px 썸네일(radius 5) + 끼니 배지(12px w700) + 음식명(10px w500) + 점수 + 표정 아이콘이다. 끼니를 모르면 배지를 **비운다** — 아무 끼니로나 떨어뜨리면 사용자가 자기 기록을 못 믿는다 [src:10].

### plate-score-card

음식 결과 맨 위 "내 피부 적합도" [src:30]. 크림 + `border-on-cream` + 높이 156으로 홈 점수 카드와 짝을 이루고, 오른쪽에 원형 게이지가 붙는다. 하단에 "민감성 피부 기준" 같은 채점 근거 문구를 두되 **자가신고 타입이 없으면 비운다 — 지어내서 채우지 않는다** [src:27].

### plate-summary-card

"분석 요약" GOOD / BAD 카드 [src:31]. 흰 배경 + `disabled` 테두리. GOOD은 `good` 색 14px w600, BAD는 `bad` 색. 본문은 10px w500 `height 1.5`.

**둘 다 비어도 카드를 빈 껍데기로 두지 않는다** — 룰이 하나도 안 걸린 평범한 식사가 실제로 있고, 그때도 침묵보다는 한 줄이 낫다("특별히 걸리는 항목 없이 무난한 식사예요").

### plate-tip-card

"AI 맞춤 TIP" 크림 카드 [src:31]. `minHeight: 92`, 제목 11px w600, 본문 10px w500 `height 1.47`. 시안이 행동 제안 자리에 넣은 대체물이다 [src:5].

### nutrient-tiles

"주요 영양 성분 (1인분 기준)" 타일 4개 [src:31]. 각 92px 높이, 흰 배경 + `disabled` 테두리 + radius 9, 사이 간격 16. 아이콘 26 + 라벨 10px + 값 10px.

천 단위 쉼표는 정규식 한 줄로 처리한다 — `intl` 을 들이지 않고 이 한 곳에서 해결한다.

### type-card

피부 결과의 "복합성 피부" 카드 [src:25]. **radius 16 + `primary` 0.6px 테두리**로 기본 카드와 층을 가른다. 제목 옆 민감도 배지는 **붉어짐이 60 이상일 때만** 단다 — 근거 없이 달면 "높음"이 안 뜨는 날 이 배지의 신뢰가 같이 사라진다.

지표 4종은 57px 원 + 24px 아이콘 + 라벨 + 상태어다. 상태어의 색은 지표 방향에 따라 다르게 계산한다 — 높을수록 좋은 지표(수분·피부결)는 40 미만이 "부족"(파랑 `#3a85e2`), 높을수록 나쁜 지표(유분·붉어짐)는 60 이상이 "주의"(빨강 `#fa6154`)다.

**서버는 지표를 5개 주지만 화면은 4개만 그린다** — 확인받은 디자인 의도다. `trouble` 은 안 그리지만 점수 계산에는 그대로 들어가 있다.

### criteria-card

"앞으로 음식 분석은 이런 기준으로" 두 기둥 카드 [src:25]. 타입 카드와 같은 radius 16 + `primary` 0.6px. 기둥 사이는 `VerticalDivider(width: 1)`, 아이콘은 37px 크림 원 안에 20px `primary`. 설명 문구가 8.5px로 이 앱에서 가장 작다.

### meal-card

기록 화면의 끼니 카드 [src:29]. 흰 배경 + `border-on-white` + radius 9, 패딩 16. 끼니 배지는 크림 배경에 `#ff9362` 테두리와 `primary` 글자(radius 14)로, 다른 화면의 배지와 다른 모양이다. 사진은 120px(radius 8), 점수는 32px w700.

하단은 `Divider` 1px 뒤 "분석 결과 보기 ›" 한 줄이다.

### ai-comment-card

기록 화면 맨 아래 "오늘의 AI 코멘트" [src:29]. 앱에서 그라디언트를 쓰는 두 요소 중 하나다(`#fef7f0` → `#fff2e4`, 세로). 테두리 `#e8e8e8` 0.8px, radius 16. 제목은 `primary` 14px w600, 본문은 `#411b09` 12px `height 1.32` — 이 카드에서만 쓰는 갈색이다.

문장은 **기록을 저장할 때 서버가 만들어 둔 것**이다. 앱이 생성하지 않는다.

### selectable

선택 가능한 상자의 공통 모양 [src:21]. 선택되면 `primary` 테두리 + 크림 배경, 아니면 `border-empty-slot` 테두리 + 흰 배경. radius 8 고정, 높이만 받는다 — 타입 타일 91, 카드형 선택지 120, 목록형 줄 40.

### concern-chips

주요 피부 고민 9종, 3열 그리드 [src:21][src:22]. `childAspectRatio: 106/36`, 세로 간격 8, 가로 간격 11, radius 18. **선택되면 `primary` 채움에 흰 글씨** — `_Selectable` 과 다른 규칙이다(칩은 채우고, 타일은 테두리만 바꾼다).

### progress-dots

설문 진행 표시 [src:21]. 1px 선 위에 10px 점 4개를 `spaceBetween` 으로 놓고, 채워진 만큼 `primary`, 나머지는 `border-empty-slot`. 채워지는 개수는 시작(1) + 타입 + 고민 + 습관으로 센다.

### habit-section

접히는 습관 한 줄 [src:21]. 높이 40, radius 8, 펼쳐지면 테두리가 `primary` 로 바뀐다. 오른쪽 값은 **고른 값이 있으면 오렌지, 없으면 회색 기본 표기**다. **한 번에 하나만 펼친다.**

### shutter

촬영 셔터 [src:23][src:26]. 78px 원에 `primary` 링 5px, 안쪽 여백 6, 그 안에 흰 원. 진행 중에는 흰 원 안에 스피너가 돈다.

**피부 촬영의 셔터는 게이트를 통과해야 켜진다** — 꺼진 상태는 링이 `white38`, 안쪽이 `white54`다. 그리고 **왜 안 찍히는지 반드시 문구로 말한다.** 이유 없이 잠긴 셔터는 고장으로 읽힌다. 음식 촬영의 셔터는 항상 켜져 있다 — 그쪽 게이트는 차단 장치가 아니라 촬영 가이드이기 때문이다 [src:26].

### turn-hint

측면 촬영 단계에서 고개를 어느 쪽으로 돌릴지 보여주는 흐르는 화살표 [src:23]. 1100ms 반복, `Curves.easeOut` 으로 28px 이동하며 투명해진다. 거울 프리뷰 앞에서 "왼쪽으로"라는 문장은 한 박자 늦게 읽힌다 — 돌릴 방향으로 흘러가는 화살표는 읽지 않아도 따라 하게 된다.

**방향이 문제일 때만** 흘린다. 거리·밝기로 막혔는데 화살표가 흐르면 사용자는 더 돌고, 각도가 커질수록 검출이 나빠진다. 다만 자리(44px)는 항상 잡아 둔다 — 임계각 근처에서 판정이 300ms마다 진동하면 읽고 있는 문구가 같이 튄다.

### zoom-chips

0.5x / 1x / 2x [src:26]. 현재 배율만 45px·15px w500 흰색, 나머지는 32px·11px `white70`. 배경은 검정 45%.

### loading-steps

분석 로딩 [src:24]. 스피너 + 32px 아래 단계 문구, `AnimatedSwitcher` 300ms로 교체하며 1800ms마다 다음 단계로 넘어간다. **마지막 단계에서 멈춘다** — 순환시키면 8초가 넘어갔을 때 첫 문구로 되돌아가 진행이 없어 보인다.

빈 스피너 대신 단계를 보여주는 것은 PRD §6 원칙 1이다 [src:35].

### failure-view · safety-notice

실패 안내는 화면마다 다른 문구를 짓지 않도록 통로를 하나로 둔다 [src:13]. 재촬영이 필요한 실패는 버튼 문구가 "다시 촬영하기"로 바뀐다.

안전 고지는 **모든 결과 화면 하단에 고정**한다(PRD §20 · R3) — `bodySmall` 가운데 정렬, 위아래 24 [src:13].

### camera-preview-box

프리뷰를 **종횡비를 지켜** 채운다 [src:14]. `Stack(fit: expand)` 아래에 `CameraPreview` 를 그대로 두면 tight 제약이 내려가 16:9 텍스처가 상자에 맞춰 늘어난다. 720×1280을 393×600에 늘리면 얼굴이 실제보다 16% 넓게 보이고, **게이트는 원본 프레임에서 비율을 재는데 사용자는 늘어난 화면을 보므로 가이드 타원과 실제 통과 조건이 어긋난다.**

## Do's and Don'ts

**Do** 색은 `AppColors` 만 부른다. 화면에 색 리터럴을 쓰지 마라 — 디자이너가 Figma 변수를 만드는 날 교체 비용이 한 파일에서 끝나야 한다 [src:1].

**Do** 점수 → 색 변환은 `ScoreGrade` 를 지난다. 화면에서 경계값을 다시 쓰면 등급 어휘가 화면마다 갈린다 [src:7].

**Do** 깊이는 면색과 테두리로 만든다. 흰 위에는 `border-on-white`, 크림 위에는 `border-on-cream`, 빈 자리에는 `border-empty-slot`. 그림자는 이미 있는 두 개 말고 늘리지 않는다 [src:1][src:12][src:17].

**Do** 빈 상태를 비워 두지 않는다. 점수가 없으면 `OO점`, 기록이 없으면 예시 한 줄과 빈 슬롯, 요약이 비면 "무난한 식사예요" 한 줄 [src:16][src:17][src:31].

**Do** 잠긴 컨트롤에는 이유를 붙인다. 셔터가 꺼져 있으면 왜 안 찍히는지 문구로 말한다 [src:23].

**Do** 문장은 서버가 만든 것을 그대로 쓴다. 실패 문구·AI 코멘트·갭 설명·요약이 전부 그렇다. 앱이 다시 지으면 규칙이 두 곳에 생겨 언젠가 어긋난다 [src:19][src:25][src:29].

**Don't** 다크 테마를 지어내지 않는다. 시안이 라이트 한 벌이라, 다크를 흉내내면 대비를 앱이 발명하게 된다 [src:2].

**Don't** 서버가 준 점수를 앱에서 다시 계산하지 않는다. 점수는 백엔드가 소유한다 [src:36].

**Don't** `HighlightStatus` 의 모르는 값을 `good` 으로 떨어뜨리지 않는다. 경고가 초록 뱃지가 되면 사용자에게 잘못된 안심을 준다 — 중립인 `warn` 으로 보낸다 [src:8].

**Don't** 기록 카드의 주의 점수를 빨강으로 칠하지 않는다. 빨강(`bad`)은 BAD 라벨 전용이고, 주의 점수는 오렌지다 [src:29].

**Don't** 402 기준 절대 좌표를 옮겨 적지 않는다. 좁은 기기에서 겹친다 — 여백과 중앙 정렬로 환산한다 [src:12].

**Don't** (브랜드 자산) `assets/icons/logo_skinpick.svg` 와 `assets/icons/sns_row.png` 는 디자인 토큰이 아니다. 앞은 이 제품의 마크이고, **뒤는 타사(SNS) 브랜드 아이콘 렌더**라 각 서비스의 브랜드 가이드라인이 걸린다. 시안 렌더를 그대로 쓰는 이유도 손으로 다시 그리면 가이드라인 위반이 되기 쉬워서다 [src:19]. 이 문서가 옮기는 것은 토큰과 배치 규칙이지 자산 파일이 아니다.

**Don't** 폰트 파일을 늘리지 않는다. Pretendard 넷이 시안에서 확인한 쓰임의 전부다. **Medium을 빼면 본문 대부분이 Regular로 떨어지는데, 앱은 죽지 않고 글자만 얇아진다** [src:6].

## Responsive Behavior

모바일 세로 한 벌이다. 중단점이 없다.

```yaml
design-frame: 402 × 874     # 시안 기준 프레임
max-width: 430              # MaterialApp.builder 의 ConstrainedBox
page-padding: 32
```

화면은 모바일 폭 기준으로 짜여 있어 데스크톱 브라우저에서 그대로 늘리면 카드 하나가 화면을 가로지른다. **폭만 430으로 잡아 주면 모바일 프레임처럼 보인다** — 그 이상은 하지 않는다 [src:3].

카메라 화면 두 곳은 **세로로 고정**한다(`portraitUp`). ML Kit에 넘기는 회전 보정이 세로를 전제하므로, 가로로 돌리면 90도 어긋난 프레임이 들어가 검출이 0개가 되고 얼굴이 화면에 뻔히 보이는데도 "얼굴을 찾을 수 없어요"에서 영구히 막힌다. 화면을 벗어날 때 원래대로 되돌린다 [src:23][src:26].

## Motion

모션이 거의 없는 시스템이다. 명시적으로 정의된 것은 셋뿐이다:

```yaml
loading-step-switch: 300ms   # AnimatedSwitcher — 로딩 단계 교체
loading-step-interval: 1800ms
turn-hint-sweep: 1100ms      # repeat + Curves.easeOut, 28px 이동
```

나머지는 Flutter 기본 전환(`GoRouter` 의 플랫폼 기본 페이지 전환, `RefreshIndicator`, `CircularProgressIndicator`)을 그대로 쓴다. 눌림 피드백도 커스텀하지 않는다 — 선택 상태는 애니메이션이 아니라 **색으로** 바뀐다.

PRD §6 원칙 6이 요구한 "점수가 눈앞에서 움직이는" 재계산 애니메이션은 시안에 없어 구현되지 않았다 [src:5][src:35].

## Known Gaps

- **Figma 변수가 없다.** 토큰 원본이 없어 값의 출처가 둘로 갈린다 — 프레임 사양에서 읽은 것과 렌더에서 샘플링한 것. 현재 샘플링으로 표시된 것은 `outline`(`#898888`) 하나이며, 다른 화면 사양을 읽을 때 우선 확인 대상이다 [src:1].

- **토큰화되지 않은 색 리터럴 11개.** `AppColors` 를 거치지 않고 화면에 직접 박힌 값들이다. 늘어나면 "색은 한 파일" 규칙이 무너진다:

  ```yaml
  ink-900: "#1a1a1a"   # 타입 카드 제목 · 지표 라벨 · 날짜 [src:25][src:29]
  ink-800: "#272727"   # AI TIP 제목 [src:31]
  ink-700: "#494949"   # 결과 화면 본문 4곳 [src:25]
  cocoa:   "#411b09"   # AI 코멘트 본문 [src:29]
  metric-blue: "#3a85e2"  # 지표 "부족" [src:25]
  metric-red:  "#fa6154"  # 지표 "주의" [src:25]
  sensitive-badge-bg: "#fff2ec"  # 민감도 배지 [src:25]
  comment-grad-end:   "#fff2e4"  # AI 코멘트 그라디언트 끝 [src:29]
  meal-chip-border:   "#ff9362"  # 끼니 배지 테두리 [src:29]
  hairline:           "#e8e8e8"  # AI 코멘트 테두리 [src:29]
  stress-medium:      "#ffc107"  # 스트레스 "보통" 신호등 [src:21]
  ```

  `ink-700`·`ink-900` 은 `text-on-card`(`#505050`)·`text-primary`(`#000000`)와 목적이 겹치는데 값이 다르다. 시안이 실제로 다른 값을 쓴 것인지 옮기는 과정의 흔들림인지 확인되지 않았다.

- **등급 경계값(75/60)은 역산이다.** 시안에 적힌 예시(92·78 좋음, 72 보통, 58 주의)에서 거꾸로 잡았다. 디자이너가 의도한 정확한 경계는 확인이 필요하다 [src:7].

- **배지가 두 벌로 그려진다.** `ScoreBadge` 위젯이 있는데 `PlateScoreCard` 는 그걸 쓰지 않고 자체 배지를 인라인으로 그린다 — 패딩(h9/v4 vs h8/v3)·radius(8 vs 10)·글자(12 w500 vs 11 w700)가 전부 다르다 [src:11][src:30]. 시안이 정말 두 모양을 요구하는지, 아니면 한쪽으로 합쳐야 하는지 확인되지 않았다.

- **접근성 미검증.** 카드 안쪽 본문이 10px, 두 기둥 카드 설명이 8.5px다. 대비비(`text-secondary #6d6d6d` on 흰 배경 등)를 재는 장치가 저장소에 없고, 색 외의 상태 표시는 지표 상태어와 하이라이트 아이콘 정도에 그친다. 정량 기준을 세운 적이 없다.

- **시안이 닿지 않은 화면이 남아 있다.** 회원가입(S01b)은 `pagePadding` 대신 `EdgeInsets.all(24)`, `hintText` 대신 `labelText`, `ElevatedButton` 대신 `FilledButton` 을 쓰고 `AppColors` 를 import하지 않는다 [src:20]. 추천 화면(S08)은 `Colors.green`/`Colors.red` 와 `Card`+`ListTile` 기본형이다 [src:32]. 결과 화면의 갭 카드·타입 선택 프롬프트, 행동 제안 카드도 Material 기본 `Card` 로 남아 있다 [src:25][src:27]. 뒤 셋은 `FeatureFlags` 로 꺼져 있어 화면에 나오지 않지만, 켜는 순간 시안과 다른 화면이 나온다 [src:5].

- **아이콘 계열이 둘이다.** `pubspec.yaml` 은 "시안 아이콘(Solar·Material Round)을 그대로 쓴다"고 적고 `flutter_svg` 를 넣었지만 [src:6], 실제 SVG는 5종(로고·홈·기록·카메라·프로필)뿐이고 나머지 화면 아이콘은 전부 Material 기본이다. 획 굵기와 모서리가 미묘하게 다른 두 계열이 같은 화면에 섞여 있다.

- **`fab_circle.svg` 는 쓰이지 않는다.** 같은 그라디언트 원을 `AppBottomNav._CaptureButton` 이 코드로 그린다 [src:12][src:33]. 둘 중 하나는 정리 대상이다.

- **`ScoreGrade.normal` 과 `caution` 의 `solidColor` 가 같다.** 진한 채움 배지에서 "보통"과 "주의"가 같은 오렌지로 보인다 — 글자(`보통`/`주의`)로만 구분된다 [src:7]. 시안 확인이 필요하다.

- **PRD와 시안의 어긋남은 시안 쪽으로 정리됐다.** PRD §6은 S05에 "5개 지표 바", S07에 "왜 60점인가 접이식 계산 내역"과 행동 실행 버튼, S08에 공유 버튼을 요구한다 [src:35]. 시안은 지표를 4개로 줄이고 나머지를 뺐다. 이 문서는 시안(= 현재 코드)을 기록한 것이고, PRD 쪽 요소를 되살리려면 시안 사양이 새로 필요하다.

## References

1. `lib/app/theme/app_colors.dart` — 색의 단일 출처. 팔레트 전량과 각 색의 시안 근거·샘플링 여부를 주석으로 담는다.
2. `lib/app/theme/app_theme.dart` — `ThemeData` 한 벌. 폰트·radius(8/9)·pagePadding(32)·textTheme 4종·버튼/입력/카드/AppBar 테마.
3. `lib/app/app.dart` — 앱 루트. `maxWidth: 430` 프레임 제약.
4. `lib/app/router/app_router.dart` — 화면 ID(S00~S09)와 경로, 인증 가드.
5. `lib/app/config/feature_flags.dart` — 시안에 없어 진입점만 막은 기능(행동 시뮬레이션·추천 화면)과 그 이유.
6. `pubspec.yaml` — Pretendard 4종 동봉 근거, `flutter_svg` 도입 이유, 자산 목록.
7. `lib/shared/enums/score_grade.dart` — 점수 → 등급 → 색(solid·tint·accent) 변환의 유일한 통로.
8. `lib/shared/enums/highlight_status.dart` — 하이라이트 상태 파서. 모르는 값을 `warn` 으로 떨어뜨리는 이유.
9. `lib/shared/enums/skin_type.dart` — 피부 타입 어휘와 선택 칩 목록.
10. `lib/shared/enums/meal_type.dart` — 끼니 표기. 모르는 값을 비우는 이유.
11. `lib/shared/widgets/score_badge.dart` — 등급 배지 두 모양(solid/tint)을 한 위젯으로 유지하는 근거.
12. `lib/shared/widgets/app_bottom_nav.dart` — 떠 있는 알약 네비와 그라디언트 촬영 버튼. 높이 상수와 그림자.
13. `lib/core/widgets/app_widgets.dart` — 공용 실패 안내와 안전 고지.
14. `lib/core/widgets/camera_preview_box.dart` — 프리뷰 종횡비 유지. 게이트 판정과 화면이 어긋나는 문제.
15. `lib/features/home/presentation/pages/home_page.dart` — 홈 배치, 크림 코멘트 카드, 프로필 메뉴.
16. `lib/features/home/presentation/widgets/daily_score_card.dart` — 점수 카드. `OO점` 규칙과 진행 막대.
17. `lib/features/home/presentation/widgets/today_records_card.dart` — 기록 카드. 빈 상태의 예시 줄과 빈 슬롯, 썸네일 폴백.
18. `lib/features/auth/presentation/pages/splash_page.dart` — 로고 한 장. 스피너를 두지 않는 이유.
19. `lib/features/auth/presentation/pages/login_page.dart` — 로그인 배치, 링크 줄, SNS 자산, 숨긴 시연 도구.
20. `lib/features/auth/presentation/pages/signup_page.dart` — 회원가입. 시안 토큰이 적용되지 않은 화면.
21. `lib/features/auth/presentation/pages/skin_type_page.dart` — 설문 화면. `_Selectable`·고민 칩·진행 점·접히는 습관 줄.
22. `lib/features/auth/domain/entities/skin_profile.dart` — 고민 9종·수면·스트레스·운동의 라벨과 설명 문구.
23. `lib/features/skin_analysis/presentation/pages/skin_capture_page.dart` — 얼굴 타원 가이드, 셔터, 방향 화살표, 안내 화면.
24. `lib/features/skin_analysis/presentation/pages/skin_loading_page.dart` — 단계 로딩. 마지막에서 멈추는 이유.
25. `lib/features/skin_analysis/presentation/pages/skin_result_page.dart` — 타입 카드·지표 4종·하이라이트·두 기둥 기준 카드.
26. `lib/features/skin_plate/presentation/pages/food_capture_page.dart` — 코너 브래킷, 줌 칩, 차단하지 않는 게이트.
27. `lib/features/skin_plate/presentation/pages/plate_result_page.dart` — 결과 배치, 음식명 칩, 저장 CTA의 상태별 표현.
28. `lib/features/skin_plate/presentation/pages/plate_detail_page.dart` — 저장된 기록 열람. 결과 화면과 같은 카드, 저장 버튼 없음.
29. `lib/features/skin_plate/presentation/pages/plate_history_page.dart` — 날짜 이동 줄, 끼니 카드, 그라디언트 AI 코멘트 카드.
30. `lib/features/skin_plate/presentation/widgets/plate_score_card.dart` — 적합도 카드와 원형 게이지 페인터.
31. `lib/features/skin_plate/presentation/widgets/plate_summary_cards.dart` — GOOD/BAD 카드, AI TIP 카드, 영양 타일 4개.
32. `lib/features/recommendation/presentation/pages/recommendation_page.dart` — 추천 화면. 시안 미적용, 플래그로 꺼져 있음.
33. `assets/icons/` — SVG 5종(로고·홈·기록·카메라·FAB 원)과 SNS 아이콘 PNG.
34. `assets/fonts/OFL.txt` — Pretendard 라이선스(SIL OFL 1.1). 앱 동봉 허용 근거.
35. `../Skinpick-backend/SkinPlate_PRD.md` — §6 화면 정의와 화면 설계 원칙 6개. 시안과 어긋나는 지점의 원문.
36. `CLAUDE.md` — 프로젝트 규약. 점수 소유권·enum 기본값·시크릿 금지 등 이 문서가 참조하는 금지 조항.
