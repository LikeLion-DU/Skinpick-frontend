
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/skin_analysis_notifier.dart';

/// S04 — 분석 로딩.
///
/// 빈 스피너 대신 단계를 순차로 보여준다. AI 응답에 5~8초가 걸리는데,
/// 그 시간에 아무것도 안 움직이면 실제보다 길게 느껴진다. (PRD §6 화면 설계 원칙 1)
///
/// 가입 직후라면 이 대기 시간에 프로필 설문을 얹는다. **분석은 촬영하는 순간
/// 이미 시작됐다**(`skin_capture_page._start` 의 unawaited analyze) — 그래서
/// 설문을 여기 두면 5~8초가 설문에 흡수되고, 설문을 끝냈을 때 결과가 준비돼 있다.
class SkinLoadingPage extends ConsumerStatefulWidget {
  const SkinLoadingPage({super.key});

  @override
  ConsumerState<SkinLoadingPage> createState() => _SkinLoadingPageState();
}

class _SkinLoadingPageState extends ConsumerState<SkinLoadingPage> {
  /// 설문이 위에 떠 있는 동안에는 분석이 끝나도 화면을 바꾸지 않는다.
  /// `pushReplacement` 는 스택의 **맨 위**를 갈아치우므로, 그때 부르면 사용자가
  /// 쓰고 있던 설문이 통째로 사라진다.
  bool _surveyOpen = false;

  @override
  void initState() {
    super.initState();
    // 라우터를 위젯 생명주기 안에서 건드릴 수 없다. 첫 프레임 뒤로 미룬다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _askProfileThenResult());
  }

  Future<void> _askProfileThenResult() async {
    if (!mounted) return;

    final declared = switch (ref.read(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };

    // 타입이 이미 있으면 물을 것이 없다 — 촬영을 중간에 접어 플래그만 남은 채
    // 프로필을 직접 설정한 사용자다. 다 아는 것을 다시 묻게 된다.
    if (ref.read(onboardingCaptureProvider) && declared == null) {
      ref.read(onboardingCaptureProvider.notifier).state = false;
      _surveyOpen = true;
      await context.push(Routes.onboardingProfile);
      if (!mounted) return;
      _surveyOpen = false;
    }

    // 설문을 보는 동안(혹은 첫 프레임 전에) 분석이 끝났으면 아래 listen 은 이미
    // 지나갔다. 이미 도착한 값에는 반응하지 않으므로 여기서 한 번 직접 본다.
    _toResult();
  }

  void _toResult() {
    if (!mounted || _surveyOpen) return;
    if (ref.read(skinAnalysisNotifierProvider).analysis.value == null) return;

    // pushReplacement 라 뒤로가기가 로딩 화면으로 돌아오지 않는다.
    context.pushReplacement(Routes.skinResult);
  }

  @override
  Widget build(BuildContext context) {
    // **습관이 비어 있어도 결과로 바로 보낸다.** 예전에는 여기서 생활 습관 4종을
    // 강제했는데, 그 근거였던 "인사이트가 습관 없이 굳는다" 가 성립하지 않는다 —
    // 인사이트는 분석 시점이 아니라 사용자가 S10 에 **들어갈 때** 서버가 처음
    // 만든다(GET /skin-insights 가 get-or-create).
    //
    // 그래서 게이트는 습관이 실제로 필요한 S10 이 쥔다. 여기서 막으면 점수·지표만
    // 보려는 사용자까지 설문 앞에 세운다.
    ref.listen(skinAnalysisNotifierProvider, (previous, next) {
      if (next.analysis.value == null) return;
      _toResult();
    });

    final analysis = ref.watch(skinAnalysisNotifierProvider).analysis;

    return Scaffold(
      body: switch (analysis) {
        // 촬영 화면은 이미 교체돼 스택에 없다. pop 하면 촬영 이전 화면으로 나가
        // 버리므로, 재촬영은 카메라로 명시적으로 다시 들어간다.
        AsyncError(:final Failure error) => FailureView(
            failure: error,
            onRetry: () => context.pushReplacement(Routes.skinCapture),
          ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const LoadingSteps(
            steps: [
              '사진을 준비하고 있어요',
              '피부 특징을 추출하는 중이에요',
              '수분·유분·홍조를 살펴보는 중이에요',
              '오늘의 Skin Score를 계산하고 있어요',
            ],
          ),
      },
    );
  }
}
