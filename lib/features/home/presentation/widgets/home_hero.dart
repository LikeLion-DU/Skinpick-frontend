import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/enums/skin_level.dart';
import '../../../../shared/widgets/skin_mascot.dart';

/// 홈 상단 — 오렌지 히어로 위의 인사말과 오늘의 식단 점수.
///
/// 옛 시안은 이 자리를 흰 배경 위 크림 카드로 두고 점수가 없는 날 `OO점` 을
/// 찍었다. 확정 시안은 배경을 오렌지로 깔고 점수를 배경 위에 직접 얹으며,
/// **점수가 없는 날에는 숫자 자리를 아예 만들지 않고** 마스코트가 말을 건다.
/// `OO점` 은 "0점"으로 오해될 자리를 막으려던 장치였는데, 자리를 없애는 편이
/// 더 확실하다 — 아직 안 먹은 것과 나쁘게 먹은 것은 다른 상태다.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.nickname,
    required this.score,
    required this.grade,
    required this.targetScore,
    this.scoreKnown = true,
  });

  final String nickname;

  /// 그날 기록이 없으면 null. 서버가 준 평균을 그대로 받는다.
  final int? score;

  /// [score] 의 등급. **서버가 매긴다** — 앱에 경계표를 두지 않는다.
  final SkinLevel? grade;

  /// 서버가 매 응답에 실어 보내는 목표. **앱에 80 을 박지 않는다** —
  /// 기록이 없는 날은 목표를 그릴 자리도 없으므로 null 이다.
  final int? targetScore;

  /// 오늘 기록을 **아는가**. 불러오는 중이거나 실패했으면 false 다.
  ///
  /// 모를 때 말풍선("오늘은 뭘 드셨나요?")을 띄우면 히어로가 "안 먹었다"고 단정한다 —
  /// 바로 아래 카드가 스피너나 오류를 보여주는 동안 화면이 자기와 모순된다.
  final bool scoreKnown;

  @override
  Widget build(BuildContext context) {
    final score = this.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $nickname님',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [AppTheme.heroTextShadow],
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '오늘도 피부에 좋은 선택을 해봐요!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            shadows: [AppTheme.heroTextShadow],
          ),
        ),
        // 점수가 없으면 숫자 자리를 만들지 않는다. **목표만 없는 경우는 다르다** —
        // 그때는 목표 막대만 접고 점수는 그린다. 둘을 함께 묶어 두었더니 목표
        // 키가 빠진 응답에서 오늘 먹은 기록이 있는데도 "뭘 드셨나요" 가 떴다.
        //
        // 아직 모를 때(로딩·실패)는 말풍선도 띄우지 않는다 — 그건 "안 먹었다"는
        // 단정이고, 그 순간 아래 카드는 스피너나 오류를 보여주고 있다.
        if (score != null)
          _ScoreBlock(score: score, grade: grade, targetScore: targetScore)
        else if (scoreKnown)
          _EmptyBubble(nickname: nickname),
      ],
    );
  }
}

/// 기록이 없는 날. 마스코트가 왼쪽으로 내미는 말풍선이다.
///
/// 꼬리가 오른쪽 마스코트를 향한다 — 그래서 이 문장이 "앱의 안내"가 아니라
/// "마스코트의 말"로 읽히고, 빈 화면이 오류처럼 보이지 않는다.
class _EmptyBubble extends StatelessWidget {
  const _EmptyBubble({required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 66),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD6C2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '오늘은 뭘 드셨나요?\n$nickname님의 식단을 찍어보세요!',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 16 / 12,
                  color: AppColors.accentStrong,
                ),
              ),
            ),
          ),
          // 꼬리. 말풍선과 같은 색의 삼각형이라 이어 붙은 것으로 보인다.
          const _BubbleTail(),
        ],
      ),
    );
  }
}

class _BubbleTail extends StatelessWidget {
  const _BubbleTail();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.7853981633974483, // 45°
      child: Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(right: 4),
        transform: Matrix4.translationValues(-8, 0, 0),
        color: const Color(0xFFFFD6C2),
      ),
    );
  }
}

