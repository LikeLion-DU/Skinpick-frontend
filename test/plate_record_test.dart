import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_analysis.dart';
import 'package:skinplate/features/skin_plate/domain/entities/plate_history.dart';
import 'package:skinplate/features/skin_plate/domain/entities/weekly_report.dart';
import 'package:skinplate/features/skin_plate/domain/entities/skin_plate.dart';
import 'package:skinplate/features/skin_plate/domain/repositories/plate_repository.dart';
import 'package:skinplate/features/skin_plate/presentation/providers/plate_notifier.dart';
import 'package:skinplate/shared/enums/cooking_method.dart';
import 'package:skinplate/shared/enums/plate_action_code.dart';

/// 분석은 임시고 기록은 명시적 선택이다. 이 파일은 그 경계가 무너지지 않는지만 본다.
///
/// 무너지는 방식은 둘이다 — 저장하지 않았는데 서버에 남거나(이탈), 저장 버튼이
/// 두 번 먹혀 같은 끼니가 두 줄이 되거나.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // saveRecord() 는 어느 테스트에서 불리든 로컬 이미지 저장을 탄다. 목킹을
  // '로컬 이미지' 그룹 안에만 두면, 그룹 밖 테스트들은 압축기가 먼저 던져서
  // 디렉터리를 물어보지 않는다는 우연에 기대게 된다.
  late Directory documents;

  setUp(() {
    documents = Directory.systemTemp.createTempSync('skinplate_documents');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => call.method == 'getApplicationDocumentsDirectory'
          ? documents.path
          : null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
    FlutterImageCompressPlatform.instance = UnsupportedFlutterImageCompress();
    documents.deleteSync(recursive: true);
  });

  const token = 'eyJhbGciOiJIUzI1NiJ9.analysis-token';

  PlateAnalysis analysisOf(String analysisToken) => PlateAnalysis(
        analysisToken: analysisToken,
        skinAnalysisId: 3,
        plateScore: 60,
        summary: '나트륨 과다',
        food: const FoodAnalysis(
          foodName: '돼지고기 김치찌개',
          foodCategory: '한식/찌개',
          cookingMethod: CookingMethod.boiled,
          spicy: true,
          ingredients: [],
          nutrition: Nutrition(
            caloriesKcal: 520,
            proteinG: 28.5,
            fatG: 24,
            carbG: 32,
            sodiumMg: 1850,
            sugarG: 6.2,
          ),
        ),
        good: const [],
        caution: const [],
        actions: const [],
        appliedRules: const ['R04'],
      );

  SkinPlate savedOf(int plateId) => SkinPlate(
        id: plateId,
        skinAnalysisId: 3,
        plateScore: 60,
        summary: '나트륨 과다',
        food: analysisOf(token).food,
        good: const [],
        caution: const [],
        actions: const [],
        appliedRules: const ['R04'],
        createdAt: DateTime(2026, 8, 14, 19, 45),
      );

  ({ProviderContainer container, PlateNotifier notifier, _FakeRepository repository})
      boot(_FakeRepository repository) {
    final container = ProviderContainer(
      overrides: [plateRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return (
      container: container,
      notifier: container.read(plateNotifierProvider.notifier),
      repository: repository,
    );
  }

  final image = XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'food.jpg');

  test('분석에 성공하면 READY 로 결과를 보여준다 — 아직 기록은 아니다', () async {
    final app = boot(_FakeRepository(analysis: Success(analysisOf(token))));

    await app.notifier.analyze(image);
    final state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.ready);
    expect(state.view, isNotNull);
    expect(state.view!.plateScore, 60);
    expect(state.isSaved, isFalse);
    expect(state.savedPlate, isNull);
    expect(app.repository.saveCalls, isEmpty);
  });

  test('저장하지 않고 나가면 record API 를 부르지 않는다', () async {
    final app = boot(_FakeRepository(analysis: Success(analysisOf(token))));

    await app.notifier.analyze(image);
    // 화면 pop · 백그라운드 · 앱 종료 — 앱이 하는 일이 없다.

    expect(app.repository.saveCalls, isEmpty);
  });

  test('저장하면 SAVED 가 되고 서버가 준 기록이 화면을 이긴다', () async {
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      save: Success(savedOf(7)),
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();
    final state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.saved);
    expect(state.savedPlate?.id, 7);
    expect(state.view, same(state.savedPlate));
    expect(app.repository.saveCalls, [token]); // 토큰 하나만 보낸다
  });

  test('SAVING 중 다시 눌러도 요청은 한 번만 나간다', () async {
    final gate = Completer<Result<SkinPlate>>();
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      saveGate: gate,
    ));

    await app.notifier.analyze(image);

    final first = app.notifier.saveRecord();
    expect(app.container.read(plateNotifierProvider).status,
        PlateRecordStatus.saving);

    await app.notifier.saveRecord(); // 중복 클릭
    await app.notifier.saveRecord();

    gate.complete(Success(savedOf(7)));
    await first;

    expect(app.repository.saveCalls, [token]);
  });

  test('SAVED 이후에는 다시 저장하지 않는다', () async {
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      save: Success(savedOf(7)),
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();
    await app.notifier.saveRecord();

    expect(app.repository.saveCalls, [token]);
    expect(app.container.read(plateNotifierProvider).status,
        PlateRecordStatus.saved);
  });

  test('네트워크 실패는 새 분석 없이 같은 토큰으로 재시도한다', () async {
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      saveQueue: [
        const FailureResult(NetworkFailure()),
        Success(savedOf(7)),
      ],
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();

    var state = app.container.read(plateNotifierProvider);
    expect(state.status, PlateRecordStatus.saveFailed);
    expect(state.canRetrySave, isTrue);
    expect(state.analysis, isNotNull); // 토큰을 버리지 않았다

    await app.notifier.saveRecord();
    state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.saved);
    expect(app.repository.saveCalls, [token, token]); // 같은 토큰
    expect(app.repository.analyzeCalls, 1); // AI 를 다시 부르지 않았다
  });

  test('타임아웃도 같은 토큰으로 재시도한다 — 저장 여부를 추측하지 않는다', () async {
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      saveQueue: [
        const FailureResult(AnalysisFailure('AI_TIMEOUT', '지연되고 있습니다.')),
        Success(savedOf(7)), // 서버에 이미 저장돼 있어도 같은 plateId 를 준다
      ],
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();
    expect(app.container.read(plateNotifierProvider).canRetrySave, isTrue);

    await app.notifier.saveRecord();

    expect(app.container.read(plateNotifierProvider).savedPlate?.id, 7);
    expect(app.repository.saveCalls, [token, token]);
  });

  test('만료는 재시도가 아니라 재촬영이다', () async {
    final app = boot(_FakeRepository(
      analysis: Success(analysisOf(token)),
      save: const FailureResult(
        AnalysisFailure('ANALYSIS_EXPIRED', '분석 결과가 만료됐어요. 다시 촬영해 주세요.'),
      ),
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();
    final state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.saveFailed);
    expect(state.canRetrySave, isFalse);
    expect((state.failure! as AnalysisFailure).shouldRetakePhoto, isTrue);
  });

  test('400·404 도 재시도 대상이 아니다 — 몇 번을 보내도 같은 답이다', () async {
    for (final code in ['INVALID_INPUT', 'SKIN_ANALYSIS_NOT_FOUND']) {
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: FailureResult(ServerFailure(code, '오류')),
      ));

      await app.notifier.analyze(image);
      await app.notifier.saveRecord();

      expect(app.container.read(plateNotifierProvider).canRetrySave, isFalse,
          reason: code);
    }
  });

  group('로컬 이미지', () {
    File savedImage(int plateId) => File('${documents.path}/plates/$plateId.jpg');

    Future<PlateState> saveWith(_FakeCompressor compressor) async {
      FlutterImageCompressPlatform.instance = compressor;
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: Success(savedOf(7)),
      ));

      await app.notifier.analyze(image);
      await app.notifier.saveRecord();
      return app.container.read(plateNotifierProvider);
    }

    test('저장에 성공하면 documents/plates 에 JPEG 로 남는다', () async {
      final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
      final state = await saveWith(_FakeCompressor((_) async => jpeg));

      expect(state.status, PlateRecordStatus.saved);
      // 파일명이 plateId 다. 히스토리가 이 규칙으로 찾아 읽는다.
      expect(savedImage(7).readAsBytesSync(), jpeg);
    });

    test('압축기가 빈 결과를 주면 실패로 보고 기록은 유지한다', () async {
      // 이 플러그인은 실패를 예외가 아니라 빈 리스트로 돌려줄 때가 있다.
      // 그대로 쓰면 0바이트 .jpg 가 남아 히스토리에 깨진 이미지가 뜬다.
      final state = await saveWith(_FakeCompressor((_) async => Uint8List(0)));

      expect(state.status, PlateRecordStatus.saved);
      expect(state.failure, isNull); // "저장 실패"라고 하지 않는다
      expect(savedImage(7).existsSync(), isFalse); // 히스토리는 음식 아이콘으로 떨어진다
    });

    test('압축기가 던져도 기록은 유지한다', () async {
      final state = await saveWith(
        _FakeCompressor((_) async => throw StateError('디스크 부족')),
      );

      expect(state.status, PlateRecordStatus.saved);
      expect(state.savedPlate?.id, 7);
      expect(state.failure, isNull);
      expect(savedImage(7).existsSync(), isFalse);
    });
  });

  test('저장 응답이 늦게 와도 그 사이 찍은 새 결과를 덮지 않는다', () async {
    final gate = Completer<Result<SkinPlate>>();
    final app = boot(_FakeRepository(
      analysisQueue: [Success(analysisOf(token)), Success(analysisOf('두-번째-토큰'))],
      saveGate: gate,
    ));

    await app.notifier.analyze(image);
    final pending = app.notifier.saveRecord(); // 응답이 붙잡혀 있다

    // 사용자가 뒤로 나가 다른 음식을 찍었다. 저장 타임아웃이 32초라 충분히 벌어진다.
    await app.notifier.analyze(image);

    gate.complete(Success(savedOf(7)));
    await pending;

    final state = app.container.read(plateNotifierProvider);
    expect(state.analysis?.analysisToken, '두-번째-토큰');
    expect(state.status, PlateRecordStatus.ready);
    // 이전 끼니가 "저장됐어요"로 새 화면을 차지하면 안 된다.
    expect(state.isSaved, isFalse);
  });

  test('이탈해도 201 이 온 기록의 사진은 남긴다', () async {
    final gate = Completer<Result<SkinPlate>>();
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
    FlutterImageCompressPlatform.instance = _FakeCompressor((_) async => jpeg);

    final app = boot(_FakeRepository(
      analysisQueue: [Success(analysisOf(token)), Success(analysisOf('두-번째-토큰'))],
      saveGate: gate,
    ));

    await app.notifier.analyze(image);
    final pending = app.notifier.saveRecord();
    await app.notifier.analyze(image); // 기다리다 나가서 새로 촬영

    gate.complete(Success(savedOf(7)));
    await pending;

    // 상태는 새 끼니 것이지만, 서버에 생긴 기록(7)의 사진은 디스크에 있어야 한다.
    // 여기서 건너뛰면 그 기록은 히스토리에서 영영 음식 아이콘이다.
    expect(app.container.read(plateNotifierProvider).isSaved, isFalse);
    expect(File('${documents.path}/plates/7.jpg').readAsBytesSync(), jpeg);
  });

  test('새 분석이 이전 임시 결과와 저장 상태를 덮어쓴다', () async {
    final app = boot(_FakeRepository(
      analysisQueue: [Success(analysisOf(token)), Success(analysisOf('두-번째-토큰'))],
      save: Success(savedOf(7)),
    ));

    await app.notifier.analyze(image);
    await app.notifier.saveRecord();
    expect(app.container.read(plateNotifierProvider).isSaved, isTrue);

    // reset() 을 부르는 곳이 없다. 다음 촬영이 유일한 정리 경로다.
    await app.notifier.analyze(image);
    final state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.ready);
    expect(state.isSaved, isFalse);
    expect(state.analysis?.analysisToken, '두-번째-토큰');
  });

  test('분석에 실패하면 결과 없음으로 떨어진다', () async {
    final app = boot(_FakeRepository(
      analysis: const FailureResult(
        AnalysisFailure('FOOD_NOT_DETECTED', '음식을 인식하지 못했습니다.'),
      ),
    ));

    await app.notifier.analyze(image);
    final state = app.container.read(plateNotifierProvider);

    expect(state.status, PlateRecordStatus.analyzing);
    expect(state.view, isNull);
    expect((state.failure! as AnalysisFailure).shouldRetakePhoto, isTrue);
  });

  group('시뮬레이션', () {
    const simulation = PlateSimulation(
      beforeScore: 60,
      afterScore: 72,
      appliedActions: [PlateActionCode.removeBatter, PlateActionCode.lessSpicy],
      removedRules: ['R02'],
      summary: '실행했을 때의 예상 점수입니다.',
    );

    test('저장 전에는 토큰으로 묻는다 — 저장을 강제하지 않는다', () async {
      final app = boot(_FakeRepository(analysis: Success(analysisOf(token)))
        ..simulateResult = const Success(simulation));

      await app.notifier.analyze(image);
      await app.notifier.simulate([PlateActionCode.removeBatter]);

      expect(app.repository.simulateCalls, ['token:$token']);
      expect(app.container.read(plateNotifierProvider).displayedScore, 72);
    });

    test('저장 후에는 plateId 로 묻는다 — 토큰은 30분이면 만료된다', () async {
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: Success(savedOf(7)),
      )..simulateResult = const Success(simulation));

      await app.notifier.analyze(image);
      await app.notifier.saveRecord();
      await app.notifier.simulate([PlateActionCode.removeBatter]);

      expect(app.repository.simulateCalls, ['plateId:7']);
    });

    test('시뮬레이션이 만료되면 삼키지 않고 재촬영으로 보낸다', () async {
      final app = boot(_FakeRepository(analysis: Success(analysisOf(token)))
        ..simulateResult = const FailureResult(
          AnalysisFailure('ANALYSIS_EXPIRED', '분석 결과가 만료됐어요. 다시 촬영해 주세요.'),
        ));

      await app.notifier.analyze(image);
      await app.notifier.simulate([PlateActionCode.removeBatter]);
      final state = app.container.read(plateNotifierProvider);

      // 토큰이 죽었으면 저장도 못 한다. 저장 실패와 같은 자리에 띄운다.
      expect(state.status, PlateRecordStatus.saveFailed);
      expect(state.canRetrySave, isFalse);
      expect((state.failure! as AnalysisFailure).shouldRetakePhoto, isTrue);
    });

    test('저장된 기록은 만료로 되돌리지 않는다 — 재촬영시키면 중복 기록이 된다', () async {
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: Success(savedOf(7)),
      )..simulateResult = const FailureResult(
          AnalysisFailure('ANALYSIS_EXPIRED', '분석 결과가 만료됐어요.'),
        ));

      await app.notifier.analyze(image);
      await app.notifier.saveRecord();
      await app.notifier.simulate([PlateActionCode.removeBatter]);
      final state = app.container.read(plateNotifierProvider);

      expect(state.status, PlateRecordStatus.saved);
      expect(state.isSaved, isTrue);
    });

    test('저장해도 시뮬레이션 결과가 유지된다', () async {
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: Success(savedOf(7)),
      )..simulateResult = const Success(simulation));

      await app.notifier.analyze(image);
      await app.notifier.simulate([PlateActionCode.removeBatter]);
      expect(app.container.read(plateNotifierProvider).displayedScore, 72);

      await app.notifier.saveRecord();
      final state = app.container.read(plateNotifierProvider);

      // 게이지가 72 에서 60 으로 떨어지면 액션 버튼은 "되돌리기" 인데 점수만 원복된다.
      expect(state.status, PlateRecordStatus.saved);
      expect(state.displayedScore, 72);
    });

    test('되돌린 뒤 늦게 온 응답이 점수를 되살리지 않는다', () async {
      final gate = Completer<Result<PlateSimulation>>();
      final app = boot(_FakeRepository(analysis: Success(analysisOf(token)))
        ..simulateGate = gate);

      await app.notifier.analyze(image);
      final pending = app.notifier.simulate([PlateActionCode.removeBatter]);

      app.notifier.clearSimulation(); // 사용자가 되돌렸다

      gate.complete(const Success(simulation));
      await pending;

      final state = app.container.read(plateNotifierProvider);
      expect(state.simulation, isNull);
      expect(state.displayedScore, 60); // 분석 점수 그대로
    });

    test('저장이 끝나는 사이 온 응답은 버리지 않는다 — 같은 끼니다', () async {
      final gate = Completer<Result<PlateSimulation>>();
      final app = boot(_FakeRepository(
        analysis: Success(analysisOf(token)),
        save: Success(savedOf(7)),
      )..simulateGate = gate);

      await app.notifier.analyze(image);
      final pending = app.notifier.simulate([PlateActionCode.removeBatter]);
      await app.notifier.saveRecord(); // 기다리는 사이 저장 완료

      gate.complete(const Success(simulation));
      await pending;

      final state = app.container.read(plateNotifierProvider);
      expect(state.isSaved, isTrue);
      expect(state.displayedScore, 72); // 저장됐다는 이유로 버리면 화면이 멈춘다
      expect(state.simulating, isFalse);
    });

    test('그 밖의 실패는 원래 점수를 그대로 둔다', () async {
      final app = boot(_FakeRepository(analysis: Success(analysisOf(token)))
        ..simulateResult = const FailureResult(NetworkFailure()));

      await app.notifier.analyze(image);
      await app.notifier.simulate([PlateActionCode.removeBatter]);
      final state = app.container.read(plateNotifierProvider);

      expect(state.status, PlateRecordStatus.ready); // 화면을 비우지 않는다
      expect(state.simulation, isNull);
      expect(state.displayedScore, 60); // 분석 점수 그대로
    });
  });
}

