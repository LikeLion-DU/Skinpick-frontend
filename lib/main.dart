import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// 앱 전체를 세로로 고정한다.
///
/// 가로 레이아웃은 시안에 없어서 눕히면 홈이 검은 띠에 낀 채로 깨지고,
/// 카메라 회전 보정(core/mlkit/camera_input_image.dart)은 애초에 "세로로 든
/// 상태"를 전제한다 — 가로에서는 얼굴이 90도 누워 들어가 검출이 침묵한다.
///
/// 세 곳을 같이 맞춰야 한다. 네이티브 설정(AndroidManifest 의
/// `screenOrientation="portrait"`, iOS `Info.plist` 의
/// `UISupportedInterfaceOrientations`)은 Flutter 가 뜨기 전의 런치 스크린까지
/// 잡고, 이 호출은 실행 중을 잡는다. 하나라도 빠지면 앱을 가로로 켰을 때
/// 런치 화면이 누운 채로 떴다가 튀어 들어온다.
///
/// **화면 단위로 다시 풀지 마라.** 예전에는 촬영 화면이 들어갈 때 세로로 잠그고
/// 나갈 때 `DeviceOrientation.values` 로 되돌렸는데, 그 되돌리기가 이 전역
/// 고정까지 같이 풀어서 카메라를 한 번 다녀오면 앱 전체가 다시 돌아갔다.
/// `test/orientation_lock_test.dart` 가 세 곳과 "되돌리지 않음"을 함께 지킨다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: SkinPlateApp()));
}
