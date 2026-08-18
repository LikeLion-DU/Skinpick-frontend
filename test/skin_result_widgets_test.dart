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

  testWidgets('제목은 서버 문구 하나다 — 타입을 두 번 말하지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));
    await tester.pumpAndSettle();

    // 서버 문구를 그대로 쓴다 — 뒤에 ' 피부' 같은 것을 붙이지 않는다.
    expect(find.text('건성 · 붉은기'), findsOneWidget);

    // 예전에는 제목("건성 피부")과 칩("건성 · 민감 경향")이 나란히 있었다.
    // 서버가 타입을 두 벌로 내던 시절의 구조라, 지금 같이 두면 같은 말이 두 번이다.
    expect(find.text('건성 피부'), findsNothing);

    // 제목이 두 줄로 접히면 시안이 깨진다. 접힘은 takeException 으로 안 잡혀 높이로 본다.
    expect(tester.getSize(find.text('건성 · 붉은기')).height, lessThan(30),
        reason: '제목이 두 줄로 접혔다');
  });

  /// 서버가 만든 제목 문구는 길이가 정해져 있지 않다. 제목과 점수를 한 줄에
  /// 나란히 두면 둘이 폭을 나눠 갖다가 잘린다 — 2026-08-17 에뮬레이터 QA 에서
  /// 실서버 문구가 기본 글자 크기에도 "복합성 · T존 ..." 으로 잘렸다.
  /// 상태가 둘 붙으면 문구는 다시 그만큼 길어진다.
  ///
  /// `didExceedMaxLines` 로 보면 안 된다. 제목에는 maxLines 가 없어서 구조적으로
  /// 항상 false 라, 누가 maxLines 를 되돌려 놓을 때 말고는 아무것도 잡지 못한다.
  /// 폭이 모자란데도 한 줄에 머물렀는지를 본다 — 그게 잘림이다.
  for (final (label, scale) in <(String, double)>[
    ('기본 글자 크기', 1.0),
    ('글자 크기 2.0', 2.0),
  ]) {
    testWidgets('$label — 긴 서버 문구도 제목에서 잘리지 않는다', (tester) async {
      const long = '복합성 · 수분 부족 · 장벽 약화(수부지)';
      final json = Map<String, dynamic>.from(data('skin_latest'));
      json['skinType'] = {
        ...json['skinType'] as Map<String, dynamic>,
        'label': long,
      };

      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(json, textScale: scale));
      await tester.pumpAndSettle();

      final title = tester.renderObject<RenderParagraph>(find.text(long));
      if (title.getMaxIntrinsicWidth(double.infinity) > title.size.width) {
        // 폭을 안 재면 한 줄이었을 높이. 접혔다면 이보다 커져야 한다.
        final oneLine = title.getMinIntrinsicHeight(double.infinity);
        expect(title.size.height, greaterThan(oneLine),
            reason: '폭이 모자란데 한 줄에 머물렀다 — 문구가 잘렸다');
      }
      expect(tester.takeException(), isNull);
    });
  }

  /// 관찰 근거는 숫자를 대신하지 않는다 — 접힌 한 줄 뒤에 있다가 눌러야 펼쳐진다.
  /// 항상 펼쳐 두면 지표 4개 × 최대 2줄이 점수·요약·하이라이트를 덮는다.
  testWidgets('관찰 근거는 접혀 있다가 펼치면 서버 문장이 나온다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));
    await tester.pumpAndSettle();

    final toggle = find.text('관찰 근거 자세히 보기');
    expect(toggle, findsOneWidget);
    expect(find.textContaining('볼과 입가에 부분적인 각질이 보임'), findsNothing);

    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    // 지표 이름이 문장 앞에 붙는다 — 어느 지표의 근거인지가 문장 안에 있어야 한다.
    expect(find.textContaining('수분  볼과 입가에 부분적인 각질이 보임'), findsOneWidget);

    // barrier 는 '장벽'이다. 서버 하이라이트("피부 장벽 양호")·룰 이유와 같은 이름이어야
    // 하고, '피부결'은 나이 축 skinTexture 가 쓰는 이름이라 한 화면에서 겹친다.
    expect(find.textContaining('장벽  전반적인 피부결이 균일한 편임'), findsOneWidget);

    // 트러블은 지표 원이 없어도 근거에는 싣는다. 서버 룰 R03 의 판정 이유가
    // 음식 결과에서 트러블을 인용하는데, 앱이 그 상태를 한 번도 안 보여주면
    // 근거 없는 감점이 된다.
    expect(find.textContaining('트러블  작은 융기가 소수만 보임'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('글자 크기 2.0 에서 근거를 펼쳐도 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest'), textScale: 2.0));
    await tester.pumpAndSettle();

    final toggle = find.text('관찰 근거 자세히 보기');
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('근거가 없던 기록이면 토글째 사라진다', (tester) async {
    // metricDetails 는 확장 필드가 없던 시절 기록에서 실제로 빠지는 키다.
    // 빈 목록을 "관찰 근거 자세히 보기" 로 열게 두면 눌러도 아무것도 없다.
    final legacy = Map<String, dynamic>.from(data('skin_latest'))
      ..remove('metricDetails');

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(legacy));
    await tester.pumpAndSettle();

    expect(find.text('관찰 근거 자세히 보기'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('앱이 홍조 임계로 민감도를 따로 판정하지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(data('skin_latest')));  // redness 64 → 옛 배지 조건
    await tester.pumpAndSettle();

    // 서버가 "붉은기" 라고 한 옆에 앱이 "민감도 높음" 을 또 달면
    // 두 판정이 어긋나는 날 어느 쪽을 믿을지 알 수 없다. 이제 임계는 서버에만 있다.
    expect(find.text('민감도 높음'), findsNothing);
  });

  testWidgets('확장 필드가 없던 기록이면 나이 카드를 숨기고 타입만 남는다', (tester) async {
    // 실제로 키가 빠지는 것은 `skinAge`·`metricDetails` 뿐이다 — `skinType` 은 지표에서
    // 다시 만들어져 옛 기록에도 온다. 여기서 셋 다 지우는 것은 방어다. 없는 값을 빈
    // 카드로 그리지 않는다는 것과, 제목이 폴백으로 버틴다는 것을 함께 본다.
    final legacy = Map<String, dynamic>.from(data('skin_latest'))
      ..remove('skinType')
      ..remove('skinAge')
      ..remove('metricDetails');

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(legacy));
    await tester.pumpAndSettle();

    expect(find.text('AI 추정 피부 나이'), findsNothing);
    // 서버 문구가 없으면 갭 카드가 들고 있는 같은 타입으로 떨어진다.
    expect(find.text('건성 피부'), findsOneWidget);
    expect(find.text('민감도 높음'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('타입을 건너뛴 사용자도 오늘 측정한 타입이 제목에 나온다', (tester) async {
    // 갭 카드는 자가 신고가 없으면 통째로 없다. 제목이 그쪽에 기대면
    // 건너뛴 사용자에게는 오늘 측정한 타입이 영영 안 나온다.
    final noGap = Map<String, dynamic>.from(data('skin_latest'))
      ..remove('skinTypeGap');

    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(noGap));
    await tester.pumpAndSettle();

    expect(find.text('건성 · 붉은기'), findsOneWidget);
    expect(find.text('오늘의 피부'), findsNothing);
  });

  /// 시스템 글자 크기를 키운 사용자. 카드 제목 줄에는 안 줄어드는 위젯을 하나도
  /// 두면 안 된다 — 제목과 점수가 둘 다 고정폭이면 시안 폭에서 그대로 넘친다.
  for (final (label, mutate) in <(String, void Function(Map<String, dynamic>))>[
    ('타입 문구가 있는 기록', _keepAll),
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
