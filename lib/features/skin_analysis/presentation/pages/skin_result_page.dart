import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/feature_flags.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../../shared/widgets/highlight_row.dart';
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
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 0, AppTheme.pagePadding, 32),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child:
                  const Icon(Icons.check, size: 38, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text('분석이 완료됐어요',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          // 프로필이 이 화면보다 뒤로 옮겨갔다. "설정한 프로필을 바탕으로"는
          // 온보딩 사용자에게 거짓말이고, 자가 신고 값은 원래 점수에 안 들어간다.
          const Center(
            child: Text(
              '방금 촬영한 사진으로\n오늘의 피부 상태를 분석했어요 : )',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ),
          const SizedBox(height: 36),

          _TypeCard(analysis: analysis, headline: headline),

          // 서버가 못 냈으면(예전 분석이거나 응답을 못 믿을 때) 키 자체가 없다.
          // 그때는 카드를 숨긴다 — 빈 값으로 그리면 없는 데이터를 보여주는 셈이다.
          // 범위도 앱에서 한 번 더 본다. 서버가 막고 있지만, 회귀가 나면
          // "AI 추정 피부 나이 0세" 가 확신에 찬 설명 문장 옆에 그려진다.
          if (analysis.skinAge?.isUsable ?? false) ...[
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
          ElevatedButton(
            onPressed: () => context.push(Routes.foodCapture),
            child: const Text('음식 분석 시작하기'),
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

/// "건성 · 붉은기" 카드 — 제목·점수와 지표 4종 원.
class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.analysis, required this.headline});

  final SkinAnalysis analysis;

  /// 서버가 조합해 준 문구. "건성 · 붉은기" 처럼 오늘의 상태까지 들어 있다.
  final String headline;

  @override
  Widget build(BuildContext context) {
    final metrics = analysis.metrics;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // **제목 하나만 남았다.** 예전에는 여기에 제목(규칙 도출 타입)과
              // 칩(AI 관찰 타입)이 나란히 있었다. 서버가 둘로 판정하던 시절의
              // 흔적인데, 값이 갈리면 "지성 피부" 옆에 "건성 · 민감 경향" 이
              // 붙는 화면이 나왔다. 서버가 판정을 하나로 모으면서 칩은 제목과
              // 같은 말을 두 번 하는 자리가 됐고, 문구에 상태까지 들어오므로
              // 제목이 그대로 그 역할을 한다.
              //
              // 서버 문구를 그대로 쓴다 — 뒤에 '피부' 같은 것을 이어 붙이지
              // 않는다. '수부지' 처럼 괄호로 끝나는 문구가 있어서 붙이면
              // "…(수부지) 피부" 로 깨진다.
              //
              // 폭은 계속 새던 자리라 Expanded 로 감싼 채 둔다 — QA 에서 기본
              // 글자 크기에도 "복합성 · T존 ..." 으로 잘렸고 2.0 에서는 제목까지
              // "보통..." 이 됐다. 이제 경쟁하는 요소가 하나 줄었지만, 상태가
              // 둘 붙으면 문구는 그때만큼 길어진다.
              Expanded(
                child: Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 서버가 준 총점. 앱에서 다시 계산하지 않는다.
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${analysis.skinScore}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const TextSpan(
                      text: '점',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _Metric(
                label: '수분',
                band: MetricBand.higherIsBetter(metrics.hydration),
                icon: Icons.water_drop,
                foreground: AppColors.hydrationFg,
                background: AppColors.hydrationBg,
              ),
              _Metric(
                label: '유분',
                band: MetricBand.higherIsWorse(metrics.oil),
                icon: Icons.opacity,
                foreground: AppColors.oilFg,
                background: AppColors.oilBg,
              ),
              _Metric(
                label: '홍조',
                band: MetricBand.higherIsWorse(metrics.redness),
                icon: Icons.waves,
                foreground: AppColors.rednessFg,
                background: AppColors.rednessBg,
              ),
              _Metric(
                label: '장벽',
                band: MetricBand.higherIsBetter(metrics.barrier),
                icon: Icons.auto_awesome,
                foreground: AppColors.textureFg,
                background: AppColors.textureBg,
              ),
            ],
          ),

          // 지표 숫자가 왜 그 숫자인지. 서버가 사진에서 본 것을 지표당 최대
          // 2줄로 내려준다 — 앱이 점수에서 문장을 짓지 않는다. 확장 필드가
          // 없던 기록은 근거가 비어 있고, 그때는 토글째 사라진다.
          if (_evidenceRows(analysis) case final rows when rows.isNotEmpty) ...[
            const SizedBox(height: 4),
            _EvidenceSection(rows: rows),
          ],

          // 서버가 만든 한 줄 요약. 앱이 문장을 짓지 않는다.
          if (analysis.summary.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              analysis.summary,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ],

          if (analysis.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderOnWhite),
            const SizedBox(height: 14),
            for (final highlight in analysis.highlights)
              HighlightRow(highlight: highlight),
          ],
        ],
      ),
    );
  }
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

/// (지표 이름, 관찰 문장) 줄 목록. 근거가 없는 지표는 줄을 만들지 않는다.
List<(String, String)> _evidenceRows(SkinAnalysis analysis) {
  final byKey = {
    for (final detail in analysis.metricDetails) detail.key: detail,
  };

  return [
    for (final (key, label) in _evidenceMetrics)
      for (final line in byKey[key]?.evidence ?? const <String>[]) (label, line),
  ];
}

/// "관찰 근거 자세히 보기" — 접어 둔 지표별 관찰 문장.
///
/// 기본은 접힘이다. 지표 4개 × 최대 2줄이라 펼쳐 둔 채로 두면 점수·요약·하이라이트가
/// 있는 카드가 문장으로 덮인다. 숫자를 대신하는 것이 아니라 그 아래 한 겹이다.
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.band,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final MetricBand band;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(shape: BoxShape.circle, color: background),
            child: Icon(icon, size: 24, color: foreground),
          ),
          const SizedBox(height: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text(band.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: band.color,
              )),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.primary, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Flexible 이 없으면 시스템 글자 크기를 키웠을 때 하드 오버플로다.
              // 두 자식이 다 고정 크기라 늘어날 자리가 없다.
              // Flexible + Spacer 로 두면 남는 폭을 반씩 나눠 가져서, Spacer 가
              // 120px 를 붙들고 있는데 제목만 "AI 추정 피부 나…" 로 잘린다.
              // Expanded 하나면 오른쪽 정렬은 그대로고 제목이 여유를 다 쓴다.
              const Expanded(
                child: Text(
                  'AI 추정 피부 나이',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${skinAge.estimatedSkinAge}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const TextSpan(
                      text: '세',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (skinAge.assessment.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              skinAge.assessment,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            '사진 속 피부결, 주름, 탄력, 피부톤 등을 종합한 AI 추정값입니다.',
            style: TextStyle(fontSize: 10, color: AppColors.textBody, height: 1.4),
          ),
        ],
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('평소 생각하신 타입 : ${gap.declared.label}'),
            Text('오늘 측정 기준     : ${gap.observed.label}'),
            const Divider(),
            Text(gap.message),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('평소 본인 피부는 어떻다고 생각하세요?'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final type in SkinType.selectable)
                  ActionChip(
                    label: Text(type.label),
                    onPressed: _busy ? null : () => _select(type),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
