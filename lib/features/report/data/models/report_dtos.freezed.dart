// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NutritionItemDto _$NutritionItemDtoFromJson(Map<String, dynamic> json) {
  return _NutritionItemDto.fromJson(json);
}

/// @nodoc
mixin _$NutritionItemDto {
  /// 서버 enum 이름. 화면은 키로만 쓰고 표시는 [label] 로 한다.
  String get nutrient => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// 서버가 `BigDecimal` 로 낸다. `1820.5` 도 `1820` 도 오므로 **num 이어야 한다** —
  /// double 로 두면 정수로 온 날 캐스팅 예외로 리포트 전체가 실패한다.
  num get amount => throw _privateConstructorUsedError;
  int get target => throw _privateConstructorUsedError;
  int get percent => throw _privateConstructorUsedError;

  /// `LOW` · `NORMAL` · `HIGH`. 모르는 값은 화면에서 회색이 된다.
  String? get status => throw _privateConstructorUsedError;
  bool get higherIsWorse => throw _privateConstructorUsedError;

  /// Serializes this NutritionItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionItemDtoCopyWith<NutritionItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionItemDtoCopyWith<$Res> {
  factory $NutritionItemDtoCopyWith(
          NutritionItemDto value, $Res Function(NutritionItemDto) then) =
      _$NutritionItemDtoCopyWithImpl<$Res, NutritionItemDto>;
  @useResult
  $Res call(
      {String nutrient,
      String label,
      String unit,
      num amount,
      int target,
      int percent,
      String? status,
      bool higherIsWorse});
}

