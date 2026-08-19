import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/skin_mascot.dart';

/// 시안 "온보딩2" — 가입 직후 처음 만나는 인사 화면.
///
/// 이 화면은 아무것도 묻지 않고 아무것도 저장하지 않는다. 다음 화면(촬영 안내)이
/// 곧바로 카메라 권한과 얼굴 촬영을 요구하기 때문에, 그 앞에 "왜 찍는지"를 한 번
/// 말해 두는 자리다. 여기에 설문이나 약관을 얹지 마라 — 얹는 순간 가입 직후
/// 이탈 지점이 하나 늘어난다.
///
/// **로그인으로 들어온 기존 사용자는 이 화면을 보지 않는다.** 라우터가
/// `Authenticated` 를 곧장 홈으로 보내고, 여기로 오는 길은 가입 성공 뒤의
/// `go` 하나뿐이다.
class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        // **스크롤 가능해야 한다.** 300 짜리 장식과 버튼이 들어 있어서 작은
        // 기기나 글자 크기를 키운 기기에서는 [시작하기] 가 화면 밖으로 밀린다 —
        // 그러면 가입자가 첫 화면에서 갇힌다. (촬영 안내 화면과 같은 이유)
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // Spacer 가 살아나려면 Column 이 유한한 높이를 받아야 한다 —
              // 스크롤 안에서는 무한이라 IntrinsicHeight 를 한 겹 끼운다.
              child: IntrinsicHeight(
                // 여백은 형제 화면인 촬영 안내의 규약을 그대로 따른다 —
                // 두 화면이 연달아 뜨는데 좌우·상하 여백이 다르면 넘어가는
                // 순간 판이 흔들린다.
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.pagePadding),
                  child: Column(
                    children: [
                      // 최소 간격은 SizedBox 가 보장하고 남는 높이만 Spacer 가
                      // 나눈다. Spacer 만 쓰면 내용이 화면보다 길어지는 순간
                      // 모든 간격이 0이 되어 글자와 장식이 달라붙는다.
                      const SizedBox(height: 40),
                      const Spacer(flex: 2),
                      Text(
                        '반가워요! 지금부터\n나만의 피부 음식을 확인해볼까요?',
                        textAlign: TextAlign.center,
                        // 시안이 이 화면만 제목을 20 으로 쓴다. Pretendard Bold
                        // 실측으로 둘째 문장이 20 에서 266.6px, 24 에서 320px 다.
                        // 좌우 여백 32 를 뺀 폭은 402 기기가 338, 360 기기가 296,
                        // 320 기기가 256 이다. 즉 **360 이상에서만 시안대로 두
                        // 줄이고**, 24 로 올리면 360 부터 세 줄로 접힌다. 320 은
                        // 20 으로도 접히는데, 접혀도 읽히므로 거기까지 맞추려고
                        // 크기를 더 줄이지는 않는다.
                        style: text.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('저와 함께 피부고민을 해결해 보아요',
                          textAlign: TextAlign.center, style: text.bodyMedium),
                      const SizedBox(height: 28),
                      const Spacer(flex: 3),
                      // 좁은 기기에서는 장식(280)이 여백 안에 안 들어간다.
                      // 세로 스크롤은 가로로 넘친 것을 구하지 못하므로 줄인다.
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _WelcomeArt(),
                      ),
                      const SizedBox(height: 28),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        onPressed: () => context.go(Routes.onboardingCapture),
                        child: const Text('시작하기'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 마스코트 한 마리와 그를 둘러싼 장식 — 모서리 괄호 둘, 반짝이 둘.
///
/// 괄호는 촬영 화면의 얼굴 프레임을 미리 보여주는 것이라 마스코트를 실제로
/// 감싸야 한다. 크기를 따로 놀게 두면 다음 화면과 연결이 끊긴다.
class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 280,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.topLeft, child: _CornerBracket()),
          // 반대편 괄호는 같은 그림을 반 바퀴 돌린 것이다. 두 번째 path 를
          // 손으로 그리면 곡률이나 획 길이가 미묘하게 어긋난다.
          Align(
            alignment: Alignment.bottomRight,
            child: RotatedBox(quarterTurns: 2, child: _CornerBracket()),
          ),
          Align(alignment: Alignment(0.62, -0.68), child: _Sparkles()),
          Align(alignment: Alignment(-0.62, 0.70), child: _Sparkles()),
          SkinMascot(size: 160),
        ],
      ),
    );
  }
}

/// 시안의 브랜드 반짝이. `ai_sparkle.svg` 는 큰 별이 왼쪽 아래, 작은 별이 오른쪽
/// 위에 있는데 시안은 그 상하 반전이라 뒤집어 쓴다 — 별을 새로 그리지 않는다.
class _Sparkles extends StatelessWidget {
  const _Sparkles();

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: -1,
      child: SvgPicture.asset(
        'assets/icons/ai_sparkle.svg',
        width: 84,
        height: 84,
        // 원본 fill 은 accentStrong(#FF4D00)인데 시안의 이 자리는 한 톤 옅은
        // primary 다. 아이콘을 복제하지 않고 색만 갈아 끼운다.
        colorFilter:
            const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}

/// 왼쪽 위 모서리를 감싸는 "ㄱ" 괄호 한 짝.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 76,
      height: 76,
      child: CustomPaint(painter: _CornerBracketPainter()),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 11.0;
    const cornerRadius = 18.0;
    // 획은 중심선을 따라 그려지므로 꺾이는 쪽은 절반만큼 안으로 들인다.
    //
    // **열린 두 끝은 상자를 넘어간다.** 끝점을 변에 딱 붙여 두고 StrokeCap.round
    // 를 쓰므로 획이 5.5px 더 나가고, 아래 후광은 그보다 더 번진다. 잘리지 않게
    // Stack 도 FittedBox 도 클립하지 않는 자리에 두었다 — 상자 크기를 여백
    // 계산에 그대로 쓰면 실제보다 좁게 잡힌다.
    const inset = strokeWidth / 2;

    final path = Path()
      ..moveTo(inset, size.height)
      ..lineTo(inset, inset + cornerRadius)
      ..arcToPoint(const Offset(inset + cornerRadius, inset),
          radius: const Radius.circular(cornerRadius))
      ..lineTo(size.width, inset);

    Paint stroke() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;

    // 시안의 괄호는 옅은 후광을 달고 있다. 같은 획을 흐리게 한 번 먼저 긋는다 —
    // ImageFiltered 로 감싸면 선명한 획까지 같이 흐려져 괄호가 뭉갠다.
    canvas.drawPath(
      path,
      stroke()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(path, stroke());
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) => false;
}
