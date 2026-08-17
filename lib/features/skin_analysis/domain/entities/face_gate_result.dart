import 'dart:ui' show Offset, Rect, Size;   // dart:ui 는 웹에도 있다. 플랫폼 중립이다.

/// 지금 찍어야 하는 사진의 종류. 세 장이 `POST /skin/analyses` 의
/// front · left · right 파트로 올라간다.
///
/// **[left] 는 "고개를 본인 왼쪽으로 돌리고 찍은 사진"이다 — 오른쪽 뺨이 보인다.**
/// "왼쪽 얼굴(왼쪽 뺨)"로 읽으면 지시문·게이트·서버 라벨이 전부 반대가 된다.
/// 이 기준은 앱 지시문("고개를 왼쪽으로")을 따르기로 한 결정(2026-08-15)이고,
/// 백엔드 Vision 라벨도 같은 기준으로 맞춰져 있다.
enum FacePhotoType { front, left, right }

/// 게이트가 막은 이유. 화면은 [FaceGateBlocked.guide] 를 그대로 띄우면 된다.
enum FaceGateReason {
  noFace,
  multipleFaces,
  tooSmall,
  tooBig,
  outOfFrame,
  offCenter,
  wrongOrientation,
  eyesClosed,
  tooDark,
}

/// 한 프레임에서 뽑아낸 관측값.
///
/// 디버그 오버레이(§22)가 주 용도지만 **얼굴 박스와 프레임 크기는 릴리즈에서도
/// 쓴다** — 프리뷰 위에 박스를 그리려면 이 둘이 있어야 한다.
class FaceGateDebug {
  const FaceGateDebug({
    required this.faceCount,
    this.yaw,
    this.pitch,
    this.roll,
    this.faceBox,
    this.nose,
    this.frameSize,
    this.eyeOpen,
    this.faceHeightRatio,
    this.luminance,
  });

  final int faceCount;
  final double? yaw;
  final double? pitch;
  final double? roll;

  /// 검출된 얼굴 박스. **여백을 붙이지 않은** 원본이고, 좌표계는 사용자가 보는
  /// 방향(= 미러 프리뷰와 같은 방향)이다. 크기·중앙 정렬 판정의 입력이다.
  final Rect? faceBox;

  /// 코 밑점. [faceBox] 와 같은 좌표계다.
  ///
  /// **그리기 전용이다 — 어떤 판정에도 쓰지 않는다.** 화면 가이드가 코를 기준으로
  /// 방향을 그리기 때문에 들고 다닌다. 랜드마크를 못 읽으면 박스 중심이 들어온다.
  final Offset? nose;

  /// [faceBox] 가 놓인 프레임의 크기. 위젯 좌표로 옮기려면 필요하다.
  final Size? frameSize;

  /// 눈 뜸 확률 (0~1, 양쪽 중 큰 값). 분류를 끈 경로에서는 null 이다.
  final double? eyeOpen;

  /// 얼굴 바운딩 박스 높이 / 프레임 높이
  final double? faceHeightRatio;

  /// 얼굴 영역 평균 휘도 (0~255). 앞 조건에서 막히면 계산하지 않아 null 이다.
  final int? luminance;

  FaceGateDebug copyWith({double? faceHeightRatio, int? luminance}) =>
      FaceGateDebug(
        faceCount: faceCount,
        yaw: yaw,
        pitch: pitch,
        roll: roll,
        faceBox: faceBox,
        nose: nose,
        frameSize: frameSize,
        eyeOpen: eyeOpen,
        faceHeightRatio: faceHeightRatio ?? this.faceHeightRatio,
        luminance: luminance ?? this.luminance,
      );
}

/// 촬영 버튼을 켤지 말지, 못 켠다면 뭐라고 안내할지.
sealed class FaceGateResult {
  const FaceGateResult();

  /// 촬영 버튼 활성화 여부. **통과한 경우에만 켠다.**
  ///
  /// [FaceGateUnavailable] 도 막는다 — 게이트를 통과하지 못한 이미지는 서버로
  /// 보내지 않는다는 것이 이 게이트의 존재 이유다. 게이트를 걸 수 없는 환경에서
  /// 열어 주면 "검증 못 했으니 그냥 보낸다"가 되어 목적이 사라진다.
  bool get canCapture => this is FaceGateOk;

  FaceGateDebug? get debug;

  /// 프리뷰에 그릴 얼굴 박스. 통과든 차단이든 얼굴이 잡혔으면 있다 —
  /// 막힌 동안에도 박스가 보여야 사용자가 무엇을 고쳐야 하는지 안다.
  Rect? get faceBox => debug?.faceBox;

  /// 프리뷰에 그릴 코 위치. 얼굴이 잡혔으면 있다.
  Offset? get nose => debug?.nose;

  /// [faceBox] 가 놓인 프레임 크기.
  Size? get frameSize => debug?.frameSize;
}

class FaceGateOk extends FaceGateResult {
  const FaceGateOk(this.faceRect, this.debug);

  /// 얼굴 영역(여백 포함). **정지 이미지 경로의 크롭에만 쓴다.**
  ///
  /// 라이브 프리뷰 경로가 돌려주는 값은 크롭에 쓰지 않는다 — 프리뷰와 촬영 원본은
  /// 해상도도 방향도 다르고, 게다가 좌우가 사용자 기준으로 뒤집혀 있다(`toUserSpace`).
  /// 그 값으로 사진을 자르면 반대쪽 뺨이 잘려 나간다.
  final Rect faceRect;

  @override
  final FaceGateDebug debug;
}

class FaceGateBlocked extends FaceGateResult {
  const FaceGateBlocked(this.reason, this.guide, this.debug);

  final FaceGateReason reason;

  /// 화면에 그대로 띄우는 안내 문구
  final String guide;

  @override
  final FaceGateDebug debug;
}

/// 웹처럼 게이트를 쓸 수 없는 환경, 또는 프레임 포맷을 읽지 못한 경우.
///
/// **통과가 아니다.** [FaceGateResult.canCapture] 가 false 라 촬영 버튼은 꺼진다 —
/// 검증하지 못한 이미지를 "검증 못 했으니 그냥 보낸다" 로 흘려보내면 게이트의
/// 존재 이유가 사라진다.
class FaceGateUnavailable extends FaceGateResult {
  const FaceGateUnavailable();

  @override
  FaceGateDebug? get debug => null;
}
