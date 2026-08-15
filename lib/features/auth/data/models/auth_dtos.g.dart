// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignupRequestDtoImpl _$$SignupRequestDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SignupRequestDtoImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$$SignupRequestDtoImplToJson(
        _$SignupRequestDtoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'nickname': instance.nickname,
    };

_$LoginRequestDtoImpl _$$LoginRequestDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginRequestDtoImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestDtoImplToJson(
        _$LoginRequestDtoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$TestLoginRequestDtoImpl _$$TestLoginRequestDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TestLoginRequestDtoImpl(
      slot: (json['slot'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$TestLoginRequestDtoImplToJson(
        _$TestLoginRequestDtoImpl instance) =>
    <String, dynamic>{
      'slot': instance.slot,
    };

_$UserSummaryDtoImpl _$$UserSummaryDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserSummaryDtoImpl(
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$$UserSummaryDtoImplToJson(
        _$UserSummaryDtoImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'nickname': instance.nickname,
    };

_$AuthResponseDtoImpl _$$AuthResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthResponseDtoImpl(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: UserSummaryDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseDtoImplToJson(
        _$AuthResponseDtoImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'expiresIn': instance.expiresIn,
      'user': instance.user,
    };

_$MeResponseDtoImpl _$$MeResponseDtoImplFromJson(Map<String, dynamic> json) =>
    _$MeResponseDtoImpl(
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      declaredSkinType: json['declaredSkinType'] as String?,
      skinConcerns: (json['skinConcerns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      sleepPattern: json['sleepPattern'] as String?,
      stressLevel: json['stressLevel'] as String?,
      exerciseHabit: json['exerciseHabit'] as String?,
      waterIntake: json['waterIntake'] as String?,
      isTestAccount: json['isTestAccount'] as bool? ?? false,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$MeResponseDtoImplToJson(_$MeResponseDtoImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'nickname': instance.nickname,
      'declaredSkinType': instance.declaredSkinType,
      'skinConcerns': instance.skinConcerns,
      'sleepPattern': instance.sleepPattern,
      'stressLevel': instance.stressLevel,
      'exerciseHabit': instance.exerciseHabit,
      'waterIntake': instance.waterIntake,
      'isTestAccount': instance.isTestAccount,
      'joinedAt': instance.joinedAt?.toIso8601String(),
    };