/// 네이티브 압축기는 유닛 테스트에서 돌지 않는다. 프로덕션 코드에 주입 구멍을
/// 내는 대신 플러그인이 이미 갖고 있는 플랫폼 인터페이스를 갈아끼운다 —
/// 유닛 테스트에서는 어차피 `UnsupportedFlutterImageCompress` 가 기본값이라
/// 채널을 목킹해도 거기까지 가지 않는다.
class _FakeCompressor extends UnsupportedFlutterImageCompress {
  _FakeCompressor(this._compress);

  final Future<Uint8List> Function(Uint8List) _compress;

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) {
    expect(format, CompressFormat.jpeg); // .jpg 라는 이름과 내용이 어긋나면 안 된다
    return _compress(image);
  }
}

/// 호출된 것만 기록한다. 이 파일이 검증하려는 것은 "몇 번, 무엇을 보냈나"다.
class _FakeRepository implements PlateRepository {
  _FakeRepository({
    Result<PlateAnalysis>? analysis,
    List<Result<PlateAnalysis>>? analysisQueue,
    Result<SkinPlate>? save,
    List<Result<SkinPlate>>? saveQueue,
    this.saveGate,
  })  : _analysisQueue = analysisQueue ?? (analysis == null ? [] : [analysis]),
        _saveQueue = saveQueue ?? (save == null ? [] : [save]);