/// @nodoc
class _$NutritionItemDtoCopyWithImpl<$Res, $Val extends NutritionItemDto>
    implements $NutritionItemDtoCopyWith<$Res> {
  _$NutritionItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutrient = null,
    Object? label = null,
    Object? unit = null,
    Object? amount = null,
    Object? target = null,
    Object? percent = null,
    Object? status = freezed,
    Object? higherIsWorse = null,
  }) {
    return _then(_value.copyWith(
      nutrient: null == nutrient
          ? _value.nutrient
          : nutrient // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      higherIsWorse: null == higherIsWorse
          ? _value.higherIsWorse
          : higherIsWorse // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionItemDtoImplCopyWith<$Res>
    implements $NutritionItemDtoCopyWith<$Res> {
  factory _$$NutritionItemDtoImplCopyWith(_$NutritionItemDtoImpl value,
          $Res Function(_$NutritionItemDtoImpl) then) =
      __$$NutritionItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nutrient,
      String label,
      String unit,
      num amount,
      int target,
      int percent,
      String? status,
      bool higherIsWorse});
}

/// @nodoc
class __$$NutritionItemDtoImplCopyWithImpl<$Res>
    extends _$NutritionItemDtoCopyWithImpl<$Res, _$NutritionItemDtoImpl>
    implements _$$NutritionItemDtoImplCopyWith<$Res> {
  __$$NutritionItemDtoImplCopyWithImpl(_$NutritionItemDtoImpl _value,
      $Res Function(_$NutritionItemDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutrient = null,
    Object? label = null,
    Object? unit = null,
    Object? amount = null,
    Object? target = null,
    Object? percent = null,
    Object? status = freezed,
    Object? higherIsWorse = null,
  }) {
    return _then(_$NutritionItemDtoImpl(
      nutrient: null == nutrient
          ? _value.nutrient
          : nutrient // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      higherIsWorse: null == higherIsWorse
          ? _value.higherIsWorse
          : higherIsWorse // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionItemDtoImpl implements _NutritionItemDto {
  const _$NutritionItemDtoImpl(
      {this.nutrient = '',
      this.label = '',
      this.unit = '',
      this.amount = 0,
      this.target = 0,
      this.percent = 0,
      this.status,
      this.higherIsWorse = false});

  factory _$NutritionItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionItemDtoImplFromJson(json);

  /// 서버 enum 이름. 화면은 키로만 쓰고 표시는 [label] 로 한다.
  @override
  @JsonKey()
  final String nutrient;
  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final String unit;

  /// 서버가 `BigDecimal` 로 낸다. `1820.5` 도 `1820` 도 오므로 **num 이어야 한다** —
  /// double 로 두면 정수로 온 날 캐스팅 예외로 리포트 전체가 실패한다.
  @override
  @JsonKey()
  final num amount;
  @override
  @JsonKey()
  final int target;
  @override
  @JsonKey()
  final int percent;

  /// `LOW` · `NORMAL` · `HIGH`. 모르는 값은 화면에서 회색이 된다.
  @override
  final String? status;
  @override
  @JsonKey()
  final bool higherIsWorse;

  @override
  String toString() {
    return 'NutritionItemDto(nutrient: $nutrient, label: $label, unit: $unit, amount: $amount, target: $target, percent: $percent, status: $status, higherIsWorse: $higherIsWorse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionItemDtoImpl &&
            (identical(other.nutrient, nutrient) ||
                other.nutrient == nutrient) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.higherIsWorse, higherIsWorse) ||
                other.higherIsWorse == higherIsWorse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nutrient, label, unit, amount,
      target, percent, status, higherIsWorse);

  /// Create a copy of NutritionItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionItemDtoImplCopyWith<_$NutritionItemDtoImpl> get copyWith =>
      __$$NutritionItemDtoImplCopyWithImpl<_$NutritionItemDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionItemDtoImplToJson(
      this,
    );
  }
}

abstract class _NutritionItemDto implements NutritionItemDto {
  const factory _NutritionItemDto(
      {final String nutrient,
      final String label,
      final String unit,
      final num amount,
      final int target,
      final int percent,
      final String? status,
      final bool higherIsWorse}) = _$NutritionItemDtoImpl;

  factory _NutritionItemDto.fromJson(Map<String, dynamic> json) =
      _$NutritionItemDtoImpl.fromJson;

  /// 서버 enum 이름. 화면은 키로만 쓰고 표시는 [label] 로 한다.
  @override
  String get nutrient;
  @override
  String get label;
  @override
  String get unit;

  /// 서버가 `BigDecimal` 로 낸다. `1820.5` 도 `1820` 도 오므로 **num 이어야 한다** —
  /// double 로 두면 정수로 온 날 캐스팅 예외로 리포트 전체가 실패한다.
  @override
  num get amount;
  @override
  int get target;
  @override
  int get percent;

  /// `LOW` · `NORMAL` · `HIGH`. 모르는 값은 화면에서 회색이 된다.
  @override
  String? get status;
  @override
  bool get higherIsWorse;

  /// Create a copy of NutritionItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionItemDtoImplCopyWith<_$NutritionItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConcernScoreDto _$ConcernScoreDtoFromJson(Map<String, dynamic> json) {
  return _ConcernScoreDto.fromJson(json);
}

/// @nodoc
mixin _$ConcernScoreDto {
  String get concern => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// **일일 응답에는 이 키가 없다.** 주간도 기록일이 하루뿐이면 없다.
  int? get change => throw _privateConstructorUsedError;

  /// Serializes this ConcernScoreDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConcernScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConcernScoreDtoCopyWith<ConcernScoreDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConcernScoreDtoCopyWith<$Res> {
  factory $ConcernScoreDtoCopyWith(
          ConcernScoreDto value, $Res Function(ConcernScoreDto) then) =
      _$ConcernScoreDtoCopyWithImpl<$Res, ConcernScoreDto>;
  @useResult
  $Res call(
      {String concern, String label, int score, String? status, int? change});
}

/// @nodoc
class _$ConcernScoreDtoCopyWithImpl<$Res, $Val extends ConcernScoreDto>
    implements $ConcernScoreDtoCopyWith<$Res> {
  _$ConcernScoreDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConcernScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concern = null,
    Object? label = null,
    Object? score = null,
    Object? status = freezed,
    Object? change = freezed,
  }) {
    return _then(_value.copyWith(
      concern: null == concern
          ? _value.concern
          : concern // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      change: freezed == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConcernScoreDtoImplCopyWith<$Res>
    implements $ConcernScoreDtoCopyWith<$Res> {
  factory _$$ConcernScoreDtoImplCopyWith(_$ConcernScoreDtoImpl value,
          $Res Function(_$ConcernScoreDtoImpl) then) =
      __$$ConcernScoreDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String concern, String label, int score, String? status, int? change});
}

/// @nodoc
class __$$ConcernScoreDtoImplCopyWithImpl<$Res>
    extends _$ConcernScoreDtoCopyWithImpl<$Res, _$ConcernScoreDtoImpl>
    implements _$$ConcernScoreDtoImplCopyWith<$Res> {
  __$$ConcernScoreDtoImplCopyWithImpl(
      _$ConcernScoreDtoImpl _value, $Res Function(_$ConcernScoreDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConcernScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concern = null,
    Object? label = null,
    Object? score = null,
    Object? status = freezed,
    Object? change = freezed,
  }) {
    return _then(_$ConcernScoreDtoImpl(
      concern: null == concern
          ? _value.concern
          : concern // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      change: freezed == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConcernScoreDtoImpl implements _ConcernScoreDto {
  const _$ConcernScoreDtoImpl(
      {this.concern = '',
      this.label = '',
      this.score = 0,
      this.status,
      this.change});

  factory _$ConcernScoreDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConcernScoreDtoImplFromJson(json);

  @override
  @JsonKey()
  final String concern;
  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final int score;
  @override
  final String? status;

  /// **일일 응답에는 이 키가 없다.** 주간도 기록일이 하루뿐이면 없다.
  @override
  final int? change;

  @override
  String toString() {
    return 'ConcernScoreDto(concern: $concern, label: $label, score: $score, status: $status, change: $change)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConcernScoreDtoImpl &&
            (identical(other.concern, concern) || other.concern == concern) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.change, change) || other.change == change));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, concern, label, score, status, change);

  /// Create a copy of ConcernScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConcernScoreDtoImplCopyWith<_$ConcernScoreDtoImpl> get copyWith =>
      __$$ConcernScoreDtoImplCopyWithImpl<_$ConcernScoreDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConcernScoreDtoImplToJson(
      this,
    );
  }
}

abstract class _ConcernScoreDto implements ConcernScoreDto {
  const factory _ConcernScoreDto(
      {final String concern,
      final String label,
      final int score,
      final String? status,
      final int? change}) = _$ConcernScoreDtoImpl;

  factory _ConcernScoreDto.fromJson(Map<String, dynamic> json) =
      _$ConcernScoreDtoImpl.fromJson;

  @override
  String get concern;
  @override
  String get label;
  @override
  int get score;
  @override
  String? get status;

  /// **일일 응답에는 이 키가 없다.** 주간도 기록일이 하루뿐이면 없다.
  @override
  int? get change;

  /// Create a copy of ConcernScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConcernScoreDtoImplCopyWith<_$ConcernScoreDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DayScoreDto _$DayScoreDtoFromJson(Map<String, dynamic> json) {
  return _DayScoreDto.fromJson(json);
}

/// @nodoc
mixin _$DayScoreDto {
  DateTime get date => throw _privateConstructorUsedError;
  int get dailyScore => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;

  /// Serializes this DayScoreDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayScoreDtoCopyWith<DayScoreDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayScoreDtoCopyWith<$Res> {
  factory $DayScoreDtoCopyWith(
          DayScoreDto value, $Res Function(DayScoreDto) then) =
      _$DayScoreDtoCopyWithImpl<$Res, DayScoreDto>;
  @useResult
  $Res call({DateTime date, int dailyScore, String? grade});
}

/// @nodoc
class _$DayScoreDtoCopyWithImpl<$Res, $Val extends DayScoreDto>
    implements $DayScoreDtoCopyWith<$Res> {
  _$DayScoreDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dailyScore = null,
    Object? grade = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dailyScore: null == dailyScore
          ? _value.dailyScore
          : dailyScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayScoreDtoImplCopyWith<$Res>
    implements $DayScoreDtoCopyWith<$Res> {
  factory _$$DayScoreDtoImplCopyWith(
          _$DayScoreDtoImpl value, $Res Function(_$DayScoreDtoImpl) then) =
      __$$DayScoreDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int dailyScore, String? grade});
}

