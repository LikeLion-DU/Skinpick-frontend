import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_colors.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_insight.dart';
import 'package:skinplate/shared/enums/metric_band.dart';
import 'package:skinplate/shared/widgets/metric_bar.dart';

/// 결과(S05)와 인사이트(S10)가 같이 쓰는 막대라, 한쪽에서 고친 것이 다른 쪽을
/// 깨는 자리다. 조용히 어긋날 수 있는 성질만 고정한다.
void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Center(child: child)),
      );

  LinearProgressIndicator barOf(WidgetTester tester) =>
      tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));

  testWidgets('막대 길이는 0~1 을 벗어나지 않는다', (tester) async {
    // 서버가 범위를 벗어난 값을 보내도 그리기가 죽으면 안 된다.
    // LinearProgressIndicator 는 1 을 넘는 value 에 assert 를 던진다.
    for (final (value, expected) in [(130, 1.0), (-5, 0.0), (52, 0.52)]) {
      await tester.pumpWidget(host(MetricBar(
        label: '유분',
        value: value,
        color: AppColors.metricBarOil,
        band: null,
      )));
      expect(barOf(tester).value, expected, reason: 'value=$value');
    }
  });

  testWidgets('변화량이 없으면 칸 자체를 만들지 않는다', (tester) async {
    // 0 을 그리면 "변화 없음"과 "비교할 분석이 없음"이 화면에서 같은 말이 된다.
    await tester.pumpWidget(host(const MetricBar(
      label: '수분',
      value: 40,
      color: AppColors.metricBarHydration,
      band: null,
    )));
    expect(find.textContaining('0'), findsWidgets); // 눈금(0·50·100)은 있다
    expect(find.text('+0'), findsNothing);

    await tester.pumpWidget(host(const MetricBar(
      label: '수분',
      value: 40,
      color: AppColors.metricBarHydration,
      band: null,
      delta: 7,
    )));
    // 부호를 그대로 보여준다 — 좋아졌다/나빠졌다는 앱이 말하지 않는다.
    expect(find.text('+7'), findsOneWidget);

    await tester.pumpWidget(host(const MetricBar(
      label: '수분',
      value: 40,
      color: AppColors.metricBarHydration,
      band: null,
      delta: -3,
    )));
    expect(find.text('-3'), findsOneWidget);
  });

  testWidgets('등급을 모르면 상태어 자리를 비운다', (tester) async {
    await tester.pumpWidget(host(const MetricBar(
      label: '홍조',
      value: 60,
      color: AppColors.metricBarRedness,
      band: null,
    )));
    expect(find.text('주의'), findsNothing);

    await tester.pumpWidget(host(const MetricBar(
      label: '홍조',
      value: 60,
      color: AppColors.metricBarRedness,
      band: MetricBand('주의', AppColors.bad),
    )));
    expect(find.text('주의'), findsOneWidget);
  });

  testWidgets('한 줄이 스크린리더에 한 덩이로 읽힌다', (tester) async {
    // 안 묶으면 이름·상태어·막대·변화량이 네 번에 나뉘어 읽히고, '-7' 이 어느
    // 지표 것인지 알 수 없는 채로 따로 떨어진다.
    // addTearDown 은 테스트 종료 검사보다 늦게 돌아서 핸들이 남았다고 잡힌다.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(host(const MetricBar(
      label: '수분',
      value: 38,
      color: AppColors.metricBarHydration,
      band: MetricBand('부족', AppColors.metricLow),
      delta: -7,
    )));

    final node = tester.getSemantics(find.byType(MetricBar));
    expect(node.label, contains('수분'));
    expect(node.label, contains('부족'));
    // 화면에서 걷어낸 숫자는 여기로 간다.
    expect(node.value, contains('38'));
    expect(node.label, contains('직전 분석 대비 -7'));

    handle.dispose();
  });

  testWidgets('글자를 키워도 알약 밖으로 넘치지 않는다', (tester) async {
    // 시안 높이(49)를 그대로 박으면 2.0 에서 이름·판정이 알약을 뚫는다.
    // minHeight 로만 잡혀 있어야 한다.
    await tester.binding.setSurfaceSize(const Size(402, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(
          body: Center(
            child: MetricBar(
              label: '트러블',
              value: 25,
              color: AppColors.metricBarTrouble,
              band: MetricBand('좋음', AppColors.good),
              delta: -12,
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  test('변화량 칸이 지표마다 들쭉날쭉해지지 않는다', () {
    // 변화량 칸은 delta 가 null 이면 사라진다. 한 화면 안에서 어떤 줄만
    // 사라지면 그 줄의 막대와 눈금이 40px 어긋난다 — 지금은 안 그렇지만,
    // toBars() 에 지표를 하나 더 넣고 byKey 에 안 넣으면 그 순간 그렇게 된다.
    const metrics = SkinMetrics(
        hydration: 38, oil: 52, redness: 64, trouble: 25, barrier: 78);
    const changes = SkinInsightChanges(
        hydration: 1, oil: 2, redness: 3, trouble: 4, barrier: 5, skinScore: 6);

    for (final bar in metrics.toBars()) {
      expect(changes.byKey(bar.key), isNotNull,
          reason: '${bar.key} 가 SkinInsightChanges.byKey 에 없다');
    }
  });
}
