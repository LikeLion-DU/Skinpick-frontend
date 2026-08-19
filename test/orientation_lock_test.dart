import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 세로 고정은 코드 한 줄이 아니라 **네 곳이 함께 지켜야 하는 약속**이다.
/// 런타임(main.dart)·안드로이드 매니페스트·iOS Info.plist 가 각각 맡는 구간이
/// 다르고, 여기에 "아무도 다시 풀지 않는다" 가 붙어야 실제로 고정된다.
///
/// 마지막 조건이 실제로 깨졌던 적이 있다. 촬영 화면 두 곳이 나가면서
/// `setPreferredOrientations(DeviceOrientation.values)` 로 전 방향을 되돌려,
/// 카메라를 한 번 다녀오면 앱 전체가 다시 가로로 돌아갔다. 전역 고정을 넣어도
/// 화면 하나가 조용히 풀 수 있어서, 값이 아니라 **되돌리는 호출이 없다는 것**을
/// 같이 검사한다.
void main() {
  test('main.dart 가 portraitUp 으로 고정한다', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('setPreferredOrientations'));
    expect(source, contains('DeviceOrientation.portraitUp'));
  });

  test('세로 고정을 푸는 화면이 없다', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => file.path != 'lib/main.dart')
        .where((file) =>
            file.readAsStringSync().contains('setPreferredOrientations'))
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason: '방향은 main.dart 에서만 정한다. 화면에서 다시 부르면 전역 고정이 풀린다',
    );
  });

  test('AndroidManifest 가 MainActivity 를 세로로 고정한다', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android:screenOrientation="portrait"'));
  });

  test('iOS Info.plist 가 가로를 허용하지 않는다', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(plist, isNot(contains('UIInterfaceOrientationLandscapeLeft')));
    expect(plist, isNot(contains('UIInterfaceOrientationLandscapeRight')));
    expect(plist, contains('UIInterfaceOrientationPortrait'));
  });
}
