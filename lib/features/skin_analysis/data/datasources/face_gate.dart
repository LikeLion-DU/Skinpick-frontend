import 'package:camera/camera.dart' show CameraDescription, CameraImage, XFile;

import '../../domain/captured_image_validator.dart';
import '../../domain/entities/face_gate_result.dart';

// dart.library.io 가 있으면 모바일 구현, 없으면(=웹) 스텁을 가져온다.
// 이 한 줄이 웹 번들에서 ML Kit 을 완전히 걷어낸다.
//
// kIsWeb 으로는 못 막는다 — kIsWeb 은 런타임 분기이고 import 는 컴파일 타임이라,
// 웹 번들을 만들 때 컴파일러가 도달 가능한 import 를 전부 따라간다. (설계서 §2.12.1)
import 'face_gate_stub.dart' if (dart.library.io) 'face_gate_mlkit.dart';

/// 공용 인터페이스. **ML Kit 타입이 하나도 등장하지 않는다.**
///
/// 시그니처가 ML Kit 타입에 오염되면 호출부가 그 타입을 만들어 넘겨야 하고,
/// 그 순간 호출부가 ML Kit 을 import 하게 되어 웹 빌드가 깨진다.
/// 경계를 파일이 아니라 타입 수준까지 밀어야 하는 이유다.
abstract interface class FaceGate {
  /// 프리뷰 프레임 1장을 판정한다.
  Future<FaceGateResult> check(CameraImage frame, FacePhotoType photoType);

  /// 업로드 직전 관문. 정지 이미지에서 다시 검출해 **통과한 경우에만** 크롭한
  /// 파일을 돌려준다. 막히면 [PreparedPhoto.file] 이 null 이고, 그 이미지는
  /// 어떤 경우에도 서버로 올라가지 않는다.
  ///
  /// 게이트가 돌려준 `faceRect` 를 여기 쓰지 않는다. 그건 프리뷰 좌표(예: 1280×720)이고
  /// 업로드하는 건 촬영 원본(예: 4032×3024)이라 해상도도 방향도 다르다. 배율을 맞추려
  /// 들면 레터박스와 EXIF 방향까지 겹친다 — 사진에서 한 번 더 검출하는 쪽이 짧고 정확하다.
  ///
  /// [fullGate] 는 4개 조건을 전부 다시 본다. 갤러리처럼 실시간 검사를 거치지 않은
  /// 경로에 쓴다. 카메라 경로는 방금 프리뷰에서 크기·방향·밝기를 통과했으므로
  /// 얼굴 개수만 확인한다 — 프리뷰와 촬영 원본은 종횡비가 달라 크기 비율이
  /// 미묘하게 어긋날 수 있고, 그걸로 막으면 사용자는 초록불을 보고 찍었는데
  /// 빠져나갈 수 없는 루프에 갇힌다.
  Future<PreparedPhoto> prepareSkinPhoto(
    XFile original, {
    FacePhotoType photoType = FacePhotoType.front,
    bool fullGate = false,
  });

  void dispose();
}

/// 업로드 관문 통과 결과.
class PreparedPhoto {
  const PreparedPhoto(this.file, this.gate, {this.checks = const []});

  /// 크롭까지 끝난 업로드용 파일. **null 이면 업로드하지 않는다.**
  final XFile? file;

  /// 막힌 이유. 화면은 [FaceGateBlocked.guide] 를 그대로 띄우면 된다.
  final FaceGateResult gate;

  /// 촬영본 확인 화면에 늘어놓을 항목들. **관문이 아니다** — 사용자가 사진을
  /// 보고 [다시 촬영] 과 [다음] 중에 고르는 근거일 뿐이라, 여기에 경고가 있어도
  /// [file] 은 그대로 있다. 막는 일은 위의 [gate] 하나가 맡는다.
  final List<PhotoCheck> checks;
}

/// 호출부가 쓰는 유일한 진입점. 두 구현 파일이 같은 이름으로 제공한다.
///
/// 이름·인자·반환 타입이 두 파일에서 하나라도 다르면 한쪽 플랫폼에서만 컴파일이
/// 깨지고, 그건 그 플랫폼을 빌드해 봐야 안다. [FaceGate] 를 양쪽이 implements 하게
/// 둔 것이 그 방어다. (설계서 §2.12.3)
FaceGate faceGate(CameraDescription camera) => createFaceGate(camera);
