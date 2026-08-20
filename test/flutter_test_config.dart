import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 모든 위젯 테스트를 **앱이 실제로 쓰는 폰트**로 그린다.
///
/// 위젯 테스트를 돌리는 `flutter_tester` 는 `--use-test-fonts`
/// `--disable-asset-fonts` 로 뜬다. 그래서 pubspec 이 선언한 Pretendard 는
/// 등록되지 않고, 모든 글자가 정사각형인 FlutterTest 폰트로 떨어진다 —
/// 한글은 공백까지 1em 이라 실제 폭과 크게 어긋난다.
///
/// 그 상태로는 360dp 에서 접히는 줄을 402dp 테스트가 못 잡고(단계 탭), 반대로
/// 테마를 안 준 테스트는 있지도 않은 오버플로를 만들어 낸다(리포트 영양 타일).
/// [FontLoader] 로 실제 폰트를 등록하면 두 오차가 같이 사라진다.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // rootBundle 을 쓰려면 바인딩이 먼저 있어야 한다. 여기서 부르지 않으면
  // 첫 testWidgets 가 만들 때까지 애셋을 읽을 수 없다.
  TestWidgetsFlutterBinding.ensureInitialized();

  final loader = FontLoader('Pretendard');
  for (final asset in const [
    'assets/fonts/Pretendard-Regular.otf',
    'assets/fonts/Pretendard-Medium.otf',
    'assets/fonts/Pretendard-SemiBold.otf',
    'assets/fonts/Pretendard-Bold.otf',
  ]) {
    // dart:io 로 읽지 않는다 — 상대 경로가 실행 디렉터리를 타서, 패키지 루트가
    // 아닌 곳에서 돌리면 test/ 전체가 main() 전에 죽는다.
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();

  await testMain();
}
