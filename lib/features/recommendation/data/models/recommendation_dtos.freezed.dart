// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecommendedFoodDto _$RecommendedFoodDtoFromJson(Map<String, dynamic> json) {
  return _RecommendedFoodDto.fromJson(json);
}

/// @nodoc
mixin _$RecommendedFoodDto {
  String get foodName => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this RecommendedFoodDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendedFoodDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendedFoodDtoCopyWith<RecommendedFoodDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendedFoodDtoCopyWith<$Res> {
  factory $RecommendedFoodDtoCopyWith(
          RecommendedFoodDto value, $Res Function(RecommendedFoodDto) then) =
      _$RecommendedFoodDtoCopyWithImpl<$Res, RecommendedFoodDto>;
  @useResult
  $Res call({String foodName, String reason});
}

/// @nodoc
class _$RecommendedFoodDtoCopyWithImpl<$Res, $Val extends RecommendedFoodDto>
    implements $RecommendedFoodDtoCopyWith<$Res> {
  _$RecommendedFoodDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendedFoodDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodName = null,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendedFoodDtoImplCopyWith<$Res>
    implements $RecommendedFoodDtoCopyWith<$Res> {
  factory _$$RecommendedFoodDtoImplCopyWith(_$RecommendedFoodDtoImpl value,
          $Res Function(_$RecommendedFoodDtoImpl) then) =
      __$$RecommendedFoodDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String foodName, String reason});
}

