import '../../../../core/result/result.dart';
import '../../../../shared/enums/skin_type.dart';
import '../entities/auth_user.dart';
import '../entities/skin_profile.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> signup({
    required String email,
    required String password,
    required String nickname,
  });

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// 로그인 화면의 "테스트 1·2·3" 버튼
  Future<Result<AuthSession>> loginWithTestAccount({int slot = 1});

  /// 앱 시작 시 저장된 토큰의 유효성을 확인하며 사용자 정보를 가져온다
  Future<Result<AuthUser>> getMe();

  /// 프로필을 부분 수정한다. 넘긴 필드만 바뀐다. (S01c 설문 또는 S05 인라인 선택)
  ///
  /// 건너뛰기는 값을 안 넘기는 것이다.
  /// SkinType.unknown 을 대신 보내면 "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  ///
  /// skinConcerns 는 빈 집합도 의미가 있다 — 서버가 "전부 해제"로 읽는다.
  Future<Result<AuthUser>> updateProfile({
    SkinType? declaredSkinType,
    Set<SkinConcern>? skinConcerns,
    SleepPattern? sleepPattern,
    StressLevel? stressLevel,
    ExerciseHabit? exerciseHabit,
    WaterIntake? waterIntake,
  });

  /// 서버는 상태를 갖지 않으므로 로컬 토큰 삭제가 곧 로그아웃이다
  Future<void> logout();
}
