import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  Widget host(Map<String, dynamic> json, {double textScale = 1.0}) {
    final analysis = SkinAnalysisDto.fromJson(json).toEntity();

    return ProviderScope(
      overrides: [
        latestSkinAnalysisProvider
            .overrideWith((ref) async => Success(analysis)),
        authNotifierProvider.overrideWith(() => _StubAuth(user)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const SkinResultPage(),
        ),
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

  testWidgets('AI 타입은 칩으로 따로 단다 — 제목은 갭 카드와 같은 값을 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));
    await tester.pumpAndSettle();

    // 제목을 AI 관찰값으로 덮으면 갭 카드와 한 화면에서 어긋난다.
    expect(find.text('건성 피부'), findsOneWidget);
    // 서버 문구는 그대로 쓴다 — 뒤에 ' 피부' 같은 것을 붙이지 않는다.
    expect(find.text('건성 · 민감 경향'), findsOneWidget);

    // 칩이 제목을 밀어내 두 줄로 접히면 시안이 깨진다. 접힘은 예외가 아니라
    // takeException 으로는 안 잡히므로 높이로 본다.
    final titleHeight = tester.getSize(find.text('건성 피부')).height;
    expect(titleHeight, lessThan(30), reason: '제목이 두 줄로 접혔다');

    // 기본 글자 크기에서는 제목과 칩이 같은 줄에 나란히 선다(시안). 폰트 크기가
    // 달라 세로 중앙이 몇 px 어긋나므로 한 줄 높이 안인지로 본다.
    final gap = (tester.getTopLeft(find.text('건성 · 민감 경향')).dy -
            tester.getTopLeft(find.text('건성 피부')).dy)
        .abs();
    expect(gap, lessThan(titleHeight), reason: '칩이 아랫줄로 내려갔다');
  });

  /// 서버가 만든 칩 문구는 길이가 정해져 있지 않다. 제목·칩·점수를 한 줄에
  /// 나란히 두면 셋이 폭을 나눠 갖다가 잘린다 — 2026-08-17 에뮬레이터 QA 에서
  /// 실서버 문구가 기본 글자 크기에도 "복합성 · T존 ..." 으로 잘렸다.
  ///
  /// `dy` 로는 못 잡는다. 폰트 크기가 달라 칩 top 이 원래 제목보다 아래라,
  /// 같은 줄에서 잘려도 "아랫줄로 내려갔다" 와 구분되지 않는다. 잘림 자체를 본다.
  for (final (label, scale) in <(String, double)>[
    ('기본 글자 크기', 1.0),
    ('글자 크기 2.0', 2.0),
  ]) {
    testWidgets('$label — 긴 서버 문구도 칩에서 잘리지 않는다', (tester) async {
      const long = '복합성 · T존 유분 경향(수부지)';
      final json = Map<String, dynamic>.from(data('skin_latest'));
      json['skinType'] = {
        ...json['skinType'] as Map<String, dynamic>,
        'label': long,
      };

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(json, textScale: scale));
      await tester.pumpAndSettle();

      final chip = tester.renderObject<RenderParagraph>(find.text(long));
      expect(chip.didExceedMaxLines, isFalse, reason: '칩 문구가 잘렸다');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('AI 타입이 있으면 앱이 홍조 임계로 민감도를 따로 판정하지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));  // redness 64 → 기존 배지 조건
    await tester.pumpAndSettle();

    // 서버가 "민감 경향" 이라고 한 옆에 앱이 "민감도 높음" 을 또 달면
    // 두 판정이 어긋나는 날 어느 쪽을 믿을지 알 수 없다.
    expect(find.text('민감도 높음'), findsNothing);
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
    expect(find.text('건성 피부'), findsOneWidget);
    // AI 타입이 없으면 기존 민감도 배지로 떨어진다 — 화면이 비지 않는다.
    expect(find.text('민감도 높음'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  /// 시스템 글자 크기를 키운 사용자. 카드 제목 줄에는 안 줄어드는 위젯을 하나도
  /// 두면 안 된다 — 제목·배지·점수가 전부 고정폭이면 시안 폭에서 그대로 넘친다.
  ///
  /// 예전 기록 쪽이 더 위험하다. AI 칩(Flexible)이 없어서 '민감도 높음' 배지가
  /// 고정폭으로 들어오기 때문이다.
  for (final (label, mutate) in <(String, void Function(Map<String, dynamic>))>[
    ('AI 타입이 있는 기록', _keepAll),
    ('확장 필드가 없던 기록', _stripExtensions),
  ]) {
    testWidgets('$label — 글자 크기 2.0 에서도 넘치지 않는다', (tester) async {
      final json = Map<String, dynamic>.from(data('skin_latest'));
      mutate(json);

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(json, textScale: 2.0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

void _keepAll(Map<String, dynamic> json) {}

void _stripExtensions(Map<String, dynamic> json) => json
  ..remove('skinType')
  ..remove('skinAge')
  ..remove('metricDetails');

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