/// @nodoc
class __$$DayScoreDtoImplCopyWithImpl<$Res>
    extends _$DayScoreDtoCopyWithImpl<$Res, _$DayScoreDtoImpl>
    implements _$$DayScoreDtoImplCopyWith<$Res> {
  __$$DayScoreDtoImplCopyWithImpl(
      _$DayScoreDtoImpl _value, $Res Function(_$DayScoreDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DayScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dailyScore = null,
    Object? grade = freezed,
  }) {
    return _then(_$DayScoreDtoImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dailyScore: null == dailyScore
          ? _value.dailyScore
          : dailyScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayScoreDtoImpl implements _DayScoreDto {
  const _$DayScoreDtoImpl(
      {required this.date, this.dailyScore = 0, this.grade});

  factory _$DayScoreDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayScoreDtoImplFromJson(json);

  @override
  final DateTime date;
  @override
  @JsonKey()
  final int dailyScore;
  @override
  final String? grade;

  @override
  String toString() {
    return 'DayScoreDto(date: $date, dailyScore: $dailyScore, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayScoreDtoImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dailyScore, dailyScore) ||
                other.dailyScore == dailyScore) &&
            (identical(other.grade, grade) || other.grade == grade));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, dailyScore, grade);

  /// Create a copy of DayScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayScoreDtoImplCopyWith<_$DayScoreDtoImpl> get copyWith =>
      __$$DayScoreDtoImplCopyWithImpl<_$DayScoreDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayScoreDtoImplToJson(
      this,
    );
  }
}

abstract class _DayScoreDto implements DayScoreDto {
  const factory _DayScoreDto(
      {required final DateTime date,
      final int dailyScore,
      final String? grade}) = _$DayScoreDtoImpl;

  factory _DayScoreDto.fromJson(Map<String, dynamic> json) =
      _$DayScoreDtoImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get dailyScore;
  @override
  String? get grade;

  /// Create a copy of DayScoreDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayScoreDtoImplCopyWith<_$DayScoreDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyCommentDto _$WeeklyCommentDtoFromJson(Map<String, dynamic> json) {
  return _WeeklyCommentDto.fromJson(json);
}

/// @nodoc
mixin _$WeeklyCommentDto {
  String? get goodPoint => throw _privateConstructorUsedError;
  String? get improvePoint => throw _privateConstructorUsedError;
  String? get habit => throw _privateConstructorUsedError;
  String? get nextWeek => throw _privateConstructorUsedError;

  /// Serializes this WeeklyCommentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyCommentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyCommentDtoCopyWith<WeeklyCommentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyCommentDtoCopyWith<$Res> {
  factory $WeeklyCommentDtoCopyWith(
          WeeklyCommentDto value, $Res Function(WeeklyCommentDto) then) =
      _$WeeklyCommentDtoCopyWithImpl<$Res, WeeklyCommentDto>;
  @useResult
  $Res call(
      {String? goodPoint,
      String? improvePoint,
      String? habit,
      String? nextWeek});
}

