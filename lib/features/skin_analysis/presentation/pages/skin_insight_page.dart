import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/metric_palette.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../shared/enums/metric_band.dart';
import '../../../../shared/enums/skin_type.dart';
import '../../../../shared/widgets/metric_bar.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/section_mark.dart';
import '../../../../shared/widgets/skin_mascot.dart';
import '../../../../shared/widgets/top_wash.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/entities/skin_insight.dart';
import '../skin_headline.dart';
import '../providers/skin_analysis_notifier.dart';

/// S10 — 개인화 피부 인사이트.
///
/// 사용자가 3초 안에 넷을 읽어야 한다: 내 피부가 지금 어떤지, 최근 생활이 어떤지,
/// AI 가 무엇을 중요하게 보는지, 오늘 무엇을 하면 되는지. 섹션 순서가 그 순서다.
///
/// **골격은 결과 화면(S05)을 따른다.** 옅은 오렌지 물([TopWash]) 위에
/// 큰 제목 · 마스코트 · 등급 배지가 서고, 그 아래로 잎사귀 마크가 붙은 구역 제목과
/// 모래색 카드가 이어진다. 예전에는 이 화면만 Material 기본 AppBar 에 회색 테두리
/// 카드를 써서, 결과에서 한 탭 건너온 사용자에게 다른 앱처럼 보였다.
///
/// **문장은 하나도 앱이 만들지 않는다.** summary·description·행동 문구 전부 서버가
/// 준 것을 그대로 싣는다 — 앱이 인과관계를 지어내면 의학적 표현 금지 규칙이 두
/// 곳으로 갈리고, 그중 하나는 아무도 안 본다.
class SkinInsightPage extends ConsumerWidget {
  const SkinInsightPage({super.key, required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final needsLifestyle =
        auth is Authenticated && auth.user.hasIncompleteLifestyle;

    return Scaffold(
      body: Stack(
        children: [
          const TopWash(),
          SafeArea(
            child: Column(
              children: [
                // 제목은 본문 맨 위에 있다(S05 와 같다). 그래서 상단 바에는
                // 출구만 남는다 — 같은 말을 AppBar 와 제목 두 곳에 쓰지 않는다.
                const _BackBar(),
                // **습관이 비어 있으면 조회 자체를 하지 않는다.** `GET /skin-insights` 는
                // get-or-create 라, 한 번이라도 부르면 서버가 습관 없이 인사이트를 만들어
                // 저장한다 — 그 뒤에 습관을 채워도 생활 관련 주제는 영영 안 들어간다.
                // 그래서 [skinInsightProvider] 를 watch 하기 **전에** 갈라야 한다.
                //
                // 게이트를 진입점(결과 화면·피부 프로필)이 아니라 여기 두는 이유 — 진입점이
                // 둘이고 앞으로 늘어난다. 화면마다 가드를 두면 언젠가 한 곳을 빠뜨리고,
                // 그 한 곳이 습관 없는 인사이트를 굳혀 버린다.
                Expanded(
                  child: needsLifestyle
                      ? const _LifestyleNeeded()
                      : _InsightView(skinAnalysisId: skinAnalysisId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면의 유일한 출구. 아이콘은 시안대로 19 지만 **누를 곳은 44 다** —
/// constraints 를 비워 두면 IconButton 이 아이콘 크기로 쪼그라든다.
class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        // 44 과녁 안에서 19 아이콘이 가운데 서므로, 아이콘의 왼쪽 끝이 본문
        // 여백(32)과 맞으려면 과녁을 그만큼 왼쪽에서 시작해야 한다.
        padding: const EdgeInsets.only(left: AppTheme.pagePadding - 12),
        child: IconButton(
          // 밑에 깔린 화면이 없을 때 pop 은 던진다. AppBar 의 자동 뒤로가기는
          // canPop 일 때만 그려져서 이 문제가 없었는데, 손으로 그린 막대는 늘
          // 보인다 — 딥링크나 위치 복원으로 들어오면 유일한 출구가 터진다.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          tooltip: '뒤로',
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 19, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// 습관을 아직 안 채운 사용자에게 **왜** 필요한지 먼저 말한다.
///
/// 곧바로 설문으로 튕기지 않는 이유 — 이 화면은 사용자가 "내 생활 상태와 함께
/// 분석하기" 를 눌러서 온 곳이다. 이유 없이 설문이 뜨면 가입 때 "선택" 이라고
/// 했던 항목이 갑자기 필수가 된 것으로만 읽힌다.
class _LifestyleNeeded extends StatelessWidget {
  const _LifestyleNeeded();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkinMascot(size: 120),
            const SizedBox(height: 20),
            Text(
              '맞춤 인사이트를 보려면\n생활 습관 정보가 필요해요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '수면·스트레스·운동·수분 네 가지를 알려주시면\n'
              '오늘 피부 상태와 함께 봐 드릴게요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                // push 다 — 입력을 마치면 이 화면으로 돌아와야 한다. 돌아오면
                // authNotifier 의 사용자 정보가 갱신돼 있어 게이트가 풀리고,
                // 그때 처음으로 인사이트를 조회한다.
                onPressed: () => context.push(Routes.lifestyle),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('생활 습관 입력하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게이트를 지난 뒤에만 만들어진다. 여기서 처음 [skinInsightProvider] 를 건드린다.
class _InsightView extends ConsumerWidget {
  const _InsightView({required this.skinAnalysisId});

  final int skinAnalysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(skinInsightProvider(skinAnalysisId));

    return insight.when(
      // 첫 조회는 서버가 AI 를 기다리느라 최대 ~27초다. 스피너만 돌면 멈춘 줄 안다.
      loading: () => const LoadingSteps(
        steps: [
          '피부와 생활 상태를 함께 보고 있어요',
          '오늘 측정한 지표를 살펴보는 중이에요',
          '설정해 둔 생활 습관과 맞춰 보는 중이에요',
          '오늘 신경 쓰면 좋을 것을 고르고 있어요',
        ],
      ),
      error: (error, _) => Center(child: Text('$error')),
      data: (result) => result.when(
        // AI 실패(502·504)는 mapToFailure 가 AnalysisFailure 로 번역하고
        // shouldRetakePhoto 가 false 라 "다시 시도" 가 나온다. 서버가 실패한
        // 인사이트를 저장하지 않으므로 같은 GET 이 그대로 재시도가 된다.
        //
        // 404(타인·없는 분석)는 ServerFailure 로 떨어져 서버 메시지만 보인다.
        failure: (failure) => FailureView(
          failure: failure,
          onRetry: () => ref.invalidate(skinInsightProvider(skinAnalysisId)),
        ),
        success: (data) => _Body(insight: data),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.insight});

  final SkinInsight insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 지표 값은 인사이트 응답에 없다. 분석 쪽에서 읽어 온다.
    //
    // ponytail: 최신 분석 = 이 화면의 분석이라고 가정한다. 피부 히스토리 화면이
    // 없어 진입 경로가 결과 화면 하나뿐이라 지금은 참이다. 과거 분석으로 들어오는
    // 길이 생기면 id 를 비교해 skinRepository.getById 로 떨어뜨린다.
    final analysis = ref.watch(latestSkinAnalysisProvider).value?.dataOrNull;
    final auth = ref.watch(authNotifierProvider);
    final user = auth is Authenticated ? auth.user : null;

    // 스크롤 뷰 + Column 이다(예전부터 그랬고 이번에 바꾼 것은 여백뿐이다).
    // 섹션 수가 고정이라 게으른 목록으로 얻을 것이 없어서 그대로 둔다.
    //
    // **일반 규칙은 아니다.** 결과 화면(S05)은 같은 성격의 내용을 ListView 로
    // 그리고, 그쪽 테스트는 안 보이는 자식이 없다는 전제로 스크롤해서 찾는다.
    // 여기 방식을 저쪽에 옮기거나 그 반대로 하지 마라 — 테스트가 같이 깨진다.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding, 4, AppTheme.pagePadding, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InsightHeader(
              analysis: analysis, declaredType: user?.declaredSkinType),
          const SizedBox(height: 24),
          if (analysis != null) ...[
            const _SectionTitle('현재 피부 상태'),
            const SizedBox(height: 12),
            _MetricsCard(analysis: analysis, changes: insight.changes),
            const SizedBox(height: 22),
          ],
          const _SectionTitle('현재 설정된 생활 상태'),
          const SizedBox(height: 12),
          _LifestyleCard(
            user: user,
            insightsAreEmpty: insight.insights.isEmpty,
            // 설정하고 돌아오면 다시 물어본다. 이 화면은 아래 깔린 채로 살아 있어서
            // autoDispose 가 안 걸리고, 그냥 두면 방금 채운 습관이 반영되지 않는다.
            onProfileChanged: () =>
                ref.invalidate(skinInsightProvider(insight.skinAnalysisId)),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('AI 인사이트'),
          const SizedBox(height: 12),
          _SummaryCard(summary: insight.summary),
          if (insight.insights.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle('오늘의 우선 관리'),
            const SizedBox(height: 12),
            for (final (index, item) in insight.insights.indexed) ...[
              // 첫 항목만 강조 카드다. priority 를 글자로 노출하지 않는다 —
              // HIGH/MEDIUM 은 서버 내부 어휘지 사용자가 배울 말이 아니다.
              _InsightCard(item: item, emphasized: index == 0),
              if (index != insight.insights.length - 1)
                const SizedBox(height: 8),
            ],
          ],
          if (insight.todayActions.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle('오늘의 행동'),
            const SizedBox(height: 12),
            // 우선 관리와 같은 주제가 다시 나온다(서버가 같은 items 로 만든다).
            // 아이콘 없이 한 줄로 납작하게 그려 같은 카드를 두 번 그린 것처럼
            // 보이지 않게 한다 — 위는 "무엇을 볼까", 여기는 "무엇을 할까"다.
            for (final action in insight.todayActions) ...[
              _ActionRow(title: action.title),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 10),
          const Text(
            '측정 환경에 따라 결과가 달라질 수 있어요',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSecondary, height: 1.35),
          ),
          const SafetyNotice(),
        ],
      ),
    );
  }
}

/// 화면 머리 — 제목 · 분석 날짜 · 마스코트 · 등급 배지 · 오늘의 피부 타입.
///
/// 결과 화면(S05)의 머리와 같은 구성이다. 이 화면은 그 결과를 생활 상태와 함께
/// 다시 읽는 자리라, 같은 얼굴로 시작해야 "같은 분석의 다음 장" 으로 읽힌다.
///
/// 최신 분석을 아직 못 받았으면 제목만 남는다 — 없는 점수를 0 으로 그리지 않는다.
class _InsightHeader extends StatelessWidget {
  const _InsightHeader({required this.analysis, this.declaredType});

  final SkinAnalysis? analysis;

  /// 서버 문구가 비었을 때 제목이 기대는 마지막 칸. 결과 화면과 같은 순서를
  /// 쓰려면 여기까지 내려와야 한다 — 없으면 '오늘의 피부' 로 먼저 떨어진다.
  final SkinType? declaredType;

  @override
  Widget build(BuildContext context) {
    final current = analysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목을 Expanded 로 감싼다. 시스템 글자 크기 2.0 에서 24px 제목과
        // 아이콘이 한 줄에 들어가지 않는다 — 감싸 두면 그때만 두 줄로 접힌다.
        const Row(
          children: [
            Expanded(
              child: Text(
                '오늘의 피부 인사이트',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.auto_awesome, size: 22, color: AppColors.primary),
          ],
        ),
        if (current != null) ...[
          const SizedBox(height: 8),
          Text(
            '분석 날짜 : ${current.analyzedAt.year}년 '
            '${current.analyzedAt.month}월 ${current.analyzedAt.day}일',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SkinMascot(size: 130),
              const SizedBox(width: 4),
              Expanded(
              child:
                  _HeaderIdentity(analysis: current, declaredType: declaredType),
            ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeaderIdentity extends StatelessWidget {
  const _HeaderIdentity({required this.analysis, this.declaredType});

  final SkinAnalysis analysis;
  final SkinType? declaredType;

  @override
  Widget build(BuildContext context) {
    // 서버가 매긴 등급이다 — 앱에 경계표를 두지 않는다.
    final grade = analysis.grade;
    // 제목은 결과 화면(S05)과 **같은 함수**가 정한다. 여기서 서버 문구만 보면
    // label 이 비어 온 분석에서 두 화면이 다른 이름을 단다.
    final label = skinHeadline(analysis, declaredType);

    return Column(
      children: [
        Pill(
          minHeight: 20,
          horizontalPadding: 10,
          borderRadius: 12,
          verticalPadding: 4,
          color: grade?.tintColor ?? AppColors.surfaceCard,
          label: '종합 ${analysis.skinScore}점',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: grade?.accentColor ?? AppColors.textOnCard,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.headingInk,
          ),
        ),
        // 타입 설명은 서버에 필드가 없어 enum 에 붙은 고정 UI 문구다
        // (결과 화면·마이페이지와 같은 값을 쓴다).
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
    );
  }
}

/// 구역 제목. 결과 화면과 같은 잎사귀 마크를 단다.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LeafMark(),
        const SizedBox(width: 6),
        // 글자 크기 2.0 에서 14px 제목이 두 배가 되어 한 줄에 안 들어간다 —
        // 감싸 두면 그때만 두 줄로 접힌다.
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.bodyInk,
            ),
          ),
        ),
      ],
    );
  }
}

/// 5지표. 결과 화면(S05)은 시안대로 4개만 그리지만 여기는 다 그린다 —
/// changes 가 5개 전부의 델타를 주고, 트러블 인사이트가 떴을 때 근거 지표가
/// 화면에 없으면 설명이 붕 뜬다.
///
/// 막대는 결과 화면과 **같은 위젯**([MetricBar])이다. 변화량 칸만 더 붙는다.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.analysis, this.changes});

  final SkinAnalysis analysis;
  final SkinInsightChanges? changes;

  @override
  Widget build(BuildContext context) {
    final bars = analysis.metrics.toBars();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오른쪽 숫자가 무엇인지 한 줄로 밝힌다. 첫 분석이면 그 칸이 아예 없고,
        // 0 을 그리거나 칸을 비워 두면 "변화가 없었다"로 읽힌다.
        Text(
          changes == null
              ? '첫 피부 분석이라 아직 비교할 데이터가 없어요'
              : '오른쪽 숫자는 직전 분석과의 차이예요.',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.bodyInk,
          ),
        ),
        const SizedBox(height: 12),
        // 마지막 막대 뒤에는 여백을 두지 않는다. 두면 카드가 끝나는 자리만
        // 다음 구역과의 간격이 8 만큼 넓어져 섹션 경계가 혼자 어긋난다.
        for (final bar in bars)
          Padding(
            padding: EdgeInsets.only(bottom: bar.key == bars.last.key ? 0 : 8),
            child: MetricBar(
              label: bar.label,
              value: bar.value,
              // 막대는 **지표의 이름표 색**이다(결과 화면과 같은 표). 상태색으로
              // 칠하면 같은 유분 59 가 한 탭 건너 다른 색이 된다.
              color: MetricPalette.of(bar.key).bar,
              // 결과 화면(S05)과 같은 밴드를 쓴다 — 상태어의 출처는 서버가 그
              // 지표에 매긴 등급 하나뿐이라, 한 탭 전에 본 같은 지표가 다른
              // 상태어로 뜰 일이 없다.
              band: MetricBand.of(analysis.levelOf(bar.key),
                  higherIsBetterMetric: bar.higherIsBetter),
              delta: changes?.byKey(bar.key),
            ),
          ),
      ],
    );
  }
}

/// ponytail: 게이트가 S10 앞에 서면서 이 카드의 **"미설정" 갈래 전체**가 로그인한
/// 사용자에게 닿지 않는다 — 습관 네 칸이 다 차야 여기까지 온다. 구체적으로
/// [_notice] 의 미완료 분기, "생활 상태 설정" 버튼, 거기에 물린 [onProfileChanged]
/// 와 그 안의 `ref.invalidate` 가 전부 그렇다.
///
/// `user == null`(비로그인) 방어용으로만 남겨 둔다. 라우터가 그 상태를 막고 있어
/// 실제로는 보이지 않는다. 지우려면 넷을 같이 지워야 한다.
class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({
    required this.user,
    required this.insightsAreEmpty,
    required this.onProfileChanged,
  });

  final AuthUser? user;

  /// 저장 여부가 안내 문구를 가른다. 서버는 빈 인사이트를 저장하지 않으므로
  /// 그 경우엔 지금 설정하면 이 분석의 인사이트가 새로 만들어진다.
  final bool insightsAreEmpty;

  final VoidCallback onProfileChanged;

  /// 인사이트가 비어 있는 이유가 둘이라 문구가 갈린다.
  ///
  /// 서버는 나쁜 값에만 습관 주제를 만든다(수면 부족·스트레스 높음·운동 안 함·수분
  /// 부족). 그러니 프로필을 이미 다 채운 사람에게 "설정하고 다시 보라"고 하면
  /// 설정할 것도 없고 다시 봐도 안 채워진다 — 화면이 못 지킬 약속을 하는 셈이다.
  String get _notice {
    if (!insightsAreEmpty) {
      // 저장된 인사이트다. 스냅샷은 분석 시점이 아니라 이 인사이트를 처음 조회한
      // 시점의 프로필이다(서버가 GET 안에서 만든다).
      return '이 인사이트는 처음 확인한 시점의 생활 상태를 기준으로 만들어졌어요.'
          ' 바꾼 내용은 다음 피부 분석부터 반영돼요.';
    }
    if (user?.hasIncompleteLifestyle ?? true) {
      return '생활 상태를 설정하고 다시 보면 인사이트가 채워져요';
    }
    return '지금은 따로 챙길 주제가 없어요. 지금처럼 유지해 보세요.';
  }

  @override
  Widget build(BuildContext context) {
    final profile = user;

    return _SandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 네 항목을 한 줄씩 편다. 칩으로 말면 이름과 값이 한 덩어리로 붙어서
          // "무엇이 어떤 상태인지"를 훑기 어렵다 — 왼쪽에 이름, 오른쪽에 값으로
          // 두 열을 세워 두면 눈이 오른쪽 열만 따라 내려가면 된다.
          _LifestyleRow(
              icon: Icons.nightlight_outlined,
              label: '수면',
              value: profile?.sleepPattern?.label),
          const SizedBox(height: 12),
          _LifestyleRow(
              icon: Icons.sentiment_very_dissatisfied_outlined,
              label: '스트레스',
              value: profile?.stressLevel?.label),
          const SizedBox(height: 12),
          _LifestyleRow(
              icon: Icons.fitness_center,
              label: '운동',
              value: profile?.exerciseHabit?.label),
          const SizedBox(height: 12),
          _LifestyleRow(
              icon: Icons.water_drop_outlined,
              label: '수분 섭취',
              value: profile?.waterIntake?.label),
          const SizedBox(height: 16),
          Text(
            _notice,
            style: const TextStyle(
                fontSize: 10, color: AppColors.sandInk, height: 1.5),
          ),
          if (profile?.hasIncompleteLifestyle ?? true)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  await context.push(Routes.skinType);
                  // 설문을 쓰는 동안 세션이 끊기면 라우터가 로그인으로 밀어내
                  // 이 화면이 헐린다. 그때 invalidate 를 부르면 버려진 ref 다.
                  if (context.mounted) onProfileChanged();
                },
                child: const Text('생활 상태 설정'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 생활 상태 한 줄. 왼쪽에 아이콘과 이름, 오른쪽에 값이다.
class _LifestyleRow extends StatelessWidget {
  const _LifestyleRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final selected = value != null;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.sandInk, height: 1)),
        ),
        Text(
          value ?? '미설정',
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _SandCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                height: 20 / 12,
                color: AppColors.sandInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item, required this.emphasized});

  final SkinInsightItem item;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 첫 항목만 모래 판 위에 올린다. 나머지는 같은 곡률의 흰 카드라
        // 순서는 유지되고 무게만 다르다.
        color: emphasized ? AppColors.surfaceCardSand : AppColors.background,
        border: emphasized ? null : Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 모르는 카테고리면 중립 아이콘이다. 억지 기본값은 엉뚱한 그림을 붙인다.
              Icon(item.category?.icon ?? Icons.spa_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyInk,
                        height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              height: 20 / 12,
              color: emphasized ? AppColors.sandInk : AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        // 회색 테두리는 이 화면에서 혼자 차갑다. 크림 테두리로 맞춘다.
        border: Border.all(color: AppColors.borderOnCream),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 결과 화면(S05)의 본문 카드와 같은 모래 판. 깊이는 그림자가 아니라 면색이다.
class _SandCard extends StatelessWidget {
  const _SandCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardSand,
        borderRadius: BorderRadius.circular(11),
      ),
      child: child,
    );
  }
}
