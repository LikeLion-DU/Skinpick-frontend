// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skin_insight_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SkinInsightChangesDto _$SkinInsightChangesDtoFromJson(
    Map<String, dynamic> json) {
  return _SkinInsightChangesDto.fromJson(json);
}

/// @nodoc
mixin _$SkinInsightChangesDto {
  int get hydration => throw _privateConstructorUsedError;
  int get oil => throw _privateConstructorUsedError;
  int get redness => throw _privateConstructorUsedError;
  int get trouble => throw _privateConstructorUsedError;
  int get barrier => throw _privateConstructorUsedError;
  int get skinScore => throw _privateConstructorUsedError;

  /// Serializes this SkinInsightChangesDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinInsightChangesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinInsightChangesDtoCopyWith<SkinInsightChangesDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinInsightChangesDtoCopyWith<$Res> {
  factory $SkinInsightChangesDtoCopyWith(SkinInsightChangesDto value,
          $Res Function(SkinInsightChangesDto) then) =
      _$SkinInsightChangesDtoCopyWithImpl<$Res, SkinInsightChangesDto>;
  @useResult
  $Res call(
      {int hydration,
      int oil,
      int redness,
      int trouble,
      int barrier,
      int skinScore});
}

/// @nodoc
class _$SkinInsightChangesDtoCopyWithImpl<$Res,
        $Val extends SkinInsightChangesDto>
    implements $SkinInsightChangesDtoCopyWith<$Res> {
  _$SkinInsightChangesDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinInsightChangesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydration = null,
    Object? oil = null,
    Object? redness = null,
    Object? trouble = null,
    Object? barrier = null,
    Object? skinScore = null,
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
      skinScore: null == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinInsightChangesDtoImplCopyWith<$Res>
    implements $SkinInsightChangesDtoCopyWith<$Res> {
  factory _$$SkinInsightChangesDtoImplCopyWith(
          _$SkinInsightChangesDtoImpl value,
          $Res Function(_$SkinInsightChangesDtoImpl) then) =
      __$$SkinInsightChangesDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int hydration,
      int oil,
      int redness,
      int trouble,
      int barrier,
      int skinScore});
}

