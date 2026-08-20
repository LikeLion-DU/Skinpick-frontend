import 'dart:convert';
import 'dart:io';
import 'package:skinplate/features/report/data/models/report_dtos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/pages/login_page.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/report/domain/entities/report.dart';
import 'package:skinplate/features/report/presentation/widgets/report_widgets.dart';
import 'package:skinplate/features/home/presentation/widgets/today_records_card.dart';
import 'package:skinplate/features/skin_plate/presentation/widgets/plate_summary_cards.dart';
import 'package:skinplate/shared/widgets/pill.dart';
import 'package:skinplate/shared/widgets/verdict_badge.dart';
import 'package:skinplate/shared/enums/skin_level.dart';

/// 리뷰에서 재현된 것들을 고정한다.
///
/// **글자 크기를 키우면 고정 크기 상자는 예외를 던지지 않고 조용히 글자를 자른다.**
/// 그래서 오버플로 예외만 보는 기존 테스트가 전부 통과했다. 여기서는 그려진 크기와
/// 필요한 크기를 직접 비교한다.
void main() {
  const designSize = Size(402, 874);

  Widget scaled(Widget child, {double scale = 2.0}) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: MaterialApp(theme: AppTheme.light, home: child),
      );

  /// 그려진 상자가 글자를 자르고 있는가.
  void expectNotClipped(WidgetTester tester, Finder text, {required String label}) {
    final box = tester.renderObject<RenderBox>(text);
    final painted = box.size;
    final needed = tester.renderObject<RenderBox>(text).getDryLayout(
          const BoxConstraints(),
        );
    expect(painted.height + 0.5, greaterThanOrEqualTo(needed.height),
        reason: '$label 세로가 잘렸다 (그려진 $painted / 필요한 $needed)');
    expect(painted.width + 0.5, greaterThanOrEqualTo(needed.width),
        reason: '$label 가로가 잘렸다 (그려진 $painted / 필요한 $needed)');
  }

  group('단계 탭 — 배율이 실제로 먹는다', () {
    /// 그려진 라벨의 화면상 높이. 변환까지 반영돼야 축소를 볼 수 있다.
    Future<double> tabTextHeight(WidgetTester tester, double scale,
        {Size surface = designSize}) async {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: [
          // 스플래시 최소 노출(3초) 타이머가 테스트 종료 후까지 살아 !timersPending 에 걸린다.
          splashMinimumHoldProvider.overrideWithValue(Duration.zero),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const SkinTypePage(),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      return tester.getRect(find.text('주요 피부 고민')).height;
    }

    testWidgets('배율을 올리면 탭 글자가 커진다 — 축소로 되돌리지 않는다', (tester) async {
      // FittedBox 로 줄여 맞추던 시절에는 2.0 을 걸어도 12.8px 로 고정됐다.
      // 접근성 설정이 이 줄에만 안 먹는 상태였다.
      final base = await tabTextHeight(tester, 1.0);
      final bigger = await tabTextHeight(tester, 2.0);

      expect(bigger, greaterThan(base),
          reason: '배율을 올렸는데 탭 글자가 그대로다');
      expect(tester.takeException(), isNull);
    });

    testWidgets('라벨을 줄임표로 지우지 않는다 — 탭의 정체가 라벨이다', (tester) async {
      await tabTextHeight(tester, 2.0);

      // "주요 피부 …" 로 접히면 무엇의 탭인지가 사라진다. 세 라벨 모두 온전해야 한다.
      for (final label in ['피부 타입', '주요 피부 고민', '나의 생활 습관']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('360dp 에서 배율을 올리면 접히되 알약이 같이 자란다', (tester) async {
      // 좁은 화면 + 키운 글자는 한 줄로 받을 수 없다. 이때 접히는 것은 사고가
      // 아니라 이 줄의 정책이다 — 축소로 되돌리면 접근성 설정이 여기만 안 먹는다.
      //
      // 지켜야 하는 것은 "한 줄"이 아니라 **글자가 안 잘리는 것**이다. 높이가
      // minHeight 라 두 줄이 되면 알약이 따라 자라야 한다.
      const surface = Size(360, 900);
      final base = await tabTextHeight(tester, 1.0, surface: surface);
      final scaled = await tabTextHeight(tester, 1.2, surface: surface);

      expect(scaled, greaterThan(base), reason: '배율을 올렸는데 탭 글자가 그대로다');

      final text = tester.renderObject<RenderBox>(find.text('주요 피부 고민'));
      final pill = tester.renderObject<RenderBox>(find
          .ancestor(of: find.text('주요 피부 고민'), matching: find.byType(Container))
          .first);

      // 접을 자리를 준 뒤의 높이와 비교한다. 한 줄 기준(제약 없는 dry layout)과
      // 재면 접힌 라벨은 언제나 "잘린" 것으로 나온다 — 폭이 좁아진 게 아니라
      // 좁은 폭을 받아들인 것이다.
      final needed = text.getDryLayout(BoxConstraints(maxWidth: text.size.width));

      expect(text.size.height, greaterThanOrEqualTo(needed.height),
          reason: '접힌 줄이 잘렸다 (그려진 ${text.size} / 필요한 $needed)');
      expect(pill.size.height, greaterThanOrEqualTo(text.size.height),
          reason: '두 줄이 됐는데 알약이 안 자랐다 '
              '(알약 ${pill.size} / 글자 ${text.size})');
      expect(tester.takeException(), isNull);
    });

    testWidgets('360dp 안드로이드에서도 라벨이 한 줄이다', (tester) async {
      // 시연·발표 기기가 안드로이드다. 갤럭시 S 계열의 논리 폭은 360 으로,
      // 시안 프레임보다 42dp 좁다 — 그 42dp 에서 라벨이 두 줄로 접혔다.
      //
      // **실제 폰트가 아니면 이 차이가 안 보인다.** test/flutter_test_config.dart
      // 가 모든 테스트에 Pretendard 를 올린다.
      await tabTextHeight(tester, 1.0, surface: const Size(360, 900));

      for (final label in ['피부 타입', '주요 피부 고민', '나의 생활 습관']) {
        final text = tester.renderObject<RenderBox>(find.text(label));
        final oneLine = text.getDryLayout(const BoxConstraints());

        expect(text.size.height, oneLine.height,
            reason: '$label 이 두 줄로 접혔다 '
                '(그려진 ${text.size} / 한 줄 $oneLine)');
      }
    });
  });

  group('글자 크기 2.0 — 배율 테스트가 없던 화면', () {
    testWidgets('로그인 — 링크 줄이 넘치지 않고 회원가입이 남는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(ProviderScope(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
      ], child: const LoginPage())));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // 세 링크가 다 살아 있어야 한다 — 잘려 나가면 가입 입구가 사라진다.
      expect(find.text('회원가입'), findsOneWidget);
      expect(find.text('아이디 찾기'), findsOneWidget);
    });

    testWidgets('로그인 — 기본 글자 크기에서는 세 링크가 한 줄이다', (tester) async {
      // Wrap 으로 바꾼 뒤 링크가 세 줄로 쪼개졌다(각 Container 가 폭을 다 먹었다).
      // 에뮬레이터 화면에서 눈으로 잡혔다.
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(ProviderScope(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
      ], child: const LoginPage()),
          scale: 1.0));
      await tester.pumpAndSettle();

      final y = tester.getTopLeft(find.text('아이디 찾기')).dy;
      expect(tester.getTopLeft(find.text('비밀번호 찾기')).dy, y);
      expect(tester.getTopLeft(find.text('회원가입')).dy, y);
    });

    testWidgets('로그인 — 링크 탭 영역이 44dp 이상이다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(ProviderScope(overrides: [
        splashMinimumHoldProvider.overrideWithValue(Duration.zero),
      ], child: const LoginPage()),
          scale: 1.0));
      await tester.pumpAndSettle();

      for (final label in ['아이디 찾기', '비밀번호 찾기', '회원가입']) {
        final size = tester.getSize(find.ancestor(
          of: find.text(label),
          matching: find.byType(Container),
        ).first);
        expect(size.height, greaterThanOrEqualTo(44), reason: '$label 탭 영역');
      }
    });

    testWidgets('습관 설문 — 카드와 줄이 넘치지 않는다', (tester) async {
      const user = AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
      );

      await tester.binding.setSurfaceSize(const Size(402, 1600));
      await tester.pumpWidget(scaled(ProviderScope(
        overrides: [authNotifierProvider.overrideWith(() => _StubAuth(user))],
        child: const SkinTypePage(mode: ProfileFormMode.lifestyle),
      )));
      await tester.pumpAndSettle();

      // 네 줄을 모두 펼친다 — 접힌 상태로는 오버플로가 드러나지 않는다.
      for (final title in ['수면 패턴', '스트레스 정도', '운동 습관', '물 섭취']) {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$title 를 펼쳤을 때');
      }
    });

    testWidgets('습관 설문 — 미선택은 보기와 같은 말을 쓰지 않는다', (tester) async {
      const user = AuthUser(
        userId: 1,
        email: 'test@skinplate.app',
        nickname: '테스트유저',
      );

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(
        ProviderScope(
          overrides: [authNotifierProvider.overrideWith(() => _StubAuth(user))],
          child: const SkinTypePage(mode: ProfileFormMode.lifestyle),
        ),
        scale: 1.0,
      ));
      await tester.pumpAndSettle();

      // 스트레스의 실제 보기에 '보통' 이 있다. 미선택을 '보통' 으로 적으면
      // 안 고른 줄과 고른 줄이 같은 글자가 된다.
      expect(find.text('미설정'), findsNWidgets(4));
      expect(find.text('보통'), findsNothing);
    });

    testWidgets('음식 결과 영양 타일 — 네 칸이 넘치지 않는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(const Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
          child: NutrientTiles(
            caloriesKcal: 500,
            sodiumMg: 1280,
            sugarG: 28,
            fatG: 14,
          ),
        ),
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('고정 크기 상자가 글자를 자르지 않는다', () {
    testWidgets('GOOD/BAD 배지', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(const Scaffold(
        body: Center(child: VerdictBadge(grade: SkinLevel.excellent)),
      )));
      await tester.pumpAndSettle();

      expectNotClipped(tester, find.text('GOOD'), label: 'GOOD 배지');
    });
  });

  group('칩은 남은 폭을 다 먹지 않는다', () {
    // `Container(alignment: …)` 를 Wrap 안에 두면 Align 이 남은 폭을 전부 차지해서
    // 칩이 한 줄에 하나씩 쌓인다. 시안은 나란히 두 개다. 로그인 링크 줄에서 눈으로
    // 잡혔고(세 링크가 세 줄로 쪼개졌다), 같은 구조가 앱 전체 칩에 있었다.
    testWidgets('고민 태그 두 개가 한 줄에 나란히 앉는다', (tester) async {
      const tags = ['발효식품 포함', '매운맛 자극'];

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ConcernList(
              hasRecords: true,
              items: [
                ConcernScore(
                  concern: 'ACNE',
                  label: '여드름',
                  score: 74,
                  status: SkinLevel.good,
                  change: null,
                  message: '발효식품이 포함돼 있어요.',
                  tags: tags,
                ),
              ],
            ),
          ),
        ),
        scale: 1.0,
      ));
      await tester.pumpAndSettle();

      // 칸 폭(362)의 절반보다 좁아야 두 개가 한 줄에 들어간다.
      for (final tag in tags) {
        // `Pill` 로 찾는다 — 내부 Container 를 찾으면 위젯이 한 겹 늘어난 날
        // 다른 상자를 재면서 조용히 통과한다.
        final chip =
            find.ancestor(of: find.text(tag), matching: find.byType(Pill)).first;
        expect(tester.getSize(chip).width, lessThan(181),
            reason: '$tag 칩이 폭을 다 먹었다');
      }
      // 같은 y 에 있어야 한다 — 줄이 갈리면 하나가 아래로 내려간다.
      expect(tester.getTopLeft(find.text(tags[0])).dy,
          tester.getTopLeft(find.text(tags[1])).dy);
    });
  });

  group('리뷰에서 나온 것들', () {
    testWidgets('요약이 비면 카드를 그리지 않는다 — 빈 테두리만 남지 않게', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(
        const Scaffold(
          body: PlateSummaryCard(summary: '', good: [], caution: []),
        ),
        scale: 1.0,
      ));
      await tester.pumpAndSettle();

      // 룰도 문장도 없으면 그릴 것이 없다. `skin_plate.summary` 는 nullable 이라
      // 옛 기록에서 실제로 빌 수 있다.
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('못 잰 영양 타일도 옆 타일과 같은 높이에 글자가 온다', (tester) async {
      // 자리를 지우기만 했더니 spaceBetween 이 자식 수에 따라 위치를 다시 잡아
      // 라벨이 47px 어긋났다. 실서버 응답이 바로 이 조합이다(오메가3만 측정됨).
      final body = jsonDecode(
          File('test/fixtures/report_daily_live.json').readAsStringSync());
      final report = DailyReportDto.fromJson(
              (body as Map<String, dynamic>)['data'] as Map<String, dynamic>)
          .toEntity();

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(scaled(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NutritionTiles(items: report.skinNutrients),
          ),
        ),
        scale: 1.0,
      ));
      await tester.pumpAndSettle();

      final tops = [
        for (final label in ['비타민C', '오메가3', '아연'])
          tester.getTopLeft(find.text(label)).dy,
      ];
      expect(tops[0], tops[1], reason: '비타민C 와 오메가3 라벨 높이');
      expect(tops[1], tops[2], reason: '오메가3 와 아연 라벨 높이');
      // 자리는 남기고 글자만 감춘다 — 위젯은 셋 다 트리에 있고 보이는 것은 하나다.
      expect(find.text('0%'), findsNWidgets(3));
      final visible = tester
          .widgetList<Visibility>(find.byType(Visibility))
          .where((v) => v.visible)
          .length;
      expect(visible, 2, reason: '측정된 항목의 비율·막대 둘만 보인다');
      expect(find.text('알 수 없음'), findsNWidgets(2));
    });

  });

  group('홈 기록 카드 — 세 상태가 구분된다', () {
    Widget card({
      bool loading = false,
      String? failureMessage,
    }) =>
        scaled(
          Scaffold(
            body: TodayRecordsCard(
              items: const [],
              imageDirectory: null,
              loading: loading,
              failureMessage: failureMessage,
              onRetry: () {},
              onCapture: () {},
              onItemTap: (_) {},
              onSeeAll: () {},
            ),
          ),
          scale: 1.0,
        );

    testWidgets('불러오는 중에는 예시를 그리지 않는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(card(loading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('ex)'), findsNothing);
    });

    testWidgets('실패는 이유와 다시 시도를 보여준다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(
          card(failureMessage: const NetworkFailure().message));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkFailure().message), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.text('ex)'), findsNothing);
    });

    testWidgets('정말 빈 날에는 예시와 촬영 안내가 뜬다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(card());
      await tester.pumpAndSettle();

      expect(find.text('ex)'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
