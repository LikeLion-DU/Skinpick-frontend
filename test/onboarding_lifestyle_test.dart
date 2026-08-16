import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 인사이트(S10)가 습관을 받으러 보내는 화면.
///
/// 인사이트는 서버 DB 의 습관을 읽어 주제를 고르고, `GET /skin-insights` 가
/// get-or-create 라 한 번 만들어지면 그 분석에 굳는다. 그래서 **인사이트를 조회하기
/// 전에** 네 개를 다 받아야 한다 — 피부 분석 결과 자체는 습관 없이도 볼 수 있다.
void main() {
  const designSize = Size(402, 874);

  Widget host(AuthUser user, {required ProfileFormMode mode}) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(user)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: SkinTypePage(mode: mode),
        ),
      );

  const fresh = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
    declaredSkinType: SkinType.oily,
    skinConcerns: {SkinConcern.acne},
  );

  const complete = AuthUser(
    userId: 2,
    email: 'done@skinplate.app',
    nickname: '완료유저',
    declaredSkinType: SkinType.oily,
    sleepPattern: SleepPattern.enough,
    stressLevel: StressLevel.low,
    exerciseHabit: ExerciseHabit.frequent,
    waterIntake: WaterIntake.enough,
  );

  ElevatedButton submitButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  testWidgets('강제 단계는 습관만 묻는다 — 타입·고민을 다시 그리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh, mode: ProfileFormMode.lifestyle));
    await tester.pumpAndSettle();

    expect(find.text('피부 타입'), findsNothing);
    expect(find.text('주요 피부 고민'), findsNothing);

    for (final label in ['수면 패턴', '스트레스 정도', '운동 습관', '수분 섭취']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('(필수)'), findsOneWidget);
  });

  testWidgets('건너뛰기는 없다 — 네 개를 다 받아야 인사이트를 만들 수 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh, mode: ProfileFormMode.lifestyle));
    await tester.pumpAndSettle();

    expect(find.text('건너뛰기'), findsNothing);
  });

  /// 화면을 붙잡고 있는 PopScope 가 있는가. MaterialApp 내부에도 PopScope 가 있어
  /// 타입만으로는 우리 것을 못 집는다 — canPop 이 막힌 것이 하나라도 있으면 된다.
  bool blocksBack(WidgetTester tester) => tester
      .widgetList(find.byWidgetPredicate((widget) => widget is PopScope))
      .cast<PopScope>()
      .any((scope) => !scope.canPop);

  /// 예전에는 이 화면이 분석과 결과 사이에 낀 강제 단계라 뒤로가기를 막았다 —
  /// 나가면 방금 한 분석을 다시 볼 길이 없었기 때문이다.
  ///
  /// 지금은 인사이트(S10)가 습관을 받으러 보내는 화면이고, 결과는 이미 봤다.
  /// 나가도 잃는 것이 없으므로 가두지 않는다. 다시 막으면 "인사이트는 나중에"를
  /// 고른 사용자가 앱을 닫는 것 말고는 나갈 방법이 없어진다.
  ///
  /// 모드마다 따로 pump 한다. 한 테스트 안에서 이어 붙이면 같은 runtimeType 이라
  /// Flutter 가 Element 를 그대로 재사용하고 initState 가 다시 돌지 않는다 —
  /// 두 번째 모드는 새로 마운트된 화면이 아니게 된다.
  for (final mode in ProfileFormMode.values) {
    testWidgets('$mode 는 뒤로가기를 막지 않는다', (tester) async {
      await tester.binding.setSurfaceSize(designSize);
      await tester.pumpWidget(host(fresh, mode: mode));
      await tester.pumpAndSettle();

      expect(blocksBack(tester), isFalse, reason: '$mode 가 화면을 붙잡고 있다');
    });
  }

  testWidgets('네 개를 다 고르기 전에는 완료할 수 없다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh, mode: ProfileFormMode.lifestyle));
    await tester.pumpAndSettle();

    expect(submitButton(tester).onPressed, isNull);

    // 수면만 고른다. 나머지 셋이 비었으므로 여전히 잠겨 있어야 한다.
    await tester.tap(find.text('수면 패턴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('부족해요'));
    await tester.pumpAndSettle();

    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('네 개를 다 고르면 완료가 열린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh, mode: ProfileFormMode.lifestyle));
    await tester.pumpAndSettle();

    for (final (row, option) in const [
      ('수면 패턴', '부족해요'),
      ('스트레스 정도', '높음'),
      ('운동 습관', '주 5회 이상'),
      ('수분 섭취', '충분해요'),
    ]) {
      await tester.tap(find.text(row));
      await tester.pumpAndSettle();
      await tester.tap(find.text(option));
      await tester.pumpAndSettle();
    }

    expect(submitButton(tester).onPressed, isNotNull);
    // 제출하면 결과가 아니라 불러온 인사이트로 돌아간다. 버튼도 그렇게 말해야 한다.
    expect(find.text('완료하고 인사이트 보기'), findsOneWidget);
  });

  testWidgets('이미 채운 사용자는 이 화면을 볼 이유가 없다', (tester) async {
    // 게이트 조건과 같은 판정이다. 인사이트 화면이 이 값으로 안내와 조회를 가른다.
    expect(complete.hasIncompleteLifestyle, isFalse);
    expect(fresh.hasIncompleteLifestyle, isTrue);

    // 하나만 비어도 미완료다 — 그 항목이 인사이트에서 통째로 빠진다.
    const missingWater = AuthUser(
      userId: 3,
      email: 'partial@skinplate.app',
      nickname: '일부유저',
      sleepPattern: SleepPattern.enough,
      stressLevel: StressLevel.low,
      exerciseHabit: ExerciseHabit.regular,
    );
    expect(missingWater.hasIncompleteLifestyle, isTrue);
  });

  testWidgets('full 모드는 그대로다 — 타입·고민·건너뛰기가 살아 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh, mode: ProfileFormMode.full));
    await tester.pumpAndSettle();

    expect(find.text('피부 타입'), findsOneWidget);
    expect(find.text('주요 피부 고민'), findsOneWidget);
    expect(find.text('건너뛰기'), findsOneWidget);
    expect(find.text('(선택)'), findsOneWidget);
    // 타입만 있으면 제출된다. 습관은 여기서 선택이다.
    expect(submitButton(tester).onPressed, isNotNull);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
