import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skinplate/app/router/app_router.dart';
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
import 'package:skinplate/shared/widgets/app_bottom_nav.dart';
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

  testWidgets('기록 화면이 스택의 유일한 페이지여도 홈으로 나갈 수 있다', (tester) async {
    // 저장 후 [기록 보러 가기] 는 go 로 온다 — 그러면 pop 할 것이 없다.
    // 홈 탭이 pop 만 하면 go_router 가 "There is nothing to pop" 을 던지고
    // 화면은 그대로다. 촬영 버튼 말고는 나갈 문이 없어진다.
    final router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(path: Routes.home, builder: (_, __) => const Text('홈')),
        GoRoute(
            path: Routes.plateHistory,
            builder: (_, __) => const PlateHistoryPage()),
        GoRoute(path: Routes.foodCapture, builder: (_, __) => const Text('촬영')),
      ],
    );

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        plateRepositoryProvider.overrideWithValue(_FakeRepository()),
        plateHistoryProvider.overrideWith((ref) async => Success([day])),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    router.go(Routes.plateHistory);
    await tester.pumpAndSettle();
    expect(find.text('오늘의 기록'), findsOneWidget);

    // 하단 홈 탭의 콜백을 그대로 부른다. 아이콘 좌표를 찍으면 시안이 바뀔 때마다
    // 테스트가 흔들리는데, 여기서 보려는 것은 그 콜백이 어디로 보내느냐다.
    tester.widget<AppBottomNav>(find.byType(AppBottomNav)).onTabSelected(AppTab.home);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'pop 할 것이 없는데 pop 하면 GoError 가 난다');
    expect(router.routerDelegate.currentConfiguration.uri.path, Routes.home);
  });

  testWidgets('삭제가 끝나면 카드가 목록에서 사라진다', (tester) async {
    // 목록을 다시 받기 전에 버튼을 풀면, 갱신 중 옛 목록이 그대로 그려지는 동안
    // 지워진 카드가 또 눌린다 — 상세는 404, × 는 "지우지 못했어요" 가 뜬다.
    final repository = _FakeRepository();
    var served = 0;

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        plateRepositoryProvider.overrideWithValue(repository),
        // 두 번째 조회부터는 지워진 뒤의 목록을 준다.
        plateHistoryProvider.overrideWith((ref) async {
          served++;
          return Success(served == 1 ? [day] : <PlateHistoryDay>[]);
        }),
      ],
      child: const MaterialApp(home: PlateHistoryPage()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('기록 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.deleted, [7]);
    expect(find.text('소시지 플래터'), findsNothing);
    expect(find.byTooltip('기록 삭제'), findsNothing);
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
