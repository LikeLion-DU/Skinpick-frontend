import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/app/theme/app_theme.dart';
import 'package:skinplate/features/auth/domain/entities/auth_user.dart';
import 'package:skinplate/features/auth/domain/entities/skin_profile.dart';
import 'package:skinplate/features/auth/presentation/pages/skin_type_page.dart';
import 'package:skinplate/features/auth/presentation/providers/auth_notifier.dart';
import 'package:skinplate/shared/enums/skin_type.dart';

/// 설문 화면은 이제 서버 프로필을 읽고 쓴다.
///
/// 프리필이 빠지면 재진입한 사용자의 제출이 이전 답을 전부 덮어쓴다 — 저장소에
/// 쓰기만 하고 읽는 곳이 없던 시절에 실제로 났던 버그다. 원천이 서버로 바뀌었으니
/// 같은 사고가 다시 날 자리도 옮겨왔다.
void main() {
  const designSize = Size(402, 874);

  Widget host(AuthUser user) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _StubAuth(user)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SkinTypePage(),
        ),
      );

  const filled = AuthUser(
    userId: 1,
    email: 'test@skinplate.app',
    nickname: '테스트유저',
    declaredSkinType: SkinType.oily,
    skinConcerns: {SkinConcern.acne},
    sleepPattern: SleepPattern.lacking,
    stressLevel: StressLevel.high,
    exerciseHabit: ExerciseHabit.frequent,
    waterIntake: WaterIntake.enough,
  );

  const fresh = AuthUser(
    userId: 2,
    email: 'fresh@skinplate.app',
    nickname: '새사용자',
  );

  testWidgets('서버 프로필이 화면에 미리 깔린다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(filled));
    await tester.pumpAndSettle();

    // 접힌 습관 줄의 오른쪽에 현재 값이 찍힌다.
    expect(find.text('부족해요'), findsOneWidget);     // 수면
    expect(find.text('높음'), findsOneWidget);         // 스트레스
    expect(find.text('주 5회 이상'), findsOneWidget);  // 운동 — 4번째 값 왕복
    expect(find.text('충분해요'), findsOneWidget);     // 수분
  });

  testWidgets('수분 섭취 줄이 있고 3단계를 고를 수 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh));
    await tester.pumpAndSettle();

    expect(find.text('수분 섭취'), findsOneWidget);

    await tester.tap(find.text('수분 섭취'));
    await tester.pumpAndSettle();

    expect(find.text('부족해요'), findsOneWidget);
    expect(find.text('보통이에요'), findsOneWidget);
    expect(find.text('충분해요'), findsOneWidget);
  });

  testWidgets('미선택 사용자는 설문이 비어 있다', (tester) async {
    await tester.binding.setSurfaceSize(designSize);
    await tester.pumpWidget(host(fresh));
    await tester.pumpAndSettle();

    // 습관 줄은 값이 없으면 기본 표기를 쓴다. 남의 값이 새어 들어오면 안 된다.
    expect(find.text('주 5회 이상'), findsNothing);
    expect(find.text('높음'), findsNothing);
  });
}

class _StubAuth extends AuthNotifier {
  _StubAuth(this.user);

  final AuthUser user;

  @override
  AuthState build() => Authenticated(user);
}
