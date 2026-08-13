/// 게이트 임계값을 한 파일에 모은다.
///
/// 실기기에서 촬영 UX 를 보면 거의 반드시 손대게 되는 값들이다. 판정 코드 안에
/// 흩어져 있으면 튜닝할 때마다 로직을 읽어야 한다. (PRD §9.5 기준값)
class FaceGateConfig {
  const FaceGateConfig._();

  /// 얼굴 바운딩 박스 높이가 프레임 높이의 몇 배 이상이어야 하는가.
  /// 이 값이 낮으면 멀리서 찍은 사진이 통과하고, OpenAI 에 올라가는 얼굴의
  /// 실효 해상도가 떨어져 홍조·트러블 판정 근거가 사라진다.
  static const double minFaceHeightRatio = 0.40;

  /// 정면 판정 허용 범위(도). yaw · roll 양쪽에 적용한다.
  static const double frontMaxYaw = 15.0;
  static const double frontMaxRoll = 15.0;

  /// 측면 판정에서 "충분히 돌렸다"고 보는 최소 yaw(도).
  /// 이 값과 [frontMaxYaw] 사이는 "조금 더 돌려주세요" 구간이다.
  static const double sideMinYaw = 25.0;

  /// 얼굴 영역 평균 휘도 하한 (0~255).
  ///
  /// 발표장 조명은 천장에서 내리쬐어 눈 아래·코 밑에 그림자를 만든다.
  /// 이 값을 올리면 시연장에서 촬영 버튼이 안 눌릴 위험이 커진다.
  static const int minLuminance = 60;

  /// 크롭·오버레이에 붙이는 여백 비율. 딱 맞게 자르면 이마와 턱이 잘리는데,
  /// 그 두 곳이 유분·트러블 판정에서 정보량이 가장 많다.
  static const double faceMarginRatio = 0.20;

  /// ML Kit 의 `headEulerAngleY` 부호가 "사용자 기준 왼쪽"과 같은 방향인지.
  ///
  /// 전면 카메라 미러 처리 때문에 기기마다 뒤집힐 수 있다. **실기기에서 반드시
  /// 확인하고**, LEFT 를 요구했는데 오른쪽으로 돌려야 통과하면 -1.0 으로 바꾼다.
  /// 이 상수 하나만 바꾸면 좌우가 통째로 뒤집힌다.
  static const double userLeftYawSign = 1.0;

  /// 심하게 고개가 꺾인 상태를 거부할지. 촬영 실패율을 올리는 조건이라
  /// 기본은 꺼 둔다 (지시서 §15). 실기기 UX 를 본 뒤에만 켠다.
  static const bool enablePitchCheck = false;
  static const double maxPitch = 20.0;

  /// 실시간 프레임 분석 최소 간격. 매 프레임 ML Kit 을 호출하면 프리뷰가 끊긴다.
  static const Duration analysisInterval = Duration(milliseconds: 300);

  // 우회 임계값(구 forceCaptureAfterFailures)은 제거했다. 게이트를 통과하지 못한
  // 이미지는 어떤 경로로도 서버에 올라가지 않는다. 상수를 남겨두면 우회가
  // 다시 붙는 자리가 된다.
}
