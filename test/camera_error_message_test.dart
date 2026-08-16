import 'package:camera/camera.dart' show CameraException;
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/camera/camera_error_message.dart';

/// 카메라 예외 원문이 화면에 새면 한국어 앱 한가운데에 영어가 찍힌다.
///
/// 실제로 그렇게 나왔다 — 권한을 거부하면 `Camera access permission was denied.`,
/// use case 가 중복 바인딩되면 `No supported surface combination is found...` 가
/// 사용자 화면에 그대로 떴다.
void main() {
  test('예외 원문을 화면 문구로 쓰지 않는다', () {
    const raw = 'No supported surface combination is found for camera device';
    final message = cameraErrorMessage(
      CameraException('CameraAccessFailed', raw),
      '카메라를 열지 못했습니다.',
    );

    expect(message, '카메라를 열지 못했습니다.');
    expect(message, isNot(contains(raw)));
  });

  test('권한 거부는 무엇을 해야 하는지 알려준다', () {
    // 거부한 사용자에게 남는 길은 설정뿐이다. 그 말이 없으면 앱을 지우게 된다.
    for (final code in [
      'CameraAccessDenied',
      'CameraAccessDeniedWithoutPrompt',
      'CameraAccessRestricted',
    ]) {
      final message = cameraErrorMessage(
        CameraException(code, 'Camera access permission was denied.'),
        '카메라를 열지 못했습니다.',
      );

      expect(message, contains('설정'), reason: '$code 가 안내를 잃었다');
      expect(message, isNot(contains('denied')));
    }
  });

  test('카메라 예외가 아니면 넘긴 문구를 그대로 쓴다', () {
    expect(
      cameraErrorMessage(StateError('boom'), '촬영에 실패했습니다.'),
      '촬영에 실패했습니다.',
    );
  });

  /// 두 OS 의 설정 경로는 서로 없는 자리다. 한쪽 문구를 양쪽에 쓰면 사용자는
  /// 존재하지 않는 메뉴를 찾다가 포기한다.
  test('권한 안내 경로가 OS 를 따라간다', () {
    String messageOn(TargetPlatform platform) {
      debugDefaultTargetPlatformOverride = platform;
      try {
        return cameraErrorMessage(
          CameraException('CameraAccessDenied', 'denied'),
          '카메라를 열지 못했습니다.',
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    expect(messageOn(TargetPlatform.iOS), contains('설정 > Skinpick > 카메라'));
    expect(messageOn(TargetPlatform.iOS), isNot(contains('앱 > 권한')));
    expect(messageOn(TargetPlatform.android), contains('설정 > 앱 > 권한'));
  });

  test('description 이 비어도 죽지 않는다', () {
    expect(
      cameraErrorMessage(CameraException('Unknown', null), '기본 문구'),
      '기본 문구',
    );
  });
}
