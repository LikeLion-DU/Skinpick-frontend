/// 화면이 분기해야 하는 실패 종류만 정의한다.
/// 서버 에러 코드를 그대로 노출하지 않고 여기서 한 번 번역한다.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// 네트워크 연결 자체가 안 됨 → "인터넷 연결을 확인해 주세요" + 재시도 버튼
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '인터넷 연결을 확인해 주세요.']);
}

/// 인증 만료·무효 → 조용히 로그인 화면으로
class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.expired = false});
  final bool expired;
}

/// 서버가 비즈니스 에러를 명시적으로 내려준 경우 → 메시지 그대로 노출
class ServerFailure extends Failure {
  const ServerFailure(this.code, super.message);
  final String code;
}

/// AI 분석 실패 (얼굴/음식 미인식, 타임아웃) → 재촬영 유도
class AnalysisFailure extends Failure {
  const AnalysisFailure(this.code, super.message);
  final String code;

  /// ANALYSIS_EXPIRED 는 저장 토큰(30분)이 지난 것이다. 서버가 401 이 아니라 422 로
  /// 내리므로 UnauthorizedInterceptor 를 타지 않는다 — 로그인 세션은 그대로 두고
  /// 재촬영만 시킨다.
  bool get shouldRetakePhoto =>
      code == 'FACE_NOT_DETECTED' ||
      code == 'FOOD_NOT_DETECTED' ||
      code == 'ANALYSIS_EXPIRED';
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '일시적인 오류가 발생했습니다.']);
}
