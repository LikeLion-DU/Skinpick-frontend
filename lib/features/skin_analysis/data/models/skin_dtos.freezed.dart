// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skin_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SkinMetricsDto _$SkinMetricsDtoFromJson(Map<String, dynamic> json) {
  return _SkinMetricsDto.fromJson(json);
}

/// @nodoc
mixin _$SkinMetricsDto {
  int get hydration => throw _privateConstructorUsedError;
  int get oil => throw _privateConstructorUsedError;
  int get redness => throw _privateConstructorUsedError;
  int get trouble => throw _privateConstructorUsedError;
  int get barrier => throw _privateConstructorUsedError;

  /// Serializes this SkinMetricsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinMetricsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinMetricsDtoCopyWith<SkinMetricsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinMetricsDtoCopyWith<$Res> {
  factory $SkinMetricsDtoCopyWith(
          SkinMetricsDto value, $Res Function(SkinMetricsDto) then) =
      _$SkinMetricsDtoCopyWithImpl<$Res, SkinMetricsDto>;
  @useResult
  $Res call({int hydration, int oil, int redness, int trouble, int barrier});
}

/// @nodoc
class _$SkinMetricsDtoCopyWithImpl<$Res, $Val extends SkinMetricsDto>
    implements $SkinMetricsDtoCopyWith<$Res> {
  _$SkinMetricsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinMetricsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydration = null,
    Object? oil = null,
    Object? redness = null,
    Object? trouble = null,
    Object? barrier = null,
  }) {
    return _then(_value.copyWith(
      hydration: null == hydration
          ? _value.hydration
          : hydration // ignore: cast_nullable_to_non_nullable
              as int,
      oil: null == oil
          ? _value.oil
          : oil // ignore: cast_nullable_to_non_nullable
              as int,
      redness: null == redness
          ? _value.redness
          : redness // ignore: cast_nullable_to_non_nullable
              as int,
      trouble: null == trouble
          ? _value.trouble
          : trouble // ignore: cast_nullable_to_non_nullable
              as int,
      barrier: null == barrier
          ? _value.barrier
          : barrier // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinMetricsDtoImplCopyWith<$Res>
    implements $SkinMetricsDtoCopyWith<$Res> {
  factory _$$SkinMetricsDtoImplCopyWith(_$SkinMetricsDtoImpl value,
          $Res Function(_$SkinMetricsDtoImpl) then) =
      __$$SkinMetricsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hydration, int oil, int redness, int trouble, int barrier});
}

/// @nodoc
class __$$SkinMetricsDtoImplCopyWithImpl<$Res>
    extends _$SkinMetricsDtoCopyWithImpl<$Res, _$SkinMetricsDtoImpl>
    implements _$$SkinMetricsDtoImplCopyWith<$Res> {
  __$$SkinMetricsDtoImplCopyWithImpl(
      _$SkinMetricsDtoImpl _value, $Res Function(_$SkinMetricsDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinMetricsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydration = null,
    Object? oil = null,
    Object? redness = null,
    Object? trouble = null,
    Object? barrier = null,
  }) {
    return _then(_$SkinMetricsDtoImpl(
      hydration: null == hydration
          ? _value.hydration
          : hydration // ignore: cast_nullable_to_non_nullable
              as int,
      oil: null == oil
          ? _value.oil
          : oil // ignore: cast_nullable_to_non_nullable
              as int,
      redness: null == redness
          ? _value.redness
          : redness // ignore: cast_nullable_to_non_nullable
              as int,
      trouble: null == trouble
          ? _value.trouble
          : trouble // ignore: cast_nullable_to_non_nullable
              as int,
      barrier: null == barrier
          ? _value.barrier
          : barrier // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinMetricsDtoImpl implements _SkinMetricsDto {
  const _$SkinMetricsDtoImpl(
      {required this.hydration,
      required this.oil,
      required this.redness,
      required this.trouble,
      required this.barrier});

  factory _$SkinMetricsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinMetricsDtoImplFromJson(json);

  @override
  final int hydration;
  @override
  final int oil;
  @override
  final int redness;
  @override
  final int trouble;
  @override
  final int barrier;

  @override
  String toString() {
    return 'SkinMetricsDto(hydration: $hydration, oil: $oil, redness: $redness, trouble: $trouble, barrier: $barrier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinMetricsDtoImpl &&
            (identical(other.hydration, hydration) ||
                other.hydration == hydration) &&
            (identical(other.oil, oil) || other.oil == oil) &&
            (identical(other.redness, redness) || other.redness == redness) &&
            (identical(other.trouble, trouble) || other.trouble == trouble) &&
            (identical(other.barrier, barrier) || other.barrier == barrier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hydration, oil, redness, trouble, barrier);

  /// Create a copy of SkinMetricsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinMetricsDtoImplCopyWith<_$SkinMetricsDtoImpl> get copyWith =>
      __$$SkinMetricsDtoImplCopyWithImpl<_$SkinMetricsDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinMetricsDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinMetricsDto implements SkinMetricsDto {
  const factory _SkinMetricsDto(
      {required final int hydration,
      required final int oil,
      required final int redness,
      required final int trouble,
      required final int barrier}) = _$SkinMetricsDtoImpl;

  factory _SkinMetricsDto.fromJson(Map<String, dynamic> json) =
      _$SkinMetricsDtoImpl.fromJson;

  @override
  int get hydration;
  @override
  int get oil;
  @override
  int get redness;
  @override
  int get trouble;
  @override
  int get barrier;

  /// Create a copy of SkinMetricsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinMetricsDtoImplCopyWith<_$SkinMetricsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HighlightDto _$HighlightDtoFromJson(Map<String, dynamic> json) {
  return _HighlightDto.fromJson(json);
}

/// @nodoc
mixin _$HighlightDto {
  String get label => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this HighlightDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightDtoCopyWith<HighlightDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightDtoCopyWith<$Res> {
  factory $HighlightDtoCopyWith(
          HighlightDto value, $Res Function(HighlightDto) then) =
      _$HighlightDtoCopyWithImpl<$Res, HighlightDto>;
  @useResult
  $Res call({String label, String status});
}

/// @nodoc
class _$HighlightDtoCopyWithImpl<$Res, $Val extends HighlightDto>
    implements $HighlightDtoCopyWith<$Res> {
  _$HighlightDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HighlightDtoImplCopyWith<$Res>
    implements $HighlightDtoCopyWith<$Res> {
  factory _$$HighlightDtoImplCopyWith(
          _$HighlightDtoImpl value, $Res Function(_$HighlightDtoImpl) then) =
      __$$HighlightDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String status});
}

/// @nodoc
class __$$HighlightDtoImplCopyWithImpl<$Res>
    extends _$HighlightDtoCopyWithImpl<$Res, _$HighlightDtoImpl>
    implements _$$HighlightDtoImplCopyWith<$Res> {
  __$$HighlightDtoImplCopyWithImpl(
      _$HighlightDtoImpl _value, $Res Function(_$HighlightDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HighlightDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? status = null,
  }) {
    return _then(_$HighlightDtoImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightDtoImpl implements _HighlightDto {
  const _$HighlightDtoImpl({required this.label, required this.status});

  factory _$HighlightDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightDtoImplFromJson(json);

  @override
  final String label;
  @override
  final String status;

  @override
  String toString() {
    return 'HighlightDto(label: $label, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightDtoImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, status);

  /// Create a copy of HighlightDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightDtoImplCopyWith<_$HighlightDtoImpl> get copyWith =>
      __$$HighlightDtoImplCopyWithImpl<_$HighlightDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightDtoImplToJson(
      this,
    );
  }
}

abstract class _HighlightDto implements HighlightDto {
  const factory _HighlightDto(
      {required final String label,
      required final String status}) = _$HighlightDtoImpl;

  factory _HighlightDto.fromJson(Map<String, dynamic> json) =
      _$HighlightDtoImpl.fromJson;

  @override
  String get label;
  @override
  String get status;

  /// Create a copy of HighlightDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightDtoImplCopyWith<_$HighlightDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinTypeGapDto _$SkinTypeGapDtoFromJson(Map<String, dynamic> json) {
  return _SkinTypeGapDto.fromJson(json);
}

/// @nodoc
mixin _$SkinTypeGapDto {
  String get declared => throw _privateConstructorUsedError;
  String get observed => throw _privateConstructorUsedError;
  bool get matched => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this SkinTypeGapDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinTypeGapDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinTypeGapDtoCopyWith<SkinTypeGapDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinTypeGapDtoCopyWith<$Res> {
  factory $SkinTypeGapDtoCopyWith(
          SkinTypeGapDto value, $Res Function(SkinTypeGapDto) then) =
      _$SkinTypeGapDtoCopyWithImpl<$Res, SkinTypeGapDto>;
  @useResult
  $Res call({String declared, String observed, bool matched, String message});
}

/// @nodoc
class _$SkinTypeGapDtoCopyWithImpl<$Res, $Val extends SkinTypeGapDto>
    implements $SkinTypeGapDtoCopyWith<$Res> {
  _$SkinTypeGapDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinTypeGapDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? declared = null,
    Object? observed = null,
    Object? matched = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      declared: null == declared
          ? _value.declared
          : declared // ignore: cast_nullable_to_non_nullable
              as String,
      observed: null == observed
          ? _value.observed
          : observed // ignore: cast_nullable_to_non_nullable
              as String,
      matched: null == matched
          ? _value.matched
          : matched // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinTypeGapDtoImplCopyWith<$Res>
    implements $SkinTypeGapDtoCopyWith<$Res> {
  factory _$$SkinTypeGapDtoImplCopyWith(_$SkinTypeGapDtoImpl value,
          $Res Function(_$SkinTypeGapDtoImpl) then) =
      __$$SkinTypeGapDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String declared, String observed, bool matched, String message});
}

/// @nodoc
class __$$SkinTypeGapDtoImplCopyWithImpl<$Res>
    extends _$SkinTypeGapDtoCopyWithImpl<$Res, _$SkinTypeGapDtoImpl>
    implements _$$SkinTypeGapDtoImplCopyWith<$Res> {
  __$$SkinTypeGapDtoImplCopyWithImpl(
      _$SkinTypeGapDtoImpl _value, $Res Function(_$SkinTypeGapDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinTypeGapDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? declared = null,
    Object? observed = null,
    Object? matched = null,
    Object? message = null,
  }) {
    return _then(_$SkinTypeGapDtoImpl(
      declared: null == declared
          ? _value.declared
          : declared // ignore: cast_nullable_to_non_nullable
              as String,
      observed: null == observed
          ? _value.observed
          : observed // ignore: cast_nullable_to_non_nullable
              as String,
      matched: null == matched
          ? _value.matched
          : matched // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinTypeGapDtoImpl implements _SkinTypeGapDto {
  const _$SkinTypeGapDtoImpl(
      {required this.declared,
      required this.observed,
      this.matched = false,
      this.message = ''});

  factory _$SkinTypeGapDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinTypeGapDtoImplFromJson(json);

  @override
  final String declared;
  @override
  final String observed;
  @override
  @JsonKey()
  final bool matched;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'SkinTypeGapDto(declared: $declared, observed: $observed, matched: $matched, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinTypeGapDtoImpl &&
            (identical(other.declared, declared) ||
                other.declared == declared) &&
            (identical(other.observed, observed) ||
                other.observed == observed) &&
            (identical(other.matched, matched) || other.matched == matched) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, declared, observed, matched, message);

  /// Create a copy of SkinTypeGapDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinTypeGapDtoImplCopyWith<_$SkinTypeGapDtoImpl> get copyWith =>
      __$$SkinTypeGapDtoImplCopyWithImpl<_$SkinTypeGapDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinTypeGapDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinTypeGapDto implements SkinTypeGapDto {
  const factory _SkinTypeGapDto(
      {required final String declared,
      required final String observed,
      final bool matched,
      final String message}) = _$SkinTypeGapDtoImpl;

  factory _SkinTypeGapDto.fromJson(Map<String, dynamic> json) =
      _$SkinTypeGapDtoImpl.fromJson;

  @override
  String get declared;
  @override
  String get observed;
  @override
  bool get matched;
  @override
  String get message;

  /// Create a copy of SkinTypeGapDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinTypeGapDtoImplCopyWith<_$SkinTypeGapDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoredItemDto _$ScoredItemDtoFromJson(Map<String, dynamic> json) {
  return _ScoredItemDto.fromJson(json);
}

/// @nodoc
mixin _$ScoredItemDto {
  String get key => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  List<String> get evidence => throw _privateConstructorUsedError;

  /// Serializes this ScoredItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoredItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoredItemDtoCopyWith<ScoredItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoredItemDtoCopyWith<$Res> {
  factory $ScoredItemDtoCopyWith(
          ScoredItemDto value, $Res Function(ScoredItemDto) then) =
      _$ScoredItemDtoCopyWithImpl<$Res, ScoredItemDto>;
  @useResult
  $Res call({String key, int score, String level, List<String> evidence});
}

/// @nodoc
class _$ScoredItemDtoCopyWithImpl<$Res, $Val extends ScoredItemDto>
    implements $ScoredItemDtoCopyWith<$Res> {
  _$ScoredItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoredItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? score = null,
    Object? level = null,
    Object? evidence = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      evidence: null == evidence
          ? _value.evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoredItemDtoImplCopyWith<$Res>
    implements $ScoredItemDtoCopyWith<$Res> {
  factory _$$ScoredItemDtoImplCopyWith(
          _$ScoredItemDtoImpl value, $Res Function(_$ScoredItemDtoImpl) then) =
      __$$ScoredItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, int score, String level, List<String> evidence});
}

/// @nodoc
class __$$ScoredItemDtoImplCopyWithImpl<$Res>
    extends _$ScoredItemDtoCopyWithImpl<$Res, _$ScoredItemDtoImpl>
    implements _$$ScoredItemDtoImplCopyWith<$Res> {
  __$$ScoredItemDtoImplCopyWithImpl(
      _$ScoredItemDtoImpl _value, $Res Function(_$ScoredItemDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoredItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? score = null,
    Object? level = null,
    Object? evidence = null,
  }) {
    return _then(_$ScoredItemDtoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      evidence: null == evidence
          ? _value._evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoredItemDtoImpl implements _ScoredItemDto {
  const _$ScoredItemDtoImpl(
      {required this.key,
      required this.score,
      this.level = '',
      final List<String> evidence = const <String>[]})
      : _evidence = evidence;

  factory _$ScoredItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoredItemDtoImplFromJson(json);

  @override
  final String key;
  @override
  final int score;
  @override
  @JsonKey()
  final String level;
  final List<String> _evidence;
  @override
  @JsonKey()
  List<String> get evidence {
    if (_evidence is EqualUnmodifiableListView) return _evidence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_evidence);
  }

  @override
  String toString() {
    return 'ScoredItemDto(key: $key, score: $score, level: $level, evidence: $evidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoredItemDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(other._evidence, _evidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, score, level,
      const DeepCollectionEquality().hash(_evidence));

  /// Create a copy of ScoredItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoredItemDtoImplCopyWith<_$ScoredItemDtoImpl> get copyWith =>
      __$$ScoredItemDtoImplCopyWithImpl<_$ScoredItemDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoredItemDtoImplToJson(
      this,
    );
  }
}

abstract class _ScoredItemDto implements ScoredItemDto {
  const factory _ScoredItemDto(
      {required final String key,
      required final int score,
      final String level,
      final List<String> evidence}) = _$ScoredItemDtoImpl;

  factory _ScoredItemDto.fromJson(Map<String, dynamic> json) =
      _$ScoredItemDtoImpl.fromJson;

  @override
  String get key;
  @override
  int get score;
  @override
  String get level;
  @override
  List<String> get evidence;

  /// Create a copy of ScoredItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoredItemDtoImplCopyWith<_$ScoredItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinTypeDto _$SkinTypeDtoFromJson(Map<String, dynamic> json) {
  return _SkinTypeDto.fromJson(json);
}

/// @nodoc
mixin _$SkinTypeDto {
  String? get primary => throw _privateConstructorUsedError;
  List<String> get traits => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this SkinTypeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinTypeDtoCopyWith<SkinTypeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinTypeDtoCopyWith<$Res> {
  factory $SkinTypeDtoCopyWith(
          SkinTypeDto value, $Res Function(SkinTypeDto) then) =
      _$SkinTypeDtoCopyWithImpl<$Res, SkinTypeDto>;
  @useResult
  $Res call({String? primary, List<String> traits, String label});
}

/// @nodoc
class _$SkinTypeDtoCopyWithImpl<$Res, $Val extends SkinTypeDto>
    implements $SkinTypeDtoCopyWith<$Res> {
  _$SkinTypeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = freezed,
    Object? traits = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      primary: freezed == primary
          ? _value.primary
          : primary // ignore: cast_nullable_to_non_nullable
              as String?,
      traits: null == traits
          ? _value.traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinTypeDtoImplCopyWith<$Res>
    implements $SkinTypeDtoCopyWith<$Res> {
  factory _$$SkinTypeDtoImplCopyWith(
          _$SkinTypeDtoImpl value, $Res Function(_$SkinTypeDtoImpl) then) =
      __$$SkinTypeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? primary, List<String> traits, String label});
}

/// @nodoc
class __$$SkinTypeDtoImplCopyWithImpl<$Res>
    extends _$SkinTypeDtoCopyWithImpl<$Res, _$SkinTypeDtoImpl>
    implements _$$SkinTypeDtoImplCopyWith<$Res> {
  __$$SkinTypeDtoImplCopyWithImpl(
      _$SkinTypeDtoImpl _value, $Res Function(_$SkinTypeDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = freezed,
    Object? traits = null,
    Object? label = null,
  }) {
    return _then(_$SkinTypeDtoImpl(
      primary: freezed == primary
          ? _value.primary
          : primary // ignore: cast_nullable_to_non_nullable
              as String?,
      traits: null == traits
          ? _value._traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinTypeDtoImpl implements _SkinTypeDto {
  const _$SkinTypeDtoImpl(
      {this.primary,
      final List<String> traits = const <String>[],
      this.label = ''})
      : _traits = traits;

  factory _$SkinTypeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinTypeDtoImplFromJson(json);

  @override
  final String? primary;
  final List<String> _traits;
  @override
  @JsonKey()
  List<String> get traits {
    if (_traits is EqualUnmodifiableListView) return _traits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_traits);
  }

  @override
  @JsonKey()
  final String label;

  @override
  String toString() {
    return 'SkinTypeDto(primary: $primary, traits: $traits, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinTypeDtoImpl &&
            (identical(other.primary, primary) || other.primary == primary) &&
            const DeepCollectionEquality().equals(other._traits, _traits) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, primary,
      const DeepCollectionEquality().hash(_traits), label);

  /// Create a copy of SkinTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinTypeDtoImplCopyWith<_$SkinTypeDtoImpl> get copyWith =>
      __$$SkinTypeDtoImplCopyWithImpl<_$SkinTypeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinTypeDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinTypeDto implements SkinTypeDto {
  const factory _SkinTypeDto(
      {final String? primary,
      final List<String> traits,
      final String label}) = _$SkinTypeDtoImpl;

  factory _SkinTypeDto.fromJson(Map<String, dynamic> json) =
      _$SkinTypeDtoImpl.fromJson;

  @override
  String? get primary;
  @override
  List<String> get traits;
  @override
  String get label;

  /// Create a copy of SkinTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinTypeDtoImplCopyWith<_$SkinTypeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinAgeDto _$SkinAgeDtoFromJson(Map<String, dynamic> json) {
  return _SkinAgeDto.fromJson(json);
}

/// @nodoc
mixin _$SkinAgeDto {
  int get estimatedSkinAge => throw _privateConstructorUsedError;
  List<ScoredItemDto> get axes => throw _privateConstructorUsedError;
  String get assessment => throw _privateConstructorUsedError;

  /// Serializes this SkinAgeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinAgeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinAgeDtoCopyWith<SkinAgeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinAgeDtoCopyWith<$Res> {
  factory $SkinAgeDtoCopyWith(
          SkinAgeDto value, $Res Function(SkinAgeDto) then) =
      _$SkinAgeDtoCopyWithImpl<$Res, SkinAgeDto>;
  @useResult
  $Res call(
      {int estimatedSkinAge, List<ScoredItemDto> axes, String assessment});
}

/// @nodoc
class _$SkinAgeDtoCopyWithImpl<$Res, $Val extends SkinAgeDto>
    implements $SkinAgeDtoCopyWith<$Res> {
  _$SkinAgeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinAgeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedSkinAge = null,
    Object? axes = null,
    Object? assessment = null,
  }) {
    return _then(_value.copyWith(
      estimatedSkinAge: null == estimatedSkinAge
          ? _value.estimatedSkinAge
          : estimatedSkinAge // ignore: cast_nullable_to_non_nullable
              as int,
      axes: null == axes
          ? _value.axes
          : axes // ignore: cast_nullable_to_non_nullable
              as List<ScoredItemDto>,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinAgeDtoImplCopyWith<$Res>
    implements $SkinAgeDtoCopyWith<$Res> {
  factory _$$SkinAgeDtoImplCopyWith(
          _$SkinAgeDtoImpl value, $Res Function(_$SkinAgeDtoImpl) then) =
      __$$SkinAgeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int estimatedSkinAge, List<ScoredItemDto> axes, String assessment});
}

/// @nodoc
class __$$SkinAgeDtoImplCopyWithImpl<$Res>
    extends _$SkinAgeDtoCopyWithImpl<$Res, _$SkinAgeDtoImpl>
    implements _$$SkinAgeDtoImplCopyWith<$Res> {
  __$$SkinAgeDtoImplCopyWithImpl(
      _$SkinAgeDtoImpl _value, $Res Function(_$SkinAgeDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinAgeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedSkinAge = null,
    Object? axes = null,
    Object? assessment = null,
  }) {
    return _then(_$SkinAgeDtoImpl(
      estimatedSkinAge: null == estimatedSkinAge
          ? _value.estimatedSkinAge
          : estimatedSkinAge // ignore: cast_nullable_to_non_nullable
              as int,
      axes: null == axes
          ? _value._axes
          : axes // ignore: cast_nullable_to_non_nullable
              as List<ScoredItemDto>,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinAgeDtoImpl implements _SkinAgeDto {
  const _$SkinAgeDtoImpl(
      {required this.estimatedSkinAge,
      final List<ScoredItemDto> axes = const <ScoredItemDto>[],
      this.assessment = ''})
      : _axes = axes;

  factory _$SkinAgeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinAgeDtoImplFromJson(json);

  @override
  final int estimatedSkinAge;
  final List<ScoredItemDto> _axes;
  @override
  @JsonKey()
  List<ScoredItemDto> get axes {
    if (_axes is EqualUnmodifiableListView) return _axes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_axes);
  }

  @override
  @JsonKey()
  final String assessment;

  @override
  String toString() {
    return 'SkinAgeDto(estimatedSkinAge: $estimatedSkinAge, axes: $axes, assessment: $assessment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinAgeDtoImpl &&
            (identical(other.estimatedSkinAge, estimatedSkinAge) ||
                other.estimatedSkinAge == estimatedSkinAge) &&
            const DeepCollectionEquality().equals(other._axes, _axes) &&
            (identical(other.assessment, assessment) ||
                other.assessment == assessment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, estimatedSkinAge,
      const DeepCollectionEquality().hash(_axes), assessment);

  /// Create a copy of SkinAgeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinAgeDtoImplCopyWith<_$SkinAgeDtoImpl> get copyWith =>
      __$$SkinAgeDtoImplCopyWithImpl<_$SkinAgeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinAgeDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinAgeDto implements SkinAgeDto {
  const factory _SkinAgeDto(
      {required final int estimatedSkinAge,
      final List<ScoredItemDto> axes,
      final String assessment}) = _$SkinAgeDtoImpl;

  factory _SkinAgeDto.fromJson(Map<String, dynamic> json) =
      _$SkinAgeDtoImpl.fromJson;

  @override
  int get estimatedSkinAge;
  @override
  List<ScoredItemDto> get axes;
  @override
  String get assessment;

  /// Create a copy of SkinAgeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinAgeDtoImplCopyWith<_$SkinAgeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinAnalysisDto _$SkinAnalysisDtoFromJson(Map<String, dynamic> json) {
  return _SkinAnalysisDto.fromJson(json);
}

/// @nodoc
mixin _$SkinAnalysisDto {
  int get skinAnalysisId => throw _privateConstructorUsedError;
  int get skinScore => throw _privateConstructorUsedError;
  SkinMetricsDto get metrics =>
      throw _privateConstructorUsedError; // 같은 5개에 등급과 근거를 붙인 것. 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
  List<ScoredItemDto> get metricDetails =>
      throw _privateConstructorUsedError; // 지표에서 규칙으로 도출한다 — 예전 분석에도 온다. 서버가 못 낼 이유가 없어졌지만
// 널 허용은 유지한다. 계약이 바뀌었다고 옛 기록을 여는 순간 앱이 멎어서는 안 된다.
  SkinTypeDto? get skinType => throw _privateConstructorUsedError;
  SkinAgeDto? get skinAge =>
      throw _privateConstructorUsedError; // 예전 분석이면 서버가 키를 생략한다
  String get summary => throw _privateConstructorUsedError;
  List<HighlightDto> get highlights => throw _privateConstructorUsedError;
  SkinTypeGapDto? get skinTypeGap =>
      throw _privateConstructorUsedError; // 미선택이면 서버가 키를 생략한다
  DateTime get analyzedAt => throw _privateConstructorUsedError;

  /// Serializes this SkinAnalysisDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinAnalysisDtoCopyWith<SkinAnalysisDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinAnalysisDtoCopyWith<$Res> {
  factory $SkinAnalysisDtoCopyWith(
          SkinAnalysisDto value, $Res Function(SkinAnalysisDto) then) =
      _$SkinAnalysisDtoCopyWithImpl<$Res, SkinAnalysisDto>;
  @useResult
  $Res call(
      {int skinAnalysisId,
      int skinScore,
      SkinMetricsDto metrics,
      List<ScoredItemDto> metricDetails,
      SkinTypeDto? skinType,
      SkinAgeDto? skinAge,
      String summary,
      List<HighlightDto> highlights,
      SkinTypeGapDto? skinTypeGap,
      DateTime analyzedAt});

  $SkinMetricsDtoCopyWith<$Res> get metrics;
  $SkinTypeDtoCopyWith<$Res>? get skinType;
  $SkinAgeDtoCopyWith<$Res>? get skinAge;
  $SkinTypeGapDtoCopyWith<$Res>? get skinTypeGap;
}

/// @nodoc
class _$SkinAnalysisDtoCopyWithImpl<$Res, $Val extends SkinAnalysisDto>
    implements $SkinAnalysisDtoCopyWith<$Res> {
  _$SkinAnalysisDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? skinScore = null,
    Object? metrics = null,
    Object? metricDetails = null,
    Object? skinType = freezed,
    Object? skinAge = freezed,
    Object? summary = null,
    Object? highlights = null,
    Object? skinTypeGap = freezed,
    Object? analyzedAt = null,
  }) {
    return _then(_value.copyWith(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinScore: null == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as SkinMetricsDto,
      metricDetails: null == metricDetails
          ? _value.metricDetails
          : metricDetails // ignore: cast_nullable_to_non_nullable
              as List<ScoredItemDto>,
      skinType: freezed == skinType
          ? _value.skinType
          : skinType // ignore: cast_nullable_to_non_nullable
              as SkinTypeDto?,
      skinAge: freezed == skinAge
          ? _value.skinAge
          : skinAge // ignore: cast_nullable_to_non_nullable
              as SkinAgeDto?,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<HighlightDto>,
      skinTypeGap: freezed == skinTypeGap
          ? _value.skinTypeGap
          : skinTypeGap // ignore: cast_nullable_to_non_nullable
              as SkinTypeGapDto?,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SkinMetricsDtoCopyWith<$Res> get metrics {
    return $SkinMetricsDtoCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SkinTypeDtoCopyWith<$Res>? get skinType {
    if (_value.skinType == null) {
      return null;
    }

    return $SkinTypeDtoCopyWith<$Res>(_value.skinType!, (value) {
      return _then(_value.copyWith(skinType: value) as $Val);
    });
  }

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SkinAgeDtoCopyWith<$Res>? get skinAge {
    if (_value.skinAge == null) {
      return null;
    }

    return $SkinAgeDtoCopyWith<$Res>(_value.skinAge!, (value) {
      return _then(_value.copyWith(skinAge: value) as $Val);
    });
  }

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SkinTypeGapDtoCopyWith<$Res>? get skinTypeGap {
    if (_value.skinTypeGap == null) {
      return null;
    }

    return $SkinTypeGapDtoCopyWith<$Res>(_value.skinTypeGap!, (value) {
      return _then(_value.copyWith(skinTypeGap: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SkinAnalysisDtoImplCopyWith<$Res>
    implements $SkinAnalysisDtoCopyWith<$Res> {
  factory _$$SkinAnalysisDtoImplCopyWith(_$SkinAnalysisDtoImpl value,
          $Res Function(_$SkinAnalysisDtoImpl) then) =
      __$$SkinAnalysisDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int skinAnalysisId,
      int skinScore,
      SkinMetricsDto metrics,
      List<ScoredItemDto> metricDetails,
      SkinTypeDto? skinType,
      SkinAgeDto? skinAge,
      String summary,
      List<HighlightDto> highlights,
      SkinTypeGapDto? skinTypeGap,
      DateTime analyzedAt});

  @override
  $SkinMetricsDtoCopyWith<$Res> get metrics;
  @override
  $SkinTypeDtoCopyWith<$Res>? get skinType;
  @override
  $SkinAgeDtoCopyWith<$Res>? get skinAge;
  @override
  $SkinTypeGapDtoCopyWith<$Res>? get skinTypeGap;
}

/// @nodoc
class __$$SkinAnalysisDtoImplCopyWithImpl<$Res>
    extends _$SkinAnalysisDtoCopyWithImpl<$Res, _$SkinAnalysisDtoImpl>
    implements _$$SkinAnalysisDtoImplCopyWith<$Res> {
  __$$SkinAnalysisDtoImplCopyWithImpl(
      _$SkinAnalysisDtoImpl _value, $Res Function(_$SkinAnalysisDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? skinScore = null,
    Object? metrics = null,
    Object? metricDetails = null,
    Object? skinType = freezed,
    Object? skinAge = freezed,
    Object? summary = null,
    Object? highlights = null,
    Object? skinTypeGap = freezed,
    Object? analyzedAt = null,
  }) {
    return _then(_$SkinAnalysisDtoImpl(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinScore: null == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as SkinMetricsDto,
      metricDetails: null == metricDetails
          ? _value._metricDetails
          : metricDetails // ignore: cast_nullable_to_non_nullable
              as List<ScoredItemDto>,
      skinType: freezed == skinType
          ? _value.skinType
          : skinType // ignore: cast_nullable_to_non_nullable
              as SkinTypeDto?,
      skinAge: freezed == skinAge
          ? _value.skinAge
          : skinAge // ignore: cast_nullable_to_non_nullable
              as SkinAgeDto?,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<HighlightDto>,
      skinTypeGap: freezed == skinTypeGap
          ? _value.skinTypeGap
          : skinTypeGap // ignore: cast_nullable_to_non_nullable
              as SkinTypeGapDto?,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinAnalysisDtoImpl implements _SkinAnalysisDto {
  const _$SkinAnalysisDtoImpl(
      {required this.skinAnalysisId,
      required this.skinScore,
      required this.metrics,
      final List<ScoredItemDto> metricDetails = const <ScoredItemDto>[],
      this.skinType,
      this.skinAge,
      this.summary = '',
      final List<HighlightDto> highlights = const <HighlightDto>[],
      this.skinTypeGap,
      required this.analyzedAt})
      : _metricDetails = metricDetails,
        _highlights = highlights;

  factory _$SkinAnalysisDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinAnalysisDtoImplFromJson(json);

  @override
  final int skinAnalysisId;
  @override
  final int skinScore;
  @override
  final SkinMetricsDto metrics;
// 같은 5개에 등급과 근거를 붙인 것. 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
  final List<ScoredItemDto> _metricDetails;
// 같은 5개에 등급과 근거를 붙인 것. 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
  @override
  @JsonKey()
  List<ScoredItemDto> get metricDetails {
    if (_metricDetails is EqualUnmodifiableListView) return _metricDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_metricDetails);
  }

// 지표에서 규칙으로 도출한다 — 예전 분석에도 온다. 서버가 못 낼 이유가 없어졌지만
// 널 허용은 유지한다. 계약이 바뀌었다고 옛 기록을 여는 순간 앱이 멎어서는 안 된다.
  @override
  final SkinTypeDto? skinType;
  @override
  final SkinAgeDto? skinAge;
// 예전 분석이면 서버가 키를 생략한다
  @override
  @JsonKey()
  final String summary;
  final List<HighlightDto> _highlights;
  @override
  @JsonKey()
  List<HighlightDto> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  @override
  final SkinTypeGapDto? skinTypeGap;
// 미선택이면 서버가 키를 생략한다
  @override
  final DateTime analyzedAt;

  @override
  String toString() {
    return 'SkinAnalysisDto(skinAnalysisId: $skinAnalysisId, skinScore: $skinScore, metrics: $metrics, metricDetails: $metricDetails, skinType: $skinType, skinAge: $skinAge, summary: $summary, highlights: $highlights, skinTypeGap: $skinTypeGap, analyzedAt: $analyzedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinAnalysisDtoImpl &&
            (identical(other.skinAnalysisId, skinAnalysisId) ||
                other.skinAnalysisId == skinAnalysisId) &&
            (identical(other.skinScore, skinScore) ||
                other.skinScore == skinScore) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            const DeepCollectionEquality()
                .equals(other._metricDetails, _metricDetails) &&
            (identical(other.skinType, skinType) ||
                other.skinType == skinType) &&
            (identical(other.skinAge, skinAge) || other.skinAge == skinAge) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            (identical(other.skinTypeGap, skinTypeGap) ||
                other.skinTypeGap == skinTypeGap) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      skinAnalysisId,
      skinScore,
      metrics,
      const DeepCollectionEquality().hash(_metricDetails),
      skinType,
      skinAge,
      summary,
      const DeepCollectionEquality().hash(_highlights),
      skinTypeGap,
      analyzedAt);

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinAnalysisDtoImplCopyWith<_$SkinAnalysisDtoImpl> get copyWith =>
      __$$SkinAnalysisDtoImplCopyWithImpl<_$SkinAnalysisDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinAnalysisDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinAnalysisDto implements SkinAnalysisDto {
  const factory _SkinAnalysisDto(
      {required final int skinAnalysisId,
      required final int skinScore,
      required final SkinMetricsDto metrics,
      final List<ScoredItemDto> metricDetails,
      final SkinTypeDto? skinType,
      final SkinAgeDto? skinAge,
      final String summary,
      final List<HighlightDto> highlights,
      final SkinTypeGapDto? skinTypeGap,
      required final DateTime analyzedAt}) = _$SkinAnalysisDtoImpl;

  factory _SkinAnalysisDto.fromJson(Map<String, dynamic> json) =
      _$SkinAnalysisDtoImpl.fromJson;

  @override
  int get skinAnalysisId;
  @override
  int get skinScore;
  @override
  SkinMetricsDto
      get metrics; // 같은 5개에 등급과 근거를 붙인 것. 이 기능 이전에 저장된 분석이면 근거가 비어 있다.
  @override
  List<ScoredItemDto>
      get metricDetails; // 지표에서 규칙으로 도출한다 — 예전 분석에도 온다. 서버가 못 낼 이유가 없어졌지만
// 널 허용은 유지한다. 계약이 바뀌었다고 옛 기록을 여는 순간 앱이 멎어서는 안 된다.
  @override
  SkinTypeDto? get skinType;
  @override
  SkinAgeDto? get skinAge; // 예전 분석이면 서버가 키를 생략한다
  @override
  String get summary;
  @override
  List<HighlightDto> get highlights;
  @override
  SkinTypeGapDto? get skinTypeGap; // 미선택이면 서버가 키를 생략한다
  @override
  DateTime get analyzedAt;

  /// Create a copy of SkinAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinAnalysisDtoImplCopyWith<_$SkinAnalysisDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
