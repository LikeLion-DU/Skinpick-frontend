import 'dart:ui' show Rect;   // dart:ui 는 웹에도 있다. 플랫폼 중립이다.

/// 지금 찍어야 하는 사진의 종류. 세 장이 `POST /skin/analyses` 의
/// front · left · right 파트로 올라간다.
///
/// **[left] 는 "고개를 본인 왼쪽으로 돌리고 찍은 사진"이다 — 오른쪽 뺨이 보인다.**
/// "왼쪽 얼굴(왼쪽 뺨)"로 읽으면 지시문·게이트·서버 라벨이 전부 반대가 된다.
/// 이 기준은 앱 지시문("고개를 왼쪽으로")을 따르기로 한 결정(2026-08-15)이고,
/// 백엔드 Vision 라벨도 같은 기준으로 맞춰져 있다.
enum FacePhotoType { front, left, right }

/// 게이트가 막은 이유. 화면은 [FaceGateBlocked.guide] 를 그대로 띄우면 된다.
enum FaceGateReason { noFace, multipleFaces, tooSmall, wrongOrientation, tooDark }

/// 디버그 오버레이(§22)용 관측값. 릴리즈 빌드에서는 화면에 노출하지 않는다.
class FaceGateDebug {
  const FaceGateDebug({
    required this.faceCount,
    this.yaw,
    this.pitch,
    this.roll,
    this.faceHeightRatio,
    this.luminance,
  });

  final int faceCount;
  final double? yaw;
  final double? pitch;
  final double? roll;

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
}

class FaceGateOk extends FaceGateResult {
  const FaceGateOk(this.faceRect, this.debug);

  /// 프리뷰 좌표계의 얼굴 영역(여백 포함). **오버레이를 그리는 데만 쓴다.**
  /// 업로드 크롭에는 쓰지 않는다 — 프리뷰와 촬영 원본은 해상도도 방향도 다르다.
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