  final List<Result<PlateAnalysis>> _analysisQueue;
  final List<Result<SkinPlate>> _saveQueue;

  /// 응답을 붙잡아 두고 SAVING 상태를 관찰할 때 쓴다.
  final Completer<Result<SkinPlate>>? saveGate;

  int analyzeCalls = 0;
  final List<String> saveCalls = [];

  @override
  Future<Result<PlateAnalysis>> analyze(Uint8List image, {int? skinAnalysisId}) async {
    analyzeCalls++;
    return _analysisQueue.length == 1
        ? _analysisQueue.first
        : _analysisQueue.removeAt(0);
  }

  @override
  Future<Result<SkinPlate>> saveRecord(String analysisToken) async {
    saveCalls.add(analysisToken);
    if (saveGate != null) return saveGate!.future;
    return _saveQueue.length == 1 ? _saveQueue.first : _saveQueue.removeAt(0);
  }

  /// 저장 전/후 어느 쪽으로 물었는지 기록한다 — 만료를 피하려면 저장 후에는
  /// 토큰이 아니라 plateId 로 가야 한다.
  final List<String> simulateCalls = [];

  Result<PlateSimulation>? simulateResult;

  /// 응답을 붙잡아 두고 그 사이 사용자가 조작하는 상황을 만든다.
  Completer<Result<PlateSimulation>>? simulateGate;

  @override
  Future<Result<PlateSimulation>> simulateAnalysis(
      String analysisToken, List<PlateActionCode> actions) async {
    simulateCalls.add('token:$analysisToken');
    if (simulateGate != null) return simulateGate!.future;
    return simulateResult ?? (throw UnimplementedError());
  }

  @override
  Future<Result<PlateSimulation>> simulate(
      int plateId, List<PlateActionCode> actions) async {
    simulateCalls.add('plateId:$plateId');
    if (simulateGate != null) return simulateGate!.future;
    return simulateResult ?? (throw UnimplementedError());
  }

  @override
  Future<Result<SkinPlate>> getById(int id) => throw UnimplementedError();

  @override
  Future<Result<void>> deleteRecord(int plateId) => throw UnimplementedError();

  @override
  Future<Result<List<PlateHistoryDay>>> history(DateTime from, DateTime to) =>
      throw UnimplementedError();

  @override
  Future<Result<WeeklyReport>> weeklyReport() => throw UnimplementedError();
}
