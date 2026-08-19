import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/metric_palette.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../../shared/widgets/highlight_row.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../../../shared/widgets/skin_mascot.dart';
import '../../../../shared/widgets/top_wash.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../providers/skin_analysis_notifier.dart';

/// S05 — 분석 완료. 확정 시안 구성이다:
/// 체크 아이콘 · 타입 카드(점수·지표 4종·요약·하이라이트) · "앞으로 이런 기준으로"
/// 카드 · 시작 버튼.
///
/// 시안이 지표 **원**을 4개만 그리는 것은 확인받은 의도다(서버는 5개를 준다).
/// trouble 은 원이 없지만 관찰 근거에는 들어간다 — 이유는 [_evidenceMetrics] 참고.
///
/// **점수와 하이라이트는 반드시 화면에 있어야 한다.** 산식이 공개돼 있어
/// 심사위원이 직접 검산할 수 있다는 게 이 기능의 근거다(PRD §4.1). 시안이 이
/// 자리를 그리지 않았을 뿐이라, 타입 카드 안에 넣어 화면을 새로 만들지 않는다.
/// 프로필 설문은 이 화면 **앞**, 로딩 자리에 있다(S04). 설문에 답하고 들어온
/// 사용자는 갭 카드에 필요한 것이 이미 갖춰져 있다 — 설문보다 분석이 먼저
/// 끝났다면 로딩 화면이 결과를 다시 받아 두고 넘긴다(`_refetchForGap`).
///
/// 설문을 그냥 닫았거나 촬영 안내에서 넘어간 사용자는 타입이 비어 있고, 그때는
/// 갭 카드 자리에 인라인 칩(`_SkinTypePrompt`)이 대신 뜬다. 그 칩은 여기서
/// 고르는 값이라 자기가 직접 다시 받아 온다.
class SkinResultPage extends ConsumerWidget {
  const SkinResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skinAnalysisNotifierProvider);

    // 방금 찍고 들어온 경우와 홈에서 들어온 경우가 다르다.
    // 후자는 Notifier 가 비어 있으므로 최신 기록으로 떨어뜨린다.
    final analysis = state.analysis.value ??
        ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;

    if (analysis == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 카드 제목. 오늘 측정한 값이 있으면 그쪽이 맞다 — 이 화면은 방금 한 분석의
    // 결과지, 자기 소개가 아니다. 서버가 못 냈을 때만 자가 신고 타입으로 떨어진다.
    //
    // skinTypeGap 이 아니라 skinType 을 본다. 둘의 타입은 이제 같은 값이지만
    // 갭 카드는 사용자가 타입을 안 골랐으면 통째로 null 이라, 그쪽에 기대면
    // 건너뛴 사용자에게는 오늘 측정한 타입이 제목에 영영 안 나온다.
    final declaredType = switch (ref.watch(authNotifierProvider)) {
      Authenticated(:final user) => user.declaredSkinType,
      _ => null,
    };
    final headline = _headline(analysis, declaredType);

    return Scaffold(
      body: Stack(
        children: [
          const TopWash(),
          SafeArea(
            child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 8, AppTheme.pagePadding, 32),
        children: [
          _ResultHeader(analysis: analysis, headline: headline),
          const SizedBox(height: 24),

          // 지표 막대 5개. 시안이 원 4개를 막대 5개로 바꿨고, 서버가 주는
          // trouble 이 화면에 처음 나온다 — 음식 결과의 룰 이유가 인용하는
          // 지표라, 한 번도 보여준 적 없는 값으로 감점을 설명하던 문제가 사라진다.
          _MetricBars(analysis: analysis),
          const SizedBox(height: 24),

          _CareSection(analysis: analysis),

          // 서버가 못 냈으면(예전 분석이거나 응답을 못 믿을 때) 키 자체가 없다.
          // 그때는 카드를 숨긴다 — 빈 값으로 그리면 없는 데이터를 보여주는 셈이다.
          //
          // **범위(18~80)는 앱에서 다시 보지 않는다.** 서버가 그 밖의 나이를 받으면
          // 카드를 통째로 빼고 키를 생략한다(`SkinAnalysisService.skinAge`, 백엔드
          // 테스트 "피부 나이가 18~80 밖이면 카드를 통째로 뺀다"). 앱이 같은 창을
          // 한 벌 더 들면 서버가 창을 옮긴 날 한쪽만 따라간다.
          if (analysis.skinAge != null) ...[
            const SizedBox(height: 22),
            _SkinAgeCard(skinAge: analysis.skinAge!),
          ],

          const SizedBox(height: 22),
          const _CriteriaCard(),

          const SizedBox(height: 22),
          if (analysis.skinTypeGap != null)
            _GapCard(gap: analysis.skinTypeGap!)
          else
            _SkinTypePrompt(analysisId: analysis.id),

          const SizedBox(height: 26),
          // 시안 버튼은 높이 50 · 곡률 14 다. 테마 기본값(48 · 8)을 이 자리만
          // 덮는다 — 테마를 바꾸면 촬영·설문 화면 버튼까지 같이 커진다.
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push(Routes.foodCapture),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text('내 피부 맞춤 음식 분석 시작하기'),
            ),
          ),
          // S10 진입점. 방금 분석의 id 로 물어야 오늘 결과와 짝이 맞는다.
          // FeatureFlags 로 감싸지 않는다 — 켜 놓을 화면이라 항상 true 인 플래그는
          // 스위치가 아니라 "여기 스위치가 있다"는 착각만 남긴다.
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.push('${Routes.skinInsight}/${analysis.id}'),
            child: const Text('내 생활 상태와 함께 분석하기'),
          ),
          // S08 진입점. 방금 분석의 id 로 추천을 물어야 오늘 결과와 짝이 맞는다.
          if (FeatureFlags.recommendationScreen) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  context.push('${Routes.recommendations}/${analysis.id}'),
              child: const Text('오늘의 추천 음식 보기'),
            ),
          ],
          const SafetyNotice(),
        ],
            ),
          ),
        ],
      ),
    );
  }
}

