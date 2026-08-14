import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../domain/entities/plate_analysis.dart';
import '../../domain/entities/skin_plate.dart';

/// 기록의 수명주기. **분석 결과가 아니라 "기록으로 확정됐는가"** 를 나타낸다.
///
/// [analyzing] 은 "아직 결과가 없다"는 뜻이다. [PlateState.failure] 가 함께 차
/// 있으면 분석이 실패한 것이고, 비어 있으면 진행 중이다. 여기에 ANALYZE_FAILED 를
/// 더하지 않는 이유 — 분석 실패는 기록 수명주기의 한 상태가 아니라 그 이전 단계이고,
/// 화면은 두 경우를 모두 "보여줄 결과가 없음"으로 분기한다.
enum PlateRecordStatus { analyzing, ready, saving, saved, saveFailed }

/// 음식 사진 · 분석 결과 · 저장된 기록 · 시뮬레이션을 한 상태에 모은다.
///
/// 시뮬레이션을 별도 프로바이더로 빼면 S07 이 두 상태를 동시에 구독하면서
/// "점수가 60인데 시뮬 결과는 이전 음식 것"인 순간이 생긴다.
///
/// [analysis] 와 [savedPlate] 를 한 필드로 합치지 않는다. 합치면 "이거 저장된
/// 건가"를 id 가 있나 없나로 추측하게 되고, 그 추측이 틀리는 날 사용자는 저장한 줄
/// 알았던 기록을 잃는다.
class PlateState {
  const PlateState({
    this.imageBytes,
    this.analysis,
    this.savedPlate,
    this.status = PlateRecordStatus.analyzing,
    this.failure,
    this.simulation,
    this.simulating = false,
  });

  /// 경로가 아니라 바이트다. 웹에는 파일 경로가 없어 Image.file 이 런타임에 던진다.
  /// 저장이 확정된 뒤 이 바이트를 디스크에 남긴다.
  final Uint8List? imageBytes;

  /// 저장 전 임시 결과. 서버에는 아무것도 없다.
  final PlateAnalysis? analysis;

  /// `POST /plates/records` 가 201 을 준 뒤에만 채워진다.
  final SkinPlate? savedPlate;

  final PlateRecordStatus status;

  /// 분석 실패([analyzing]) 또는 저장 실패([saveFailed]) 원인.
  final Failure? failure;

  /// 행동을 실행해 본 결과. null 이면 아직 아무 버튼도 안 눌렀다.
  final PlateSimulation? simulation;
  final bool simulating;

  /// 화면이 그리는 면. 저장이 끝났으면 서버가 다시 계산해 준 쪽이 이긴다.
  PlateView? get view => savedPlate ?? analysis;

  bool get isSaved => savedPlate != null;

  /// 화면에 띄울 점수. 시뮬레이션을 했으면 그 결과가 이긴다.
  int? get displayedScore => simulation?.afterScore ?? view?.plateScore;

  /// 같은 analysisToken 으로 다시 보내는 게 의미 있는 실패인가.
  ///
  /// 서버가 토큰의 jti 로 멱등이라 재시도는 안전하다 — timeout 이면 서버에는 이미
  /// 저장됐을 수도 있는데, 그때도 같은 plateId 를 201 로 돌려준다. 그래서 "음식명·
  /// 시각이 같은 기록이 있나"로 저장 여부를 추측할 필요가 없다. 같은 음식을 두 번
  /// 먹는 것은 정상이라 그 추측은 어차피 틀린다.
  ///
  /// 만료·잘못된 요청·피부 분석 없음은 몇 번을 보내도 같은 답이다. 재시도 버튼을
  /// 주면 사용자가 눌러보다 결국 앱을 닫는다.
  bool get canRetrySave =>
      status == PlateRecordStatus.saveFailed &&
      switch (failure) {
        NetworkFailure() => true, // 연결 실패
        UnknownFailure() => true, // 5xx 본문이 공통 래퍼가 아닌 경우 포함
        AnalysisFailure(:final code) => code == 'AI_TIMEOUT',
        ServerFailure(:final code) => code == 'INTERNAL_ERROR',
        // ANALYSIS_EXPIRED 는 AnalysisFailure 지만 AI_TIMEOUT 이 아니라 여기서 false 다.
        // 재시도가 아니라 재촬영이다.
        _ => false,
      };

