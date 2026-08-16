import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/skin_analysis_notifier.dart';

/// S01d — 가입 직후 촬영 안내. 예전에는 이 자리에 피부 프로필 설문(S01c)이 있었다.
///
/// 순서를 바꾼 이유는 자가 신고 피부 타입이 쓰이는 자리 하나뿐이다 — 점수에는
/// 안 들어가고 결과 화면의 갭 카드에만 들어간다. 사진을 한 장도 안 찍은
/// 사용자에게 6문항 설문부터 세울 이유가 없다. 설문은 촬영을 마치고 분석을
/// 기다리는 자리(S04)로 옮겼다.
///
/// 이 화면은 홈의 하위 라우트다. 홈을 스택 바닥에 깔아 두지 않으면 결과
/// 화면(S05)의 뒤로가기가 갈 곳이 없어 온보딩 사용자가 그 화면에 갇힌다.
class SkinCaptureIntroPage extends ConsumerWidget {
  const SkinCaptureIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding, 60, AppTheme.pagePadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('피부 진단을 위해\n얼굴 촬영을 도와드릴게요',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('정확한 분석을 위해 정면, 좌측, 우측 사진을\n촬영해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(flex: 4),
              ElevatedButton(
                onPressed: () {
                  // 로딩 화면이 이 플래그를 보고 분석을 기다리는 동안 설문을
                  // 얹는다. 촬영을 거친 사용자만 켠다 — 넘어간 사용자는 지금
                  // 바로 설문을 본다.
                  ref.read(onboardingCaptureProvider.notifier).state = true;
                  context.pushReplacement(Routes.skinCapture);
                },
                child: const Text('촬영하기'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                // 넘어가도 설문은 보여준다 — 진단도 프로필도 없이 홈에 떨어지면
                // 음식 점수와 비교할 기준값이 하나도 없다. 다만 강제하지는
                // 않는다(건너뛰기가 있는 full 모드). 진단을 안 본 사용자에게는
                // "AI 진단을 보정해 달라"고 말할 근거가 아직 없다.
                onPressed: () => context.pushReplacement(Routes.skinType),
                child: const Text('넘어가기'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
