import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/shared/widgets/pill.dart';

/// 알약 공용 위젯이 지키는 세 가지를 고정한다.
///
/// 이 위젯은 모양을 통일하려고 만든 게 아니라 **틀리기 쉬운 골격**을 한곳에 모은
/// 것이다. 그래서 색·반경 같은 것은 여기서 검사하지 않는다 — 자리마다 다르고
/// 호출부가 정하는 값이다. 여기서 잡는 것은 바꿨을 때 조용히 깨지는 것들이다.
void main() {
  const designWidth = 402.0;
  const designSize = Size(designWidth, 874);

  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views.first;
    view.physicalSize = designSize;
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  /// **실제 배치인 [Wrap] 안에 넣는다.** 알약을 화면 본문에 통째로 놓으면 세로가
  /// 늘어나는데, 그건 이 위젯이 아니라 [Center] 가 `heightFactor` 없이 bounded
  /// 제약을 받을 때의 성질이다 — 추출 전 `Container` 도 똑같았다. 여기에
  /// `heightFactor: 1` 을 더하면 그건 시각 변경이라 하지 않았다.
  Widget host(Widget child, {double scale = 1.0}) => MediaQuery(
        data: MediaQueryData(
          size: designSize,
          textScaler: TextScaler.linear(scale),
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Wrap(spacing: 8, runSpacing: 8, children: [child]),
          ),
        ),
      );

  Pill pill(String label, {double minHeight = 22}) => Pill(
        label: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        minHeight: minHeight,
        horizontalPadding: 14,
        borderRadius: 11,
        color: const Color(0xFFEEEEEE),
      );

  testWidgets('Wrap 안에서 한 칸이 줄 전체를 먹지 않는다', (tester) async {
    // 과거 버그: Container(alignment:) 로 가운데 정렬하면 Container 가 부모 폭을
    // 전부 차지해 칩 하나가 한 줄을 통째로 쓴다. 예외가 안 나서 오버플로만 보는
    // 테스트로는 안 잡혔다. Center(widthFactor: 1) 이 그것을 막는다.
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: designSize),
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Wrap(spacing: 8, runSpacing: 8, children: [
            pill('나트륨'),
            pill('당류'),
            pill('단백질'),
          ]),
        ),
      ),
    ));

    final widths = tester
        .widgetList<Pill>(find.byType(Pill))
        .map((p) => tester.getSize(find.byWidget(p)).width)
        .toList();

    for (final width in widths) {
      expect(width, lessThan(designWidth / 2),
          reason: '칩 하나가 줄을 먹고 있다 (폭 $width / 화면 $designWidth)');
    }

    // 셋이 한 줄에 들어가야 한다 — 같은 y 좌표.
    final tops = tester
        .widgetList<Pill>(find.byType(Pill))
        .map((p) => tester.getTopLeft(find.byWidget(p)).dy)
        .toSet();
    expect(tops, hasLength(1), reason: '칩 세 개가 서로 다른 줄로 밀렸다');
  });

  testWidgets('글자 크기 2.0 에서 글자를 자르지 않는다', (tester) async {
    // 시안 높이를 height 로 박으면 배율이 커질 때 상자가 글자를 자르는데,
    // 이것도 예외가 나지 않는다. minHeight 로만 주는 이유다.
    await tester.pumpWidget(host(pill('발효식품 포함'), scale: 2.0));

    final box = tester.renderObject<RenderBox>(find.byType(Pill));
    final text = tester.renderObject<RenderBox>(find.text('발효식품 포함'));

    expect(box.size.height, greaterThanOrEqualTo(text.size.height),
        reason: '알약이 글자보다 낮다 (알약 ${box.size} / 글자 ${text.size})');
    expect(box.size.height, greaterThan(22),
        reason: '배율 2.0 인데 minHeight 에 그대로 묶여 있다');
  });

  testWidgets('minHeight 는 최소값이지 고정값이 아니다', (tester) async {
    await tester.pumpWidget(host(pill('가', minHeight: 40)));

    expect(tester.getSize(find.byType(Pill)).height, 40);
  });

  testWidgets('minWidth 를 준 자리는 짧은 글자에서도 그 폭을 지킨다', (tester) async {
    // GOOD/BAD 배지가 쓰는 규약. 폭을 고정하는 게 아니라 최소값으로만 쓴다.
    await tester.pumpWidget(host(const Pill(
      label: 'A',
      style: TextStyle(fontSize: 10),
      minWidth: 53,
      minHeight: 19,
      horizontalPadding: 6,
      borderRadius: 12.5,
      color: Color(0xFFFF6B35),
    )));

    expect(tester.getSize(find.byType(Pill)).width, 53);
  });

  testWidgets('긴 글자는 minWidth 를 넘겨 늘어난다 — 잘리지 않는다', (tester) async {
    await tester.pumpWidget(host(const Pill(
      label: '아주 긴 라벨입니다',
      style: TextStyle(fontSize: 10),
      minWidth: 53,
      minHeight: 19,
      horizontalPadding: 6,
      borderRadius: 12.5,
      color: Color(0xFFFF6B35),
    )));

    expect(tester.getSize(find.byType(Pill)).width, greaterThan(53));
  });
  testWidgets('세로 패딩은 기본 2 다 — 같은 줄 칩들의 높이가 이 값으로 맞는다', (tester) async {
    // 세 번째 규칙이다. 한곳에 모으면서 blast radius 가 열두 곳으로 늘었으니
    // 값 자체를 못 박는다 — 4 로 바꾸면 모든 알약이 조용히 4px 자란다.
    await tester.pumpWidget(host(
      // 최소 높이를 0 으로 두면 높이는 글자 + 위아래 패딩으로만 정해진다.
      const Pill(
        label: '가',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        minHeight: 0,
        horizontalPadding: 14,
        borderRadius: 11,
      ),
    ));

    final pillHeight = tester.getSize(find.byType(Pill)).height;
    final textHeight = tester.getSize(find.text('가')).height;
    expect(pillHeight - textHeight, 4, reason: '위아래 2 씩');
  });

  testWidgets('세로 패딩이 필요한 자리는 값을 바꿀 수 있다', (tester) async {
    // 끼니 배지(3) · 음식명 칩(5) · 갭 칩(6) 이 그런 자리다. 닫아 두면 그 칩들이
    // 이 위젯을 못 쓰고 규칙이 다른 곳에 남는다.
    await tester.pumpWidget(host(
      const Pill(
        label: '가',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        minHeight: 0,
        horizontalPadding: 14,
        borderRadius: 11,
        verticalPadding: 5,
      ),
    ));

    final pillHeight = tester.getSize(find.byType(Pill)).height;
    final textHeight = tester.getSize(find.text('가')).height;
    expect(pillHeight - textHeight, 10);
  });

  testWidgets('폭이 고정된 자리는 글자를 자르지 않고 줄임표로 접는다', (tester) async {
    // 단계 탭처럼 3열로 나뉜 칸이다. 예전에는 height 를 박아 두어서 배율 2.0 에서
    // 글자가 위아래로 잘렸다 — 예외가 없어 테스트도 통과했다.
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(
        size: designSize,
        textScaler: TextScaler.linear(2.0),
      ),
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Pill(
                  label: '주요 피부 고민',
                  style: TextStyle(fontSize: 14),
                  minHeight: 36,
                  horizontalPadding: 8,
                  borderRadius: 16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ));

    final text = tester.renderObject<RenderBox>(find.text('주요 피부 고민'));
    final needed = text.getDryLayout(const BoxConstraints());
    // 세로는 자르지 않는다. 가로는 줄임표로 접히므로 폭은 좁아도 된다.
    expect(text.size.height, greaterThanOrEqualTo(needed.height));
  });

}
