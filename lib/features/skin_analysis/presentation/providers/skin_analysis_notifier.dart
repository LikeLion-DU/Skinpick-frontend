import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/entities/skin_photo_set.dart';

/// 홈(S02)의 "오늘의 Skin Score" 카드용. 기록이 없으면 Success(null) 이다.
///
/// Result 를 그대로 실어 보낸다. Failure 를 throw 로 바꿔 AsyncError 에 담으면
/// 화면이 `error as Failure` 캐스팅을 하게 되고, 그 캐스팅이 틀리는 날 앱이 죽는다.
final latestSkinAnalysisProvider = FutureProvider<Result<SkinAnalysis?>>(
  (ref) => ref.watch(skinRepositoryProvider).getLatest(),
);

/// 가입 직후 촬영 화면의 안내(`SkinCapturePage._introView`)에서 "촬영하기"로
/// 들어왔는가. 안내는 그 화면이 갖고 있다 — 별도 페이지가 아니다.
///
/// 로딩 화면(S04)이 이 값을 보고 분석을 기다리는 동안 프로필 설문을 얹은 뒤 끈다.
/// 라우트 쿼리로 넘기지 않는 것은 촬영→로딩이 `pushReplacement` 라 값을 실어
/// 날라야 하고, 로딩 화면의 재시도가 카메라로 되돌아갈 때 그 값이 끊기기 때문이다.
final onboardingCaptureProvider = StateProvider<bool>((ref) => false);

/// 분석 결과를 들고 있는다.
///
/// **얼굴 사진 바이트는 들고 있지 않는다.** 확정 시안의 결과 화면(S05)에는 사진
/// 자리가 없다. 읽는 곳 없이 들고만 있으면 분석 한 번마다 수 MB 짜리 Uint8List 가
/// dispose 되지 않는 notifier 에 그대로 박힌다. 시안에 사진이 다시 들어오면
/// `analyze` 에서 `photos.front.readAsBytes()` 를 되살리면 된다 — 경로가 아니라
/// 바이트여야 한다. 웹에는 파일 경로가 없어서 Image.file 이 런타임에 던진다.
class SkinAnalysisState {
  const SkinAnalysisState({
    this.analysis = const AsyncData<SkinAnalysis?>(null),
  });

  final AsyncValue<SkinAnalysis?> analysis;

  SkinAnalysisState copyWith({AsyncValue<SkinAnalysis?>? analysis}) =>
      SkinAnalysisState(analysis: analysis ?? this.analysis);
}

final skinAnalysisNotifierProvider =
    NotifierProvider<SkinAnalysisNotifier, SkinAnalysisState>(
        SkinAnalysisNotifier.new);

class SkinAnalysisNotifier extends Notifier<SkinAnalysisState> {
  @override
  SkinAnalysisState build() => const SkinAnalysisState();

  Future<void> analyze(SkinPhotoSet photos) async {
    state = const SkinAnalysisState(analysis: AsyncLoading());

    final result = await ref.read(skinRepositoryProvider).analyze(photos);

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
