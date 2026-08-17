import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/skin_plate/data/models/plate_dtos.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_detail_page.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_result_page.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_notifier.dart';

/// **같은 `skinBasis: TODAY` 가 두 화면에서 다른 문구여야 한다.**
///
/// 서버는 저장된 기록의 기준을 **저장한 날**로 굳혀서 준다. 그래서 8/15 에 남긴
/// 기록을 8/17 에 열어도 `TODAY` 가 오는데, 거기에 "오늘 피부 상태 기준" 이라고
/// 쓰면 거짓말이 된다. 이 기능이 막으려던 버그가 정확히 그것이다.
///
/// [SkinBasisLine] 위젯 자체는 `plate_widgets_test.dart` 가 검증한다. 여기서 잡는
/// 것은 **배선**이다 — 두 화면의 `pastRecord` 를 서로 바꿔 놓아도 위젯 테스트는
/// 전부 초록이라, 그 버그가 아무 증상 없이 들어온다.
void main() {
  const designSize = Size(402, 874);

  /// 저장된 기록 fixture 에 `skinBasis` 만 얹는다. `plate.json` 은 이 필드가
  /// 생기기 전(2026-08-14) 채취분이라 키가 없다 — 구 응답 회귀는 그대로 두고,
  /// 여기서만 신규 필드를 더해 두 화면의 문구를 가른다.
  SkinPlate savedPlateWithBasis() {
    final body = jsonDecode(File('test/fixtures/plate.json').readAsStringSync())
        as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(body['data'] as Map<String, dynamic>)
      ..['skinBasis'] = 'TODAY'
      ..['skinMeasuredAt'] = '2026-08-15';

    return SkinPlateDto.fromJson(data).toEntity();
  }

  testWidgets('분석 결과 화면 — 방금 찍은 것이므로 "오늘"이다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedPlateWithBasis();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        plateNotifierProvider.overrideWith(
          () => _StubPlate(PlateState(
            savedPlate: plate,
            status: PlateRecordStatus.saved,
          )),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const PlateResultPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('오늘 피부 상태 기준'), findsOneWidget);
    expect(find.text('기록 당일 피부 상태 기준'), findsNothing);
  });

  testWidgets('저장된 기록 상세 — 나중에 여는 것이므로 "기록 당일"이다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    final plate = savedPlateWithBasis();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        plateDetailProvider(plate.id).overrideWith(
          (ref) => Future<Result<SkinPlate>>.value(Success(plate)),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: PlateDetailPage(plateId: plate.id),
      ),
    ));
    await tester.pumpAndSettle();

    // 두 화면이 같은 값에서 갈리는지가 이 테스트의 전부다. 여기서 "오늘" 이 나오면
    // 과거 기록을 열 때마다 화면이 없는 사실을 말하게 된다.
    expect(find.text('기록 당일 피부 상태 기준'), findsOneWidget);
    expect(find.text('오늘 피부 상태 기준'), findsNothing);
  });
}

class _StubPlate extends PlateNotifier {
  _StubPlate(this._state);

  final PlateState _state;

  @override
  PlateState build() => _state;
}
