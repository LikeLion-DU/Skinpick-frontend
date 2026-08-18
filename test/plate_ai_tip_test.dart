import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_analysis.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_detail_page.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_result_page.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_notifier.dart';

/// **"AI 맞춤 TIP" 은 AI 가 만든 문장일 때만 뜬다.**
///
/// 서버는 저장할 때 한 번 AI 문장을 만든다. `POST /plates/analyze` 응답에는 그
/// 필드가 아예 없다. 앱이 그 자리를 룰 요약(summary)으로 메우고 있어서, 저장을
/// 누르면 같은 카드의 문장이 다른 문장으로 갈렸다 — 2026-08-18 실기기 QA 에서
/// 오작동으로 신고됐다.
///
/// 위젯 단위로는 안 잡힌다. [PlateTipCard] 는 받은 문자열을 그릴 뿐이고, 무엇을
/// 넘길지 고르는 것이 화면이다. 그래서 여기서 잡는 것은 **배선**이다.
void main() {
  const designSize = Size(402, 874);

  Map<String, dynamic> data(String name) =>
      (jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  /// 저장 전. `plate_analyze` 는 aiTip 키가 없는 실제 analyze 응답이다.
  PlateAnalysis analysis() =>
      PlateAnalysisDto.fromJson(data('plate_analyze')).toEntity();

  /// 저장 후. `plate_record` 에는 서버가 만든 AI 문장이 들어 있다.
  SkinPlate savedWithTip() =>
      SkinPlateDto.fromJson(data('plate_record')).toEntity();

  /// 저장은 됐지만 AI 문장 생성이 실패한 기록. 서버가 키를 통째로 뺀다.
  SkinPlate savedWithoutTip() {
    final json = Map<String, dynamic>.from(data('plate_record'))
      ..remove('aiTip');
    return SkinPlateDto.fromJson(json).toEntity();
  }

  Widget resultPage(PlateState state) => ProviderScope(
        overrides: [plateNotifierProvider.overrideWith(() => _StubPlate(state))],
        child: MaterialApp(theme: AppTheme.light, home: const PlateResultPage()),
      );

  Widget detailPage(SkinPlate plate) => ProviderScope(
        overrides: [
          plateDetailProvider(plate.id).overrideWith(
            (ref) => Future<Result<SkinPlate>>.value(Success(plate)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PlateDetailPage(plateId: plate.id),
        ),
      );

  testWidgets('저장 전 — AI TIP 카드를 그리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = analysis();

    await tester.pumpWidget(resultPage(
      PlateState(analysis: plate, status: PlateRecordStatus.ready),
    ));
    await tester.pumpAndSettle();

    expect(find.text('AI 맞춤 TIP'), findsNothing);

    // 룰 요약이 그 자리를 대신 채우지 않는다. 이게 이 테스트의 핵심이다 —
    // 카드만 숨기고 summary 를 다른 데로 흘리면 같은 문제가 이름만 바꿔 남는다.
    expect(plate.summary, isNotEmpty, reason: '픽스처 전제 — 룰 요약은 있다');
    expect(find.text(plate.summary), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('저장 후 — 서버가 만든 AI 문장만 뜬다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedWithTip();

    await tester.pumpWidget(resultPage(
      PlateState(savedPlate: plate, status: PlateRecordStatus.saved),
    ));
    await tester.pumpAndSettle();

    expect(find.text('AI 맞춤 TIP'), findsOneWidget);
    expect(find.text(plate.aiTip!), findsOneWidget);

    // 룰 요약은 여전히 응답에 있지만 이 카드에 오르지 않는다.
    expect(find.text(plate.summary), findsNothing);
  });

  testWidgets('저장 후 — AI 생성이 실패한 기록은 카드가 없다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedWithoutTip();

    await tester.pumpWidget(resultPage(
      PlateState(savedPlate: plate, status: PlateRecordStatus.saved),
    ));
    await tester.pumpAndSettle();

    expect(plate.aiTip, isNull, reason: '픽스처 전제 — aiTip 키를 지웠다');
    expect(find.text('AI 맞춤 TIP'), findsNothing);
    expect(find.text(plate.summary), findsNothing);
    expect(tester.takeException(), isNull);
  });

  /// 저장 버튼을 누른 전후를 **한 화면에서** 이어서 본다. 이 기능이 고치려던
  /// 것은 정적인 두 상태가 아니라 그 사이의 전환이다 — 읽고 있던 문장이 다른
  /// 문장으로 갈아치워지는 순간.
  ///
  /// 화면을 새로 pump 해서 흉내 내면 안 된다. 같은 `ProviderScope` 를 다시
  /// pump 하면 Riverpod 이 기존 notifier 를 그대로 두어서 상태가 안 바뀌고,
  /// 테스트는 저장 전 화면을 저장 후라고 착각한 채 통과하거나 실패한다.
  testWidgets('저장 전에 읽던 문장이 저장 후에 다른 문장으로 갈아치워지지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final before = analysis();
    final after = savedWithTip();

    await tester.pumpWidget(resultPage(
      PlateState(analysis: before, status: PlateRecordStatus.ready),
    ));
    await tester.pumpAndSettle();

    expect(find.text('AI 맞춤 TIP'), findsNothing);
    expect(find.text(before.summary), findsNothing);

    // 저장 성공 — 같은 화면, 같은 notifier 의 상태만 바뀐다.
    final container = ProviderScope.containerOf(
        tester.element(find.byType(PlateResultPage)));
    (container.read(plateNotifierProvider.notifier) as _StubPlate).emit(
      PlateState(savedPlate: after, status: PlateRecordStatus.saved),
    );
    await tester.pumpAndSettle();

    // 없던 카드가 생긴다. 있던 문장이 바뀌는 것과 다르다.
    expect(find.text('AI 맞춤 TIP'), findsOneWidget);
    expect(find.text(after.aiTip!), findsOneWidget);

    // 저장 전에 그 자리에 있던 문장이 애초에 없었다는 것까지 못 박는다.
    expect(after.aiTip, isNot(before.summary));
    expect(find.text(before.summary), findsNothing);
  });

  testWidgets('기록 상세 — aiTip 이 없으면 룰 요약으로 메우지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedWithoutTip();

    await tester.pumpWidget(detailPage(plate));
    await tester.pumpAndSettle();

    expect(find.text('AI 맞춤 TIP'), findsNothing);
    expect(find.text(plate.summary), findsNothing);
  });

  testWidgets('기록 상세 — aiTip 이 있으면 그대로 뜬다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedWithTip();

    await tester.pumpWidget(detailPage(plate));
    await tester.pumpAndSettle();

    expect(find.text('AI 맞춤 TIP'), findsOneWidget);
    expect(find.text(plate.aiTip!), findsOneWidget);
  });
}

class _StubPlate extends PlateNotifier {
  _StubPlate(this._initial);

  final PlateState _initial;

  @override
  PlateState build() => _initial;

  /// 저장 성공처럼 상태만 갈아 끼운다. 화면을 다시 pump 하는 것과 다르다 —
  /// 그쪽은 notifier 가 재생성되지 않아 상태가 그대로 남는다.
  void emit(PlateState next) => state = next;
}
