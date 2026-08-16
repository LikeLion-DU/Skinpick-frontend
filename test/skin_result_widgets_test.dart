import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/core/result/result.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/features/skin_analysis/data/models/skin_dtos.dart';
import 'package:skinplate/features/skin_analysis/presentation/pages/skin_result_page.dart';
import 'package:skinplate/features/skin_analysis/presentation/providers/skin_analysis_notifier.dart';

/// 결과 화면(S05)이 서버가 새로 주는 세 필드를 제대로 그리는지 본다.
///
/// 오버플로는 컴파일도 되고 단위 테스트도 통과하지만 화면에는 노란 줄무늬로 나온다.
/// 시안 폭에서 한 번 그려 보는 것만으로 그 부류를 전부 걸러낸다.
void main() {
  const designSize = Size(402, 874);

  Map<String, dynamic> data(String name) =>
      (jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  const user = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
  );

  Widget host(Map<String, dynamic> json) {
    final analysis = SkinAnalysisDto.fromJson(json).toEntity();

    return ProviderScope(
      overrides: [
        latestSkinAnalysisProvider
            .overrideWith((ref) async => Success(analysis)),
        authNotifierProvider.overrideWith(() => _StubAuth(user)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const SkinResultPage(),
      ),
    );
  }

  testWidgets('피부 나이 카드를 그린다 — 숫자만 크게 놓지 않고 추정값임을 같이 밝힌다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));
    await tester.pumpAndSettle();

    expect(find.text('AI 추정 피부 나이'), findsOneWidget);
    // 실제 나이를 맞히는 것이 아니라 사진 기반 추정이라 보조 문구가 항상 붙는다.
    expect(find.textContaining('AI 추정값입니다'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('타입 제목은 서버가 조합해 준 문구를 쓴다 — 앱이 경향을 이어 붙이지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));
    await tester.pumpAndSettle();

    // 규칙 도출값(skinTypeGap.observed = DRY)만 쓰면 "건성 피부" 가 된다.
    // 서버 label 에는 경향까지 들어 있다.
    expect(find.text('건성 · 민감 경향 피부'), findsOneWidget);
  });

  testWidgets('확장 필드가 없던 기록이면 나이 카드를 숨기고 기존 문구로 떨어진다', (tester) async {
    // 이 기능 이전에 저장된 분석은 서버가 세 키를 통째로 생략한다(non_null).
    // 빈 값으로 그리면 없는 데이터를 보여주는 셈이라 카드를 통째로 뺀다.
    final legacy = Map<String, dynamic>.from(data('skin_latest'))
      ..remove('skinType')
      ..remove('skinAge')
      ..remove('metricDetails');

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(legacy));
    await tester.pumpAndSettle();

    expect(find.text('AI 추정 피부 나이'), findsNothing);
    // 갭 카드의 observed(DRY)로 떨어진다 — 화면이 비지 않는다.
    expect(find.text('건성 피부'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
