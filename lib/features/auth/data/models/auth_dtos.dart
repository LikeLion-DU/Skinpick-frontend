import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/skin_type.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/skin_profile.dart';

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
    @Default(<String>[]) List<String> skinConcerns,
    String? sleepPattern,
    String? stressLevel,
    String? exerciseHabit,
    String? waterIntake,
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
        skinConcerns: skinConcerns
            .map(SkinConcern.fromWire)
            .whereType<SkinConcern>()
            .toSet(),
        sleepPattern: _parseWire(sleepPattern, SleepPattern.fromWire),
        stressLevel: _parseWire(stressLevel, StressLevel.fromWire),
        exerciseHabit: _parseWire(exerciseHabit, ExerciseHabit.fromWire),
        waterIntake: _parseWire(waterIntake, WaterIntake.fromWire),
        isTestAccount: isTestAccount,
        joinedAt: joinedAt,
      );
}

/// 키가 없으면 null, 있으면 파서에 넘긴다. 모르는 값도 null 이다 —
/// 습관은 "미선택"이 정상 상태라 억지 기본값을 두면 안 고른 사람과 섞인다.
T? _parseWire<T>(String? value, T? Function(String) fromWire) =>
    value == null ? null : fromWire(value);
