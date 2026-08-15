import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/di/providers.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_insight_dtos.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_insight_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';

/// 인사이트 화면이 세 갈래 응답을 다 그리는지 본다.
///
/// 오버플로는 컴파일도 되고 테스트도 통과하지만 화면에는 노란 줄무늬로 나온다.
/// 시안 폭(402)에서 한 번 그려 보는 것만으로 그 부류를 전부 걸러낸다.
void main() {
  const designSize = Size(402, 874);

  Map<String, dynamic> data(String name) =>
      (jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  final analysis = SkinAnalysisDto.fromJson(data('skin_latest')).toEntity();

  /// 프로필이 다 채워진 사용자. 미설정 안내가 끼어들면 오버플로 판정이 흐려진다.
  const filledUser = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
    skinConcerns: {SkinConcern.acne},
    sleepPattern: SleepPattern.lacking,
    stressLevel: StressLevel.high,
    exerciseHabit: ExerciseHabit.none,
    waterIntake: WaterIntake.lacking,
  );

  Widget host(String fixture, {AuthUser user = filledUser}) {
    final insight = SkinInsightDto.fromJson(data(fixture)).toEntity();

    return ProviderScope(
      overrides: [
        skinInsightProvider(insight.skinAnalysisId)
            .overrideWith((ref) async => Success(insight)),
        latestSkinAnalysisProvider
            .overrideWith((ref) async => Success(analysis)),
        authNotifierProvider.overrideWith(() => _StubAuth(user)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: SkinInsightPage(skinAnalysisId: insight.skinAnalysisId),
      ),
    );
  }

  // 한 테스트 안에서 다시 pump 하면 Riverpod 이 컨테이너를 재사용하는데, family
  // 오버라이드의 인자가 달라 "override 종류가 바뀌었다"로 죽는다. 픽스처마다 나눈다.
  for (final fixture in [
    'skin_insight',
    'skin_insight_first',
    'skin_insight_healthy',
  ]) {
    testWidgets('$fixture — 시안 폭에서 넘치지 않는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(fixture));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('5지표를 다 그리고 변화량을 붙인다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host('skin_insight'));
    await tester.pumpAndSettle();

    // 결과 화면(S05)은 4개만 그리지만 여기는 트러블까지 다섯이다.
    for (final label in ['수분', '유분', '홍조', '트러블', '장벽']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('-7'), findsOneWidget); // 트러블 델타
    expect(find.text('+5'), findsOneWidget); // 수분 델타
  });

  testWidgets('첫 분석이면 0 을 그리지 않고 비교 문구를 띄운다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host('skin_insight_first'));
    await tester.pumpAndSettle();

    expect(find.text('첫 피부 분석이라 아직 비교할 데이터가 없어요'), findsOneWidget);
  });

  testWidgets('다룰 주제가 없으면 두 섹션이 사라지고 요약만 남는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host('skin_insight_healthy'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 우선 관리'), findsNothing);
    expect(find.text('오늘의 행동'), findsNothing);
    // 빈 화면이 아니다 — 요약은 남아 있다.
    expect(find.textContaining('안정적이에요'), findsOneWidget);
  });

  testWidgets('인사이트 순서를 서버가 준 대로 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host('skin_insight'));
    await tester.pumpAndSettle();

    final sleep = tester.getTopLeft(find.text('수면 관리')).dy;
    final trouble = tester.getTopLeft(find.text('트러블 관리')).dy;

    // 서버가 HIGH 를 먼저 준다. 앱이 다시 정렬하면 여기가 뒤집힌다.
    expect(sleep, lessThan(trouble));
  });

  testWidgets('생활 상태가 비면 미설정으로 표시하고 설정 버튼을 준다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(
      'skin_insight_healthy',
      user: const AuthUser(
        userId: 2,
        email: 'fresh@skinplate.app',
        nickname: '새사용자',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('미설정'), findsNWidgets(4));
    expect(find.text('생활 상태 설정'), findsOneWidget);
    // 저장되지 않은 인사이트다 — 지금 설정하면 이 분석이 다시 만들어진다.
    expect(find.textContaining('다시 보면 인사이트가 채워져요'), findsOneWidget);
  });

  testWidgets('저장된 인사이트에는 스냅샷 안내를 띄운다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host('skin_insight'));
    await tester.pumpAndSettle();

    // 이쪽은 반대다. 지금 바꿔도 이 인사이트는 안 바뀐다.
    expect(find.textContaining('다음 피부 분석부터 반영돼요'), findsOneWidget);
    expect(find.textContaining('다시 보면 인사이트가 채워져요'), findsNothing);
    // 스냅샷은 분석 시점이 아니라 인사이트를 처음 조회한 시점이다.
    expect(find.textContaining('피부 분석 당시'), findsNothing);
  });

  testWidgets('프로필을 다 채웠는데 비면 설정하라고 하지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    // 서버는 나쁜 값에만 습관 주제를 만든다. 습관을 전부 좋은 값으로 채운
    // 사용자에게 "설정하고 다시 보라"고 하면 설정할 것도 없고 다시 봐도 안 채워진다.
    await tester.pumpWidget(host(
      'skin_insight_healthy',
      user: const AuthUser(
        userId: 3,
        email: 'healthy@skinplate.app',
        nickname: '건강한사용자',
        sleepPattern: SleepPattern.enough,
        stressLevel: StressLevel.low,
        exerciseHabit: ExerciseHabit.frequent,
        waterIntake: WaterIntake.enough,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('다시 보면 인사이트가 채워져요'), findsNothing);
    expect(find.text('생활 상태 설정'), findsNothing);
    expect(find.textContaining('따로 챙길 주제가 없어요'), findsOneWidget);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
