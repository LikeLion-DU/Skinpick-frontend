// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SignupRequestDto _$SignupRequestDtoFromJson(Map<String, dynamic> json) {
  return _SignupRequestDto.fromJson(json);
}

/// @nodoc
mixin _$SignupRequestDto {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this SignupRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignupRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignupRequestDtoCopyWith<SignupRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignupRequestDtoCopyWith<$Res> {
  factory $SignupRequestDtoCopyWith(
          SignupRequestDto value, $Res Function(SignupRequestDto) then) =
      _$SignupRequestDtoCopyWithImpl<$Res, SignupRequestDto>;
  @useResult
  $Res call({String email, String password, String nickname});
}

/// @nodoc
class _$SignupRequestDtoCopyWithImpl<$Res, $Val extends SignupRequestDto>
    implements $SignupRequestDtoCopyWith<$Res> {
  _$SignupRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignupRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? nickname = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SignupRequestDtoImplCopyWith<$Res>
    implements $SignupRequestDtoCopyWith<$Res> {
  factory _$$SignupRequestDtoImplCopyWith(_$SignupRequestDtoImpl value,
          $Res Function(_$SignupRequestDtoImpl) then) =
      __$$SignupRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password, String nickname});
}

/// @nodoc
class __$$SignupRequestDtoImplCopyWithImpl<$Res>
    extends _$SignupRequestDtoCopyWithImpl<$Res, _$SignupRequestDtoImpl>
    implements _$$SignupRequestDtoImplCopyWith<$Res> {
  __$$SignupRequestDtoImplCopyWithImpl(_$SignupRequestDtoImpl _value,
      $Res Function(_$SignupRequestDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SignupRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? nickname = null,
  }) {
    return _then(_$SignupRequestDtoImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SignupRequestDtoImpl implements _SignupRequestDto {
  const _$SignupRequestDtoImpl(
      {required this.email, required this.password, required this.nickname});

  factory _$SignupRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignupRequestDtoImplFromJson(json);

  @override
  final String email;
  @override
  final String password;
  @override
  final String nickname;

  @override
  String toString() {
    return 'SignupRequestDto(email: $email, password: $password, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignupRequestDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password, nickname);

  /// Create a copy of SignupRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignupRequestDtoImplCopyWith<_$SignupRequestDtoImpl> get copyWith =>
      __$$SignupRequestDtoImplCopyWithImpl<_$SignupRequestDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignupRequestDtoImplToJson(
      this,
    );
  }
}

abstract class _SignupRequestDto implements SignupRequestDto {
  const factory _SignupRequestDto(
      {required final String email,
      required final String password,
      required final String nickname}) = _$SignupRequestDtoImpl;

  factory _SignupRequestDto.fromJson(Map<String, dynamic> json) =
      _$SignupRequestDtoImpl.fromJson;

  @override
  String get email;
  @override
  String get password;
  @override
  String get nickname;

  /// Create a copy of SignupRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignupRequestDtoImplCopyWith<_$SignupRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) {
  return _LoginRequestDto.fromJson(json);
}

/// @nodoc
mixin _$LoginRequestDto {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestDtoCopyWith<LoginRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestDtoCopyWith<$Res> {
  factory $LoginRequestDtoCopyWith(
          LoginRequestDto value, $Res Function(LoginRequestDto) then) =
      _$LoginRequestDtoCopyWithImpl<$Res, LoginRequestDto>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestDtoCopyWithImpl<$Res, $Val extends LoginRequestDto>
    implements $LoginRequestDtoCopyWith<$Res> {
  _$LoginRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestDtoImplCopyWith<$Res>
    implements $LoginRequestDtoCopyWith<$Res> {
  factory _$$LoginRequestDtoImplCopyWith(_$LoginRequestDtoImpl value,
          $Res Function(_$LoginRequestDtoImpl) then) =
      __$$LoginRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestDtoImplCopyWithImpl<$Res>
    extends _$LoginRequestDtoCopyWithImpl<$Res, _$LoginRequestDtoImpl>
    implements _$$LoginRequestDtoImplCopyWith<$Res> {
  __$$LoginRequestDtoImplCopyWithImpl(
      _$LoginRequestDtoImpl _value, $Res Function(_$LoginRequestDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginRequestDtoImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestDtoImpl implements _LoginRequestDto {
  const _$LoginRequestDtoImpl({required this.email, required this.password});

  factory _$LoginRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestDtoImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequestDto(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of LoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestDtoImplCopyWith<_$LoginRequestDtoImpl> get copyWith =>
      __$$LoginRequestDtoImplCopyWithImpl<_$LoginRequestDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestDtoImplToJson(
      this,
    );
  }
}

abstract class _LoginRequestDto implements LoginRequestDto {
  const factory _LoginRequestDto(
      {required final String email,
      required final String password}) = _$LoginRequestDtoImpl;

  factory _LoginRequestDto.fromJson(Map<String, dynamic> json) =
      _$LoginRequestDtoImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of LoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestDtoImplCopyWith<_$LoginRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TestLoginRequestDto _$TestLoginRequestDtoFromJson(Map<String, dynamic> json) {
  return _TestLoginRequestDto.fromJson(json);
}

/// @nodoc
mixin _$TestLoginRequestDto {
  int get slot => throw _privateConstructorUsedError;

  /// Serializes this TestLoginRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestLoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestLoginRequestDtoCopyWith<TestLoginRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestLoginRequestDtoCopyWith<$Res> {
  factory $TestLoginRequestDtoCopyWith(
          TestLoginRequestDto value, $Res Function(TestLoginRequestDto) then) =
      _$TestLoginRequestDtoCopyWithImpl<$Res, TestLoginRequestDto>;
  @useResult
  $Res call({int slot});
}

/// @nodoc
class _$TestLoginRequestDtoCopyWithImpl<$Res, $Val extends TestLoginRequestDto>
    implements $TestLoginRequestDtoCopyWith<$Res> {
  _$TestLoginRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestLoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slot = null,
  }) {
    return _then(_value.copyWith(
      slot: null == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestLoginRequestDtoImplCopyWith<$Res>
    implements $TestLoginRequestDtoCopyWith<$Res> {
  factory _$$TestLoginRequestDtoImplCopyWith(_$TestLoginRequestDtoImpl value,
          $Res Function(_$TestLoginRequestDtoImpl) then) =
      __$$TestLoginRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int slot});
}

/// @nodoc
class __$$TestLoginRequestDtoImplCopyWithImpl<$Res>
    extends _$TestLoginRequestDtoCopyWithImpl<$Res, _$TestLoginRequestDtoImpl>
    implements _$$TestLoginRequestDtoImplCopyWith<$Res> {
  __$$TestLoginRequestDtoImplCopyWithImpl(_$TestLoginRequestDtoImpl _value,
      $Res Function(_$TestLoginRequestDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestLoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slot = null,
  }) {
    return _then(_$TestLoginRequestDtoImpl(
      slot: null == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestLoginRequestDtoImpl implements _TestLoginRequestDto {
  const _$TestLoginRequestDtoImpl({this.slot = 1});

  factory _$TestLoginRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestLoginRequestDtoImplFromJson(json);

  @override
  @JsonKey()
  final int slot;

  @override
  String toString() {
    return 'TestLoginRequestDto(slot: $slot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestLoginRequestDtoImpl &&
            (identical(other.slot, slot) || other.slot == slot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slot);

  /// Create a copy of TestLoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestLoginRequestDtoImplCopyWith<_$TestLoginRequestDtoImpl> get copyWith =>
      __$$TestLoginRequestDtoImplCopyWithImpl<_$TestLoginRequestDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestLoginRequestDtoImplToJson(
      this,
    );
  }
}

abstract class _TestLoginRequestDto implements TestLoginRequestDto {
  const factory _TestLoginRequestDto({final int slot}) =
      _$TestLoginRequestDtoImpl;

  factory _TestLoginRequestDto.fromJson(Map<String, dynamic> json) =
      _$TestLoginRequestDtoImpl.fromJson;

  @override
  int get slot;

  /// Create a copy of TestLoginRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestLoginRequestDtoImplCopyWith<_$TestLoginRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSummaryDto _$UserSummaryDtoFromJson(Map<String, dynamic> json) {
  return _UserSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$UserSummaryDto {
  int get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this UserSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSummaryDtoCopyWith<UserSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryDtoCopyWith<$Res> {
  factory $UserSummaryDtoCopyWith(
          UserSummaryDto value, $Res Function(UserSummaryDto) then) =
      _$UserSummaryDtoCopyWithImpl<$Res, UserSummaryDto>;
  @useResult
  $Res call({int userId, String email, String nickname});
}

/// @nodoc
class _$UserSummaryDtoCopyWithImpl<$Res, $Val extends UserSummaryDto>
    implements $UserSummaryDtoCopyWith<$Res> {
  _$UserSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? nickname = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSummaryDtoImplCopyWith<$Res>
    implements $UserSummaryDtoCopyWith<$Res> {
  factory _$$UserSummaryDtoImplCopyWith(_$UserSummaryDtoImpl value,
          $Res Function(_$UserSummaryDtoImpl) then) =
      __$$UserSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String email, String nickname});
}

/// @nodoc
class __$$UserSummaryDtoImplCopyWithImpl<$Res>
    extends _$UserSummaryDtoCopyWithImpl<$Res, _$UserSummaryDtoImpl>
    implements _$$UserSummaryDtoImplCopyWith<$Res> {
  __$$UserSummaryDtoImplCopyWithImpl(
      _$UserSummaryDtoImpl _value, $Res Function(_$UserSummaryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? nickname = null,
  }) {
    return _then(_$UserSummaryDtoImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSummaryDtoImpl implements _UserSummaryDto {
  const _$UserSummaryDtoImpl(
      {required this.userId, required this.email, required this.nickname});

  factory _$UserSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSummaryDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String email;
  @override
  final String nickname;

  @override
  String toString() {
    return 'UserSummaryDto(userId: $userId, email: $email, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, email, nickname);

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryDtoImplCopyWith<_$UserSummaryDtoImpl> get copyWith =>
      __$$UserSummaryDtoImplCopyWithImpl<_$UserSummaryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSummaryDtoImplToJson(
      this,
    );
  }
}

abstract class _UserSummaryDto implements UserSummaryDto {
  const factory _UserSummaryDto(
      {required final int userId,
      required final String email,
      required final String nickname}) = _$UserSummaryDtoImpl;

  factory _UserSummaryDto.fromJson(Map<String, dynamic> json) =
      _$UserSummaryDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get email;
  @override
  String get nickname;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSummaryDtoImplCopyWith<_$UserSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) {
  return _AuthResponseDto.fromJson(json);
}

/// @nodoc
mixin _$AuthResponseDto {
  String get accessToken => throw _privateConstructorUsedError;
  String get tokenType => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;
  UserSummaryDto get user => throw _privateConstructorUsedError;

  /// Serializes this AuthResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseDtoCopyWith<AuthResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseDtoCopyWith<$Res> {
  factory $AuthResponseDtoCopyWith(
          AuthResponseDto value, $Res Function(AuthResponseDto) then) =
      _$AuthResponseDtoCopyWithImpl<$Res, AuthResponseDto>;
  @useResult
  $Res call(
      {String accessToken,
      String tokenType,
      int expiresIn,
      UserSummaryDto user});

  $UserSummaryDtoCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseDtoCopyWithImpl<$Res, $Val extends AuthResponseDto>
    implements $AuthResponseDtoCopyWith<$Res> {
  _$AuthResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummaryDto,
    ) as $Val);
  }

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryDtoCopyWith<$Res> get user {
    return $UserSummaryDtoCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseDtoImplCopyWith<$Res>
    implements $AuthResponseDtoCopyWith<$Res> {
  factory _$$AuthResponseDtoImplCopyWith(_$AuthResponseDtoImpl value,
          $Res Function(_$AuthResponseDtoImpl) then) =
      __$$AuthResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String tokenType,
      int expiresIn,
      UserSummaryDto user});

  @override
  $UserSummaryDtoCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseDtoImplCopyWithImpl<$Res>
    extends _$AuthResponseDtoCopyWithImpl<$Res, _$AuthResponseDtoImpl>
    implements _$$AuthResponseDtoImplCopyWith<$Res> {
  __$$AuthResponseDtoImplCopyWithImpl(
      _$AuthResponseDtoImpl _value, $Res Function(_$AuthResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = null,
    Object? user = null,
  }) {
    return _then(_$AuthResponseDtoImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummaryDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseDtoImpl implements _AuthResponseDto {
  const _$AuthResponseDtoImpl(
      {required this.accessToken,
      required this.tokenType,
      required this.expiresIn,
      required this.user});

  factory _$AuthResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseDtoImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String tokenType;
  @override
  final int expiresIn;
  @override
  final UserSummaryDto user;

  @override
  String toString() {
    return 'AuthResponseDto(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseDtoImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, tokenType, expiresIn, user);

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseDtoImplCopyWith<_$AuthResponseDtoImpl> get copyWith =>
      __$$AuthResponseDtoImplCopyWithImpl<_$AuthResponseDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _AuthResponseDto implements AuthResponseDto {
  const factory _AuthResponseDto(
      {required final String accessToken,
      required final String tokenType,
      required final int expiresIn,
      required final UserSummaryDto user}) = _$AuthResponseDtoImpl;

  factory _AuthResponseDto.fromJson(Map<String, dynamic> json) =
      _$AuthResponseDtoImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get tokenType;
  @override
  int get expiresIn;
  @override
  UserSummaryDto get user;

  /// Create a copy of AuthResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseDtoImplCopyWith<_$AuthResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeResponseDto _$MeResponseDtoFromJson(Map<String, dynamic> json) {
  return _MeResponseDto.fromJson(json);
}

/// @nodoc
mixin _$MeResponseDto {
  int get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get declaredSkinType =>
      throw _privateConstructorUsedError; // 미선택이면 서버가 키를 생략한다
  List<String> get skinConcerns => throw _privateConstructorUsedError;
  String? get sleepPattern => throw _privateConstructorUsedError;
  String? get stressLevel => throw _privateConstructorUsedError;
  String? get exerciseHabit => throw _privateConstructorUsedError;
  String? get waterIntake => throw _privateConstructorUsedError;
  @JsonKey(name: 'isTestAccount')
  bool get isTestAccount => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this MeResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeResponseDtoCopyWith<MeResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeResponseDtoCopyWith<$Res> {
  factory $MeResponseDtoCopyWith(
          MeResponseDto value, $Res Function(MeResponseDto) then) =
      _$MeResponseDtoCopyWithImpl<$Res, MeResponseDto>;
  @useResult
  $Res call(
      {int userId,
      String email,
      String nickname,
      String? declaredSkinType,
      List<String> skinConcerns,
      String? sleepPattern,
      String? stressLevel,
      String? exerciseHabit,
      String? waterIntake,
      @JsonKey(name: 'isTestAccount') bool isTestAccount,
      DateTime? joinedAt});
}

/// @nodoc
class _$MeResponseDtoCopyWithImpl<$Res, $Val extends MeResponseDto>
    implements $MeResponseDtoCopyWith<$Res> {
  _$MeResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? nickname = null,
    Object? declaredSkinType = freezed,
    Object? skinConcerns = null,
    Object? sleepPattern = freezed,
    Object? stressLevel = freezed,
    Object? exerciseHabit = freezed,
    Object? waterIntake = freezed,
    Object? isTestAccount = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      declaredSkinType: freezed == declaredSkinType
          ? _value.declaredSkinType
          : declaredSkinType // ignore: cast_nullable_to_non_nullable
              as String?,
      skinConcerns: null == skinConcerns
          ? _value.skinConcerns
          : skinConcerns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepPattern: freezed == sleepPattern
          ? _value.sleepPattern
          : sleepPattern // ignore: cast_nullable_to_non_nullable
              as String?,
      stressLevel: freezed == stressLevel
          ? _value.stressLevel
          : stressLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseHabit: freezed == exerciseHabit
          ? _value.exerciseHabit
          : exerciseHabit // ignore: cast_nullable_to_non_nullable
              as String?,
      waterIntake: freezed == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as String?,
      isTestAccount: null == isTestAccount
          ? _value.isTestAccount
          : isTestAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeResponseDtoImplCopyWith<$Res>
    implements $MeResponseDtoCopyWith<$Res> {
  factory _$$MeResponseDtoImplCopyWith(
          _$MeResponseDtoImpl value, $Res Function(_$MeResponseDtoImpl) then) =
      __$$MeResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int userId,
      String email,
      String nickname,
      String? declaredSkinType,
      List<String> skinConcerns,
      String? sleepPattern,
      String? stressLevel,
      String? exerciseHabit,
      String? waterIntake,
      @JsonKey(name: 'isTestAccount') bool isTestAccount,
      DateTime? joinedAt});
}

/// @nodoc
class __$$MeResponseDtoImplCopyWithImpl<$Res>
    extends _$MeResponseDtoCopyWithImpl<$Res, _$MeResponseDtoImpl>
    implements _$$MeResponseDtoImplCopyWith<$Res> {
  __$$MeResponseDtoImplCopyWithImpl(
      _$MeResponseDtoImpl _value, $Res Function(_$MeResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? nickname = null,
    Object? declaredSkinType = freezed,
    Object? skinConcerns = null,
    Object? sleepPattern = freezed,
    Object? stressLevel = freezed,
    Object? exerciseHabit = freezed,
    Object? waterIntake = freezed,
    Object? isTestAccount = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_$MeResponseDtoImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      declaredSkinType: freezed == declaredSkinType
          ? _value.declaredSkinType
          : declaredSkinType // ignore: cast_nullable_to_non_nullable
              as String?,
      skinConcerns: null == skinConcerns
          ? _value._skinConcerns
          : skinConcerns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepPattern: freezed == sleepPattern
          ? _value.sleepPattern
          : sleepPattern // ignore: cast_nullable_to_non_nullable
              as String?,
      stressLevel: freezed == stressLevel
          ? _value.stressLevel
          : stressLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseHabit: freezed == exerciseHabit
          ? _value.exerciseHabit
          : exerciseHabit // ignore: cast_nullable_to_non_nullable
              as String?,
      waterIntake: freezed == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as String?,
      isTestAccount: null == isTestAccount
          ? _value.isTestAccount
          : isTestAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeResponseDtoImpl implements _MeResponseDto {
  const _$MeResponseDtoImpl(
      {required this.userId,
      required this.email,
      required this.nickname,
      this.declaredSkinType,
      final List<String> skinConcerns = const <String>[],
      this.sleepPattern,
      this.stressLevel,
      this.exerciseHabit,
      this.waterIntake,
      @JsonKey(name: 'isTestAccount') this.isTestAccount = false,
      this.joinedAt})
      : _skinConcerns = skinConcerns;

  factory _$MeResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeResponseDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String email;
  @override
  final String nickname;
  @override
  final String? declaredSkinType;
// 미선택이면 서버가 키를 생략한다
  final List<String> _skinConcerns;
// 미선택이면 서버가 키를 생략한다
  @override
  @JsonKey()
  List<String> get skinConcerns {
    if (_skinConcerns is EqualUnmodifiableListView) return _skinConcerns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skinConcerns);
  }

  @override
  final String? sleepPattern;
  @override
  final String? stressLevel;
  @override
  final String? exerciseHabit;
  @override
  final String? waterIntake;
  @override
  @JsonKey(name: 'isTestAccount')
  final bool isTestAccount;
  @override
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'MeResponseDto(userId: $userId, email: $email, nickname: $nickname, declaredSkinType: $declaredSkinType, skinConcerns: $skinConcerns, sleepPattern: $sleepPattern, stressLevel: $stressLevel, exerciseHabit: $exerciseHabit, waterIntake: $waterIntake, isTestAccount: $isTestAccount, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeResponseDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.declaredSkinType, declaredSkinType) ||
                other.declaredSkinType == declaredSkinType) &&
            const DeepCollectionEquality()
                .equals(other._skinConcerns, _skinConcerns) &&
            (identical(other.sleepPattern, sleepPattern) ||
                other.sleepPattern == sleepPattern) &&
            (identical(other.stressLevel, stressLevel) ||
                other.stressLevel == stressLevel) &&
            (identical(other.exerciseHabit, exerciseHabit) ||
                other.exerciseHabit == exerciseHabit) &&
            (identical(other.waterIntake, waterIntake) ||
                other.waterIntake == waterIntake) &&
            (identical(other.isTestAccount, isTestAccount) ||
                other.isTestAccount == isTestAccount) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      email,
      nickname,
      declaredSkinType,
      const DeepCollectionEquality().hash(_skinConcerns),
      sleepPattern,
      stressLevel,
      exerciseHabit,
      waterIntake,
      isTestAccount,
      joinedAt);

  /// Create a copy of MeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeResponseDtoImplCopyWith<_$MeResponseDtoImpl> get copyWith =>
      __$$MeResponseDtoImplCopyWithImpl<_$MeResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _MeResponseDto implements MeResponseDto {
  const factory _MeResponseDto(
      {required final int userId,
      required final String email,
      required final String nickname,
      final String? declaredSkinType,
      final List<String> skinConcerns,
      final String? sleepPattern,
      final String? stressLevel,
      final String? exerciseHabit,
      final String? waterIntake,
      @JsonKey(name: 'isTestAccount') final bool isTestAccount,
      final DateTime? joinedAt}) = _$MeResponseDtoImpl;

  factory _MeResponseDto.fromJson(Map<String, dynamic> json) =
      _$MeResponseDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get email;
  @override
  String get nickname;
  @override
  String? get declaredSkinType; // 미선택이면 서버가 키를 생략한다
  @override
  List<String> get skinConcerns;
  @override
  String? get sleepPattern;
  @override
  String? get stressLevel;
  @override
  String? get exerciseHabit;
  @override
  String? get waterIntake;
  @override
  @JsonKey(name: 'isTestAccount')
  bool get isTestAccount;
  @override
  DateTime? get joinedAt;

  /// Create a copy of MeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeResponseDtoImplCopyWith<_$MeResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