// 지표 밴드는 shared/enums/metric_band.dart 로 옮겼다. 인사이트 화면(S10)이 같은
// 지표를 같은 색으로 칠해야 하는데, 여기 private 으로 두면 그쪽이 다른 기준을
// 쓰게 되고 두 화면에서 같은 값이 다른 색으로 나온다.

/// 타입 카드의 제목을 정한다.
///
/// 서버 문구가 1순위다. 타입만이 아니라 오늘의 상태까지 조합돼 있어서
/// ("건성 · 붉은기") 앱이 더 얹을 것이 없다.
///
/// 문구가 없을 때만 타입 하나로 떨어진다. 그 타입도 세 군데를 순서대로 본다.
///
/// **`skinType` 이 없어서 뒤로 넘어가는 일은 지금은 없다** — 서버가 AI 원본이 아니라
/// 저장된 지표에서 매번 다시 만들어서 확장 필드가 없던 옛 기록에도 온다. 그래도
/// 체인을 남긴다. 계약이 바뀌었다고 옛 기록을 여는 순간 제목이 비어서는 안 된다.
/// 뒤 두 칸도 빌 수 있다 — 갭 카드는 사용자가 타입을 건너뛰면 없고, 자가 신고도
/// 마찬가지다. 그래서 마지막에 '오늘의 피부' 가 있다.
///
/// 폴백에만 '피부' 를 붙인다. 타입 하나면 "건성" 보다 "건성 피부" 가 제목처럼 읽힌다.
/// 서버 문구에는 붙이지 않는다 — 괄호로 끝나는 것이 있어 "…(수부지) 피부" 로 깨진다.
String _headline(SkinAnalysis analysis, SkinType? declaredType) {
  final label = analysis.skinType?.label ?? '';
  if (label.isNotEmpty) return label;

  final type = analysis.skinType?.primary ??
      analysis.skinTypeGap?.observed ??
      declaredType;

  return type == null ? '오늘의 피부' : '${type.label} 피부';
}

