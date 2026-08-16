import 'package:camera/camera.dart' show CameraException;
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kDebugMode;

/// 카메라 예외를 사용자에게 보여줄 한국어로 바꾼다.
///
/// **`CameraException.description` 을 화면에 내보내지 않는다.** camera 플러그인의 그
/// 필드는 전부 개발자용 영문이다 — `"Camera access permission was denied."`,
/// `"takePicture() was called on a disposed CameraController."`, 그리고 안드로이드
/// 플랫폼 오류는 네이티브 원문을 그대로 실어 보낸다. 한국어 화면 한가운데에 영어
/// 예외가 찍히던 원인이 여기였고, use case 중복 바인딩 메시지도 이 통로로 나왔다.
///
/// 원인 파악은 `code` 로 하고 원문은 디버그 로그로만 흘린다.
///
/// 피부·음식 촬영이 같은 변환을 쓴다. 화면마다 두면 한쪽만 고쳐지고, 그 차이는
/// "어떤 기기에서만 영어가 뜬다" 는 형태로만 드러나 원인을 찾기 어렵다.
String cameraErrorMessage(Object error, String fallback) {
  if (error is! CameraException) return fallback;

  if (kDebugMode) {
    debugPrint('CameraException(${error.code}): ${error.description}');
  }

  return switch (error.code) {
    // 거부한 사용자에게 남는 길은 설정뿐이다. 그 말을 안 하면 갤러리로 우회하거나
    // 앱을 지우는 수밖에 없다.
    'CameraAccessDenied' ||
    'CameraAccessDeniedWithoutPrompt' ||
    'CameraAccessRestricted' =>
      '카메라 권한이 필요해요.\n$_settingsGuide',
    _ => fallback,
  };
}

/// 권한을 되돌리러 가는 길. **두 OS 가 서로 없는 경로다** — Android 설정에는 앱
/// 이름이 최상위로 올라오지 않고, iOS 설정에는 "앱 > 권한" 이 없다. 없는 경로를
/// 안내하면 사용자는 설정을 뒤지다 포기하고 앱을 지운다.
///
/// **iOS 쪽은 메뉴 계단을 적지 않는다.** 서드파티 앱 설정의 위치가 OS 버전마다
/// 옮겨 다닌다(iOS 18 부터는 설정 > Apps 아래다). 계단을 박아 두면 그 버전에서만
/// 맞고 나머지에서는 틀린 안내가 되므로, 어느 버전에서도 참인 문장으로 쓴다.
///
/// 코드는 양쪽이 같다(`CameraAccessDenied` 셋). 갈라지는 것은 문구뿐이라
/// 여기서만 나눈다.
String get _settingsGuide => defaultTargetPlatform == TargetPlatform.iOS
    ? '설정 앱에서 Skinpick 의 카메라 권한을 켜 주세요.'
    : '설정 > 앱 > 권한에서 허용해 주세요.';
