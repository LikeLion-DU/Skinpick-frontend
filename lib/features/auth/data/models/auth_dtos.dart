import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

// ---------- Request ----------

@freezed
class SignupRequestDto with _$SignupRequestDto {
  const factory SignupRequestDto({
    required String email,
    required String password,
    required String nickname,
  }) = _SignupRequestDto;

  factory SignupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestDtoFromJson(json);
}

@freezed
class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

@freezed
class TestLoginRequestDto with _$TestLoginRequestDto {
  /// slot 1 = 발표 시연 전용 / 2·3 = 팀 테스트
  const factory TestLoginRequestDto({@Default(1) int slot}) = _TestLoginRequestDto;

  factory TestLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TestLoginRequestDtoFromJson(json);
}

// ---------- Response ----------

@freezed
class UserSummaryDto with _$UserSummaryDto {
  const factory UserSummaryDto({
    required int userId,
    required String email,
    required String nickname,
  }) = _UserSummaryDto;

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryDtoFromJson(json);
}

@freezed
class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    required UserSummaryDto user,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}

@freezed
class MeResponseDto with _$MeResponseDto {
  const factory MeResponseDto({
    required int userId,
    required String email,
    required String nickname,
    String? declaredSkinType,          // 미선택이면 서버가 키를 생략한다
    @JsonKey(name: 'isTestAccount') @Default(false) bool isTestAccount,
    DateTime? joinedAt,
  }) = _MeResponseDto;

  factory MeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MeResponseDtoFromJson(json);
}

// ---------- DTO → Entity ----------

extension AuthResponseDtoX on AuthResponseDto {
  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        expiresIn: expiresIn,
        user: AuthUser(
          userId: user.userId,
          email: user.email,
          nickname: user.nickname,
        ),
      );
}

extension MeResponseDtoX on MeResponseDto {
  AuthUser toEntity() => AuthUser(
        userId: userId,
        email: email,
        nickname: nickname,
        declaredSkinType: SkinType.fromJson(declaredSkinType),
        isTestAccount: isTestAccount,
        joinedAt: joinedAt,
      );
}