/// 화면 머리 — 제목 · 분석 날짜 · 마스코트 · 오늘의 피부 타입.
///
/// 시안이 옛 "분석이 완료됐어요" 확인 화면을 걷어내고 결과를 바로 편다. 촬영 →
/// 로딩 → 결과 흐름에서 로딩 화면이 이미 "분석이 완료됐어요"를 말하므로, 같은
/// 말을 한 번 더 하는 화면이 사이에 끼어 있던 셈이다.
///
/// **총점은 배지에 남긴다.** 시안에는 총점 자리가 없지만 산식이 공개돼 있어
/// 직접 검산할 수 있다는 것이 이 기능의 근거다(PRD §4.1). 시안이 그 자리에 둔
/// "민감도 높음" 은 서버 응답에 대응하는 필드가 없어 그리지 않는다 —
/// 상태 문구는 `skinType.label` 에 이미 조합돼 들어온다.
class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.analysis, required this.headline});

  final SkinAnalysis analysis;

  /// 서버가 조합해 준 문구. "건성 · 붉은기" 처럼 오늘의 상태까지 들어 있다.
  final String headline;

  @override
  Widget build(BuildContext context) {
    final at = analysis.analyzedAt;
    // 서버가 매긴 등급이다 — 앱에 경계표를 두지 않는다.
    final grade = analysis.grade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목을 Expanded 로 감싼다. 시스템 글자 크기 2.0 에서 24px 제목과
        // 체크 아이콘이 한 줄에 들어가지 않아 오른쪽으로 78px 넘쳤다 —
        // 감싸 두면 그때만 두 줄로 접힌다.
        const Row(
          children: [
            Expanded(
              child: Text(
                '피부 분석 결과',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline,
                size: 22, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '분석 날짜 : ${at.year}년 ${at.month}월 ${at.day}일',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SkinMascot(size: 150),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: grade?.tintColor ?? AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '종합 ${analysis.skinScore}점',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: grade?.accentColor ?? AppColors.textOnCard,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 서버 문구를 그대로 쓴다 — 뒤에 '피부' 같은 것을 이어 붙이지
                  // 않는다. '수부지' 처럼 괄호로 끝나는 문구가 있어서 붙이면
                  // "…(수부지) 피부" 로 깨진다.
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  // 타입 설명은 서버에 필드가 없어 enum 에 붙은 고정 UI 문구다
                  // (마이페이지와 같은 값을 쓴다).
                  if (analysis.skinType?.primary?.description
                      case final description?) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        height: 15 / 10,
                        color: AppColors.bodyInk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 지표 5개를 막대로 편다. 크림 알약 안에 흰 판이 앉고, 그 안에 눈금 막대가 있다.
///
/// 색은 **지표의 이름표**다(수분은 파랑, 홍조는 빨강…). 상태를 뜻하지 않는다 —
/// 색으로 상태를 말하면 홍조 막대가 길수록 빨개져 "많을수록 좋다"로 읽히는데
/// 홍조는 반대다. 그래서 **길이는 값, 색은 지표, 말은 판정([MetricBand])** 으로
/// 셋을 나눈다.
///
/// 시안 캡션("점수가 높을 수록 좋게 나온 수치입니다")은 쓰지 않는다. 유분·홍조·
/// 트러블은 높을수록 나쁘고 그 사실이 `toBars()` 의 방향 플래그에 박혀 있어서,
/// 그 문장을 그대로 옮기면 화면이 다섯 지표 중 셋에 대해 거짓말을 한다.
class _MetricBars extends StatelessWidget {
  const _MetricBars({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '지표마다 좋은 방향이 달라 상태어를 함께 적었어요.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.bodyInk,
          ),
        ),
        const SizedBox(height: 12),
        for (final bar in analysis.metrics.toBars())
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MetricBar(
              label: bar.label,
              value: bar.value,
              color: MetricPalette.of(bar.key).bar,
              // 상태어는 서버가 그 지표에 매긴 등급에서 나온다.
              band: MetricBand.of(analysis.levelOf(bar.key),
                  higherIsBetterMetric: bar.higherIsBetter),
            ),
          ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
    required this.band,
  });

  final String label;
  final int value;
  final Color color;

  /// 서버 등급을 모르면 null 이고, 그때는 상태어 줄을 그리지 않는다.
  final MetricBand? band;

  @override
  Widget build(BuildContext context) {
    // **높이를 고정하지 않는다.** 시안 값(49)을 그대로 박아 두면 시스템 글자
    // 크기 2.0 에서 이름·판정이 알약 밖으로 넘친다. 최소 높이로만 잡고
    // 내용이 높이를 정하게 둔다.
    return Container(
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
                    color: Color(0xFF737373),
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
                      // 서버가 준 원값을 그대로 쓴다. 방향을 뒤집지 않는다 —
                      // 뒤집으면 같은 숫자가 지표마다 다른 길이로 그려진다.
                      value: (value / 100).clamp(0.0, 1.0),
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
        ],
        ),
      ),
    );
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
        color: Color(0xFF545454),
      ),
    );
  }
}

