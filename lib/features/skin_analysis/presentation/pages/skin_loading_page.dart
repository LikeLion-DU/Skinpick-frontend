
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

  /// 이 분석에서 설문을 한 번 띄웠는가. 결과까지 도착하면 그때 플래그를 끈다.
  bool _surveyShown = false;

  @override
  void initState() {
    super.initState();
    // 라우터를 위젯 생명주기 안에서 건드릴 수 없다. 첫 프레임 뒤로 미룬다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _askProfileThenResult());
  }

  Future<void> _askProfileThenResult() async {
    if (!mounted) return;

    final onboarding = ref.read(onboardingCaptureProvider);

    // 타입이 이미 있으면 물을 것이 없다 — 촬영을 중간에 접어 플래그만 남은 채
    // 프로필을 직접 설정한 사용자다. 다 아는 것을 다시 묻게 된다.
    final declared = switch (ref.read(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };

    // 들어오자마자 실패해 있으면 얹지 않는다. 여기서 잡히는 것은 **로컬 실패**뿐이다
    // — 비행기 모드처럼 요청이 나가기도 전에 깨진 경우. 서버 실패(얼굴 미검출,
    // 5xx, 타임아웃)는 셔터 몇 초 뒤에 오므로 그때는 이미 설문이 위에 떠 있다.
    //
    // 그 경우를 잡겠다고 설문을 걷지는 않는다. 설문은 이 분석과 무관하게 쓸모가
    // 있고(프로필은 서버에 남는다), 쓰던 화면이 밑에서 사라지는 쪽이 실패를 20초
    // 늦게 아는 것보다 나쁘다. 재촬영하면 타입이 이미 있어 다시 묻지 않는다.
    //
    // **플래그는 끄지 않는다** — 아직 아무것도 못 물었다. 여기서 끄면 재촬영으로
    // 성공했을 때 프로필을 영영 안 묻게 된다.
    final failed = ref.read(skinAnalysisNotifierProvider).analysis.hasError;
    if (failed) return;

    if (onboarding && declared != null) {
      ref.read(onboardingCaptureProvider.notifier).state = false;
    }

    if (onboarding && declared == null) {
      // 플래그는 여기서 끄지 않는다. **"띄웠다" 가 아니라 "온보딩이 끝났다" 에
      // 끈다** — 결과까지 도착했을 때(_toResult). 띄우자마자 끄면, 설문을 열었다가
      // 바로 닫은 사용자의 분석이 그 뒤에 실패했을 때 재촬영해도 다시 묻지 못한다.
      // 여덟 줄 위의 "아직 아무것도 못 물었으면 살려 둔다" 와 같은 규칙이다.
      _surveyShown = true;
      _surveyOpen = true;
      await context.push(Routes.onboardingProfile);
      if (!mounted) return;
      _surveyOpen = false;

      // 설문을 그냥 닫았으면(뒤로가기) 서버에 바뀐 것이 없다. 다시 받아 봐야
      // 같은 응답이고, 그동안 사용자는 가짜 진행 표시를 계속 본다.
      final answered = switch (ref.read(authNotifierProvider)) {
        Authenticated(:final user) => user.declaredSkinType != null,
        _ => false,
      };
      if (answered) await _refetchForGap();
      if (!mounted) return;
    }

    // 설문을 보는 동안(혹은 첫 프레임 전에) 분석이 끝났으면 아래 listen 은 이미
    // 지나갔다. 이미 도착한 값에는 반응하지 않으므로 여기서 한 번 직접 본다.
    _toResult();
  }

  /// **갭 문장은 서버가 만든다.** 분석 요청은 셔터를 누르는 순간 이미 나갔고,
  /// 서버는 응답을 조립할 때 사용자의 declared 타입을 읽는다
  /// (`SkinAnalysisService.toResponse`). 설문보다 분석이 먼저 끝나면 그 응답에는
  /// 방금 고른 타입이 안 들어가 `skinTypeGap` 이 null 로 남는다. 그대로 두면
  /// 결과 화면이 같은 질문을 던지는 인라인 칩을 띄우고, 카드 제목이 측정값 대신
  /// 자가 신고값으로 떨어진다.
  ///
  /// 아직 안 왔으면 다시 받을 것도 없다 — 그 응답은 프로필이 서버에 들어간 뒤에
  /// 조립되므로 갭이 처음부터 들어 있다.
  Future<void> _refetchForGap() async {
    final id = ref.read(skinAnalysisNotifierProvider).analysis.valueOrNull?.id;
    if (id == null) return;

    await ref.read(skinAnalysisNotifierProvider.notifier).refresh(id);
  }

  /// `value` 가 아니라 `valueOrNull` 이다. **AsyncError 에서 `value` 는 담고 있는
  /// 에러를 그대로 되던진다** — 분석이 실패한 순간 여기서 예외가 나가고, 사용자는
  /// 실패 화면 대신 아무 일도 안 일어난 로딩 화면을 보게 된다.
  void _toResult() {
    if (!mounted || _surveyOpen) return;
    if (ref.read(skinAnalysisNotifierProvider).analysis.valueOrNull == null) {
      return;
    }

    // 결과까지 왔다 = 온보딩 순간이 지났다. 설문을 열었다가 그냥 닫은 사용자도
    // 여기서 끈다 — 묻기는 물었고, 안 고른 것은 그 사람의 선택이다. 그 자리는
    // 결과 화면의 인라인 칩이 이어받는다.
    if (_surveyShown) {
      ref.read(onboardingCaptureProvider.notifier).state = false;
    }

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
      if (next.analysis.valueOrNull == null) return;
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
