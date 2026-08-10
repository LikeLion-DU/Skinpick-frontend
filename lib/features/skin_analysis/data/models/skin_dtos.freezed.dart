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

SkinAnalysisDto _$SkinAnalysisDtoFromJson(Map<String, dynamic> json) {
  return _SkinAnalysisDto.fromJson(json);
}

/// @nodoc
mixin _$SkinAnalysisDto {
  int get skinAnalysisId => throw _privateConstructorUsedError;
  int get skinScore => throw _privateConstructorUsedError;
  SkinMetricsDto get metrics => throw _privateConstructorUsedError;
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
      String summary,
      List<HighlightDto> highlights,
      SkinTypeGapDto? skinTypeGap,
      DateTime analyzedAt});

  $SkinMetricsDtoCopyWith<$Res> get metrics;
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
      String summary,
      List<HighlightDto> highlights,
      SkinTypeGapDto? skinTypeGap,
      DateTime analyzedAt});

  @override
  $SkinMetricsDtoCopyWith<$Res> get metrics;
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
      this.summary = '',
      final List<HighlightDto> highlights = const <HighlightDto>[],
      this.skinTypeGap,
      required this.analyzedAt})
      : _highlights = highlights;

  factory _$SkinAnalysisDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinAnalysisDtoImplFromJson(json);

  @override
  final int skinAnalysisId;
  @override
  final int skinScore;
  @override
  final SkinMetricsDto metrics;
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
    return 'SkinAnalysisDto(skinAnalysisId: $skinAnalysisId, skinScore: $skinScore, metrics: $metrics, summary: $summary, highlights: $highlights, skinTypeGap: $skinTypeGap, analyzedAt: $analyzedAt)';
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
  SkinMetricsDto get metrics;
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