/// "지금 피부가 필요로 하는 관리" — 관리 축 칩 · 권고 문단 · 하이라이트 · 관찰 근거.
///
/// 칩(`careFocus`)과 문단(`careMessage`)을 **서버가 준다.** 지표에서 규칙으로
/// 도출한 값이라(`SkinCareGuide`) 같은 사진은 언제 열어도 같은 문구이고, 예전에
/// 저장된 분석에도 나온다 — 하이라이트와 같은 성격이다.
///
/// 앱이 지표를 보고 축을 고르지 않는다. 그러면 "무엇을 챙겨야 하는가"의 기준이
/// 서버와 앱 두 곳에 생기고, 룰 임계값을 바꾼 날 한쪽만 따라간다.
///
/// `careMessage` 가 없는 응답(이 필드 이전 서버)에서는 `summary` 로 떨어진다 —
/// 관찰 요약이라 권고와 다른 말이지만, 빈 카드보다는 낫다.
class _CareSection extends StatelessWidget {
  const _CareSection({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final rows = _evidenceRows(analysis);
    final text = _careText(analysis);

    // 칩도 문장도 하이라이트도 근거도 없는 응답(새 필드 이전 서버 + 요약까지 빈
    // 기록)이면 제목만 남는다. 빈 카드는 오류처럼 보이므로 통째로 접는다.
    if (analysis.careFocus.isEmpty &&
        text == null &&
        analysis.highlights.isEmpty &&
        rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목을 Expanded 로 감싼다. 글자 크기 2.0 에서 14px 제목이 두 배가 되어
        // 한 줄에 들어가지 않는다 — 감싸 두면 그때만 두 줄로 접힌다.
        const Row(
          children: [
            LeafMark(),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                '지금 피부가 필요로 하는 관리',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyInk,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 관리 축 칩. 서버가 지표에서 규칙으로 낸 것을 라벨 그대로 그린다.
        if (analysis.careFocus.isNotEmpty) ...[
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final focus in analysis.careFocus)
                Container(
                  // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
                  // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
                  constraints: const BoxConstraints(minHeight: 22),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    focus.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCardSand,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 서버가 만든 권고 문단. 없으면 관찰 요약으로 떨어지고, 그것마저
              // 없으면 자리를 비운다 — 둘 다 서버 문장이고 앱이 짓는 문장은
              // 하나도 없다. "두드러지는 지표가 없어요" 같은 문장을 앱이 채우면
              // 그건 서버가 하지 않은 판정이다.
              if (text != null)
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    height: 20 / 12,
                    color: Color(0xFF4D1700),
                  ),
                ),
              if (analysis.highlights.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.borderOnCream),
                const SizedBox(height: 10),
                for (final highlight in analysis.highlights)
                  HighlightRow(highlight: highlight),
              ],
              // 지표 숫자가 왜 그 숫자인지. 서버가 사진에서 본 것을 지표당 최대
              // 2줄로 내려준다 — 앱이 점수에서 문장을 짓지 않는다. 확장 필드가
              // 없던 기록은 근거가 비어 있고, 그때는 토글째 사라진다.
              if (rows.isNotEmpty) _EvidenceSection(rows: rows),
            ],
          ),
        ),
      ],
    );
  }
}

