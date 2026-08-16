import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_analysis.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_history.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/domain/repositories/plate_repository.dart';
import 'package:skinplate/features/skin_plate/presentation/pages/plate_history_page.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_history_provider.dart';
import 'package:skinplate/shared/enums/meal_type.dart';
import 'package:skinplate/shared/enums/plate_action_code.dart';

/// 기록 삭제는 되돌릴 수 없다 — 서버 기록도 기기 사진도 사라진다.
/// 그래서 확인 창을 반드시 지나야 하고, 취소하면 아무 일도 없어야 한다.
void main() {
  const designSize = Size(402, 874);

  final day = PlateHistoryDay(
    date: DateTime.now(),
    skinScore: 70,
    plateScore: 81,
    targetScore: 80,
    plates: [
      PlateHistoryItem(
        plateId: 7,
        foodName: '소시지 플래터',
        plateScore: 81,
        mealType: MealType.dinner,
        recordedAt: DateTime.now(),
      ),
    ],
  );

  Widget host(_FakeRepository repository) => ProviderScope(
        overrides: [
          plateRepositoryProvider.overrideWithValue(repository),
          plateHistoryProvider.overrideWith((ref) async => Success([day])),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PlateHistoryPage(),
        ),
      );

  testWidgets('× 를 눌러도 바로 지우지 않고 먼저 묻는다', (tester) async {
    final repository = _FakeRepository();
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('기록 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('이 기록을 지울까요?'), findsOneWidget);
    expect(find.textContaining('되돌릴 수 없어요'), findsOneWidget);
    expect(repository.deleted, isEmpty, reason: '묻기 전에 지우면 안 된다');
  });

  testWidgets('취소하면 아무 일도 없다', (tester) async {
    final repository = _FakeRepository();
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('기록 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(repository.deleted, isEmpty);
    expect(find.text('소시지 플래터'), findsOneWidget);
  });

  testWidgets('삭제를 고르면 그 기록의 id 로 지운다', (tester) async {
    final repository = _FakeRepository();
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('기록 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.deleted, [7]);
  });

  testWidgets('실패하면 서버 문구를 그대로 보여준다', (tester) async {
    final repository = _FakeRepository(
        result: const FailureResult(ServerFailure('X', '지우지 못했어요')));
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('기록 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('지우지 못했어요'), findsOneWidget);
  });
}

class _FakeRepository implements PlateRepository {
  _FakeRepository({this.result = const Success<void>(null)});

  final Result<void> result;
  final List<int> deleted = <int>[];

  @override
  Future<Result<void>> deleteRecord(int plateId) async {
    if (result is Success) deleted.add(plateId);
    return result;
  }

  @override
  Future<Result<PlateAnalysis>> analyze(image, {int? skinAnalysisId}) =>
      throw UnimplementedError();
  @override
  Future<Result<SkinPlate>> saveRecord(String analysisToken) =>
      throw UnimplementedError();
  @override
  Future<Result<SkinPlate>> getById(int id) => throw UnimplementedError();
  @override
  Future<Result<List<PlateHistoryDay>>> history(DateTime from, DateTime to) =>
      throw UnimplementedError();
  @override
  Future<Result<PlateSimulation>> simulateAnalysis(
          String analysisToken, List<PlateActionCode> actions) =>
      throw UnimplementedError();
  @override
  Future<Result<PlateSimulation>> simulate(
          int plateId, List<PlateActionCode> actions) =>
      throw UnimplementedError();
}