/// @nodoc
class _$WeeklyCommentDtoCopyWithImpl<$Res, $Val extends WeeklyCommentDto>
    implements $WeeklyCommentDtoCopyWith<$Res> {
  _$WeeklyCommentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyCommentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goodPoint = freezed,
    Object? improvePoint = freezed,
    Object? habit = freezed,
    Object? nextWeek = freezed,
  }) {
    return _then(_value.copyWith(
      goodPoint: freezed == goodPoint
          ? _value.goodPoint
          : goodPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      improvePoint: freezed == improvePoint
          ? _value.improvePoint
          : improvePoint // ignore: cast_nullable_to_non_nullable
              as String?,
      habit: freezed == habit
          ? _value.habit
          : habit // ignore: cast_nullable_to_non_nullable
              as String?,
      nextWeek: freezed == nextWeek
          ? _value.nextWeek
          : nextWeek // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyCommentDtoImplCopyWith<$Res>
    implements $WeeklyCommentDtoCopyWith<$Res> {
  factory _$$WeeklyCommentDtoImplCopyWith(_$WeeklyCommentDtoImpl value,
          $Res Function(_$WeeklyCommentDtoImpl) then) =
      __$$WeeklyCommentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? goodPoint,
      String? improvePoint,
      String? habit,
      String? nextWeek});
}

/// @nodoc
class __$$WeeklyCommentDtoImplCopyWithImpl<$Res>
    extends _$WeeklyCommentDtoCopyWithImpl<$Res, _$WeeklyCommentDtoImpl>
    implements _$$WeeklyCommentDtoImplCopyWith<$Res> {
  __$$WeeklyCommentDtoImplCopyWithImpl(_$WeeklyCommentDtoImpl _value,
      $Res Function(_$WeeklyCommentDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyCommentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goodPoint = freezed,
    Object? improvePoint = freezed,
    Object? habit = freezed,
    Object? nextWeek = freezed,
  }) {
    return _then(_$WeeklyCommentDtoImpl(
      goodPoint: freezed == goodPoint
          ? _value.goodPoint
          : goodPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      improvePoint: freezed == improvePoint
          ? _value.improvePoint
          : improvePoint // ignore: cast_nullable_to_non_nullable
              as String?,
      habit: freezed == habit
          ? _value.habit
          : habit // ignore: cast_nullable_to_non_nullable
              as String?,
      nextWeek: freezed == nextWeek
          ? _value.nextWeek
          : nextWeek // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyCommentDtoImpl implements _WeeklyCommentDto {
  const _$WeeklyCommentDtoImpl(
      {this.goodPoint, this.improvePoint, this.habit, this.nextWeek});

  factory _$WeeklyCommentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyCommentDtoImplFromJson(json);

  @override
  final String? goodPoint;
  @override
  final String? improvePoint;
  @override
  final String? habit;
  @override
  final String? nextWeek;

  @override
  String toString() {
    return 'WeeklyCommentDto(goodPoint: $goodPoint, improvePoint: $improvePoint, habit: $habit, nextWeek: $nextWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyCommentDtoImpl &&
            (identical(other.goodPoint, goodPoint) ||
                other.goodPoint == goodPoint) &&
            (identical(other.improvePoint, improvePoint) ||
                other.improvePoint == improvePoint) &&
            (identical(other.habit, habit) || other.habit == habit) &&
            (identical(other.nextWeek, nextWeek) ||
                other.nextWeek == nextWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, goodPoint, improvePoint, habit, nextWeek);

  /// Create a copy of WeeklyCommentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyCommentDtoImplCopyWith<_$WeeklyCommentDtoImpl> get copyWith =>
      __$$WeeklyCommentDtoImplCopyWithImpl<_$WeeklyCommentDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyCommentDtoImplToJson(
      this,
    );
  }
}

abstract class _WeeklyCommentDto implements WeeklyCommentDto {
  const factory _WeeklyCommentDto(
      {final String? goodPoint,
      final String? improvePoint,
      final String? habit,
      final String? nextWeek}) = _$WeeklyCommentDtoImpl;

  factory _WeeklyCommentDto.fromJson(Map<String, dynamic> json) =
      _$WeeklyCommentDtoImpl.fromJson;

  @override
  String? get goodPoint;
  @override
  String? get improvePoint;
  @override
  String? get habit;
  @override
  String? get nextWeek;

  /// Create a copy of WeeklyCommentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyCommentDtoImplCopyWith<_$WeeklyCommentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyReportDto _$DailyReportDtoFromJson(Map<String, dynamic> json) {
  return _DailyReportDto.fromJson(json);
}

/// @nodoc
mixin _$DailyReportDto {
  DateTime get date => throw _privateConstructorUsedError;

  /// 기록이 없는 날은 키가 없다. **0 을 기본값으로 두면 화면이 "0점"을 그린다** —
  /// 0 점은 "아주 나쁘게 먹었다"이고 이건 "아직 안 찍었다"다.
  int? get dailyScore => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  int get recordCount => throw _privateConstructorUsedError;
  List<NutritionItemDto> get nutrition => throw _privateConstructorUsedError;
  List<ConcernScoreDto> get concerns => throw _privateConstructorUsedError;

  /// 히스토리와 **같은 DTO** 다. 서버가 하나로 내려주므로 앱도 하나로 받는다.
  List<PlateHistoryItemDto> get meals => throw _privateConstructorUsedError;
  String? get aiComment => throw _privateConstructorUsedError;
  List<String> get goodPoints => throw _privateConstructorUsedError;
  List<String> get improvePoints => throw _privateConstructorUsedError;

  /// Serializes this DailyReportDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyReportDtoCopyWith<DailyReportDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyReportDtoCopyWith<$Res> {
  factory $DailyReportDtoCopyWith(
          DailyReportDto value, $Res Function(DailyReportDto) then) =
      _$DailyReportDtoCopyWithImpl<$Res, DailyReportDto>;
  @useResult
  $Res call(
      {DateTime date,
      int? dailyScore,
      String? grade,
      int recordCount,
      List<NutritionItemDto> nutrition,
      List<ConcernScoreDto> concerns,
      List<PlateHistoryItemDto> meals,
      String? aiComment,
      List<String> goodPoints,
      List<String> improvePoints});
}

/// @nodoc
class _$DailyReportDtoCopyWithImpl<$Res, $Val extends DailyReportDto>
    implements $DailyReportDtoCopyWith<$Res> {
  _$DailyReportDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dailyScore = freezed,
    Object? grade = freezed,
    Object? recordCount = null,
    Object? nutrition = null,
    Object? concerns = null,
    Object? meals = null,
    Object? aiComment = freezed,
    Object? goodPoints = null,
    Object? improvePoints = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dailyScore: freezed == dailyScore
          ? _value.dailyScore
          : dailyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      recordCount: null == recordCount
          ? _value.recordCount
          : recordCount // ignore: cast_nullable_to_non_nullable
              as int,
      nutrition: null == nutrition
          ? _value.nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as List<NutritionItemDto>,
      concerns: null == concerns
          ? _value.concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<ConcernScoreDto>,
      meals: null == meals
          ? _value.meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryItemDto>,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as String?,
      goodPoints: null == goodPoints
          ? _value.goodPoints
          : goodPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      improvePoints: null == improvePoints
          ? _value.improvePoints
          : improvePoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyReportDtoImplCopyWith<$Res>
    implements $DailyReportDtoCopyWith<$Res> {
  factory _$$DailyReportDtoImplCopyWith(_$DailyReportDtoImpl value,
          $Res Function(_$DailyReportDtoImpl) then) =
      __$$DailyReportDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int? dailyScore,
      String? grade,
      int recordCount,
      List<NutritionItemDto> nutrition,
      List<ConcernScoreDto> concerns,
      List<PlateHistoryItemDto> meals,
      String? aiComment,
      List<String> goodPoints,
      List<String> improvePoints});
}

/// @nodoc
class __$$DailyReportDtoImplCopyWithImpl<$Res>
    extends _$DailyReportDtoCopyWithImpl<$Res, _$DailyReportDtoImpl>
    implements _$$DailyReportDtoImplCopyWith<$Res> {
  __$$DailyReportDtoImplCopyWithImpl(
      _$DailyReportDtoImpl _value, $Res Function(_$DailyReportDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dailyScore = freezed,
    Object? grade = freezed,
    Object? recordCount = null,
    Object? nutrition = null,
    Object? concerns = null,
    Object? meals = null,
    Object? aiComment = freezed,
    Object? goodPoints = null,
    Object? improvePoints = null,
  }) {
    return _then(_$DailyReportDtoImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dailyScore: freezed == dailyScore
          ? _value.dailyScore
          : dailyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      recordCount: null == recordCount
          ? _value.recordCount
          : recordCount // ignore: cast_nullable_to_non_nullable
              as int,
      nutrition: null == nutrition
          ? _value._nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as List<NutritionItemDto>,
      concerns: null == concerns
          ? _value._concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<ConcernScoreDto>,
      meals: null == meals
          ? _value._meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryItemDto>,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as String?,
      goodPoints: null == goodPoints
          ? _value._goodPoints
          : goodPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      improvePoints: null == improvePoints
          ? _value._improvePoints
          : improvePoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyReportDtoImpl implements _DailyReportDto {
  const _$DailyReportDtoImpl(
      {required this.date,
      this.dailyScore,
      this.grade,
      this.recordCount = 0,
      final List<NutritionItemDto> nutrition = const <NutritionItemDto>[],
      final List<ConcernScoreDto> concerns = const <ConcernScoreDto>[],
      final List<PlateHistoryItemDto> meals = const <PlateHistoryItemDto>[],
      this.aiComment,
      final List<String> goodPoints = const <String>[],
      final List<String> improvePoints = const <String>[]})
      : _nutrition = nutrition,
        _concerns = concerns,
        _meals = meals,
        _goodPoints = goodPoints,
        _improvePoints = improvePoints;

  factory _$DailyReportDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyReportDtoImplFromJson(json);

  @override
  final DateTime date;

  /// 기록이 없는 날은 키가 없다. **0 을 기본값으로 두면 화면이 "0점"을 그린다** —
  /// 0 점은 "아주 나쁘게 먹었다"이고 이건 "아직 안 찍었다"다.
  @override
  final int? dailyScore;
  @override
  final String? grade;
  @override
  @JsonKey()
  final int recordCount;
  final List<NutritionItemDto> _nutrition;
  @override
  @JsonKey()
  List<NutritionItemDto> get nutrition {
    if (_nutrition is EqualUnmodifiableListView) return _nutrition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutrition);
  }

  final List<ConcernScoreDto> _concerns;
  @override
  @JsonKey()
  List<ConcernScoreDto> get concerns {
    if (_concerns is EqualUnmodifiableListView) return _concerns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concerns);
  }

  /// 히스토리와 **같은 DTO** 다. 서버가 하나로 내려주므로 앱도 하나로 받는다.
  final List<PlateHistoryItemDto> _meals;

  /// 히스토리와 **같은 DTO** 다. 서버가 하나로 내려주므로 앱도 하나로 받는다.
  @override
  @JsonKey()
  List<PlateHistoryItemDto> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  final String? aiComment;
  final List<String> _goodPoints;
  @override
  @JsonKey()
  List<String> get goodPoints {
    if (_goodPoints is EqualUnmodifiableListView) return _goodPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goodPoints);
  }

  final List<String> _improvePoints;
  @override
  @JsonKey()
  List<String> get improvePoints {
    if (_improvePoints is EqualUnmodifiableListView) return _improvePoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvePoints);
  }

  @override
  String toString() {
    return 'DailyReportDto(date: $date, dailyScore: $dailyScore, grade: $grade, recordCount: $recordCount, nutrition: $nutrition, concerns: $concerns, meals: $meals, aiComment: $aiComment, goodPoints: $goodPoints, improvePoints: $improvePoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyReportDtoImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dailyScore, dailyScore) ||
                other.dailyScore == dailyScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.recordCount, recordCount) ||
                other.recordCount == recordCount) &&
            const DeepCollectionEquality()
                .equals(other._nutrition, _nutrition) &&
            const DeepCollectionEquality().equals(other._concerns, _concerns) &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.aiComment, aiComment) ||
                other.aiComment == aiComment) &&
            const DeepCollectionEquality()
                .equals(other._goodPoints, _goodPoints) &&
            const DeepCollectionEquality()
                .equals(other._improvePoints, _improvePoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      dailyScore,
      grade,
      recordCount,
      const DeepCollectionEquality().hash(_nutrition),
      const DeepCollectionEquality().hash(_concerns),
      const DeepCollectionEquality().hash(_meals),
      aiComment,
      const DeepCollectionEquality().hash(_goodPoints),
      const DeepCollectionEquality().hash(_improvePoints));

  /// Create a copy of DailyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyReportDtoImplCopyWith<_$DailyReportDtoImpl> get copyWith =>
      __$$DailyReportDtoImplCopyWithImpl<_$DailyReportDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyReportDtoImplToJson(
      this,
    );
  }
}

