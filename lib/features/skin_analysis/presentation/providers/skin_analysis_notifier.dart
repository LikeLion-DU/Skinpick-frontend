import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/skin_analysis.dart';

/// 홈(S02)의 "오늘의 Skin Score" 카드용. 기록이 없으면 Success(null) 이다.
///
/// Result 를 그대로 실어 보낸다. Failure 를 throw 로 바꿔 AsyncError 에 담으면
/// 화면이 `error as Failure` 캐스팅을 하게 되고, 그 캐스팅이 틀리는 날 앱이 죽는다.
final latestSkinAnalysisProvider = FutureProvider<Result<SkinAnalysis?>>(
  (ref) => ref.watch(skinRepositoryProvider).getLatest(),
);

/// 촬영한 사진과 분석 결과를 함께 들고 있는다.
///
/// 이미지가 상태에 있어야 하는 이유 — 결과 화면(S05)은 서버가 준 URL 이 아니라
/// **앱이 방금 찍은 사진**을 띄운다. 서버는 사진을 저장하지 않는다. (PRD §9.6)
///
/// 경로가 아니라 바이트를 들고 있는다. 웹에는 파일 경로가 없어서 Image.file 이
/// 런타임에 던진다. Image.memory 는 웹·모바일이 같은 코드로 돈다.
class SkinAnalysisState {
  const SkinAnalysisState({
    this.imageBytes,
    this.analysis = const AsyncData<SkinAnalysis?>(null),
  });

  final Uint8List? imageBytes;
  final AsyncValue<SkinAnalysis?> analysis;

  SkinAnalysisState copyWith({
    Uint8List? imageBytes,
    AsyncValue<SkinAnalysis?>? analysis,
  }) =>
      SkinAnalysisState(
        imageBytes: imageBytes ?? this.imageBytes,
        analysis: analysis ?? this.analysis,
      );
}

final skinAnalysisNotifierProvider =
    NotifierProvider<SkinAnalysisNotifier, SkinAnalysisState>(
        SkinAnalysisNotifier.new);

class SkinAnalysisNotifier extends Notifier<SkinAnalysisState> {
  @override
  SkinAnalysisState build() => const SkinAnalysisState();

  Future<void> analyze(XFile image) async {
    state = SkinAnalysisState(
      imageBytes: await image.readAsBytes(),
      analysis: const AsyncLoading(),
    );

    final result = await ref.read(skinRepositoryProvider).analyze(image);

    state = state.copyWith(
      analysis: result.when(
        success: (analysis) => AsyncData<SkinAnalysis?>(analysis),
        failure: (failure) => AsyncError<SkinAnalysis?>(failure, StackTrace.current),
      ),
    );

    // 홈 카드가 방금 찍은 결과를 보여줘야 한다.
    if (result.isSuccess) ref.invalidate(latestSkinAnalysisProvider);
  }

  /// S05 에서 피부 타입을 인라인으로 고른 뒤 갭 카드를 띄우려면 결과를 다시 받아야 한다.
  /// 갭 문장은 서버가 만든다 — 앱이 조합하면 규칙이 두 곳에 생긴다.
  Future<void> refresh(int id) async {
    final result = await ref.read(skinRepositoryProvider).getById(id);

    state = state.copyWith(
      analysis: result.when(
        success: (analysis) => AsyncData<SkinAnalysis?>(analysis),
        // 다시 받기에 실패해도 이미 보고 있던 결과는 지우지 않는다.
        failure: (_) => state.analysis,
      ),
    );
  }

  void reset() => state = const SkinAnalysisState();
}
