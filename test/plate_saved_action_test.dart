import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
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

  /// **찾았다고 보이는 게 아니다.** 결과 화면은 ListView 인데 `cacheExtent` 가
  /// 화면 밖 항목도 250px 까지 미리 만들어서, `find` 는 뷰포트를 벗어난 위젯도
  /// 그대로 찾아낸다. 실제로 근거 카드가 붙으면서 저장 버튼이 화면 밖으로 밀렸는데
  /// 테스트는 통과하고 있었다. 그래서 좌표로 잰다.
  void expectVisible(WidgetTester tester, Finder finder, String label) {
    final rect = tester.getRect(finder);
    expect(rect.height, greaterThan(0), reason: '$label 이 높이 0 이다');
    expect(rect.bottom, lessThanOrEqualTo(designSize.height),
        reason: '$label 이 화면 아래로 잘렸다 (bottom=${rect.bottom})');
    expect(rect.top, greaterThanOrEqualTo(0.0), reason: '$label 이 위로 잘렸다');
  }

  testWidgets('저장되면 홈과 기록으로 갈 길이 화면 안에 열린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      PlateState(savedPlate: plate, status: PlateRecordStatus.saved),
    ));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 기록에 저장됐어요'), findsOneWidget);
    expectVisible(tester, find.widgetWithText(ElevatedButton, '홈으로'), '홈으로');
    expectVisible(
        tester, find.widgetWithText(TextButton, '기록 보러 가기'), '기록 보러 가기');
  });

  testWidgets('저장 버튼은 스크롤하지 않아도 화면 안에 있다', (tester) async {
    // 이 화면의 존재 이유가 기록 확정이다. 주 동작이 스크롤 아래에 숨으면
    // 사용자는 분석만 보고 저장하지 않은 채 나간다.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      PlateState(savedPlate: plate, status: PlateRecordStatus.ready),
    ));
    await tester.pumpAndSettle();

    expectVisible(tester, find.widgetWithText(ElevatedButton, '기록에 저장하기'),
        '기록에 저장하기');
    expect(find.text('홈으로'), findsNothing);
  });
}

class _StubPlate extends PlateNotifier {
  _StubPlate(this._state);

  final PlateState _state;

  @override
  PlateState build() => _state;
}