  /// 시뮬레이션 두 필드만 갈아끼운다. 나머지는 건드리지 않는다.
  /// 범용 copyWith 를 두지 않는 이유 — `?? this.x` 로는 오류를 지울 수 없어서
  /// 상태 전이마다 clearXxx 플래그가 하나씩 늘어난다.
  ///
  /// [simulation] 은 생략할 수 없다. 기본값 null 로 두면 `withSimulation(simulating:
  /// true)` 가 사용자가 보고 있던 점수를 조용히 지운다 — "두 필드만 갈아끼운다"는
  /// 설명을 그대로 읽으면 쓰게 되는 형태가 바로 그것이다.
  PlateState withSimulation({
    required PlateSimulation? simulation,
    required bool simulating,
  }) =>
      PlateState(
        imageBytes: imageBytes,
        analysis: analysis,
        savedPlate: savedPlate,
        status: status,
        failure: failure,
        simulation: simulation,
        simulating: simulating,
      );
}

final plateNotifierProvider =
    NotifierProvider<PlateNotifier, PlateState>(PlateNotifier.new);

class PlateNotifier extends Notifier<PlateState> {
  @override
  PlateState build() => const PlateState();

  /// 몇 번째 분석인지. 결과 화면에서 뒤로 나가 다시 찍으면 요청이 둘이 되는데,
  /// AI 호출이라 수십 초가 걸려 먼저 보낸 쪽이 나중에 도착할 수 있다. 세대가
  /// 다르면 그 응답은 사용자가 이미 버린 음식의 것이다.
  int _generation = 0;

  /// 분석만 한다. 서버에 기록이 생기지 않는다.
  ///
  /// [skinAnalysisId] 를 생략하면 서버가 최신 피부 분석을 자동으로 쓴다.
  Future<void> analyze(XFile image, {int? skinAnalysisId}) async {
    final generation = ++_generation;

    // 여기서 한 번만 읽는다. XFile 을 그대로 데이터소스에 넘기면 업로드 직전에
    // 같은 파일을 한 번 더 읽어 멀티 MB 사본이 둘이 된다.
    final bytes = await image.readAsBytes();
    if (generation != _generation) return;

    // 프로바이더가 keep-alive 고 화면을 나가도 상태가 살아 있다. 새 분석이
    // 이전 임시 결과를 **덮어쓰는 것**이 유일한 정리 경로다. 부분 갱신이 아니라
    // 통째로 갈아엎어야 이전 음식의 결과·저장 상태가 섞이지 않는다.
    state = PlateState(imageBytes: bytes);

    final result = await ref
        .read(plateRepositoryProvider)
        .analyze(bytes, skinAnalysisId: skinAnalysisId);

    if (generation != _generation) return;

    state = result.when(
      success: (analysis) => PlateState(
        imageBytes: bytes,
        analysis: analysis,
        status: PlateRecordStatus.ready,
      ),
      failure: (failure) => PlateState(imageBytes: bytes, failure: failure),
    );
  }

  /// 분석 결과를 기록으로 확정한다. 여기서 처음으로 히스토리·리포트에 반영된다.
  ///
  /// 저장 실패 후 다시 부르면 **새로 분석하지 않고** 같은 토큰을 다시 보낸다.
  /// AI 를 다시 부르지 않으므로 빠르고, 서버가 멱등이라 중복 기록이 생기지 않는다.
  Future<void> saveRecord() async {
    final analysis = state.analysis;
    final bytes = state.imageBytes;

    // SAVED 가드. 서버가 멱등이라 사고는 안 나지만, 눌리지 않아야 할 버튼이
    // 눌렸다는 것 자체가 버그다. SAVING 중 중복 클릭도 여기서 걸린다.
    if (analysis == null ||
        state.status == PlateRecordStatus.saving ||
        state.isSaved) {
      return;
    }

    state = PlateState(
      imageBytes: bytes,
      analysis: analysis,
      status: PlateRecordStatus.saving,
    );

    final result =
        await ref.read(plateRepositoryProvider).saveRecord(analysis.analysisToken);

    // 기다리는 동안 사용자가 뒤로 나가 다른 음식을 찍었을 수 있다(타임아웃이 32초다). 아래 대입은 상태를 통째로 새로 만들기
    // 때문에, 확인하지 않으면 방금 찍은 결과가 이전 음식의 사진·점수로 덮인다.
    if (state.analysis?.analysisToken != analysis.analysisToken) return;

    state = result.when(
      success: (saved) => PlateState(
        imageBytes: bytes,
        analysis: analysis,
        savedPlate: saved,
        status: PlateRecordStatus.saved,
        // 저장했다고 시뮬레이션 결과를 지우지 않는다. 지우면 게이지가 72 에서 60
        // 으로 되돌아가는데 액션 버튼은 "되돌리기" 상태로 남는다.
        simulation: state.simulation,
      ),
      // analysis 를 버리지 않는다. 재시도가 같은 토큰을 써야 한다.
      failure: (failure) => PlateState(
        imageBytes: bytes,
        analysis: analysis,
        status: PlateRecordStatus.saveFailed,
        failure: failure,
        simulation: state.simulation,
      ),
    );
  }