/// 관리 문단으로 쓸 **서버 문장**. 없으면 null 이다.
///
/// `careMessage`(서버가 지표에서 만든 권고) → `summary`(AI 관찰 요약) 순이다.
/// 둘 다 없으면 아무 문장도 만들지 않는다.
String? _careText(SkinAnalysis analysis) {
  if (analysis.careMessage case final message? when message.isNotEmpty) {
    return message;
  }
  if (analysis.summary.isNotEmpty) return analysis.summary;
  return null;
}

/// 관찰 근거를 그리는 순서와 이름.
///
/// **지표 원보다 한 줄 많다.** 원은 시안대로 4개지만 근거는 trouble 까지 5개다 —
/// 서버 룰 R03 의 판정 이유가 음식 결과에서 "지금 트러블 지표가 … 상태에서" 라고
/// 인용하는데, 서버 `highlights` 는 위치 기반 3줄이라 트러블이 탈락할 수 있다.
/// 그러면 앱이 한 번도 보여준 적 없는 상태를 근거로 감점을 설명하게 된다.
/// 원 없이 근거만 있는 줄이 생기는 것보다 그쪽이 나쁘다.
///
/// 이름은 **서버 문구를 따른다.** barrier 는 '장벽'이다 — 하이라이트가 "피부 장벽
/// 양호", 룰 이유가 "지금 장벽 지표가 …" 이다. '피부결'로 부르면 나이 축
/// `skinTexture`(프롬프트가 정의한 이름이 '피부결'이다)와 한 화면에서 같은 이름이
/// 두 지표를 가리킨다.
const _evidenceMetrics = [
  ('hydration', '수분'),
  ('oil', '유분'),
  ('redness', '홍조'),
  ('trouble', '트러블'),
  ('barrier', '장벽'),
];

/// (지표 이름, 관찰 문장) 줄 목록. **지표당 한 줄이다.**
///
/// 서버는 지표당 문장을 최대 2개 준다(`METRIC_EVIDENCE_MAX`). 문장마다 줄을 만들면
/// 그 줄마다 지표 이름이 다시 찍혀서 "수분이 두 번 떴다"로 읽힌다 — 2026-08-18
/// 실기기 QA 에서 실제로 그렇게 신고됐다. 픽스처와 `AI_MOCK` 이 지표당 1문장뿐이라
/// 위젯 테스트도 에뮬레이터도 이 경우를 한 번도 그리지 않았다.
///
/// 문장은 손대지 않고 구분자만 넣는다. `·` 는 이 앱이 이미 쓰는 기호다
/// ("건성 · 붉은기" · "매운 정도 · 보통").
///
/// 근거가 없는 지표는 줄을 만들지 않는다.
List<(String, String)> _evidenceRows(SkinAnalysis analysis) {
  final byKey = {
    for (final detail in analysis.metricDetails) detail.key: detail,
  };

  return [
    for (final (key, label) in _evidenceMetrics)
      if (byKey[key]?.evidence case final sentences?
          when sentences.isNotEmpty)
        (label, sentences.join(' · ')),
  ];
}