/// @nodoc
class __$$RecommendedFoodDtoImplCopyWithImpl<$Res>
    extends _$RecommendedFoodDtoCopyWithImpl<$Res, _$RecommendedFoodDtoImpl>
    implements _$$RecommendedFoodDtoImplCopyWith<$Res> {
  __$$RecommendedFoodDtoImplCopyWithImpl(_$RecommendedFoodDtoImpl _value,
      $Res Function(_$RecommendedFoodDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendedFoodDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodName = null,
    Object? reason = null,
  }) {
    return _then(_$RecommendedFoodDtoImpl(
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendedFoodDtoImpl implements _RecommendedFoodDto {
  const _$RecommendedFoodDtoImpl({required this.foodName, this.reason = ''});

  factory _$RecommendedFoodDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendedFoodDtoImplFromJson(json);

  @override
  final String foodName;
  @override
  @JsonKey()
  final String reason;

  @override
  String toString() {
    return 'RecommendedFoodDto(foodName: $foodName, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendedFoodDtoImpl &&
            (identical(other.foodName, foodName) ||
                other.foodName == foodName) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, foodName, reason);

  /// Create a copy of RecommendedFoodDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendedFoodDtoImplCopyWith<_$RecommendedFoodDtoImpl> get copyWith =>
      __$$RecommendedFoodDtoImplCopyWithImpl<_$RecommendedFoodDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendedFoodDtoImplToJson(
      this,
    );
  }
}

abstract class _RecommendedFoodDto implements RecommendedFoodDto {
  const factory _RecommendedFoodDto(
      {required final String foodName,
      final String reason}) = _$RecommendedFoodDtoImpl;

  factory _RecommendedFoodDto.fromJson(Map<String, dynamic> json) =
      _$RecommendedFoodDtoImpl.fromJson;

  @override
  String get foodName;
  @override
  String get reason;

  /// Create a copy of RecommendedFoodDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendedFoodDtoImplCopyWith<_$RecommendedFoodDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecommendationDto _$RecommendationDtoFromJson(Map<String, dynamic> json) {
  return _RecommendationDto.fromJson(json);
}

/// @nodoc
mixin _$RecommendationDto {
  int get skinAnalysisId => throw _privateConstructorUsedError;
  List<RecommendedFoodDto> get recommend => throw _privateConstructorUsedError;
  List<RecommendedFoodDto> get avoid => throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this RecommendationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationDtoCopyWith<RecommendationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationDtoCopyWith<$Res> {
  factory $RecommendationDtoCopyWith(
          RecommendationDto value, $Res Function(RecommendationDto) then) =
      _$RecommendationDtoCopyWithImpl<$Res, RecommendationDto>;
  @useResult
  $Res call(
      {int skinAnalysisId,
      List<RecommendedFoodDto> recommend,
      List<RecommendedFoodDto> avoid,
      DateTime? generatedAt});
}

/// @nodoc
class _$RecommendationDtoCopyWithImpl<$Res, $Val extends RecommendationDto>
    implements $RecommendationDtoCopyWith<$Res> {
  _$RecommendationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? recommend = null,
    Object? avoid = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      recommend: null == recommend
          ? _value.recommend
          : recommend // ignore: cast_nullable_to_non_nullable
              as List<RecommendedFoodDto>,
      avoid: null == avoid
          ? _value.avoid
          : avoid // ignore: cast_nullable_to_non_nullable
              as List<RecommendedFoodDto>,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationDtoImplCopyWith<$Res>
    implements $RecommendationDtoCopyWith<$Res> {
  factory _$$RecommendationDtoImplCopyWith(_$RecommendationDtoImpl value,
          $Res Function(_$RecommendationDtoImpl) then) =
      __$$RecommendationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int skinAnalysisId,
      List<RecommendedFoodDto> recommend,
      List<RecommendedFoodDto> avoid,
      DateTime? generatedAt});
}

/// @nodoc
class __$$RecommendationDtoImplCopyWithImpl<$Res>
    extends _$RecommendationDtoCopyWithImpl<$Res, _$RecommendationDtoImpl>
    implements _$$RecommendationDtoImplCopyWith<$Res> {
  __$$RecommendationDtoImplCopyWithImpl(_$RecommendationDtoImpl _value,
      $Res Function(_$RecommendationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? recommend = null,
    Object? avoid = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_$RecommendationDtoImpl(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      recommend: null == recommend
          ? _value._recommend
          : recommend // ignore: cast_nullable_to_non_nullable
              as List<RecommendedFoodDto>,
      avoid: null == avoid
          ? _value._avoid
          : avoid // ignore: cast_nullable_to_non_nullable
              as List<RecommendedFoodDto>,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationDtoImpl implements _RecommendationDto {
  const _$RecommendationDtoImpl(
      {required this.skinAnalysisId,
      final List<RecommendedFoodDto> recommend = const <RecommendedFoodDto>[],
      final List<RecommendedFoodDto> avoid = const <RecommendedFoodDto>[],
      this.generatedAt})
      : _recommend = recommend,
        _avoid = avoid;

  factory _$RecommendationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationDtoImplFromJson(json);

  @override
  final int skinAnalysisId;
  final List<RecommendedFoodDto> _recommend;
  @override
  @JsonKey()
  List<RecommendedFoodDto> get recommend {
    if (_recommend is EqualUnmodifiableListView) return _recommend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommend);
  }

  final List<RecommendedFoodDto> _avoid;
  @override
  @JsonKey()
  List<RecommendedFoodDto> get avoid {
    if (_avoid is EqualUnmodifiableListView) return _avoid;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_avoid);
  }

  @override
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'RecommendationDto(skinAnalysisId: $skinAnalysisId, recommend: $recommend, avoid: $avoid, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationDtoImpl &&
            (identical(other.skinAnalysisId, skinAnalysisId) ||
                other.skinAnalysisId == skinAnalysisId) &&
            const DeepCollectionEquality()
                .equals(other._recommend, _recommend) &&
            const DeepCollectionEquality().equals(other._avoid, _avoid) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      skinAnalysisId,
      const DeepCollectionEquality().hash(_recommend),
      const DeepCollectionEquality().hash(_avoid),
      generatedAt);

  /// Create a copy of RecommendationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationDtoImplCopyWith<_$RecommendationDtoImpl> get copyWith =>
      __$$RecommendationDtoImplCopyWithImpl<_$RecommendationDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationDtoImplToJson(
      this,
    );
  }
}

abstract class _RecommendationDto implements RecommendationDto {
  const factory _RecommendationDto(
      {required final int skinAnalysisId,
      final List<RecommendedFoodDto> recommend,
      final List<RecommendedFoodDto> avoid,
      final DateTime? generatedAt}) = _$RecommendationDtoImpl;

  factory _RecommendationDto.fromJson(Map<String, dynamic> json) =
      _$RecommendationDtoImpl.fromJson;

  @override
  int get skinAnalysisId;
  @override
  List<RecommendedFoodDto> get recommend;
  @override
  List<RecommendedFoodDto> get avoid;
  @override
  DateTime? get generatedAt;

  /// Create a copy of RecommendationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationDtoImplCopyWith<_$RecommendationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
