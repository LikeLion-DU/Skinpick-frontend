import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/widgets/app_widgets.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_result_page.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_notifier.dart';

/// 저장이 끝난 뒤 사용자가 나갈 곳이 있어야 한다.
///
/// 예전에는 "오늘의 기록에 저장됐어요" 한 줄만 남아서, 방금 만든 기록을 보러 갈
/// 수도 없고 뒤로가기 말고는 화면을 벗어날 방법이 없었다.
void main() {
  const designSize = Size(402, 874);

  Widget host(PlateState state) => ProviderScope(
        overrides: [
          plateNotifierProvider.overrideWith(() => _StubPlate(state)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PlateResultPage(),
        ),
      );

  final body = jsonDecode(File('test/fixtures/plate.json').readAsStringSync())
      as Map<String, dynamic>;
  final plate =
      SkinPlateDto.fromJson(body['data'] as Map<String, dynamic>).toEntity();

  /// 결과 화면은 ListView 라 화면 밖 항목을 만들지 않는다. 저장 영역은 맨 아래라
  /// [FeatureFlags] 로 카드가 하나만 늘어도 뷰포트를 벗어나고, 그러면 찾지 못한 것이
  /// "버튼이 없다"로 보인다. 플래그 상태와 무관하게 보려면 끝까지 내려야 한다.
  Future<void> scrollToBottom(WidgetTester tester) async {
    await tester.dragUntilVisible(
      find.byType(SafetyNotice),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('저장되면 홈과 기록으로 갈 길이 열린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      PlateState(savedPlate: plate, status: PlateRecordStatus.saved),
    ));
    await tester.pumpAndSettle();
    await scrollToBottom(tester);

    expect(find.text('오늘의 기록에 저장됐어요'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '홈으로'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '기록 보러 가기'), findsOneWidget);
  });

  testWidgets('저장 전에는 저장 버튼만 있다 — 나갈 길을 먼저 보여주지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      PlateState(savedPlate: plate, status: PlateRecordStatus.ready),
    ));
    await tester.pumpAndSettle();
    await scrollToBottom(tester);

    expect(find.widgetWithText(ElevatedButton, '기록에 저장하기'), findsOneWidget);
    expect(find.text('홈으로'), findsNothing);
  });
}

class _StubPlate extends PlateNotifier {
  _StubPlate(this._state);

  final PlateState _state;

  @override
  PlateState build() => _state;
}
