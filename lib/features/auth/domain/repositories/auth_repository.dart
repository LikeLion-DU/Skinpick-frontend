import '../../../../core/result/result.dart';
import '../../../../shared/enums/skin_type.dart';
import '../entities/auth_user.dart';

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

  /// 로그인 화면의 "테스트 계정으로 시작하기" 버튼
  Future<Result<AuthSession>> loginWithTestAccount({int slot = 1});

  /// 앱 시작 시 저장된 토큰의 유효성을 확인하며 사용자 정보를 가져온다
  Future<Result<AuthUser>> getMe();

  /// 피부 타입을 선택·변경한다. (S01c 또는 S05 인라인 선택)
  ///
  /// 건너뛰기는 이 메서드를 호출하지 않는 것이다.
  /// SkinType.unknown 을 대신 보내면 "잘 모르겠다고 답한 사용자"와 구분이 사라진다.
  Future<Result<AuthUser>> updateSkinType(SkinType skinType);

  /// 서버는 상태를 갖지 않으므로 로컬 토큰 삭제가 곧 로그아웃이다
  Future<void> logout();
}
