import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/enums/plate_action_code.dart';
import '../../domain/entities/skin_plate.dart';

/// 음식 사진 · Plate 결과 · 시뮬레이션 결과를 한 상태에 모은다.
///
/// 시뮬레이션을 별도 프로바이더로 빼면 S07 이 두 상태를 동시에 구독하면서
/// "점수가 60인데 시뮬 결과는 이전 음식 것"인 순간이 생긴다.
class PlateState {
  const PlateState({
    this.image,
    this.plate = const AsyncData<SkinPlate?>(null),
    this.simulation,
    this.simulating = false,
  });

  final File? image;
  final AsyncValue<SkinPlate?> plate;

  /// 행동을 실행해 본 결과. null 이면 아직 아무 버튼도 안 눌렀다.
  final PlateSimulation? simulation;
  final bool simulating;

  /// 화면에 띄울 점수. 시뮬레이션을 했으면 그 결과가 이긴다.
  int? get displayedScore => simulation?.afterScore ?? plate.value?.plateScore;

  PlateState copyWith({
    File? image,
    AsyncValue<SkinPlate?>? plate,
    PlateSimulation? simulation,
    bool? simulating,
    bool clearSimulation = false,
  }) =>
      PlateState(
        image: image ?? this.image,
        plate: plate ?? this.plate,
        simulation: clearSimulation ? null : (simulation ?? this.simulation),
        simulating: simulating ?? this.simulating,
      );
}

final plateNotifierProvider =
    NotifierProvider<PlateNotifier, PlateState>(PlateNotifier.new);

class PlateNotifier extends Notifier<PlateState> {
  @override
  PlateState build() => const PlateState();

  /// [skinAnalysisId] 를 생략하면 서버가 최신 피부 분석을 자동으로 쓴다.
  Future<void> create(File image, {int? skinAnalysisId}) async {
    state = PlateState(image: image, plate: const AsyncLoading());

    final result = await ref
        .read(plateRepositoryProvider)
        .create(image, skinAnalysisId: skinAnalysisId);

    state = state.copyWith(
      plate: result.when(
        success: (plate) => AsyncData<SkinPlate?>(plate),
        failure: (failure) => AsyncError<SkinPlate?>(failure, StackTrace.current),
      ),
      clearSimulation: true,
    );
  }

  /// 추천 행동을 실행했다고 가정하고 서버에 다시 물어본다.
  ///
  /// 앱에서 `plateScore + expectedGain` 으로 더하지 않는다. 그 합산은 실제 재계산과
  /// 다르다 — 예시 A 는 합산 74 지만 실제로는 68 이다(나트륨이 925 가 되어 R04 가
  /// 아예 발동하지 않는다). 점수는 백엔드가 소유한다.
  Future<void> simulate(List<PlateActionCode> actions) async {
    final plateId = state.plate.value?.id;
    if (plateId == null || actions.isEmpty) return;

    state = state.copyWith(simulating: true);

    final result = await ref.read(plateRepositoryProvider).simulate(plateId, actions);

    state = result.when(
      success: (simulation) =>
          state.copyWith(simulation: simulation, simulating: false),
      // 시뮬레이션이 실패해도 원래 점수는 그대로 남는다. 화면을 비우지 않는다.
      failure: (_) => state.copyWith(simulating: false),
    );
  }

  /// 되돌리기 — 원래 점수로 복귀한다. 서버에 저장된 적이 없으므로 지우기만 하면 된다.
  void clearSimulation() => state = state.copyWith(clearSimulation: true);

  void reset() => state = const PlateState();
}