/// 기록이 있는 날. 큰 숫자 → 등급 배지 → 목표 막대 순으로 읽힌다.
class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.score,
    required this.grade,
    required this.targetScore,
  });

  final int score;

  /// 서버가 매긴 등급. 모르면(옛 서버) 배지를 그리지 않는다 — 앱이 점수에서
  /// 다시 매기면 경계표가 두 벌이 되고, 서버가 경계를 옮긴 날 한쪽만 따라간다.
  final SkinLevel? grade;

  /// 서버가 정한 목표. 없으면 막대와 "목표 N점" 줄을 그리지 않는다.
  final int? targetScore;

  @override
  Widget build(BuildContext context) {
    final grade = this.grade;
    final targetScore = this.targetScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // 64px 숫자다. 글자 크기 2.0 이면 숫자와 등급 배지가 프레임을 67px
            // 넘긴다 — 들어갈 만큼만 줄인다. 배지를 밀어내는 대신 숫자가 양보하는
            // 쪽이 맞다. 배지는 이미 최소 크기이고, 숫자는 커도 읽힌다.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1,
                        shadows: [AppTheme.heroTextShadow],
                      ),
                    ),
                    const Text(
                      '점',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1,
                        shadows: [AppTheme.heroTextShadow],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (grade != null) ...[
              const SizedBox(width: 12),
              // 히어로 위에서는 등급 배지가 살구색 한 벌이다. 흰 배경용
              // 틴트(초록·빨강)를 그대로 올리면 오렌지 위에서 탁해진다.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeNeutralBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  grade.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 11),
        const Text(
          '오늘의 피부 식단 점수',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            shadows: [AppTheme.heroTextShadow],
          ),
        ),
        if (targetScore != null) ...[
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // 목표를 넘긴 날 막대가 넘치지 않도록 자른다. 100 점을 목표 80 으로
              // 나누면 1.25 가 되는데, 그대로 넘기면 렌더가 깨진다.
              value: (score / targetScore).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(AppColors.progressFill),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '목표 $targetScore점',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                shadows: [AppTheme.heroTextShadow],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 히어로의 오렌지 그라디언트. 위 41% 는 단색이고 그 아래로 흰색까지 풀린다.
///
/// 시안은 이 판을 프레임보다 53 위에서 시작해 927 높이로 깐다. 화면 높이에
/// 맞춰 늘리면 안 된다 — 늘리면 기기가 길어질수록 오렌지 구간이 함께 길어져
/// 카드가 오렌지 위에 앉고, 짧아지면 인사말 뒤가 흰색이 된다.
class HeroWash extends StatelessWidget {
  const HeroWash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: -53,
      left: 0,
      right: 0,
      height: 927,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primary, Colors.white],
            stops: [0, 0.4137, 1],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

/// 히어로 오른쪽 마스코트와 후광·방울. 레이아웃에 참여하지 않는 장식이다.
///
/// 좌표는 시안(402×874) 절대값을 그대로 쓴다. 여백으로 환산하지 않는 이유는
/// 이 무리가 **서로의 상대 위치로만 성립**하기 때문이다 — 후광이 얼굴에서
/// 조금이라도 밀리면 한쪽만 밝아져 그림이 어긋난 것처럼 보인다. 대신 좁은
/// 기기에서 오른쪽으로 밀려 잘리도록 왼쪽 기준으로 배치한다.
class HeroMascot extends StatelessWidget {
  const HeroMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 199,
      top: 131,
      // 오른쪽 후광이 402 를 20 넘긴다. 시안도 프레임 밖으로 나가 잘려 있다 —
      // 폭을 402 에 맞춰 줄이면 후광이 원 모양으로 잘려 테두리가 보인다.
      width: 223,
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 77, top: 0, child: MascotGlow(size: 146)),
          Positioned(left: 0, top: 73, child: MascotGlow(size: 146)),
          Positioned(left: 127, top: 0, child: MascotBubble(size: 33)),
          Positioned(left: 52, top: 27, child: MascotBubble(size: 15)),
          Positioned(left: 160, top: 152, child: MascotBubble(size: 25)),
          Positioned(left: 21, top: 22, child: SkinMascot(size: 171)),
        ],
      ),
    );
  }
}
