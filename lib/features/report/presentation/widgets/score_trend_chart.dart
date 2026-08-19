import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/kst_date.dart';
import '../../domain/entities/report.dart';

/// 일별 점수 막대.
///
/// **차트 패키지를 들이지 않는다.** 그리는 것은 최대 7개의 막대와 가로줄 넷이라
/// 위젯 조합으로 끝난다. 패키지를 하나 넣으면 pubspec 과 네이티브 설정을
/// 건드리게 되는데(이 저장소는 그걸 한 사람이 전담한다) 얻는 것이 축 라벨
/// 자동 배치 정도다.
///
/// 확정 시안이 꺾은선을 **막대**로 바꿨다. 꺾은선은 빈 날을 어떻게 이어도
/// 거짓말이 된다 — 실선으로 이으면 보간한 것처럼 읽히고, 점선으로 이어도 선이
/// 거기 있다. 막대는 **없는 날에 아무것도 그리지 않으면 그것으로 끝난다.**
///
/// 세로 축은 **0~100 고정**이다. 데이터 최소·최대에 맞춰 늘리면 70~72 점짜리
/// 한 주가 폭락한 그래프로 보인다.
class ScoreTrendChart extends StatelessWidget {
  const ScoreTrendChart({super.key, required this.report});

  final WeeklyReport report;

  /// 100 점 막대의 높이. 시안(약 287)보다 낮춘 값이다 — 시안 카드가 489 로
  /// 화면의 절반을 넘게 쓰는데, 그러면 아래 카드들이 한 번도 안 보인 채로
  /// 스크롤을 시작해야 한다.
  static const double _plotHeight = 210;

  /// 점수 라벨 자리. 이만큼 안 비우면 100 점 막대의 라벨이 잘린다.
  static const double _labelSpace = 20;

  /// 가로 안내선 개수(바닥선 제외).
  static const int _gridLines = 4;

  @override
  Widget build(BuildContext context) {
    final axis = report.axis;
    final scores = [for (final date in axis) report.scoreOn(date)?.dailyScore];

    return Column(
      children: [
        SizedBox(
          height: _plotHeight + _labelSpace,
          child: Stack(
            children: [
              // 안내선이 막대 뒤에 깔린다. 위에 그리면 막대를 가로지른다.
              const Positioned.fill(
                top: _labelSpace,
                child: _GridLines(count: _gridLines),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final score in scores)
                    Expanded(child: _Bar(score: score)),
                ],
              ),
            ],
          ),
        ),
        // 바닥선. 막대가 하나도 없어도 축이 보여야 "그리다 만 화면"으로 안 읽힌다.
        Container(height: 1, color: AppColors.borderOnWhite),
        const SizedBox(height: 9),
        Row(
          children: [
            for (var index = 0; index < axis.length; index++)
              Expanded(
                child: Text(
                  weekdayLabel(axis[index]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    // 기록이 없는 날은 라벨까지 옅게 둔다 — 막대가 없는 칸이
                    // "0 점"이 아니라 "안 찍은 날"임을 축에서도 말한다.
                    color: scores[index] == null
                        ? AppColors.borderEmptySlot
                        : const Color(0xFF999999),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.score});

  /// 기록이 없는 날은 null. **0 으로 떨어뜨리지 않는다** — 안 찍은 날이
  /// 폭락한 날처럼 보인다.
  final int? score;

  @override
  Widget build(BuildContext context) {
    final score = this.score;
    if (score == null) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 눈금판 높이(_plotHeight)가 고정이라 이 숫자만 배율을 1.3 까지 따른다.
        // 2.0 을 그대로 따르면 막대가 판 위로 33px 밀려 나간다 — 그러면 7 일
        // 막대의 높이 비교가 깨져서 그래프가 뜻을 잃는다.
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Text(
            '$score',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: ScoreTrendChart._plotHeight * (score / 100),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ],
    );
  }
}

class _GridLines extends StatelessWidget {
  const _GridLines({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var index = 0; index < count; index++)
          Container(height: 1, color: const Color(0xFFF0F0F0)),
        // 마지막 칸은 바닥선이 대신한다. 여기서 한 줄 더 그리면 이중선이 된다.
        const SizedBox.shrink(),
      ],
    );
  }
}