/// @nodoc
class __$$SkinInsightChangesDtoImplCopyWithImpl<$Res>
    extends _$SkinInsightChangesDtoCopyWithImpl<$Res,
        _$SkinInsightChangesDtoImpl>
    implements _$$SkinInsightChangesDtoImplCopyWith<$Res> {
  __$$SkinInsightChangesDtoImplCopyWithImpl(_$SkinInsightChangesDtoImpl _value,
      $Res Function(_$SkinInsightChangesDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinInsightChangesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydration = null,
    Object? oil = null,
    Object? redness = null,
    Object? trouble = null,
    Object? barrier = null,
    Object? skinScore = null,
  }) {
    return _then(_$SkinInsightChangesDtoImpl(
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
      skinScore: null == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinInsightChangesDtoImpl implements _SkinInsightChangesDto {
  const _$SkinInsightChangesDtoImpl(
      {required this.hydration,
      required this.oil,
      required this.redness,
      required this.trouble,
      required this.barrier,
      required this.skinScore});

  factory _$SkinInsightChangesDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinInsightChangesDtoImplFromJson(json);

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
  final int skinScore;

  @override
  String toString() {
    return 'SkinInsightChangesDto(hydration: $hydration, oil: $oil, redness: $redness, trouble: $trouble, barrier: $barrier, skinScore: $skinScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinInsightChangesDtoImpl &&
            (identical(other.hydration, hydration) ||
                other.hydration == hydration) &&
            (identical(other.oil, oil) || other.oil == oil) &&
            (identical(other.redness, redness) || other.redness == redness) &&
            (identical(other.trouble, trouble) || other.trouble == trouble) &&
            (identical(other.barrier, barrier) || other.barrier == barrier) &&
            (identical(other.skinScore, skinScore) ||
                other.skinScore == skinScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, hydration, oil, redness, trouble, barrier, skinScore);

  /// Create a copy of SkinInsightChangesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinInsightChangesDtoImplCopyWith<_$SkinInsightChangesDtoImpl>
      get copyWith => __$$SkinInsightChangesDtoImplCopyWithImpl<
          _$SkinInsightChangesDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinInsightChangesDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinInsightChangesDto implements SkinInsightChangesDto {
  const factory _SkinInsightChangesDto(
      {required final int hydration,
      required final int oil,
      required final int redness,
      required final int trouble,
      required final int barrier,
      required final int skinScore}) = _$SkinInsightChangesDtoImpl;

  factory _SkinInsightChangesDto.fromJson(Map<String, dynamic> json) =
      _$SkinInsightChangesDtoImpl.fromJson;

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
  @override
  int get skinScore;

  /// Create a copy of SkinInsightChangesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinInsightChangesDtoImplCopyWith<_$SkinInsightChangesDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SkinInsightItemDto _$SkinInsightItemDtoFromJson(Map<String, dynamic> json) {
  return _SkinInsightItemDto.fromJson(json);
}

/// @nodoc
mixin _$SkinInsightItemDto {
  String get category => throw _privateConstructorUsedError;

  /// HIGH / MEDIUM / LOW. 배열 순서에서 파생된 값이라 앱이 쓰지 않는다 —
  /// 받아만 두고 엔티티로 넘기지 않는다. 넘기면 언젠가 이걸로 정렬하는 코드가 생긴다.
  String get priority => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this SkinInsightItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinInsightItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinInsightItemDtoCopyWith<SkinInsightItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinInsightItemDtoCopyWith<$Res> {
  factory $SkinInsightItemDtoCopyWith(
          SkinInsightItemDto value, $Res Function(SkinInsightItemDto) then) =
      _$SkinInsightItemDtoCopyWithImpl<$Res, SkinInsightItemDto>;
  @useResult
  $Res call(
      {String category, String priority, String title, String description});
}

/// @nodoc
class _$SkinInsightItemDtoCopyWithImpl<$Res, $Val extends SkinInsightItemDto>
    implements $SkinInsightItemDtoCopyWith<$Res> {
  _$SkinInsightItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinInsightItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? priority = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinInsightItemDtoImplCopyWith<$Res>
    implements $SkinInsightItemDtoCopyWith<$Res> {
  factory _$$SkinInsightItemDtoImplCopyWith(_$SkinInsightItemDtoImpl value,
          $Res Function(_$SkinInsightItemDtoImpl) then) =
      __$$SkinInsightItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category, String priority, String title, String description});
}

/// @nodoc
class __$$SkinInsightItemDtoImplCopyWithImpl<$Res>
    extends _$SkinInsightItemDtoCopyWithImpl<$Res, _$SkinInsightItemDtoImpl>
    implements _$$SkinInsightItemDtoImplCopyWith<$Res> {
  __$$SkinInsightItemDtoImplCopyWithImpl(_$SkinInsightItemDtoImpl _value,
      $Res Function(_$SkinInsightItemDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinInsightItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? priority = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(_$SkinInsightItemDtoImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinInsightItemDtoImpl implements _SkinInsightItemDto {
  const _$SkinInsightItemDtoImpl(
      {required this.category,
      this.priority = '',
      this.title = '',
      this.description = ''});

  factory _$SkinInsightItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinInsightItemDtoImplFromJson(json);

  @override
  final String category;

  /// HIGH / MEDIUM / LOW. 배열 순서에서 파생된 값이라 앱이 쓰지 않는다 —
  /// 받아만 두고 엔티티로 넘기지 않는다. 넘기면 언젠가 이걸로 정렬하는 코드가 생긴다.
  @override
  @JsonKey()
  final String priority;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'SkinInsightItemDto(category: $category, priority: $priority, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinInsightItemDtoImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, category, priority, title, description);

  /// Create a copy of SkinInsightItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinInsightItemDtoImplCopyWith<_$SkinInsightItemDtoImpl> get copyWith =>
      __$$SkinInsightItemDtoImplCopyWithImpl<_$SkinInsightItemDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinInsightItemDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinInsightItemDto implements SkinInsightItemDto {
  const factory _SkinInsightItemDto(
      {required final String category,
      final String priority,
      final String title,
      final String description}) = _$SkinInsightItemDtoImpl;

  factory _SkinInsightItemDto.fromJson(Map<String, dynamic> json) =
      _$SkinInsightItemDtoImpl.fromJson;

  @override
  String get category;

  /// HIGH / MEDIUM / LOW. 배열 순서에서 파생된 값이라 앱이 쓰지 않는다 —
  /// 받아만 두고 엔티티로 넘기지 않는다. 넘기면 언젠가 이걸로 정렬하는 코드가 생긴다.
  @override
  String get priority;
  @override
  String get title;
  @override
  String get description;

  /// Create a copy of SkinInsightItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinInsightItemDtoImplCopyWith<_$SkinInsightItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinTodayActionDto _$SkinTodayActionDtoFromJson(Map<String, dynamic> json) {
  return _SkinTodayActionDto.fromJson(json);
}

/// @nodoc
mixin _$SkinTodayActionDto {
  String get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this SkinTodayActionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinTodayActionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinTodayActionDtoCopyWith<SkinTodayActionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinTodayActionDtoCopyWith<$Res> {
  factory $SkinTodayActionDtoCopyWith(
          SkinTodayActionDto value, $Res Function(SkinTodayActionDto) then) =
      _$SkinTodayActionDtoCopyWithImpl<$Res, SkinTodayActionDto>;
  @useResult
  $Res call({String category, String title});
}

/// @nodoc
class _$SkinTodayActionDtoCopyWithImpl<$Res, $Val extends SkinTodayActionDto>
    implements $SkinTodayActionDtoCopyWith<$Res> {
  _$SkinTodayActionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinTodayActionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkinTodayActionDtoImplCopyWith<$Res>
    implements $SkinTodayActionDtoCopyWith<$Res> {
  factory _$$SkinTodayActionDtoImplCopyWith(_$SkinTodayActionDtoImpl value,
          $Res Function(_$SkinTodayActionDtoImpl) then) =
      __$$SkinTodayActionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String title});
}

/// @nodoc
class __$$SkinTodayActionDtoImplCopyWithImpl<$Res>
    extends _$SkinTodayActionDtoCopyWithImpl<$Res, _$SkinTodayActionDtoImpl>
    implements _$$SkinTodayActionDtoImplCopyWith<$Res> {
  __$$SkinTodayActionDtoImplCopyWithImpl(_$SkinTodayActionDtoImpl _value,
      $Res Function(_$SkinTodayActionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinTodayActionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? title = null,
  }) {
    return _then(_$SkinTodayActionDtoImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinTodayActionDtoImpl implements _SkinTodayActionDto {
  const _$SkinTodayActionDtoImpl({required this.category, this.title = ''});

  factory _$SkinTodayActionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinTodayActionDtoImplFromJson(json);

  @override
  final String category;
  @override
  @JsonKey()
  final String title;

  @override
  String toString() {
    return 'SkinTodayActionDto(category: $category, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinTodayActionDtoImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, title);

  /// Create a copy of SkinTodayActionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinTodayActionDtoImplCopyWith<_$SkinTodayActionDtoImpl> get copyWith =>
      __$$SkinTodayActionDtoImplCopyWithImpl<_$SkinTodayActionDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinTodayActionDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinTodayActionDto implements SkinTodayActionDto {
  const factory _SkinTodayActionDto(
      {required final String category,
      final String title}) = _$SkinTodayActionDtoImpl;

  factory _SkinTodayActionDto.fromJson(Map<String, dynamic> json) =
      _$SkinTodayActionDtoImpl.fromJson;

  @override
  String get category;
  @override
  String get title;

  /// Create a copy of SkinTodayActionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinTodayActionDtoImplCopyWith<_$SkinTodayActionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinInsightDto _$SkinInsightDtoFromJson(Map<String, dynamic> json) {
  return _SkinInsightDto.fromJson(json);
}

/// @nodoc
mixin _$SkinInsightDto {
  int get skinAnalysisId => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;

  /// 직전 분석이 없으면 서버가 키를 통째로 지운다.
  SkinInsightChangesDto? get changes => throw _privateConstructorUsedError;

  /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이고, 서버는 이 경우를 저장하지 않는다.
  List<SkinInsightItemDto> get insights => throw _privateConstructorUsedError;
  List<SkinTodayActionDto> get todayActions =>
      throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this SkinInsightDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinInsightDtoCopyWith<SkinInsightDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinInsightDtoCopyWith<$Res> {
  factory $SkinInsightDtoCopyWith(
          SkinInsightDto value, $Res Function(SkinInsightDto) then) =
      _$SkinInsightDtoCopyWithImpl<$Res, SkinInsightDto>;
  @useResult
  $Res call(
      {int skinAnalysisId,
      String summary,
      SkinInsightChangesDto? changes,
      List<SkinInsightItemDto> insights,
      List<SkinTodayActionDto> todayActions,
      DateTime? generatedAt});

  $SkinInsightChangesDtoCopyWith<$Res>? get changes;
}

/// @nodoc
class _$SkinInsightDtoCopyWithImpl<$Res, $Val extends SkinInsightDto>
    implements $SkinInsightDtoCopyWith<$Res> {
  _$SkinInsightDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? summary = null,
    Object? changes = freezed,
    Object? insights = null,
    Object? todayActions = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      changes: freezed == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as SkinInsightChangesDto?,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<SkinInsightItemDto>,
      todayActions: null == todayActions
          ? _value.todayActions
          : todayActions // ignore: cast_nullable_to_non_nullable
              as List<SkinTodayActionDto>,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SkinInsightChangesDtoCopyWith<$Res>? get changes {
    if (_value.changes == null) {
      return null;
    }

    return $SkinInsightChangesDtoCopyWith<$Res>(_value.changes!, (value) {
      return _then(_value.copyWith(changes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SkinInsightDtoImplCopyWith<$Res>
    implements $SkinInsightDtoCopyWith<$Res> {
  factory _$$SkinInsightDtoImplCopyWith(_$SkinInsightDtoImpl value,
          $Res Function(_$SkinInsightDtoImpl) then) =
      __$$SkinInsightDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int skinAnalysisId,
      String summary,
      SkinInsightChangesDto? changes,
      List<SkinInsightItemDto> insights,
      List<SkinTodayActionDto> todayActions,
      DateTime? generatedAt});

  @override
  $SkinInsightChangesDtoCopyWith<$Res>? get changes;
}

/// @nodoc
class __$$SkinInsightDtoImplCopyWithImpl<$Res>
    extends _$SkinInsightDtoCopyWithImpl<$Res, _$SkinInsightDtoImpl>
    implements _$$SkinInsightDtoImplCopyWith<$Res> {
  __$$SkinInsightDtoImplCopyWithImpl(
      _$SkinInsightDtoImpl _value, $Res Function(_$SkinInsightDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skinAnalysisId = null,
    Object? summary = null,
    Object? changes = freezed,
    Object? insights = null,
    Object? todayActions = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_$SkinInsightDtoImpl(
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      changes: freezed == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as SkinInsightChangesDto?,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<SkinInsightItemDto>,
      todayActions: null == todayActions
          ? _value._todayActions
          : todayActions // ignore: cast_nullable_to_non_nullable
              as List<SkinTodayActionDto>,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinInsightDtoImpl implements _SkinInsightDto {
  const _$SkinInsightDtoImpl(
      {required this.skinAnalysisId,
      this.summary = '',
      this.changes,
      final List<SkinInsightItemDto> insights = const <SkinInsightItemDto>[],
      final List<SkinTodayActionDto> todayActions =
          const <SkinTodayActionDto>[],
      this.generatedAt})
      : _insights = insights,
        _todayActions = todayActions;

  factory _$SkinInsightDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinInsightDtoImplFromJson(json);

  @override
  final int skinAnalysisId;
  @override
  @JsonKey()
  final String summary;

  /// 직전 분석이 없으면 서버가 키를 통째로 지운다.
  @override
  final SkinInsightChangesDto? changes;

  /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이고, 서버는 이 경우를 저장하지 않는다.
  final List<SkinInsightItemDto> _insights;

  /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이고, 서버는 이 경우를 저장하지 않는다.
  @override
  @JsonKey()
  List<SkinInsightItemDto> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  final List<SkinTodayActionDto> _todayActions;
  @override
  @JsonKey()
  List<SkinTodayActionDto> get todayActions {
    if (_todayActions is EqualUnmodifiableListView) return _todayActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayActions);
  }

  @override
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'SkinInsightDto(skinAnalysisId: $skinAnalysisId, summary: $summary, changes: $changes, insights: $insights, todayActions: $todayActions, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinInsightDtoImpl &&
            (identical(other.skinAnalysisId, skinAnalysisId) ||
                other.skinAnalysisId == skinAnalysisId) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.changes, changes) || other.changes == changes) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            const DeepCollectionEquality()
                .equals(other._todayActions, _todayActions) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      skinAnalysisId,
      summary,
      changes,
      const DeepCollectionEquality().hash(_insights),
      const DeepCollectionEquality().hash(_todayActions),
      generatedAt);

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinInsightDtoImplCopyWith<_$SkinInsightDtoImpl> get copyWith =>
      __$$SkinInsightDtoImplCopyWithImpl<_$SkinInsightDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinInsightDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinInsightDto implements SkinInsightDto {
  const factory _SkinInsightDto(
      {required final int skinAnalysisId,
      final String summary,
      final SkinInsightChangesDto? changes,
      final List<SkinInsightItemDto> insights,
      final List<SkinTodayActionDto> todayActions,
      final DateTime? generatedAt}) = _$SkinInsightDtoImpl;

  factory _SkinInsightDto.fromJson(Map<String, dynamic> json) =
      _$SkinInsightDtoImpl.fromJson;

  @override
  int get skinAnalysisId;
  @override
  String get summary;

  /// 직전 분석이 없으면 서버가 키를 통째로 지운다.
  @override
  SkinInsightChangesDto? get changes;

  /// 다룰 주제가 없으면 빈 배열이다. 정상 응답이고, 서버는 이 경우를 저장하지 않는다.
  @override
  List<SkinInsightItemDto> get insights;
  @override
  List<SkinTodayActionDto> get todayActions;
  @override
  DateTime? get generatedAt;

  /// Create a copy of SkinInsightDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinInsightDtoImplCopyWith<_$SkinInsightDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
