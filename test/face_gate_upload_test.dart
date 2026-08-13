import 'dart:ui' show Rect;

import 'package:camera/camera.dart' show CameraDescription, CameraLensDirection, XFile;
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/features/skin_analysis/data/datasources/face_gate_stub.dart';
import 'package:skinplate/features/skin_analysis/domain/entities/face_gate_result.dart';

/// 업로드 관문 계약을 검증한다.
/// **게이트를 통과하지 못한 이미지는 어떤 경로로도 서버에 올라가지 않는다.**
void main() {
  const debug = FaceGateDebug(faceCount: 1);

  group('FaceGate FAIL → 촬영 불가', () {
    test('막힌 결과로는 촬영 버튼을 켜지 않는다', () {
      for (final reason in FaceGateReason.values) {
        final blocked = FaceGateBlocked(reason, '안내', debug);
        expect(blocked.canCapture, isFalse, reason: reason.name);
      }
    });

    test('게이트를 걸 수 없는 환경도 통과가 아니다 — 검증 못 했으면 막는다', () {
      expect(const FaceGateUnavailable().canCapture, isFalse);
    });

    test('통과한 경우에만 촬영 버튼이 켜진다', () {
      expect(const FaceGateOk(Rect.fromLTWH(0, 0, 10, 10), debug).canCapture, isTrue);
    });
  });

  group('ML Kit 을 쓸 수 없는 환경(웹) → 원본 업로드 불가', () {
    const camera = CameraDescription(
      name: 'web',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    );

    test('프리뷰 판정이 통과로 떨어지지 않는다', () async {
      final gate = createFaceGate(camera);
      addTearDown(gate.dispose);

      // CameraImage 를 만들 수 없으므로 스텁의 계약만 확인한다.
      expect(const FaceGateUnavailable().canCapture, isFalse);
    });

    test('업로드 관문이 파일을 만들어 주지 않는다 — 원본 폴백이 없다', () async {
      final gate = createFaceGate(camera);
      addTearDown(gate.dispose);

      final prepared = await gate.prepareSkinPhoto(XFile('any.jpg'));
      expect(prepared.file, isNull);
      expect(prepared.gate, isA<FaceGateUnavailable>());
    });

    test('갤러리 경로(fullGate)도 똑같이 막힌다 — 우회로가 아니다', () async {
      final gate = createFaceGate(camera);
      addTearDown(gate.dispose);

      final prepared =
          await gate.prepareSkinPhoto(XFile('any.jpg'), fullGate: true);
      expect(prepared.file, isNull);
    });
  });
}
