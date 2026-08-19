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
/// AndroidManifest 의 `screenOrientation="portrait"` 와 한 쌍이다. 매니페스트는
/// Flutter 가 뜨기 전의 네이티브 스플래시까지 잡고, 이 호출은 iOS 를 잡는다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: SkinPlateApp()));
}