/// "관찰 근거 자세히 보기" — 접어 둔 지표별 관찰 문장.
///
/// 기본은 접힘이다. 지표 5줄이고 한 줄에 문장이 둘까지 들어가서, 펼쳐 둔 채로 두면
/// 점수·요약·하이라이트가 있는 카드가 문장으로 덮인다. 숫자를 대신하는 것이 아니라
/// 그 아래 한 겹이다.
///
/// 문장은 서버가 만든 것을 그대로 옮긴다.
class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // 기본 ExpansionTile 은 위아래 구분선을 그린다. 카드 안에 넣으면
      // 시안에 없던 칸막이가 생긴다.
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      iconColor: AppColors.textSecondary,
      collapsedIconColor: AppColors.textSecondary,
      title: const Text(
        '관찰 근거 자세히 보기',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      children: [
        // 지표 이름을 고정폭 칸으로 세우지 않는다. 시스템 글자 크기를 키우면
        // '트러블' 이 그 칸에서 두 줄로 접힌다. 한 문단으로 흘려 두면 어떤
        // 배율에서도 문장처럼 이어진다.
        for (final (label, line) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(text: line),
                ],
              ),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textBody,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// AI 추정 피부 나이 카드.
///
/// 실제 나이를 맞히는 것이 아니라 사진 기반 외관 추정이라, 보조 문구를 항상 같이
/// 띄운다. 숫자만 크게 놓으면 측정값으로 읽힌다.
///
/// 설명 문장은 서버가 만든다 — 앱이 짓거나 고치지 않는다.
class _SkinAgeCard extends StatelessWidget {
  const _SkinAgeCard({required this.skinAge});

  final SkinAge skinAge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            LeafMark(),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'AI 추정 피부 나이',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyInk,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCardSand,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${skinAge.estimatedSkinAge}세',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (skinAge.assessment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  skinAge.assessment,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    height: 20 / 12,
                    color: Color(0xFF4D1700),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // 실제 나이를 맞히는 것이 아니라 사진 기반 외관 추정이라, 보조
              // 문구를 항상 같이 띄운다. 숫자만 놓으면 측정값으로 읽힌다.
              const Text(
                '사진 속 피부결, 주름, 탄력, 피부톤 등을 종합한 AI 추정값입니다.',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                  color: Color(0xFF4D1700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "앞으로 음식 분석은 이런 기준으로" — 두 기둥 안내 카드.
class _CriteriaCard extends StatelessWidget {
  const _CriteriaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('앞으로 음식 분석은 이런 기준으로',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                _column(Icons.face_retouching_natural, '피부 고민 맞춤 분석',
                    '민감도, 수분, 피지 밸런스 등\n내 피부 고민을 고려해 분석해요.'),
                const VerticalDivider(
                    width: 1, color: AppColors.borderOnWhite),
                _column(Icons.restaurant_menu, '영양 균형 체크',
                    '음식의 영양 구성을 확인하고\n피부에 어떤 영향을 줄지 알려드려요.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(IconData icon, String title, String description) => Expanded(
        child: Column(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBody,
                )),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.textBody,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

/// "알고 계셨던 것과 오늘 측정이 다르다"를 보여주는 카드.
/// 문장은 서버가 만들어 준다 — 앱이 조합하면 규칙이 두 곳에 생긴다.
class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap});

  final SkinTypeGap gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardSand,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GapChip(label: '평소 생각', value: gap.declared.label),
              _GapChip(label: '오늘 측정', value: gap.observed.label),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gap.message,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              height: 20 / 12,
              color: Color(0xFF4D1700),
            ),
          ),
        ],
      ),
    );
  }
}

/// 갭 카드의 두 칸. "평소 생각 · 지성" 처럼 라벨과 값을 한 칩에 담는다.
class _GapChip extends StatelessWidget {
  const _GapChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$label · $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// 피부 타입을 아직 안 고른 사용자. 갭 카드 자리에 선택 칩이 대신 뜬다.
/// 건너뛴 사용자도 결과를 본 뒤 마음이 바뀌면 그 자리에서 고를 수 있다. (PRD §4.4.1)
class _SkinTypePrompt extends ConsumerStatefulWidget {
  const _SkinTypePrompt({required this.analysisId});

  final int analysisId;

  @override
  ConsumerState<_SkinTypePrompt> createState() => _SkinTypePromptState();
}

class _SkinTypePromptState extends ConsumerState<_SkinTypePrompt> {
  bool _busy = false;

  Future<void> _select(SkinType type) async {
    setState(() => _busy = true);

    final failure =
        await ref.read(authNotifierProvider.notifier)
            .updateProfile(declaredSkinType: type);

    if (failure == null) {
      // 갭 문장은 서버가 만든다. 다시 받아야 카드가 뜬다.
      await ref
          .read(skinAnalysisNotifierProvider.notifier)
          .refresh(widget.analysisId);
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardSand,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '평소 본인 피부는 어떻다고 생각하세요?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyInk,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in SkinType.selectable)
                GestureDetector(
                  onTap: _busy ? null : () => _select(type),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    // 높이를 박지 않는다 — 시안 값을 고정하면 글자 크기를 키운 기기에서
                    // 알약이 글자를 자른다(예외가 안 나서 테스트도 통과한다).
                    constraints: const BoxConstraints(minHeight: 22),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                          color: _busy ? AppColors.disabled : AppColors.primary),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _busy ? AppColors.disabled : AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
