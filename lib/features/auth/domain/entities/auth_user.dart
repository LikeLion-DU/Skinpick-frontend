import '../../../../shared/enums/skin_type.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
    this.declaredSkinType,
    this.isTestAccount = false,
    this.joinedAt,
  });

  final int userId;
  final String email;
  final String nickname;

  /// null = 아직 안 정함(건너뜀). SkinType.unknown 과 다르다.
  final SkinType? declaredSkinType;

  final bool isTestAccount;
  final DateTime? joinedAt;

  bool get needsSkinTypePrompt => declaredSkinType == null;
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