  /// 추천 행동을 실행했다고 가정하고 서버에 다시 물어본다.
  ///
  /// 앱에서 `plateScore + expectedGain` 으로 더하지 않는다. 그 합산은 실제 재계산과
  /// 다르다 — 예시 A 는 합산 74 지만 실제로는 68 이다(나트륨이 925 가 되어 R04 가
  /// 아예 발동하지 않는다). 점수는 백엔드가 소유한다.
  ///
  /// 저장 여부에 따라 묻는 곳이 다르다.
  ///
  /// 저장됐으면 **plateId** 로 묻는다. 토큰으로 물으면 30분 TTL 에 걸려, 기록이
  /// 멀쩡히 남아 있는데도 결과 화면에 오래 머물렀다는 이유로 만료가 난다.
  Future<void> simulate(List<PlateActionCode> actions) async {
    final saved = state.savedPlate;
    final analysis = state.analysis;
    if (actions.isEmpty || (saved == null && analysis == null)) return;

    state = state.withSimulation(
      simulation: state.simulation,
      simulating: true,
    );

    final repository = ref.read(plateRepositoryProvider);
    final result = saved != null
        ? await repository.simulate(saved.id, actions)
        : await repository.simulateAnalysis(analysis!.analysisToken, actions);

    // 응답을 기다리는 사이 새 음식을 찍었거나 저장이 끝났을 수 있다. 그러면 이
    // 결과는 다른 끼니의 것이라 지금 화면에 붙이면 안 된다 — 사진과 음식명은 B 인데
    // "60점 → 72점" 배너만 A 의 것인 화면이 만들어진다.
    if (state.savedPlate?.id != saved?.id ||
        state.analysis?.analysisToken != analysis?.analysisToken) {
      return;
    }

    state = result.when(
      success: (simulation) =>
          state.withSimulation(simulation: simulation, simulating: false),
      failure: (failure) {
        // 만료만은 삼키지 않는다. 토큰이 죽었으면 저장도 못 하므로 저장 실패와 같은
        // 자리에 띄운다 — 사용자가 할 일도 같다(재촬영). 조용히 넘어가면 버튼을
        // 눌러도 아무 일이 없는 화면이 된다.
        //
        // **저장 전에만** 그렇게 한다. 저장된 기록은 plateId 로 묻기 때문에 만료가
        // 날 수 없고, 그런데도 이 분기를 타면 이미 서버에 있는 끼니를 "저장 안 됨"
        // 으로 되돌려 재촬영시킨다 — 그때 만들어지는 건 다른 토큰이라 서버 멱등도
        // 걸리지 않고 중복 기록이 생긴다.
        if (saved == null &&
            failure is AnalysisFailure &&
            failure.code == 'ANALYSIS_EXPIRED') {
          return PlateState(
            imageBytes: state.imageBytes,
            analysis: state.analysis,
            status: PlateRecordStatus.saveFailed,
            failure: failure,
          );
        }
        // 나머지는 원래 점수를 그대로 둔다. 화면을 비우지 않는다.
        return state.withSimulation(
          simulation: state.simulation,
          simulating: false,
        );
      },
    );
  }

  /// 되돌리기 — 원래 점수로 복귀한다. 서버에 저장된 적이 없으므로 지우기만 하면 된다.
  void clearSimulation() =>
      state = state.withSimulation(simulation: null, simulating: false);
}
