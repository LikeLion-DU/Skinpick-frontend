import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 촬영 셔터. 피부 촬영과 음식 촬영이 같은 것을 쓴다.
///
/// 값은 시안 360:822(`얼굴촬영(시작/정면)`)에서 그대로 가져왔다 —
/// 지름 101(링 바깥까지) · 링 5 · 흰 원판 80 · 링과 원판 사이 옅은 회색 띠 ·
/// 링은 좌상 [AppColors.shutterRingStart] 에서 우하 [AppColors.accentStrong] 으로.
///
/// **[CustomPaint] 로 그린다.** 겹친 [Container] 로 만들면 링이 그라디언트라
/// 바깥 원을 통째로 칠하고 덮어야 하는데, 그러면 링과 원판 사이의 반투명 회색이
/// 카메라 프리뷰가 아니라 오렌지 위에 얹혀 복숭아색 띠가 된다. 시안은 그 틈으로
/// 프리뷰가 비치는 회색 띠다 — 고리만 그려야 그 순서가 맞는다.
class CaptureShutter extends StatelessWidget {
  const CaptureShutter({
    super.key,
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  /// 시안 360:822. 레이아웃이 이 값을 알아야 해서 공개한다.
  static const diameter = 101.0;
  static const _ringWidth = 5.0;
  static const _discDiameter = 80.0;

  /// 게이트를 통과해 지금 누를 수 있다.
  final bool enabled;

  /// 촬영이 진행 중이다. **꺼짐과 다르게 보여야 한다** — 흐리게만 처리하면
  /// "그냥 안 되는 버튼" 으로 읽혀 사용자가 다시 누른다.
  final bool busy;
  final VoidCallback onTap;

  /// 흐리게 그릴지. **촬영 중은 흐리게 하지 않는다** — 흰 원판이 흐려지면 밝은
  /// 배경(흰 벽·역광·욕실 거울)에서 사실상 사라져서 돌고 있는 스피너까지 안
  /// 보이고, "그냥 안 되는 버튼" 으로 읽혀 사용자가 다시 누른다.
  ///
  /// 그리는 색에 알파로 들어가 위젯 트리에는 안 남는다. 규칙을 여기로 빼 둬야
  /// 테스트가 붙잡을 수 있다.
  @visibleForTesting
  static bool dimmedFor({required bool enabled, required bool busy}) =>
      !enabled && !busy;

  @override
  Widget build(BuildContext context) {
    final dimmed = dimmedFor(enabled: enabled, busy: busy);

    return Semantics(
      button: true,
      enabled: enabled,
      label: busy ? '사진 촬영 중' : '사진 촬영',
      child: GestureDetector(
        // 촬영 중 재탭을 막는 것은 그대로다 — enabled 를 부르는 쪽이
        // `ready && !busy` 로 넘긴다.
        onTap: enabled ? onTap : null,
        child: CustomPaint(
          painter: _ShutterPainter(dimmed: dimmed),
          child: SizedBox.square(
            dimension: diameter,
            child: busy
                ? const Center(
                    child: SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _ShutterPainter extends CustomPainter {
  const _ShutterPainter({required this.dimmed});

  /// 꺼짐. 투명도를 색에 직접 넣는다 — [Opacity] 로 감싸면 프리뷰가 합성되는
  /// 매 프레임마다 오프스크린 레이어가 생기는데, 게이트가 300ms 마다 판정을
  /// 뒤집어서 그 레이어가 계속 세워졌다 헐린다.
  final bool dimmed;

  static const _outerRadius = CaptureShutter.diameter / 2;
  static const _ringRadius = _outerRadius - CaptureShutter._ringWidth / 2;
  static const _discRadius = CaptureShutter._discDiameter / 2;

  /// 시안의 흐림은 stdDeviation 12.5 다. [BoxShadow] 의 `blurRadius` 는
  /// `sigma = blurRadius * 0.57735 + 0.5` 로 환산돼서 25 를 넣으면 sigma 가
  /// 14.93 이 된다(2배 규칙은 CSS 관례지 Flutter 것이 아니다). sigma 를 직접 준다.
  static const _glowSigma = 12.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final alpha = dimmed ? 0.45 : 1.0;

    // 1. 글로우 — 시안은 링 바깥으로 번진다. 꺼짐일 때는 깔지 않는다.
    if (!dimmed) {
      canvas.drawCircle(
        center,
        _ringRadius,
        Paint()
          ..color = AppColors.accentStrong
          ..style = PaintingStyle.stroke
          ..strokeWidth = CaptureShutter._ringWidth
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowSigma),
      );
    }

    // 2. 옅은 회색 판 — **프리뷰 위에 직접 얹는다.** 링을 통째로 칠한 뒤
    //    덮는 방식이면 이 회색이 오렌지 위에 앉아 복숭아색이 된다.
    canvas.drawCircle(
      center,
      _outerRadius,
      Paint()..color = AppColors.disabled.withValues(alpha: 0.2 * alpha),
    );

    // 3. 링 — 고리만 그린다. 안쪽을 비워 둬야 2번이 보인다.
    canvas.drawCircle(
      center,
      _ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = CaptureShutter._ringWidth
        ..shader = LinearGradient(
          colors: [
            AppColors.shutterRingStart.withValues(alpha: alpha),
            AppColors.accentStrong.withValues(alpha: alpha),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: _outerRadius)),
    );

    // 4. 흰 원판.
    canvas.drawCircle(
      center,
      _discRadius,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_ShutterPainter oldDelegate) =>
      oldDelegate.dimmed != dimmed;
}