abstract class _DailyReportDto implements DailyReportDto {
  const factory _DailyReportDto(
      {required final DateTime date,
      final int? dailyScore,
      final String? grade,
      final int recordCount,
      final List<NutritionItemDto> nutrition,
      final List<ConcernScoreDto> concerns,
      final List<PlateHistoryItemDto> meals,
      final String? aiComment,
      final List<String> goodPoints,
      final List<String> improvePoints}) = _$DailyReportDtoImpl;

  factory _DailyReportDto.fromJson(Map<String, dynamic> json) =
      _$DailyReportDtoImpl.fromJson;

  @override
  DateTime get date;

  /// 기록이 없는 날은 키가 없다. **0 을 기본값으로 두면 화면이 "0점"을 그린다** —
  /// 0 점은 "아주 나쁘게 먹었다"이고 이건 "아직 안 찍었다"다.
  @override
  int? get dailyScore;
  @override
  String? get grade;
  @override
  int get recordCount;
  @override
  List<NutritionItemDto> get nutrition;
  @override
  List<ConcernScoreDto> get concerns;

  /// 히스토리와 **같은 DTO** 다. 서버가 하나로 내려주므로 앱도 하나로 받는다.
  @override
  List<PlateHistoryItemDto> get meals;
  @override
  String? get aiComment;
  @override
  List<String> get goodPoints;
  @override
  List<String> get improvePoints;

