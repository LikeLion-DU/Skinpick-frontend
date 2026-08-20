import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/error/failure.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_profile_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/skin_analysis.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';
import 'package:skinplate/shared/enums/highlight_status.dart';
import 'package:skinplate/shared/enums/skin_level.dart';

/// 피부 프로필은 **음식 개인화의 기준을 확인하는 화면**이다.
/// 여기서 새로 계산하는 값이 없어야 하고, 미설정이 빈칸으로 새면 안 된다.
void main() {
  const designSize = Size(402, 874);

  final analysis = SkinAnalysis(
    id: 101,
    skinScore: 58,
    metrics: const SkinMetrics(
      hydration: 38,
      oil: 52,
      redness: 64,
      trouble: 25,
      barrier: 78,
    ),
    // 서버가 방향을 맞춰 매긴 지표 등급. 타일의 상태어가 여기서 나온다 —
    // 앱에는 지표 경계표가 없다.
    metricDetails: const [
      ScoredItem(key: 'hydration', level: SkinLevel.caution, score: 38,
          evidence: []),
      ScoredItem(key: 'oil', level: SkinLevel.normal, score: 52, evidence: []),
      ScoredItem(key: 'redness', level: SkinLevel.caution, score: 64,
          evidence: []),
      ScoredItem(key: 'trouble', level: SkinLevel.good, score: 25,
          evidence: []),
      ScoredItem(key: 'barrier', level: SkinLevel.good, score: 78,
          evidence: []),
    ],
    careFocus: const [
      CareFocus(focus: 'HYDRATION', label: '수분·장벽'),
      CareFocus(focus: 'ANTIOXIDANT', label: '항산화'),
    ],
    summary: '건조와 홍조가 함께 보여요.',
    highlights: const [
      Highlight(label: '피부 장벽 양호', status: HighlightStatus.good),
    ],
    analyzedAt: DateTime(2026, 8, 16, 10, 30),
  );

  /// 확장 필드가 없던 시절의 분석. 지표 값은 있고 등급은 없다.
  final legacyAnalysis = SkinAnalysis(
    id: 102,
    skinScore: 58,
    metrics: const SkinMetrics(
      hydration: 38,
      oil: 52,
      redness: 64,
      trouble: 25,
      barrier: 78,
    ),
    summary: '건조와 홍조가 함께 보여요.',
    highlights: const [],
    analyzedAt: DateTime(2026, 8, 16, 10, 30),
  );

  const user = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '두잉',
    skinConcerns: {SkinConcern.darkCircle},
    sleepPattern: SleepPattern.lacking,
    // 스트레스·운동·물은 일부러 비운다 — 미설정이 어떻게 보이는지가 요점이다.
  );

  Widget host({SkinAnalysis? latest}) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(user)),
          latestSkinAnalysisProvider.overrideWith((ref) async => Success(latest)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SkinProfilePage(),
        ),
      );

  testWidgets('최근 분석의 지표 5개를 전부 펴고 시안 폭에서 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: analysis));
    await tester.pumpAndSettle();

    // 결과 화면(S05)은 4개만 보여주지만 여기는 채점 기준을 확인하는 곳이라
    // 트러블이 빠지면 근거가 하나 사라진다.
    for (final label in ['수분', '유분', '홍조', '트러블', '장벽']) {
      expect(find.text(label), findsOneWidget, reason: '$label 지표가 없다');
    }
    // 언제 측정한 기준인지가 이 화면의 존재 이유다. 시안이 그 자리에 둔
    // "민감도 높음" 배지는 서버에 필드가 없어 날짜로 채웠다.
    expect(find.text('2026. 8. 16 측정'), findsOneWidget);
    expect(find.text('다크서클'), findsOneWidget);

    // 상태어는 서버 등급을 옮긴 것이다. 수분은 낮아서 "부족", 홍조는 높아서
    // "주의" — 같은 CAUTION 을 방향에 맞는 말로 옮긴다.
    expect(find.text('부족'), findsOneWidget);
    expect(find.text('주의'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('좋음'), findsNWidgets(2));

    // 관리 축 칩은 고민(다크서클)과 다른 값이다 — 제목이 둘로 나뉘어 있다.
    expect(find.text('지금 필요한 관리'), findsOneWidget);
    expect(find.text('수분·장벽'), findsOneWidget);
  });

  testWidgets('지표 등급이 없는 옛 분석 — 상태어만 빠지고 타일은 남는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: legacyAnalysis));
    await tester.pumpAndSettle();

    for (final label in ['수분', '유분', '홍조', '트러블', '장벽']) {
      expect(find.text(label), findsOneWidget, reason: '$label 지표가 없다');
    }
    // 앱이 38 을 보고 "부족"이라 말하지 않는다 — 그게 두 번째 경계표다.
    expect(find.text('부족'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('글자 크기 2.0 — 지표 타일과 관리 칩이 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
      child: host(latest: analysis),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  /// 실서버 응답 원문을 그대로 파싱해 마이페이지까지 올린다. 손으로 만든 엔티티는
  /// "내가 상상한 서버" 를 검증하게 된다.
  testWidgets('실서버 피부 응답이 5지표 타일과 관리 칩으로 올라온다', (tester) async {
    final body = jsonDecode(
        File('test/fixtures/skin_latest_live.json').readAsStringSync());
    final live = SkinAnalysisDto.fromJson(
            (body as Map<String, dynamic>)['data'] as Map<String, dynamic>)
        .toEntity();

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: live));
    await tester.pumpAndSettle();

    for (final label in ['수분', '유분', '홍조', '트러블', '장벽']) {
      expect(find.text(label), findsOneWidget, reason: '$label 타일이 없다');
    }
    // 상태어는 서버가 지표마다 매긴 등급에서 나온다.
    expect(find.text('부족'), findsOneWidget);
    expect(find.text('주의'), findsOneWidget);
    expect(find.text('좋음'), findsNWidgets(2));
    // 관리 방향은 고민(사용자가 고른 값)과 다른 섹션이다.
    expect(find.text('지금 필요한 관리'), findsOneWidget);
    expect(find.text('수분·장벽'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('미설정 습관은 빈칸이 아니라 미설정으로 적는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(latest: analysis));
    await tester.pumpAndSettle();

    expect(find.text('부족해요'), findsOneWidget); // 수면
    expect(find.text('미설정'), findsNWidgets(3)); // 스트레스·운동·물 섭취
  });

  testWidgets('불러오기에 실패하면 기록이 없다고 말하지 않는다', (tester) async {
    // 실패와 "정말 없음"을 같이 다루면, 분석을 해 둔 사용자가 오프라인으로 열었을 때
    // 앱이 없는 사실을 단정한다. 그것도 재시도할 방법 없이.
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => _StubAuth(user)),
        latestSkinAnalysisProvider.overrideWith(
            (ref) async => const FailureResult(NetworkFailure())),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SkinProfilePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('아직 피부 분석 기록이 없어요'), findsNothing);
    expect(find.text('피부 분석을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('분석이 없으면 인사이트 버튼을 그리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // 인사이트는 분석 하나를 기준으로 만들어진다. 눌러서 빈 화면을 보는 것보다
    // 버튼이 없는 편이 낫다.
    expect(find.text('개인화 피부 인사이트 보기'), findsNothing);
    expect(find.text('피부 분석하기'), findsOneWidget);
    expect(find.textContaining('아직 피부 분석 기록이 없어요'), findsOneWidget);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
