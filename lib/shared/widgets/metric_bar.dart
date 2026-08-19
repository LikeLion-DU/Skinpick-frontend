import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../enums/metric_band.dart';

/// 피부 지표 한 줄. 크림 알약 안에 흰 판이 앉고, 그 안에 눈금 막대가 있다.
///
/// **피부 결과(S05)와 인사이트(S10)가 같이 쓴다.** 한 탭 건너 같은 유분 52 가 다른
/// 골격으로 그려지면 두 화면이 다른 앱처럼 보인다 — 실제로 S10 이 자기 막대를
/// 따로 그리고 있었다(얇은 줄 + 오른쪽 숫자). 골격을 여기 한 벌만 둔다.
///
/// 색은 **지표의 이름표**다(수분은 파랑, 홍조는 빨강…). 상태를 뜻하지 않는다 —
/// 색으로 상태를 말하면 홍조 막대가 길수록 빨개져 "많을수록 좋다"로 읽히는데
/// 홍조는 반대다. 그래서 **길이는 값, 색은 지표, 말은 판정([MetricBand])** 으로
/// 셋을 나눈다.
class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.band,
    this.delta,
  });

  final String label;
  final int value;
  final Color color;

  /// 서버 등급을 모르면 null 이고, 그때는 상태어 줄을 그리지 않는다.
  final MetricBand? band;

  /// 직전 분석과의 차이. **null 이면 칸 자체를 만들지 않는다** — 0 을 그리면
  /// "변화 없음"과 "비교할 분석이 없음"이 화면에서 같은 말이 된다.
  ///
  /// 부호는 그대로 보여준다. 좋아졌다/나빠졌다는 앱이 말하지 않는다 — 측정 환경
  /// 차이를 서버도 단정하지 않기 때문이다.
  final int? delta;

  @override
  Widget build(BuildContext context) {
    // 서버가 범위를 벗어난 값을 보내도 그린 길이와 읽어 주는 수가 같아야 한다.
    final shown = value.clamp(0, 100);

    // **한 줄을 한 덩이로 읽힌다.** 안 묶으면 스크린리더가 이름·상태어·막대·
    // 변화량을 네 번에 나눠 읽어서, '-7' 이 어느 지표 것인지 알 수 없는 채로
    // 따로 떨어진다.
    //
    // **높이를 고정하지 않는다.** 시안 값(49)을 그대로 박아 두면 시스템 글자
    // 크기 2.0 에서 이름·판정이 알약 밖으로 넘친다. 최소 높이로만 잡고
    // 내용이 높이를 정하게 둔다.
    return MergeSemantics(
        child: Container(
      constraints: const BoxConstraints(minHeight: 49),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이름과 판정은 크림 위에, 막대와 눈금은 흰 판 위에 둔다 —
            // 시안이 그렇게 갈랐고, 눈금 숫자가 색 위에 있으면 읽기 어렵다.
            SizedBox(
              width: 66,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metricLabel,
                    ),
                  ),
                  if (band case final band?) ...[
                    const SizedBox(height: 2),
                    Text(
                      band.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: band.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 1.7, 3, 1.7),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9.5),
                      child: LinearProgressIndicator(
                        // 서버가 준 값의 방향을 뒤집지 않는다 — 뒤집으면 같은
                        // 숫자가 지표마다 다른 길이로 그려진다.
                        value: shown / 100,
                        // 화면에서 숫자를 걷어냈으므로(길이와 눈금이 대신한다)
                        // 스크린리더에는 값을 직접 실어 준다. 안 실으면 읽어
                        // 주는 것이 이름과 상태어뿐이라 지표가 얼마인지 알 길이
                        // 없다 — 눈으로 보는 사람만 막대 길이로 짐작할 수 있다.
                        //
                        // **자른 값을 싣는다.** 원값을 실으면 접근성 트리가
                        // "0~100 을 벗어났다"며 던진다 — 화면은 멀쩡한데
                        // 스크린리더를 켠 사용자에게만 터진다.
                        semanticsValue: '$shown',
                        minHeight: 14,
                        backgroundColor: AppColors.surfaceCardWarm,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        _AxisLabel('0'),
                        Spacer(),
                        _AxisLabel('50'),
                        Spacer(),
                        _AxisLabel('100'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 변화량 칸. 흰 판 밖(크림 위)에 둔다 — 눈금과 같은 판에 올리면
            // '+5' 가 100 옆에 붙어 눈금의 일부로 읽힌다.
            if (delta case final delta?)
              SizedBox(
                width: 40,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      delta > 0 ? '+$delta' : '$delta',
                      // '+7' 은 그대로 읽으면 무엇의 7 인지 알 수 없다.
                      semanticsLabel: '직전 분석 대비 $delta',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: AppColors.axisInk,
      ),
    );
  }
}