  /// Create a copy of DailyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyReportDtoImplCopyWith<_$DailyReportDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyReportDto _$WeeklyReportDtoFromJson(Map<String, dynamic> json) {
  return _WeeklyReportDto.fromJson(json);
}

/// @nodoc
mixin _$WeeklyReportDto {
  DateTime get from => throw _privateConstructorUsedError;
  DateTime get to => throw _privateConstructorUsedError;
  int? get averageDailyScore => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  int get totalDays => throw _privateConstructorUsedError;
  int get recordedDays => throw _privateConstructorUsedError;
  int get recordCount => throw _privateConstructorUsedError;

  /// 기록이 있는 날만 들어 있다. 없는 날은 아예 항목이 없다.
  List<DayScoreDto> get dailyScores => throw _privateConstructorUsedError;
  List<NutritionItemDto> get nutrition => throw _privateConstructorUsedError;
  List<ConcernScoreDto> get concerns => throw _privateConstructorUsedError;
  DayScoreDto? get bestDay => throw _privateConstructorUsedError;
  DayScoreDto? get worstDay => throw _privateConstructorUsedError;
  WeeklyCommentDto? get aiComment => throw _privateConstructorUsedError;

  /// Serializes this WeeklyReportDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyReportDtoCopyWith<WeeklyReportDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyReportDtoCopyWith<$Res> {
  factory $WeeklyReportDtoCopyWith(
          WeeklyReportDto value, $Res Function(WeeklyReportDto) then) =
      _$WeeklyReportDtoCopyWithImpl<$Res, WeeklyReportDto>;
  @useResult
  $Res call(
      {DateTime from,
      DateTime to,
      int? averageDailyScore,
      String? grade,
      int totalDays,
      int recordedDays,
      int recordCount,
      List<DayScoreDto> dailyScores,
      List<NutritionItemDto> nutrition,
      List<ConcernScoreDto> concerns,
      DayScoreDto? bestDay,
      DayScoreDto? worstDay,
      WeeklyCommentDto? aiComment});

  $DayScoreDtoCopyWith<$Res>? get bestDay;
  $DayScoreDtoCopyWith<$Res>? get worstDay;
  $WeeklyCommentDtoCopyWith<$Res>? get aiComment;
}

