import '../../../../shared/enums/skin_type.dart';
import 'skin_profile.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
    this.declaredSkinType,
    this.skinConcerns = const <SkinConcern>{},
    this.sleepPattern,
    this.stressLevel,
    this.exerciseHabit,
    this.waterIntake,
    this.isTestAccount = false,
    this.joinedAt,
  });

  final int userId;
  final String email;
  final String nickname;

  /// null = 아직 안 정함(건너뜀). SkinType.unknown 과 다르다.
  final SkinType? declaredSkinType;

  /// 빈 집합 = 고민 없음. 서버는 이 필드만 null(변경 없음)과 [](전부 해제)를 구분한다.
  final Set<SkinConcern> skinConcerns;

  /// 생활 습관 4종. null = 미선택. UI 에 해제 개념이 없어 null 로 되돌릴 길은 없다.
  final SleepPattern? sleepPattern;
  final StressLevel? stressLevel;
  final ExerciseHabit? exerciseHabit;
  final WaterIntake? waterIntake;

  final bool isTestAccount;
  final DateTime? joinedAt;

  bool get needsSkinTypePrompt => declaredSkinType == null;

  /// 인사이트 화면이 "생활 상태 설정" 안내를 띄울지 결정한다.
  /// 하나라도 비어 있으면 인사이트가 그만큼 덜 개인화된다.
  bool get hasIncompleteLifestyle =>
      sleepPattern == null ||
      stressLevel == null ||
      exerciseHabit == null ||
      waterIntake == null;
}

/// 로그인 결과 = 토큰 + 사용자
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final int expiresIn; // 초
  final AuthUser user;
}