/// @nodoc
class _$WeeklyReportDtoCopyWithImpl<$Res, $Val extends WeeklyReportDto>
    implements $WeeklyReportDtoCopyWith<$Res> {
  _$WeeklyReportDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? averageDailyScore = freezed,
    Object? grade = freezed,
    Object? totalDays = null,
    Object? recordedDays = null,
    Object? recordCount = null,
    Object? dailyScores = null,
    Object? nutrition = null,
    Object? concerns = null,
    Object? bestDay = freezed,
    Object? worstDay = freezed,
    Object? aiComment = freezed,
  }) {
    return _then(_value.copyWith(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageDailyScore: freezed == averageDailyScore
          ? _value.averageDailyScore
          : averageDailyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as int,
      recordedDays: null == recordedDays
          ? _value.recordedDays
          : recordedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recordCount: null == recordCount
          ? _value.recordCount
          : recordCount // ignore: cast_nullable_to_non_nullable
              as int,
      dailyScores: null == dailyScores
          ? _value.dailyScores
          : dailyScores // ignore: cast_nullable_to_non_nullable
              as List<DayScoreDto>,
      nutrition: null == nutrition
          ? _value.nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as List<NutritionItemDto>,
      concerns: null == concerns
          ? _value.concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<ConcernScoreDto>,
      bestDay: freezed == bestDay
          ? _value.bestDay
          : bestDay // ignore: cast_nullable_to_non_nullable
              as DayScoreDto?,
      worstDay: freezed == worstDay
          ? _value.worstDay
          : worstDay // ignore: cast_nullable_to_non_nullable
              as DayScoreDto?,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as WeeklyCommentDto?,
    ) as $Val);
  }

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayScoreDtoCopyWith<$Res>? get bestDay {
    if (_value.bestDay == null) {
      return null;
    }

    return $DayScoreDtoCopyWith<$Res>(_value.bestDay!, (value) {
      return _then(_value.copyWith(bestDay: value) as $Val);
    });
  }

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayScoreDtoCopyWith<$Res>? get worstDay {
    if (_value.worstDay == null) {
      return null;
    }

    return $DayScoreDtoCopyWith<$Res>(_value.worstDay!, (value) {
      return _then(_value.copyWith(worstDay: value) as $Val);
    });
  }

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeeklyCommentDtoCopyWith<$Res>? get aiComment {
    if (_value.aiComment == null) {
      return null;
    }

    return $WeeklyCommentDtoCopyWith<$Res>(_value.aiComment!, (value) {
      return _then(_value.copyWith(aiComment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeeklyReportDtoImplCopyWith<$Res>
    implements $WeeklyReportDtoCopyWith<$Res> {
  factory _$$WeeklyReportDtoImplCopyWith(_$WeeklyReportDtoImpl value,
          $Res Function(_$WeeklyReportDtoImpl) then) =
      __$$WeeklyReportDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime from,
      DateTime to,
      int? averageDailyScore,
      String? grade,
      int totalDays,
      int recordedDays,
      int recordCount,
      List<DayScoreDto> dailyScores,
      List<NutritionItemDto> nutrition,
      List<ConcernScoreDto> concerns,
      DayScoreDto? bestDay,
      DayScoreDto? worstDay,
      WeeklyCommentDto? aiComment});

  @override
  $DayScoreDtoCopyWith<$Res>? get bestDay;
  @override
  $DayScoreDtoCopyWith<$Res>? get worstDay;
  @override
  $WeeklyCommentDtoCopyWith<$Res>? get aiComment;
}

/// @nodoc
class __$$WeeklyReportDtoImplCopyWithImpl<$Res>
    extends _$WeeklyReportDtoCopyWithImpl<$Res, _$WeeklyReportDtoImpl>
    implements _$$WeeklyReportDtoImplCopyWith<$Res> {
  __$$WeeklyReportDtoImplCopyWithImpl(
      _$WeeklyReportDtoImpl _value, $Res Function(_$WeeklyReportDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? averageDailyScore = freezed,
    Object? grade = freezed,
    Object? totalDays = null,
    Object? recordedDays = null,
    Object? recordCount = null,
    Object? dailyScores = null,
    Object? nutrition = null,
    Object? concerns = null,
    Object? bestDay = freezed,
    Object? worstDay = freezed,
    Object? aiComment = freezed,
  }) {
    return _then(_$WeeklyReportDtoImpl(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageDailyScore: freezed == averageDailyScore
          ? _value.averageDailyScore
          : averageDailyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as int,
      recordedDays: null == recordedDays
          ? _value.recordedDays
          : recordedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recordCount: null == recordCount
          ? _value.recordCount
          : recordCount // ignore: cast_nullable_to_non_nullable
              as int,
      dailyScores: null == dailyScores
          ? _value._dailyScores
          : dailyScores // ignore: cast_nullable_to_non_nullable
              as List<DayScoreDto>,
      nutrition: null == nutrition
          ? _value._nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as List<NutritionItemDto>,
      concerns: null == concerns
          ? _value._concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<ConcernScoreDto>,
      bestDay: freezed == bestDay
          ? _value.bestDay
          : bestDay // ignore: cast_nullable_to_non_nullable
              as DayScoreDto?,
      worstDay: freezed == worstDay
          ? _value.worstDay
          : worstDay // ignore: cast_nullable_to_non_nullable
              as DayScoreDto?,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as WeeklyCommentDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyReportDtoImpl implements _WeeklyReportDto {
  const _$WeeklyReportDtoImpl(
      {required this.from,
      required this.to,
      this.averageDailyScore,
      this.grade,
      this.totalDays = 0,
      this.recordedDays = 0,
      this.recordCount = 0,
      final List<DayScoreDto> dailyScores = const <DayScoreDto>[],
      final List<NutritionItemDto> nutrition = const <NutritionItemDto>[],
      final List<ConcernScoreDto> concerns = const <ConcernScoreDto>[],
      this.bestDay,
      this.worstDay,
      this.aiComment})
      : _dailyScores = dailyScores,
        _nutrition = nutrition,
        _concerns = concerns;

  factory _$WeeklyReportDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyReportDtoImplFromJson(json);

  @override
  final DateTime from;
  @override
  final DateTime to;
  @override
  final int? averageDailyScore;
  @override
  final String? grade;
  @override
  @JsonKey()
  final int totalDays;
  @override
  @JsonKey()
  final int recordedDays;
  @override
  @JsonKey()
  final int recordCount;

  /// 기록이 있는 날만 들어 있다. 없는 날은 아예 항목이 없다.
  final List<DayScoreDto> _dailyScores;

  /// 기록이 있는 날만 들어 있다. 없는 날은 아예 항목이 없다.
  @override
  @JsonKey()
  List<DayScoreDto> get dailyScores {
    if (_dailyScores is EqualUnmodifiableListView) return _dailyScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyScores);
  }

  final List<NutritionItemDto> _nutrition;
  @override
  @JsonKey()
  List<NutritionItemDto> get nutrition {
    if (_nutrition is EqualUnmodifiableListView) return _nutrition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutrition);
  }

  final List<ConcernScoreDto> _concerns;
  @override
  @JsonKey()
  List<ConcernScoreDto> get concerns {
    if (_concerns is EqualUnmodifiableListView) return _concerns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concerns);
  }

  @override
  final DayScoreDto? bestDay;
  @override
  final DayScoreDto? worstDay;
  @override
  final WeeklyCommentDto? aiComment;

  @override
  String toString() {
    return 'WeeklyReportDto(from: $from, to: $to, averageDailyScore: $averageDailyScore, grade: $grade, totalDays: $totalDays, recordedDays: $recordedDays, recordCount: $recordCount, dailyScores: $dailyScores, nutrition: $nutrition, concerns: $concerns, bestDay: $bestDay, worstDay: $worstDay, aiComment: $aiComment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyReportDtoImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.averageDailyScore, averageDailyScore) ||
                other.averageDailyScore == averageDailyScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.totalDays, totalDays) ||
                other.totalDays == totalDays) &&
            (identical(other.recordedDays, recordedDays) ||
                other.recordedDays == recordedDays) &&
            (identical(other.recordCount, recordCount) ||
                other.recordCount == recordCount) &&
            const DeepCollectionEquality()
                .equals(other._dailyScores, _dailyScores) &&
            const DeepCollectionEquality()
                .equals(other._nutrition, _nutrition) &&
            const DeepCollectionEquality().equals(other._concerns, _concerns) &&
            (identical(other.bestDay, bestDay) || other.bestDay == bestDay) &&
            (identical(other.worstDay, worstDay) ||
                other.worstDay == worstDay) &&
            (identical(other.aiComment, aiComment) ||
                other.aiComment == aiComment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      from,
      to,
      averageDailyScore,
      grade,
      totalDays,
      recordedDays,
      recordCount,
      const DeepCollectionEquality().hash(_dailyScores),
      const DeepCollectionEquality().hash(_nutrition),
      const DeepCollectionEquality().hash(_concerns),
      bestDay,
      worstDay,
      aiComment);

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyReportDtoImplCopyWith<_$WeeklyReportDtoImpl> get copyWith =>
      __$$WeeklyReportDtoImplCopyWithImpl<_$WeeklyReportDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyReportDtoImplToJson(
      this,
    );
  }
}

abstract class _WeeklyReportDto implements WeeklyReportDto {
  const factory _WeeklyReportDto(
      {required final DateTime from,
      required final DateTime to,
      final int? averageDailyScore,
      final String? grade,
      final int totalDays,
      final int recordedDays,
      final int recordCount,
      final List<DayScoreDto> dailyScores,
      final List<NutritionItemDto> nutrition,
      final List<ConcernScoreDto> concerns,
      final DayScoreDto? bestDay,
      final DayScoreDto? worstDay,
      final WeeklyCommentDto? aiComment}) = _$WeeklyReportDtoImpl;

  factory _WeeklyReportDto.fromJson(Map<String, dynamic> json) =
      _$WeeklyReportDtoImpl.fromJson;

  @override
  DateTime get from;
  @override
  DateTime get to;
  @override
  int? get averageDailyScore;
  @override
  String? get grade;
  @override
  int get totalDays;
  @override
  int get recordedDays;
  @override
  int get recordCount;

  /// 기록이 있는 날만 들어 있다. 없는 날은 아예 항목이 없다.
  @override
  List<DayScoreDto> get dailyScores;
  @override
  List<NutritionItemDto> get nutrition;
  @override
  List<ConcernScoreDto> get concerns;
  @override
  DayScoreDto? get bestDay;
  @override
  DayScoreDto? get worstDay;
  @override
  WeeklyCommentDto? get aiComment;

  /// Create a copy of WeeklyReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyReportDtoImplCopyWith<_$WeeklyReportDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
