// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plate_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NutritionDto _$NutritionDtoFromJson(Map<String, dynamic> json) {
  return _NutritionDto.fromJson(json);
}

/// @nodoc
mixin _$NutritionDto {
  int get caloriesKcal => throw _privateConstructorUsedError;
  num get proteinG => throw _privateConstructorUsedError;
  num get fatG => throw _privateConstructorUsedError;
  num get carbG => throw _privateConstructorUsedError;
  int get sodiumMg => throw _privateConstructorUsedError;
  num get sugarG => throw _privateConstructorUsedError;

  /// Serializes this NutritionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionDtoCopyWith<NutritionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionDtoCopyWith<$Res> {
  factory $NutritionDtoCopyWith(
          NutritionDto value, $Res Function(NutritionDto) then) =
      _$NutritionDtoCopyWithImpl<$Res, NutritionDto>;
  @useResult
  $Res call(
      {int caloriesKcal,
      num proteinG,
      num fatG,
      num carbG,
      int sodiumMg,
      num sugarG});
}

/// @nodoc
class _$NutritionDtoCopyWithImpl<$Res, $Val extends NutritionDto>
    implements $NutritionDtoCopyWith<$Res> {
  _$NutritionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caloriesKcal = null,
    Object? proteinG = null,
    Object? fatG = null,
    Object? carbG = null,
    Object? sodiumMg = null,
    Object? sugarG = null,
  }) {
    return _then(_value.copyWith(
      caloriesKcal: null == caloriesKcal
          ? _value.caloriesKcal
          : caloriesKcal // ignore: cast_nullable_to_non_nullable
              as int,
      proteinG: null == proteinG
          ? _value.proteinG
          : proteinG // ignore: cast_nullable_to_non_nullable
              as num,
      fatG: null == fatG
          ? _value.fatG
          : fatG // ignore: cast_nullable_to_non_nullable
              as num,
      carbG: null == carbG
          ? _value.carbG
          : carbG // ignore: cast_nullable_to_non_nullable
              as num,
      sodiumMg: null == sodiumMg
          ? _value.sodiumMg
          : sodiumMg // ignore: cast_nullable_to_non_nullable
              as int,
      sugarG: null == sugarG
          ? _value.sugarG
          : sugarG // ignore: cast_nullable_to_non_nullable
              as num,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionDtoImplCopyWith<$Res>
    implements $NutritionDtoCopyWith<$Res> {
  factory _$$NutritionDtoImplCopyWith(
          _$NutritionDtoImpl value, $Res Function(_$NutritionDtoImpl) then) =
      __$$NutritionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int caloriesKcal,
      num proteinG,
      num fatG,
      num carbG,
      int sodiumMg,
      num sugarG});
}

/// @nodoc
class __$$NutritionDtoImplCopyWithImpl<$Res>
    extends _$NutritionDtoCopyWithImpl<$Res, _$NutritionDtoImpl>
    implements _$$NutritionDtoImplCopyWith<$Res> {
  __$$NutritionDtoImplCopyWithImpl(
      _$NutritionDtoImpl _value, $Res Function(_$NutritionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caloriesKcal = null,
    Object? proteinG = null,
    Object? fatG = null,
    Object? carbG = null,
    Object? sodiumMg = null,
    Object? sugarG = null,
  }) {
    return _then(_$NutritionDtoImpl(
      caloriesKcal: null == caloriesKcal
          ? _value.caloriesKcal
          : caloriesKcal // ignore: cast_nullable_to_non_nullable
              as int,
      proteinG: null == proteinG
          ? _value.proteinG
          : proteinG // ignore: cast_nullable_to_non_nullable
              as num,
      fatG: null == fatG
          ? _value.fatG
          : fatG // ignore: cast_nullable_to_non_nullable
              as num,
      carbG: null == carbG
          ? _value.carbG
          : carbG // ignore: cast_nullable_to_non_nullable
              as num,
      sodiumMg: null == sodiumMg
          ? _value.sodiumMg
          : sodiumMg // ignore: cast_nullable_to_non_nullable
              as int,
      sugarG: null == sugarG
          ? _value.sugarG
          : sugarG // ignore: cast_nullable_to_non_nullable
              as num,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionDtoImpl implements _NutritionDto {
  const _$NutritionDtoImpl(
      {this.caloriesKcal = 0,
      this.proteinG = 0,
      this.fatG = 0,
      this.carbG = 0,
      this.sodiumMg = 0,
      this.sugarG = 0});

  factory _$NutritionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionDtoImplFromJson(json);

  @override
  @JsonKey()
  final int caloriesKcal;
  @override
  @JsonKey()
  final num proteinG;
  @override
  @JsonKey()
  final num fatG;
  @override
  @JsonKey()
  final num carbG;
  @override
  @JsonKey()
  final int sodiumMg;
  @override
  @JsonKey()
  final num sugarG;

  @override
  String toString() {
    return 'NutritionDto(caloriesKcal: $caloriesKcal, proteinG: $proteinG, fatG: $fatG, carbG: $carbG, sodiumMg: $sodiumMg, sugarG: $sugarG)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionDtoImpl &&
            (identical(other.caloriesKcal, caloriesKcal) ||
                other.caloriesKcal == caloriesKcal) &&
            (identical(other.proteinG, proteinG) ||
                other.proteinG == proteinG) &&
            (identical(other.fatG, fatG) || other.fatG == fatG) &&
            (identical(other.carbG, carbG) || other.carbG == carbG) &&
            (identical(other.sodiumMg, sodiumMg) ||
                other.sodiumMg == sodiumMg) &&
            (identical(other.sugarG, sugarG) || other.sugarG == sugarG));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, caloriesKcal, proteinG, fatG, carbG, sodiumMg, sugarG);

  /// Create a copy of NutritionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionDtoImplCopyWith<_$NutritionDtoImpl> get copyWith =>
      __$$NutritionDtoImplCopyWithImpl<_$NutritionDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionDtoImplToJson(
      this,
    );
  }
}

abstract class _NutritionDto implements NutritionDto {
  const factory _NutritionDto(
      {final int caloriesKcal,
      final num proteinG,
      final num fatG,
      final num carbG,
      final int sodiumMg,
      final num sugarG}) = _$NutritionDtoImpl;

  factory _NutritionDto.fromJson(Map<String, dynamic> json) =
      _$NutritionDtoImpl.fromJson;

  @override
  int get caloriesKcal;
  @override
  num get proteinG;
  @override
  num get fatG;
  @override
  num get carbG;
  @override
  int get sodiumMg;
  @override
  num get sugarG;

  /// Create a copy of NutritionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionDtoImplCopyWith<_$NutritionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IngredientDto _$IngredientDtoFromJson(Map<String, dynamic> json) {
  return _IngredientDto.fromJson(json);
}

/// @nodoc
mixin _$IngredientDto {
  String get name => throw _privateConstructorUsedError;
  String get tag => throw _privateConstructorUsedError;

  /// Serializes this IngredientDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IngredientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientDtoCopyWith<IngredientDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientDtoCopyWith<$Res> {
  factory $IngredientDtoCopyWith(
          IngredientDto value, $Res Function(IngredientDto) then) =
      _$IngredientDtoCopyWithImpl<$Res, IngredientDto>;
  @useResult
  $Res call({String name, String tag});
}

/// @nodoc
class _$IngredientDtoCopyWithImpl<$Res, $Val extends IngredientDto>
    implements $IngredientDtoCopyWith<$Res> {
  _$IngredientDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? tag = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IngredientDtoImplCopyWith<$Res>
    implements $IngredientDtoCopyWith<$Res> {
  factory _$$IngredientDtoImplCopyWith(
          _$IngredientDtoImpl value, $Res Function(_$IngredientDtoImpl) then) =
      __$$IngredientDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String tag});
}

/// @nodoc
class __$$IngredientDtoImplCopyWithImpl<$Res>
    extends _$IngredientDtoCopyWithImpl<$Res, _$IngredientDtoImpl>
    implements _$$IngredientDtoImplCopyWith<$Res> {
  __$$IngredientDtoImplCopyWithImpl(
      _$IngredientDtoImpl _value, $Res Function(_$IngredientDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of IngredientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? tag = null,
  }) {
    return _then(_$IngredientDtoImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientDtoImpl implements _IngredientDto {
  const _$IngredientDtoImpl({required this.name, this.tag = 'ETC'});

  factory _$IngredientDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientDtoImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String tag;

  @override
  String toString() {
    return 'IngredientDto(name: $name, tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tag, tag) || other.tag == tag));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, tag);

  /// Create a copy of IngredientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientDtoImplCopyWith<_$IngredientDtoImpl> get copyWith =>
      __$$IngredientDtoImplCopyWithImpl<_$IngredientDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientDtoImplToJson(
      this,
    );
  }
}

abstract class _IngredientDto implements IngredientDto {
  const factory _IngredientDto({required final String name, final String tag}) =
      _$IngredientDtoImpl;

  factory _IngredientDto.fromJson(Map<String, dynamic> json) =
      _$IngredientDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get tag;

  /// Create a copy of IngredientDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientDtoImplCopyWith<_$IngredientDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FoodAnalysisDto _$FoodAnalysisDtoFromJson(Map<String, dynamic> json) {
  return _FoodAnalysisDto.fromJson(json);
}

/// @nodoc
mixin _$FoodAnalysisDto {
  /// `POST /plates/analyze` 응답에는 없다. 저장 전이라 행이 없고, 서버는
  /// non_null 직렬화라 키 자체를 뺀다. required 로 두면 분석 응답이 파싱에서 죽는다.
  int? get foodAnalysisId => throw _privateConstructorUsedError;
  String get foodName => throw _privateConstructorUsedError;
  String? get foodCategory => throw _privateConstructorUsedError;
  String get cookingMethod => throw _privateConstructorUsedError;
  bool get spicy => throw _privateConstructorUsedError;

  /// 음식 특성 5종. **서버는 "모른다"를 null 이 아니라 `UNKNOWN`(foodGroup 은
  /// `ETC`) 문자열로 내려보낸다.** nullable 로 받아 null 체크만 하면 화면에
  /// UNKNOWN 이 그대로 뜬다 — 숨김은 [FoodGroup] 쪽 enum 이 맡는다.
  /// 기본값이 막는 것은 **옛 기록이 아니라 옛 서버 응답**이다. 저장된 옛 행에도
  /// 서버는 키를 UNKNOWN/ETC 로 채워 내리고(`plate_legacy_traits.json`), 이 키를
  /// 아예 안 만들던 것은 배포 경계에 남은 구 서버다(`plate_analyze.json`).
  String get foodGroup => throw _privateConstructorUsedError;
  String get portionSize => throw _privateConstructorUsedError;
  String get spiciness => throw _privateConstructorUsedError;
  String get oiliness => throw _privateConstructorUsedError;
  String get processingLevel => throw _privateConstructorUsedError;
  List<IngredientDto> get ingredients => throw _privateConstructorUsedError;
  NutritionDto get nutrition => throw _privateConstructorUsedError;

  /// Serializes this FoodAnalysisDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodAnalysisDtoCopyWith<FoodAnalysisDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodAnalysisDtoCopyWith<$Res> {
  factory $FoodAnalysisDtoCopyWith(
          FoodAnalysisDto value, $Res Function(FoodAnalysisDto) then) =
      _$FoodAnalysisDtoCopyWithImpl<$Res, FoodAnalysisDto>;
  @useResult
  $Res call(
      {int? foodAnalysisId,
      String foodName,
      String? foodCategory,
      String cookingMethod,
      bool spicy,
      String foodGroup,
      String portionSize,
      String spiciness,
      String oiliness,
      String processingLevel,
      List<IngredientDto> ingredients,
      NutritionDto nutrition});

  $NutritionDtoCopyWith<$Res> get nutrition;
}

/// @nodoc
class _$FoodAnalysisDtoCopyWithImpl<$Res, $Val extends FoodAnalysisDto>
    implements $FoodAnalysisDtoCopyWith<$Res> {
  _$FoodAnalysisDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodAnalysisId = freezed,
    Object? foodName = null,
    Object? foodCategory = freezed,
    Object? cookingMethod = null,
    Object? spicy = null,
    Object? foodGroup = null,
    Object? portionSize = null,
    Object? spiciness = null,
    Object? oiliness = null,
    Object? processingLevel = null,
    Object? ingredients = null,
    Object? nutrition = null,
  }) {
    return _then(_value.copyWith(
      foodAnalysisId: freezed == foodAnalysisId
          ? _value.foodAnalysisId
          : foodAnalysisId // ignore: cast_nullable_to_non_nullable
              as int?,
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      foodCategory: freezed == foodCategory
          ? _value.foodCategory
          : foodCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      cookingMethod: null == cookingMethod
          ? _value.cookingMethod
          : cookingMethod // ignore: cast_nullable_to_non_nullable
              as String,
      spicy: null == spicy
          ? _value.spicy
          : spicy // ignore: cast_nullable_to_non_nullable
              as bool,
      foodGroup: null == foodGroup
          ? _value.foodGroup
          : foodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      portionSize: null == portionSize
          ? _value.portionSize
          : portionSize // ignore: cast_nullable_to_non_nullable
              as String,
      spiciness: null == spiciness
          ? _value.spiciness
          : spiciness // ignore: cast_nullable_to_non_nullable
              as String,
      oiliness: null == oiliness
          ? _value.oiliness
          : oiliness // ignore: cast_nullable_to_non_nullable
              as String,
      processingLevel: null == processingLevel
          ? _value.processingLevel
          : processingLevel // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<IngredientDto>,
      nutrition: null == nutrition
          ? _value.nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as NutritionDto,
    ) as $Val);
  }

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionDtoCopyWith<$Res> get nutrition {
    return $NutritionDtoCopyWith<$Res>(_value.nutrition, (value) {
      return _then(_value.copyWith(nutrition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FoodAnalysisDtoImplCopyWith<$Res>
    implements $FoodAnalysisDtoCopyWith<$Res> {
  factory _$$FoodAnalysisDtoImplCopyWith(_$FoodAnalysisDtoImpl value,
          $Res Function(_$FoodAnalysisDtoImpl) then) =
      __$$FoodAnalysisDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? foodAnalysisId,
      String foodName,
      String? foodCategory,
      String cookingMethod,
      bool spicy,
      String foodGroup,
      String portionSize,
      String spiciness,
      String oiliness,
      String processingLevel,
      List<IngredientDto> ingredients,
      NutritionDto nutrition});

  @override
  $NutritionDtoCopyWith<$Res> get nutrition;
}

/// @nodoc
class __$$FoodAnalysisDtoImplCopyWithImpl<$Res>
    extends _$FoodAnalysisDtoCopyWithImpl<$Res, _$FoodAnalysisDtoImpl>
    implements _$$FoodAnalysisDtoImplCopyWith<$Res> {
  __$$FoodAnalysisDtoImplCopyWithImpl(
      _$FoodAnalysisDtoImpl _value, $Res Function(_$FoodAnalysisDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodAnalysisId = freezed,
    Object? foodName = null,
    Object? foodCategory = freezed,
    Object? cookingMethod = null,
    Object? spicy = null,
    Object? foodGroup = null,
    Object? portionSize = null,
    Object? spiciness = null,
    Object? oiliness = null,
    Object? processingLevel = null,
    Object? ingredients = null,
    Object? nutrition = null,
  }) {
    return _then(_$FoodAnalysisDtoImpl(
      foodAnalysisId: freezed == foodAnalysisId
          ? _value.foodAnalysisId
          : foodAnalysisId // ignore: cast_nullable_to_non_nullable
              as int?,
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      foodCategory: freezed == foodCategory
          ? _value.foodCategory
          : foodCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      cookingMethod: null == cookingMethod
          ? _value.cookingMethod
          : cookingMethod // ignore: cast_nullable_to_non_nullable
              as String,
      spicy: null == spicy
          ? _value.spicy
          : spicy // ignore: cast_nullable_to_non_nullable
              as bool,
      foodGroup: null == foodGroup
          ? _value.foodGroup
          : foodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      portionSize: null == portionSize
          ? _value.portionSize
          : portionSize // ignore: cast_nullable_to_non_nullable
              as String,
      spiciness: null == spiciness
          ? _value.spiciness
          : spiciness // ignore: cast_nullable_to_non_nullable
              as String,
      oiliness: null == oiliness
          ? _value.oiliness
          : oiliness // ignore: cast_nullable_to_non_nullable
              as String,
      processingLevel: null == processingLevel
          ? _value.processingLevel
          : processingLevel // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<IngredientDto>,
      nutrition: null == nutrition
          ? _value.nutrition
          : nutrition // ignore: cast_nullable_to_non_nullable
              as NutritionDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodAnalysisDtoImpl implements _FoodAnalysisDto {
  const _$FoodAnalysisDtoImpl(
      {this.foodAnalysisId,
      required this.foodName,
      this.foodCategory,
      this.cookingMethod = 'ETC',
      this.spicy = false,
      this.foodGroup = 'ETC',
      this.portionSize = 'UNKNOWN',
      this.spiciness = 'UNKNOWN',
      this.oiliness = 'UNKNOWN',
      this.processingLevel = 'UNKNOWN',
      final List<IngredientDto> ingredients = const <IngredientDto>[],
      required this.nutrition})
      : _ingredients = ingredients;

  factory _$FoodAnalysisDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodAnalysisDtoImplFromJson(json);

  /// `POST /plates/analyze` 응답에는 없다. 저장 전이라 행이 없고, 서버는
  /// non_null 직렬화라 키 자체를 뺀다. required 로 두면 분석 응답이 파싱에서 죽는다.
  @override
  final int? foodAnalysisId;
  @override
  final String foodName;
  @override
  final String? foodCategory;
  @override
  @JsonKey()
  final String cookingMethod;
  @override
  @JsonKey()
  final bool spicy;

  /// 음식 특성 5종. **서버는 "모른다"를 null 이 아니라 `UNKNOWN`(foodGroup 은
  /// `ETC`) 문자열로 내려보낸다.** nullable 로 받아 null 체크만 하면 화면에
  /// UNKNOWN 이 그대로 뜬다 — 숨김은 [FoodGroup] 쪽 enum 이 맡는다.
  /// 기본값이 막는 것은 **옛 기록이 아니라 옛 서버 응답**이다. 저장된 옛 행에도
  /// 서버는 키를 UNKNOWN/ETC 로 채워 내리고(`plate_legacy_traits.json`), 이 키를
  /// 아예 안 만들던 것은 배포 경계에 남은 구 서버다(`plate_analyze.json`).
  @override
  @JsonKey()
  final String foodGroup;
  @override
  @JsonKey()
  final String portionSize;
  @override
  @JsonKey()
  final String spiciness;
  @override
  @JsonKey()
  final String oiliness;
  @override
  @JsonKey()
  final String processingLevel;
  final List<IngredientDto> _ingredients;
  @override
  @JsonKey()
  List<IngredientDto> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  @override
  final NutritionDto nutrition;

  @override
  String toString() {
    return 'FoodAnalysisDto(foodAnalysisId: $foodAnalysisId, foodName: $foodName, foodCategory: $foodCategory, cookingMethod: $cookingMethod, spicy: $spicy, foodGroup: $foodGroup, portionSize: $portionSize, spiciness: $spiciness, oiliness: $oiliness, processingLevel: $processingLevel, ingredients: $ingredients, nutrition: $nutrition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodAnalysisDtoImpl &&
            (identical(other.foodAnalysisId, foodAnalysisId) ||
                other.foodAnalysisId == foodAnalysisId) &&
            (identical(other.foodName, foodName) ||
                other.foodName == foodName) &&
            (identical(other.foodCategory, foodCategory) ||
                other.foodCategory == foodCategory) &&
            (identical(other.cookingMethod, cookingMethod) ||
                other.cookingMethod == cookingMethod) &&
            (identical(other.spicy, spicy) || other.spicy == spicy) &&
            (identical(other.foodGroup, foodGroup) ||
                other.foodGroup == foodGroup) &&
            (identical(other.portionSize, portionSize) ||
                other.portionSize == portionSize) &&
            (identical(other.spiciness, spiciness) ||
                other.spiciness == spiciness) &&
            (identical(other.oiliness, oiliness) ||
                other.oiliness == oiliness) &&
            (identical(other.processingLevel, processingLevel) ||
                other.processingLevel == processingLevel) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            (identical(other.nutrition, nutrition) ||
                other.nutrition == nutrition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      foodAnalysisId,
      foodName,
      foodCategory,
      cookingMethod,
      spicy,
      foodGroup,
      portionSize,
      spiciness,
      oiliness,
      processingLevel,
      const DeepCollectionEquality().hash(_ingredients),
      nutrition);

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodAnalysisDtoImplCopyWith<_$FoodAnalysisDtoImpl> get copyWith =>
      __$$FoodAnalysisDtoImplCopyWithImpl<_$FoodAnalysisDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodAnalysisDtoImplToJson(
      this,
    );
  }
}

abstract class _FoodAnalysisDto implements FoodAnalysisDto {
  const factory _FoodAnalysisDto(
      {final int? foodAnalysisId,
      required final String foodName,
      final String? foodCategory,
      final String cookingMethod,
      final bool spicy,
      final String foodGroup,
      final String portionSize,
      final String spiciness,
      final String oiliness,
      final String processingLevel,
      final List<IngredientDto> ingredients,
      required final NutritionDto nutrition}) = _$FoodAnalysisDtoImpl;

  factory _FoodAnalysisDto.fromJson(Map<String, dynamic> json) =
      _$FoodAnalysisDtoImpl.fromJson;

  /// `POST /plates/analyze` 응답에는 없다. 저장 전이라 행이 없고, 서버는
  /// non_null 직렬화라 키 자체를 뺀다. required 로 두면 분석 응답이 파싱에서 죽는다.
  @override
  int? get foodAnalysisId;
  @override
  String get foodName;
  @override
  String? get foodCategory;
  @override
  String get cookingMethod;
  @override
  bool get spicy;

  /// 음식 특성 5종. **서버는 "모른다"를 null 이 아니라 `UNKNOWN`(foodGroup 은
  /// `ETC`) 문자열로 내려보낸다.** nullable 로 받아 null 체크만 하면 화면에
  /// UNKNOWN 이 그대로 뜬다 — 숨김은 [FoodGroup] 쪽 enum 이 맡는다.
  /// 기본값이 막는 것은 **옛 기록이 아니라 옛 서버 응답**이다. 저장된 옛 행에도
  /// 서버는 키를 UNKNOWN/ETC 로 채워 내리고(`plate_legacy_traits.json`), 이 키를
  /// 아예 안 만들던 것은 배포 경계에 남은 구 서버다(`plate_analyze.json`).
  @override
  String get foodGroup;
  @override
  String get portionSize;
  @override
  String get spiciness;
  @override
  String get oiliness;
  @override
  String get processingLevel;
  @override
  List<IngredientDto> get ingredients;
  @override
  NutritionDto get nutrition;

  /// Create a copy of FoodAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodAnalysisDtoImplCopyWith<_$FoodAnalysisDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackDto _$FeedbackDtoFromJson(Map<String, dynamic> json) {
  return _FeedbackDto.fromJson(json);
}

/// @nodoc
mixin _$FeedbackDto {
  String get message => throw _privateConstructorUsedError;

  /// 지금 피부 상태와 음식 특성을 잇는 설명. [message] 는 짧은 제목이고 이쪽이
  /// 그 아래 보조 문장이다. V8 이전 기록에는 키가 아예 없다.
  ///
  /// **[ActionDto] 에는 이 필드가 없다.** 행동 카드는 문구 자체가 설명이라
  /// 서버가 만들지 않는다 — 거기서 파싱을 시도하면 항상 비어 있다.
  String? get reason => throw _privateConstructorUsedError;
  int get scoreDelta => throw _privateConstructorUsedError;
  String? get ruleCode => throw _privateConstructorUsedError;

  /// Serializes this FeedbackDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackDtoCopyWith<FeedbackDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackDtoCopyWith<$Res> {
  factory $FeedbackDtoCopyWith(
          FeedbackDto value, $Res Function(FeedbackDto) then) =
      _$FeedbackDtoCopyWithImpl<$Res, FeedbackDto>;
  @useResult
  $Res call({String message, String? reason, int scoreDelta, String? ruleCode});
}

/// @nodoc
class _$FeedbackDtoCopyWithImpl<$Res, $Val extends FeedbackDto>
    implements $FeedbackDtoCopyWith<$Res> {
  _$FeedbackDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? reason = freezed,
    Object? scoreDelta = null,
    Object? ruleCode = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreDelta: null == scoreDelta
          ? _value.scoreDelta
          : scoreDelta // ignore: cast_nullable_to_non_nullable
              as int,
      ruleCode: freezed == ruleCode
          ? _value.ruleCode
          : ruleCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedbackDtoImplCopyWith<$Res>
    implements $FeedbackDtoCopyWith<$Res> {
  factory _$$FeedbackDtoImplCopyWith(
          _$FeedbackDtoImpl value, $Res Function(_$FeedbackDtoImpl) then) =
      __$$FeedbackDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? reason, int scoreDelta, String? ruleCode});
}

/// @nodoc
class __$$FeedbackDtoImplCopyWithImpl<$Res>
    extends _$FeedbackDtoCopyWithImpl<$Res, _$FeedbackDtoImpl>
    implements _$$FeedbackDtoImplCopyWith<$Res> {
  __$$FeedbackDtoImplCopyWithImpl(
      _$FeedbackDtoImpl _value, $Res Function(_$FeedbackDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedbackDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? reason = freezed,
    Object? scoreDelta = null,
    Object? ruleCode = freezed,
  }) {
    return _then(_$FeedbackDtoImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreDelta: null == scoreDelta
          ? _value.scoreDelta
          : scoreDelta // ignore: cast_nullable_to_non_nullable
              as int,
      ruleCode: freezed == ruleCode
          ? _value.ruleCode
          : ruleCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackDtoImpl implements _FeedbackDto {
  const _$FeedbackDtoImpl(
      {required this.message, this.reason, this.scoreDelta = 0, this.ruleCode});

  factory _$FeedbackDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackDtoImplFromJson(json);

  @override
  final String message;

  /// 지금 피부 상태와 음식 특성을 잇는 설명. [message] 는 짧은 제목이고 이쪽이
  /// 그 아래 보조 문장이다. V8 이전 기록에는 키가 아예 없다.
  ///
  /// **[ActionDto] 에는 이 필드가 없다.** 행동 카드는 문구 자체가 설명이라
  /// 서버가 만들지 않는다 — 거기서 파싱을 시도하면 항상 비어 있다.
  @override
  final String? reason;
  @override
  @JsonKey()
  final int scoreDelta;
  @override
  final String? ruleCode;

  @override
  String toString() {
    return 'FeedbackDto(message: $message, reason: $reason, scoreDelta: $scoreDelta, ruleCode: $ruleCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackDtoImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.scoreDelta, scoreDelta) ||
                other.scoreDelta == scoreDelta) &&
            (identical(other.ruleCode, ruleCode) ||
                other.ruleCode == ruleCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, reason, scoreDelta, ruleCode);

  /// Create a copy of FeedbackDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackDtoImplCopyWith<_$FeedbackDtoImpl> get copyWith =>
      __$$FeedbackDtoImplCopyWithImpl<_$FeedbackDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackDtoImplToJson(
      this,
    );
  }
}

abstract class _FeedbackDto implements FeedbackDto {
  const factory _FeedbackDto(
      {required final String message,
      final String? reason,
      final int scoreDelta,
      final String? ruleCode}) = _$FeedbackDtoImpl;

  factory _FeedbackDto.fromJson(Map<String, dynamic> json) =
      _$FeedbackDtoImpl.fromJson;

  @override
  String get message;

  /// 지금 피부 상태와 음식 특성을 잇는 설명. [message] 는 짧은 제목이고 이쪽이
  /// 그 아래 보조 문장이다. V8 이전 기록에는 키가 아예 없다.
  ///
  /// **[ActionDto] 에는 이 필드가 없다.** 행동 카드는 문구 자체가 설명이라
  /// 서버가 만들지 않는다 — 거기서 파싱을 시도하면 항상 비어 있다.
  @override
  String? get reason;
  @override
  int get scoreDelta;
  @override
  String? get ruleCode;

  /// Create a copy of FeedbackDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackDtoImplCopyWith<_$FeedbackDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActionDto _$ActionDtoFromJson(Map<String, dynamic> json) {
  return _ActionDto.fromJson(json);
}

/// @nodoc
mixin _$ActionDto {
  String get message => throw _privateConstructorUsedError;
  int get expectedGain => throw _privateConstructorUsedError;
  String? get ruleCode => throw _privateConstructorUsedError;

  /// Serializes this ActionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionDtoCopyWith<ActionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionDtoCopyWith<$Res> {
  factory $ActionDtoCopyWith(ActionDto value, $Res Function(ActionDto) then) =
      _$ActionDtoCopyWithImpl<$Res, ActionDto>;
  @useResult
  $Res call({String message, int expectedGain, String? ruleCode});
}

/// @nodoc
class _$ActionDtoCopyWithImpl<$Res, $Val extends ActionDto>
    implements $ActionDtoCopyWith<$Res> {
  _$ActionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? expectedGain = null,
    Object? ruleCode = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      expectedGain: null == expectedGain
          ? _value.expectedGain
          : expectedGain // ignore: cast_nullable_to_non_nullable
              as int,
      ruleCode: freezed == ruleCode
          ? _value.ruleCode
          : ruleCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActionDtoImplCopyWith<$Res>
    implements $ActionDtoCopyWith<$Res> {
  factory _$$ActionDtoImplCopyWith(
          _$ActionDtoImpl value, $Res Function(_$ActionDtoImpl) then) =
      __$$ActionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int expectedGain, String? ruleCode});
}

/// @nodoc
class __$$ActionDtoImplCopyWithImpl<$Res>
    extends _$ActionDtoCopyWithImpl<$Res, _$ActionDtoImpl>
    implements _$$ActionDtoImplCopyWith<$Res> {
  __$$ActionDtoImplCopyWithImpl(
      _$ActionDtoImpl _value, $Res Function(_$ActionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? expectedGain = null,
    Object? ruleCode = freezed,
  }) {
    return _then(_$ActionDtoImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      expectedGain: null == expectedGain
          ? _value.expectedGain
          : expectedGain // ignore: cast_nullable_to_non_nullable
              as int,
      ruleCode: freezed == ruleCode
          ? _value.ruleCode
          : ruleCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionDtoImpl implements _ActionDto {
  const _$ActionDtoImpl(
      {required this.message, this.expectedGain = 0, this.ruleCode});

  factory _$ActionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionDtoImplFromJson(json);

  @override
  final String message;
  @override
  @JsonKey()
  final int expectedGain;
  @override
  final String? ruleCode;

  @override
  String toString() {
    return 'ActionDto(message: $message, expectedGain: $expectedGain, ruleCode: $ruleCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionDtoImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.expectedGain, expectedGain) ||
                other.expectedGain == expectedGain) &&
            (identical(other.ruleCode, ruleCode) ||
                other.ruleCode == ruleCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, expectedGain, ruleCode);

  /// Create a copy of ActionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionDtoImplCopyWith<_$ActionDtoImpl> get copyWith =>
      __$$ActionDtoImplCopyWithImpl<_$ActionDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionDtoImplToJson(
      this,
    );
  }
}

abstract class _ActionDto implements ActionDto {
  const factory _ActionDto(
      {required final String message,
      final int expectedGain,
      final String? ruleCode}) = _$ActionDtoImpl;

  factory _ActionDto.fromJson(Map<String, dynamic> json) =
      _$ActionDtoImpl.fromJson;

  @override
  String get message;
  @override
  int get expectedGain;
  @override
  String? get ruleCode;

  /// Create a copy of ActionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionDtoImplCopyWith<_$ActionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackGroupDto _$FeedbackGroupDtoFromJson(Map<String, dynamic> json) {
  return _FeedbackGroupDto.fromJson(json);
}

/// @nodoc
mixin _$FeedbackGroupDto {
  List<FeedbackDto> get good => throw _privateConstructorUsedError;
  List<FeedbackDto> get caution => throw _privateConstructorUsedError;
  List<ActionDto> get action => throw _privateConstructorUsedError;

  /// Serializes this FeedbackGroupDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackGroupDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackGroupDtoCopyWith<FeedbackGroupDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackGroupDtoCopyWith<$Res> {
  factory $FeedbackGroupDtoCopyWith(
          FeedbackGroupDto value, $Res Function(FeedbackGroupDto) then) =
      _$FeedbackGroupDtoCopyWithImpl<$Res, FeedbackGroupDto>;
  @useResult
  $Res call(
      {List<FeedbackDto> good,
      List<FeedbackDto> caution,
      List<ActionDto> action});
}

/// @nodoc
class _$FeedbackGroupDtoCopyWithImpl<$Res, $Val extends FeedbackGroupDto>
    implements $FeedbackGroupDtoCopyWith<$Res> {
  _$FeedbackGroupDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackGroupDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? good = null,
    Object? caution = null,
    Object? action = null,
  }) {
    return _then(_value.copyWith(
      good: null == good
          ? _value.good
          : good // ignore: cast_nullable_to_non_nullable
              as List<FeedbackDto>,
      caution: null == caution
          ? _value.caution
          : caution // ignore: cast_nullable_to_non_nullable
              as List<FeedbackDto>,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as List<ActionDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedbackGroupDtoImplCopyWith<$Res>
    implements $FeedbackGroupDtoCopyWith<$Res> {
  factory _$$FeedbackGroupDtoImplCopyWith(_$FeedbackGroupDtoImpl value,
          $Res Function(_$FeedbackGroupDtoImpl) then) =
      __$$FeedbackGroupDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<FeedbackDto> good,
      List<FeedbackDto> caution,
      List<ActionDto> action});
}

/// @nodoc
class __$$FeedbackGroupDtoImplCopyWithImpl<$Res>
    extends _$FeedbackGroupDtoCopyWithImpl<$Res, _$FeedbackGroupDtoImpl>
    implements _$$FeedbackGroupDtoImplCopyWith<$Res> {
  __$$FeedbackGroupDtoImplCopyWithImpl(_$FeedbackGroupDtoImpl _value,
      $Res Function(_$FeedbackGroupDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedbackGroupDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? good = null,
    Object? caution = null,
    Object? action = null,
  }) {
    return _then(_$FeedbackGroupDtoImpl(
      good: null == good
          ? _value._good
          : good // ignore: cast_nullable_to_non_nullable
              as List<FeedbackDto>,
      caution: null == caution
          ? _value._caution
          : caution // ignore: cast_nullable_to_non_nullable
              as List<FeedbackDto>,
      action: null == action
          ? _value._action
          : action // ignore: cast_nullable_to_non_nullable
              as List<ActionDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackGroupDtoImpl implements _FeedbackGroupDto {
  const _$FeedbackGroupDtoImpl(
      {final List<FeedbackDto> good = const <FeedbackDto>[],
      final List<FeedbackDto> caution = const <FeedbackDto>[],
      final List<ActionDto> action = const <ActionDto>[]})
      : _good = good,
        _caution = caution,
        _action = action;

  factory _$FeedbackGroupDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackGroupDtoImplFromJson(json);

  final List<FeedbackDto> _good;
  @override
  @JsonKey()
  List<FeedbackDto> get good {
    if (_good is EqualUnmodifiableListView) return _good;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_good);
  }

  final List<FeedbackDto> _caution;
  @override
  @JsonKey()
  List<FeedbackDto> get caution {
    if (_caution is EqualUnmodifiableListView) return _caution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_caution);
  }

  final List<ActionDto> _action;
  @override
  @JsonKey()
  List<ActionDto> get action {
    if (_action is EqualUnmodifiableListView) return _action;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_action);
  }

  @override
  String toString() {
    return 'FeedbackGroupDto(good: $good, caution: $caution, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackGroupDtoImpl &&
            const DeepCollectionEquality().equals(other._good, _good) &&
            const DeepCollectionEquality().equals(other._caution, _caution) &&
            const DeepCollectionEquality().equals(other._action, _action));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_good),
      const DeepCollectionEquality().hash(_caution),
      const DeepCollectionEquality().hash(_action));

  /// Create a copy of FeedbackGroupDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackGroupDtoImplCopyWith<_$FeedbackGroupDtoImpl> get copyWith =>
      __$$FeedbackGroupDtoImplCopyWithImpl<_$FeedbackGroupDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackGroupDtoImplToJson(
      this,
    );
  }
}

abstract class _FeedbackGroupDto implements FeedbackGroupDto {
  const factory _FeedbackGroupDto(
      {final List<FeedbackDto> good,
      final List<FeedbackDto> caution,
      final List<ActionDto> action}) = _$FeedbackGroupDtoImpl;

  factory _FeedbackGroupDto.fromJson(Map<String, dynamic> json) =
      _$FeedbackGroupDtoImpl.fromJson;

  @override
  List<FeedbackDto> get good;
  @override
  List<FeedbackDto> get caution;
  @override
  List<ActionDto> get action;

  /// Create a copy of FeedbackGroupDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackGroupDtoImplCopyWith<_$FeedbackGroupDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateAnalysisDto _$PlateAnalysisDtoFromJson(Map<String, dynamic> json) {
  return _PlateAnalysisDto.fromJson(json);
}

/// @nodoc
mixin _$PlateAnalysisDto {
  String get analysisToken => throw _privateConstructorUsedError;
  int get skinAnalysisId => throw _privateConstructorUsedError;

  /// 어느 날 피부로 계산했는지. 신규 필드라 옛 응답에는 키가 없다.
  ///
  /// **분석(`/plates/analyze`)의 `TODAY` 는 오늘이고, 저장된 기록의 `TODAY` 는
  /// 그 기록을 저장한 날이다.** 서버가 저장 시점에 굳혀 두기 때문에 8/15 기록을
  /// 8/17 에 열어도 `TODAY` 가 온다 — 화면 문구가 갈리는 이유가 이것이다.
  String? get skinBasis => throw _privateConstructorUsedError;
  DateTime? get skinMeasuredAt => throw _privateConstructorUsedError;
  int get plateScore => throw _privateConstructorUsedError;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  String? get grade => throw _privateConstructorUsedError;
  int get baseScore => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  FoodAnalysisDto get food => throw _privateConstructorUsedError;
  FeedbackGroupDto get feedbacks => throw _privateConstructorUsedError;
  List<String> get appliedRules => throw _privateConstructorUsedError;

  /// Serializes this PlateAnalysisDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateAnalysisDtoCopyWith<PlateAnalysisDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateAnalysisDtoCopyWith<$Res> {
  factory $PlateAnalysisDtoCopyWith(
          PlateAnalysisDto value, $Res Function(PlateAnalysisDto) then) =
      _$PlateAnalysisDtoCopyWithImpl<$Res, PlateAnalysisDto>;
  @useResult
  $Res call(
      {String analysisToken,
      int skinAnalysisId,
      String? skinBasis,
      DateTime? skinMeasuredAt,
      int plateScore,
      String? grade,
      int baseScore,
      String summary,
      FoodAnalysisDto food,
      FeedbackGroupDto feedbacks,
      List<String> appliedRules});

  $FoodAnalysisDtoCopyWith<$Res> get food;
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks;
}

/// @nodoc
class _$PlateAnalysisDtoCopyWithImpl<$Res, $Val extends PlateAnalysisDto>
    implements $PlateAnalysisDtoCopyWith<$Res> {
  _$PlateAnalysisDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analysisToken = null,
    Object? skinAnalysisId = null,
    Object? skinBasis = freezed,
    Object? skinMeasuredAt = freezed,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? baseScore = null,
    Object? summary = null,
    Object? food = null,
    Object? feedbacks = null,
    Object? appliedRules = null,
  }) {
    return _then(_value.copyWith(
      analysisToken: null == analysisToken
          ? _value.analysisToken
          : analysisToken // ignore: cast_nullable_to_non_nullable
              as String,
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinBasis: freezed == skinBasis
          ? _value.skinBasis
          : skinBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      skinMeasuredAt: freezed == skinMeasuredAt
          ? _value.skinMeasuredAt
          : skinMeasuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      baseScore: null == baseScore
          ? _value.baseScore
          : baseScore // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as FoodAnalysisDto,
      feedbacks: null == feedbacks
          ? _value.feedbacks
          : feedbacks // ignore: cast_nullable_to_non_nullable
              as FeedbackGroupDto,
      appliedRules: null == appliedRules
          ? _value.appliedRules
          : appliedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodAnalysisDtoCopyWith<$Res> get food {
    return $FoodAnalysisDtoCopyWith<$Res>(_value.food, (value) {
      return _then(_value.copyWith(food: value) as $Val);
    });
  }

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks {
    return $FeedbackGroupDtoCopyWith<$Res>(_value.feedbacks, (value) {
      return _then(_value.copyWith(feedbacks: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlateAnalysisDtoImplCopyWith<$Res>
    implements $PlateAnalysisDtoCopyWith<$Res> {
  factory _$$PlateAnalysisDtoImplCopyWith(_$PlateAnalysisDtoImpl value,
          $Res Function(_$PlateAnalysisDtoImpl) then) =
      __$$PlateAnalysisDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String analysisToken,
      int skinAnalysisId,
      String? skinBasis,
      DateTime? skinMeasuredAt,
      int plateScore,
      String? grade,
      int baseScore,
      String summary,
      FoodAnalysisDto food,
      FeedbackGroupDto feedbacks,
      List<String> appliedRules});

  @override
  $FoodAnalysisDtoCopyWith<$Res> get food;
  @override
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks;
}

/// @nodoc
class __$$PlateAnalysisDtoImplCopyWithImpl<$Res>
    extends _$PlateAnalysisDtoCopyWithImpl<$Res, _$PlateAnalysisDtoImpl>
    implements _$$PlateAnalysisDtoImplCopyWith<$Res> {
  __$$PlateAnalysisDtoImplCopyWithImpl(_$PlateAnalysisDtoImpl _value,
      $Res Function(_$PlateAnalysisDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analysisToken = null,
    Object? skinAnalysisId = null,
    Object? skinBasis = freezed,
    Object? skinMeasuredAt = freezed,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? baseScore = null,
    Object? summary = null,
    Object? food = null,
    Object? feedbacks = null,
    Object? appliedRules = null,
  }) {
    return _then(_$PlateAnalysisDtoImpl(
      analysisToken: null == analysisToken
          ? _value.analysisToken
          : analysisToken // ignore: cast_nullable_to_non_nullable
              as String,
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinBasis: freezed == skinBasis
          ? _value.skinBasis
          : skinBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      skinMeasuredAt: freezed == skinMeasuredAt
          ? _value.skinMeasuredAt
          : skinMeasuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      baseScore: null == baseScore
          ? _value.baseScore
          : baseScore // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as FoodAnalysisDto,
      feedbacks: null == feedbacks
          ? _value.feedbacks
          : feedbacks // ignore: cast_nullable_to_non_nullable
              as FeedbackGroupDto,
      appliedRules: null == appliedRules
          ? _value._appliedRules
          : appliedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateAnalysisDtoImpl implements _PlateAnalysisDto {
  const _$PlateAnalysisDtoImpl(
      {required this.analysisToken,
      required this.skinAnalysisId,
      this.skinBasis,
      this.skinMeasuredAt,
      required this.plateScore,
      this.grade,
      this.baseScore = 70,
      this.summary = '',
      required this.food,
      required this.feedbacks,
      final List<String> appliedRules = const <String>[]})
      : _appliedRules = appliedRules;

  factory _$PlateAnalysisDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateAnalysisDtoImplFromJson(json);

  @override
  final String analysisToken;
  @override
  final int skinAnalysisId;

  /// 어느 날 피부로 계산했는지. 신규 필드라 옛 응답에는 키가 없다.
  ///
  /// **분석(`/plates/analyze`)의 `TODAY` 는 오늘이고, 저장된 기록의 `TODAY` 는
  /// 그 기록을 저장한 날이다.** 서버가 저장 시점에 굳혀 두기 때문에 8/15 기록을
  /// 8/17 에 열어도 `TODAY` 가 온다 — 화면 문구가 갈리는 이유가 이것이다.
  @override
  final String? skinBasis;
  @override
  final DateTime? skinMeasuredAt;
  @override
  final int plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  @override
  final String? grade;
  @override
  @JsonKey()
  final int baseScore;
  @override
  @JsonKey()
  final String summary;
  @override
  final FoodAnalysisDto food;
  @override
  final FeedbackGroupDto feedbacks;
  final List<String> _appliedRules;
  @override
  @JsonKey()
  List<String> get appliedRules {
    if (_appliedRules is EqualUnmodifiableListView) return _appliedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appliedRules);
  }

  @override
  String toString() {
    return 'PlateAnalysisDto(analysisToken: $analysisToken, skinAnalysisId: $skinAnalysisId, skinBasis: $skinBasis, skinMeasuredAt: $skinMeasuredAt, plateScore: $plateScore, grade: $grade, baseScore: $baseScore, summary: $summary, food: $food, feedbacks: $feedbacks, appliedRules: $appliedRules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateAnalysisDtoImpl &&
            (identical(other.analysisToken, analysisToken) ||
                other.analysisToken == analysisToken) &&
            (identical(other.skinAnalysisId, skinAnalysisId) ||
                other.skinAnalysisId == skinAnalysisId) &&
            (identical(other.skinBasis, skinBasis) ||
                other.skinBasis == skinBasis) &&
            (identical(other.skinMeasuredAt, skinMeasuredAt) ||
                other.skinMeasuredAt == skinMeasuredAt) &&
            (identical(other.plateScore, plateScore) ||
                other.plateScore == plateScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.baseScore, baseScore) ||
                other.baseScore == baseScore) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.food, food) || other.food == food) &&
            (identical(other.feedbacks, feedbacks) ||
                other.feedbacks == feedbacks) &&
            const DeepCollectionEquality()
                .equals(other._appliedRules, _appliedRules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      analysisToken,
      skinAnalysisId,
      skinBasis,
      skinMeasuredAt,
      plateScore,
      grade,
      baseScore,
      summary,
      food,
      feedbacks,
      const DeepCollectionEquality().hash(_appliedRules));

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateAnalysisDtoImplCopyWith<_$PlateAnalysisDtoImpl> get copyWith =>
      __$$PlateAnalysisDtoImplCopyWithImpl<_$PlateAnalysisDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateAnalysisDtoImplToJson(
      this,
    );
  }
}

abstract class _PlateAnalysisDto implements PlateAnalysisDto {
  const factory _PlateAnalysisDto(
      {required final String analysisToken,
      required final int skinAnalysisId,
      final String? skinBasis,
      final DateTime? skinMeasuredAt,
      required final int plateScore,
      final String? grade,
      final int baseScore,
      final String summary,
      required final FoodAnalysisDto food,
      required final FeedbackGroupDto feedbacks,
      final List<String> appliedRules}) = _$PlateAnalysisDtoImpl;

  factory _PlateAnalysisDto.fromJson(Map<String, dynamic> json) =
      _$PlateAnalysisDtoImpl.fromJson;

  @override
  String get analysisToken;
  @override
  int get skinAnalysisId;

  /// 어느 날 피부로 계산했는지. 신규 필드라 옛 응답에는 키가 없다.
  ///
  /// **분석(`/plates/analyze`)의 `TODAY` 는 오늘이고, 저장된 기록의 `TODAY` 는
  /// 그 기록을 저장한 날이다.** 서버가 저장 시점에 굳혀 두기 때문에 8/15 기록을
  /// 8/17 에 열어도 `TODAY` 가 온다 — 화면 문구가 갈리는 이유가 이것이다.
  @override
  String? get skinBasis;
  @override
  DateTime? get skinMeasuredAt;
  @override
  int get plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  @override
  String? get grade;
  @override
  int get baseScore;
  @override
  String get summary;
  @override
  FoodAnalysisDto get food;
  @override
  FeedbackGroupDto get feedbacks;
  @override
  List<String> get appliedRules;

  /// Create a copy of PlateAnalysisDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateAnalysisDtoImplCopyWith<_$PlateAnalysisDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkinPlateDto _$SkinPlateDtoFromJson(Map<String, dynamic> json) {
  return _SkinPlateDto.fromJson(json);
}

/// @nodoc
mixin _$SkinPlateDto {
  int get plateId => throw _privateConstructorUsedError;

  /// S07 에서 S08 추천으로 넘어갈 때 필요하다. 추천 조회가 이 값을 요구한다.
  /// 앱이 "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때 엉뚱한 날짜의
  /// 추천이 뜬다. 서버가 응답에 실어 준다.
  int get skinAnalysisId => throw _privateConstructorUsedError;

  /// 이 기록을 **저장한 날**의 피부인지. [PlateAnalysisDto.skinBasis] 참고 —
  /// 여기서의 `TODAY` 는 "오늘"이 아니라 "기록 당일"이다.
  String? get skinBasis => throw _privateConstructorUsedError;
  DateTime? get skinMeasuredAt => throw _privateConstructorUsedError;
  int get plateScore => throw _privateConstructorUsedError;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  String? get grade => throw _privateConstructorUsedError;
  int get baseScore => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  FoodAnalysisDto get food => throw _privateConstructorUsedError;
  FeedbackGroupDto get feedbacks => throw _privateConstructorUsedError;
  List<String> get appliedRules => throw _privateConstructorUsedError;

  /// "AI 맞춤 TIP". 생성 실패 시 서버가 키를 뺀다 — 그때 앱은 카드를 그리지
  /// 않는다. 룰 요약(summary)으로 메우지 마라. [PlateAnalysisDto] 에는 이 필드가
  /// 아예 없어서, 폴백을 두면 저장 전후로 같은 카드의 문장이 갈린다.
  String? get aiTip => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SkinPlateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkinPlateDtoCopyWith<SkinPlateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkinPlateDtoCopyWith<$Res> {
  factory $SkinPlateDtoCopyWith(
          SkinPlateDto value, $Res Function(SkinPlateDto) then) =
      _$SkinPlateDtoCopyWithImpl<$Res, SkinPlateDto>;
  @useResult
  $Res call(
      {int plateId,
      int skinAnalysisId,
      String? skinBasis,
      DateTime? skinMeasuredAt,
      int plateScore,
      String? grade,
      int baseScore,
      String summary,
      FoodAnalysisDto food,
      FeedbackGroupDto feedbacks,
      List<String> appliedRules,
      String? aiTip,
      DateTime createdAt});

  $FoodAnalysisDtoCopyWith<$Res> get food;
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks;
}

/// @nodoc
class _$SkinPlateDtoCopyWithImpl<$Res, $Val extends SkinPlateDto>
    implements $SkinPlateDtoCopyWith<$Res> {
  _$SkinPlateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plateId = null,
    Object? skinAnalysisId = null,
    Object? skinBasis = freezed,
    Object? skinMeasuredAt = freezed,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? baseScore = null,
    Object? summary = null,
    Object? food = null,
    Object? feedbacks = null,
    Object? appliedRules = null,
    Object? aiTip = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      plateId: null == plateId
          ? _value.plateId
          : plateId // ignore: cast_nullable_to_non_nullable
              as int,
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinBasis: freezed == skinBasis
          ? _value.skinBasis
          : skinBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      skinMeasuredAt: freezed == skinMeasuredAt
          ? _value.skinMeasuredAt
          : skinMeasuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      baseScore: null == baseScore
          ? _value.baseScore
          : baseScore // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as FoodAnalysisDto,
      feedbacks: null == feedbacks
          ? _value.feedbacks
          : feedbacks // ignore: cast_nullable_to_non_nullable
              as FeedbackGroupDto,
      appliedRules: null == appliedRules
          ? _value.appliedRules
          : appliedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aiTip: freezed == aiTip
          ? _value.aiTip
          : aiTip // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodAnalysisDtoCopyWith<$Res> get food {
    return $FoodAnalysisDtoCopyWith<$Res>(_value.food, (value) {
      return _then(_value.copyWith(food: value) as $Val);
    });
  }

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks {
    return $FeedbackGroupDtoCopyWith<$Res>(_value.feedbacks, (value) {
      return _then(_value.copyWith(feedbacks: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SkinPlateDtoImplCopyWith<$Res>
    implements $SkinPlateDtoCopyWith<$Res> {
  factory _$$SkinPlateDtoImplCopyWith(
          _$SkinPlateDtoImpl value, $Res Function(_$SkinPlateDtoImpl) then) =
      __$$SkinPlateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int plateId,
      int skinAnalysisId,
      String? skinBasis,
      DateTime? skinMeasuredAt,
      int plateScore,
      String? grade,
      int baseScore,
      String summary,
      FoodAnalysisDto food,
      FeedbackGroupDto feedbacks,
      List<String> appliedRules,
      String? aiTip,
      DateTime createdAt});

  @override
  $FoodAnalysisDtoCopyWith<$Res> get food;
  @override
  $FeedbackGroupDtoCopyWith<$Res> get feedbacks;
}

/// @nodoc
class __$$SkinPlateDtoImplCopyWithImpl<$Res>
    extends _$SkinPlateDtoCopyWithImpl<$Res, _$SkinPlateDtoImpl>
    implements _$$SkinPlateDtoImplCopyWith<$Res> {
  __$$SkinPlateDtoImplCopyWithImpl(
      _$SkinPlateDtoImpl _value, $Res Function(_$SkinPlateDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plateId = null,
    Object? skinAnalysisId = null,
    Object? skinBasis = freezed,
    Object? skinMeasuredAt = freezed,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? baseScore = null,
    Object? summary = null,
    Object? food = null,
    Object? feedbacks = null,
    Object? appliedRules = null,
    Object? aiTip = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$SkinPlateDtoImpl(
      plateId: null == plateId
          ? _value.plateId
          : plateId // ignore: cast_nullable_to_non_nullable
              as int,
      skinAnalysisId: null == skinAnalysisId
          ? _value.skinAnalysisId
          : skinAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      skinBasis: freezed == skinBasis
          ? _value.skinBasis
          : skinBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      skinMeasuredAt: freezed == skinMeasuredAt
          ? _value.skinMeasuredAt
          : skinMeasuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      baseScore: null == baseScore
          ? _value.baseScore
          : baseScore // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as FoodAnalysisDto,
      feedbacks: null == feedbacks
          ? _value.feedbacks
          : feedbacks // ignore: cast_nullable_to_non_nullable
              as FeedbackGroupDto,
      appliedRules: null == appliedRules
          ? _value._appliedRules
          : appliedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aiTip: freezed == aiTip
          ? _value.aiTip
          : aiTip // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkinPlateDtoImpl implements _SkinPlateDto {
  const _$SkinPlateDtoImpl(
      {required this.plateId,
      required this.skinAnalysisId,
      this.skinBasis,
      this.skinMeasuredAt,
      required this.plateScore,
      this.grade,
      this.baseScore = 70,
      this.summary = '',
      required this.food,
      required this.feedbacks,
      final List<String> appliedRules = const <String>[],
      this.aiTip,
      required this.createdAt})
      : _appliedRules = appliedRules;

  factory _$SkinPlateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkinPlateDtoImplFromJson(json);

  @override
  final int plateId;

  /// S07 에서 S08 추천으로 넘어갈 때 필요하다. 추천 조회가 이 값을 요구한다.
  /// 앱이 "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때 엉뚱한 날짜의
  /// 추천이 뜬다. 서버가 응답에 실어 준다.
  @override
  final int skinAnalysisId;

  /// 이 기록을 **저장한 날**의 피부인지. [PlateAnalysisDto.skinBasis] 참고 —
  /// 여기서의 `TODAY` 는 "오늘"이 아니라 "기록 당일"이다.
  @override
  final String? skinBasis;
  @override
  final DateTime? skinMeasuredAt;
  @override
  final int plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  @override
  final String? grade;
  @override
  @JsonKey()
  final int baseScore;
  @override
  @JsonKey()
  final String summary;
  @override
  final FoodAnalysisDto food;
  @override
  final FeedbackGroupDto feedbacks;
  final List<String> _appliedRules;
  @override
  @JsonKey()
  List<String> get appliedRules {
    if (_appliedRules is EqualUnmodifiableListView) return _appliedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appliedRules);
  }

  /// "AI 맞춤 TIP". 생성 실패 시 서버가 키를 뺀다 — 그때 앱은 카드를 그리지
  /// 않는다. 룰 요약(summary)으로 메우지 마라. [PlateAnalysisDto] 에는 이 필드가
  /// 아예 없어서, 폴백을 두면 저장 전후로 같은 카드의 문장이 갈린다.
  @override
  final String? aiTip;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SkinPlateDto(plateId: $plateId, skinAnalysisId: $skinAnalysisId, skinBasis: $skinBasis, skinMeasuredAt: $skinMeasuredAt, plateScore: $plateScore, grade: $grade, baseScore: $baseScore, summary: $summary, food: $food, feedbacks: $feedbacks, appliedRules: $appliedRules, aiTip: $aiTip, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkinPlateDtoImpl &&
            (identical(other.plateId, plateId) || other.plateId == plateId) &&
            (identical(other.skinAnalysisId, skinAnalysisId) ||
                other.skinAnalysisId == skinAnalysisId) &&
            (identical(other.skinBasis, skinBasis) ||
                other.skinBasis == skinBasis) &&
            (identical(other.skinMeasuredAt, skinMeasuredAt) ||
                other.skinMeasuredAt == skinMeasuredAt) &&
            (identical(other.plateScore, plateScore) ||
                other.plateScore == plateScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.baseScore, baseScore) ||
                other.baseScore == baseScore) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.food, food) || other.food == food) &&
            (identical(other.feedbacks, feedbacks) ||
                other.feedbacks == feedbacks) &&
            const DeepCollectionEquality()
                .equals(other._appliedRules, _appliedRules) &&
            (identical(other.aiTip, aiTip) || other.aiTip == aiTip) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      plateId,
      skinAnalysisId,
      skinBasis,
      skinMeasuredAt,
      plateScore,
      grade,
      baseScore,
      summary,
      food,
      feedbacks,
      const DeepCollectionEquality().hash(_appliedRules),
      aiTip,
      createdAt);

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkinPlateDtoImplCopyWith<_$SkinPlateDtoImpl> get copyWith =>
      __$$SkinPlateDtoImplCopyWithImpl<_$SkinPlateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkinPlateDtoImplToJson(
      this,
    );
  }
}

abstract class _SkinPlateDto implements SkinPlateDto {
  const factory _SkinPlateDto(
      {required final int plateId,
      required final int skinAnalysisId,
      final String? skinBasis,
      final DateTime? skinMeasuredAt,
      required final int plateScore,
      final String? grade,
      final int baseScore,
      final String summary,
      required final FoodAnalysisDto food,
      required final FeedbackGroupDto feedbacks,
      final List<String> appliedRules,
      final String? aiTip,
      required final DateTime createdAt}) = _$SkinPlateDtoImpl;

  factory _SkinPlateDto.fromJson(Map<String, dynamic> json) =
      _$SkinPlateDtoImpl.fromJson;

  @override
  int get plateId;

  /// S07 에서 S08 추천으로 넘어갈 때 필요하다. 추천 조회가 이 값을 요구한다.
  /// 앱이 "최신 피부 분석"을 대신 쓰면 과거 Plate 를 열었을 때 엉뚱한 날짜의
  /// 추천이 뜬다. 서버가 응답에 실어 준다.
  @override
  int get skinAnalysisId;

  /// 이 기록을 **저장한 날**의 피부인지. [PlateAnalysisDto.skinBasis] 참고 —
  /// 여기서의 `TODAY` 는 "오늘"이 아니라 "기록 당일"이다.
  @override
  String? get skinBasis;
  @override
  DateTime? get skinMeasuredAt;
  @override
  int get plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱에 경계표를 두지 않는다.
  /// 이 필드가 없던 서버와 붙으면 null 이고, 화면은 배지를 비운다.
  @override
  String? get grade;
  @override
  int get baseScore;
  @override
  String get summary;
  @override
  FoodAnalysisDto get food;
  @override
  FeedbackGroupDto get feedbacks;
  @override
  List<String> get appliedRules;

  /// "AI 맞춤 TIP". 생성 실패 시 서버가 키를 뺀다 — 그때 앱은 카드를 그리지
  /// 않는다. 룰 요약(summary)으로 메우지 마라. [PlateAnalysisDto] 에는 이 필드가
  /// 아예 없어서, 폴백을 두면 저장 전후로 같은 카드의 문장이 갈린다.
  @override
  String? get aiTip;
  @override
  DateTime get createdAt;

  /// Create a copy of SkinPlateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkinPlateDtoImplCopyWith<_$SkinPlateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateHistoryItemDto _$PlateHistoryItemDtoFromJson(Map<String, dynamic> json) {
  return _PlateHistoryItemDto.fromJson(json);
}

/// @nodoc
mixin _$PlateHistoryItemDto {
  int get plateId => throw _privateConstructorUsedError;
  String get foodName => throw _privateConstructorUsedError;
  int get plateScore => throw _privateConstructorUsedError;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱이 점수에서 다시 내면
  /// 경계표가 두 벌이 되고, 서버가 경계를 옮긴 날 한쪽만 따라간다.
  /// 모르는 값이면 null 이고 화면은 배지를 비운다.
  String? get grade => throw _privateConstructorUsedError;

  /// 서버가 시각에서 파생해 보낸다. 모르는 값이면 화면이 배지를 비운다.
  String? get mealType => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// 이 끼니에서 눈에 띄는 항목 두세 개("나트륨" · "단백질").
  ///
  /// **서버가 고른다.** 앱이 고르려면 목록에 영양값 전체를 실어야 하고, 그러면
  /// "얼마부터 높은가"가 앱에도 한 벌 생긴다. 걸리는 항목이 없는 평범한 끼니는
  /// 빈 배열이고, 이 필드가 생기기 전 서버와 붙어도 기본값이 빈 배열이라 안전하다.
  List<String> get highlightTags => throw _privateConstructorUsedError;

  /// Serializes this PlateHistoryItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlateHistoryItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateHistoryItemDtoCopyWith<PlateHistoryItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateHistoryItemDtoCopyWith<$Res> {
  factory $PlateHistoryItemDtoCopyWith(
          PlateHistoryItemDto value, $Res Function(PlateHistoryItemDto) then) =
      _$PlateHistoryItemDtoCopyWithImpl<$Res, PlateHistoryItemDto>;
  @useResult
  $Res call(
      {int plateId,
      String foodName,
      int plateScore,
      String? grade,
      String? mealType,
      DateTime recordedAt,
      List<String> highlightTags});
}

/// @nodoc
class _$PlateHistoryItemDtoCopyWithImpl<$Res, $Val extends PlateHistoryItemDto>
    implements $PlateHistoryItemDtoCopyWith<$Res> {
  _$PlateHistoryItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateHistoryItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plateId = null,
    Object? foodName = null,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? mealType = freezed,
    Object? recordedAt = null,
    Object? highlightTags = null,
  }) {
    return _then(_value.copyWith(
      plateId: null == plateId
          ? _value.plateId
          : plateId // ignore: cast_nullable_to_non_nullable
              as int,
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      mealType: freezed == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as String?,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      highlightTags: null == highlightTags
          ? _value.highlightTags
          : highlightTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateHistoryItemDtoImplCopyWith<$Res>
    implements $PlateHistoryItemDtoCopyWith<$Res> {
  factory _$$PlateHistoryItemDtoImplCopyWith(_$PlateHistoryItemDtoImpl value,
          $Res Function(_$PlateHistoryItemDtoImpl) then) =
      __$$PlateHistoryItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int plateId,
      String foodName,
      int plateScore,
      String? grade,
      String? mealType,
      DateTime recordedAt,
      List<String> highlightTags});
}

/// @nodoc
class __$$PlateHistoryItemDtoImplCopyWithImpl<$Res>
    extends _$PlateHistoryItemDtoCopyWithImpl<$Res, _$PlateHistoryItemDtoImpl>
    implements _$$PlateHistoryItemDtoImplCopyWith<$Res> {
  __$$PlateHistoryItemDtoImplCopyWithImpl(_$PlateHistoryItemDtoImpl _value,
      $Res Function(_$PlateHistoryItemDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlateHistoryItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plateId = null,
    Object? foodName = null,
    Object? plateScore = null,
    Object? grade = freezed,
    Object? mealType = freezed,
    Object? recordedAt = null,
    Object? highlightTags = null,
  }) {
    return _then(_$PlateHistoryItemDtoImpl(
      plateId: null == plateId
          ? _value.plateId
          : plateId // ignore: cast_nullable_to_non_nullable
              as int,
      foodName: null == foodName
          ? _value.foodName
          : foodName // ignore: cast_nullable_to_non_nullable
              as String,
      plateScore: null == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      mealType: freezed == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as String?,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      highlightTags: null == highlightTags
          ? _value._highlightTags
          : highlightTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateHistoryItemDtoImpl implements _PlateHistoryItemDto {
  const _$PlateHistoryItemDtoImpl(
      {required this.plateId,
      required this.foodName,
      this.plateScore = 0,
      this.grade,
      this.mealType,
      required this.recordedAt,
      final List<String> highlightTags = const <String>[]})
      : _highlightTags = highlightTags;

  factory _$PlateHistoryItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateHistoryItemDtoImplFromJson(json);

  @override
  final int plateId;
  @override
  final String foodName;
  @override
  @JsonKey()
  final int plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱이 점수에서 다시 내면
  /// 경계표가 두 벌이 되고, 서버가 경계를 옮긴 날 한쪽만 따라간다.
  /// 모르는 값이면 null 이고 화면은 배지를 비운다.
  @override
  final String? grade;

  /// 서버가 시각에서 파생해 보낸다. 모르는 값이면 화면이 배지를 비운다.
  @override
  final String? mealType;
  @override
  final DateTime recordedAt;

  /// 이 끼니에서 눈에 띄는 항목 두세 개("나트륨" · "단백질").
  ///
  /// **서버가 고른다.** 앱이 고르려면 목록에 영양값 전체를 실어야 하고, 그러면
  /// "얼마부터 높은가"가 앱에도 한 벌 생긴다. 걸리는 항목이 없는 평범한 끼니는
  /// 빈 배열이고, 이 필드가 생기기 전 서버와 붙어도 기본값이 빈 배열이라 안전하다.
  final List<String> _highlightTags;

  /// 이 끼니에서 눈에 띄는 항목 두세 개("나트륨" · "단백질").
  ///
  /// **서버가 고른다.** 앱이 고르려면 목록에 영양값 전체를 실어야 하고, 그러면
  /// "얼마부터 높은가"가 앱에도 한 벌 생긴다. 걸리는 항목이 없는 평범한 끼니는
  /// 빈 배열이고, 이 필드가 생기기 전 서버와 붙어도 기본값이 빈 배열이라 안전하다.
  @override
  @JsonKey()
  List<String> get highlightTags {
    if (_highlightTags is EqualUnmodifiableListView) return _highlightTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlightTags);
  }

  @override
  String toString() {
    return 'PlateHistoryItemDto(plateId: $plateId, foodName: $foodName, plateScore: $plateScore, grade: $grade, mealType: $mealType, recordedAt: $recordedAt, highlightTags: $highlightTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateHistoryItemDtoImpl &&
            (identical(other.plateId, plateId) || other.plateId == plateId) &&
            (identical(other.foodName, foodName) ||
                other.foodName == foodName) &&
            (identical(other.plateScore, plateScore) ||
                other.plateScore == plateScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            const DeepCollectionEquality()
                .equals(other._highlightTags, _highlightTags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      plateId,
      foodName,
      plateScore,
      grade,
      mealType,
      recordedAt,
      const DeepCollectionEquality().hash(_highlightTags));

  /// Create a copy of PlateHistoryItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateHistoryItemDtoImplCopyWith<_$PlateHistoryItemDtoImpl> get copyWith =>
      __$$PlateHistoryItemDtoImplCopyWithImpl<_$PlateHistoryItemDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateHistoryItemDtoImplToJson(
      this,
    );
  }
}

abstract class _PlateHistoryItemDto implements PlateHistoryItemDto {
  const factory _PlateHistoryItemDto(
      {required final int plateId,
      required final String foodName,
      final int plateScore,
      final String? grade,
      final String? mealType,
      required final DateTime recordedAt,
      final List<String> highlightTags}) = _$PlateHistoryItemDtoImpl;

  factory _PlateHistoryItemDto.fromJson(Map<String, dynamic> json) =
      _$PlateHistoryItemDtoImpl.fromJson;

  @override
  int get plateId;
  @override
  String get foodName;
  @override
  int get plateScore;

  /// [plateScore] 의 등급. **서버가 매겨서 보낸다** — 앱이 점수에서 다시 내면
  /// 경계표가 두 벌이 되고, 서버가 경계를 옮긴 날 한쪽만 따라간다.
  /// 모르는 값이면 null 이고 화면은 배지를 비운다.
  @override
  String? get grade;

  /// 서버가 시각에서 파생해 보낸다. 모르는 값이면 화면이 배지를 비운다.
  @override
  String? get mealType;
  @override
  DateTime get recordedAt;

  /// 이 끼니에서 눈에 띄는 항목 두세 개("나트륨" · "단백질").
  ///
  /// **서버가 고른다.** 앱이 고르려면 목록에 영양값 전체를 실어야 하고, 그러면
  /// "얼마부터 높은가"가 앱에도 한 벌 생긴다. 걸리는 항목이 없는 평범한 끼니는
  /// 빈 배열이고, 이 필드가 생기기 전 서버와 붙어도 기본값이 빈 배열이라 안전하다.
  @override
  List<String> get highlightTags;

  /// Create a copy of PlateHistoryItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateHistoryItemDtoImplCopyWith<_$PlateHistoryItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateHistoryDayDto _$PlateHistoryDayDtoFromJson(Map<String, dynamic> json) {
  return _PlateHistoryDayDto.fromJson(json);
}

/// @nodoc
mixin _$PlateHistoryDayDto {
  DateTime get date => throw _privateConstructorUsedError;

  /// **정상 응답에는 항상 온다.** 그날 얼굴을 안 찍었어도 서버가 그날 첫 기록의
  /// 채점 기준 분석 점수로 채운다(`PlateHistoryService`). 계약상 nullable 이라
  /// 그대로 열어 두는 것이지, 비는 날이 있어서가 아니다.
  int? get skinScore => throw _privateConstructorUsedError;

  /// 그날 기록들의 평균. 서버가 계산해서 준다.
  ///
  /// 서버 쪽 타입이 primitive `int` 라 이 키는 생략될 수 없고, 기록이 하나도
  /// 없는 날은 `days` 에 아예 안 들어온다. nullable 은 방어다.
  ///
  /// **그래도 기본값을 두지 않는다.** 0 으로 떨어뜨리면 홈이 "0점 · 주의" 를
  /// 그리는데, 0점은 "아주 나쁘게 먹었다"로 읽힌다 — 아직 안 먹은 것과 다른
  /// 상태다. null 이어야 카드가 시안대로 `OO점` 으로 빠진다.
  int? get plateScore => throw _privateConstructorUsedError;

  /// [plateScore] 의 등급. 서버가 매긴다 — 홈 히어로 배지가 이 값을 쓴다.
  String? get grade => throw _privateConstructorUsedError;

  /// 시안의 "목표 80점". **값은 서버가 정한다** — 앱에 80 을 박지 않는다.
  /// 지금은 모두에게 같은 상수지만 사용자별 목표가 생기는 날 앱 배포가 필요해진다.
  /// 서버가 안 보내면 목표 막대를 그릴 근거가 없으므로 null 로 둔다.
  int? get targetScore => throw _privateConstructorUsedError;

  /// "오늘의 AI 코멘트". 없으면 서버가 키를 빼고, 앱은 카드를 그리지 않는다.
  String? get aiComment => throw _privateConstructorUsedError;
  List<PlateHistoryItemDto> get plates => throw _privateConstructorUsedError;

  /// Serializes this PlateHistoryDayDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlateHistoryDayDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateHistoryDayDtoCopyWith<PlateHistoryDayDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateHistoryDayDtoCopyWith<$Res> {
  factory $PlateHistoryDayDtoCopyWith(
          PlateHistoryDayDto value, $Res Function(PlateHistoryDayDto) then) =
      _$PlateHistoryDayDtoCopyWithImpl<$Res, PlateHistoryDayDto>;
  @useResult
  $Res call(
      {DateTime date,
      int? skinScore,
      int? plateScore,
      String? grade,
      int? targetScore,
      String? aiComment,
      List<PlateHistoryItemDto> plates});
}

/// @nodoc
class _$PlateHistoryDayDtoCopyWithImpl<$Res, $Val extends PlateHistoryDayDto>
    implements $PlateHistoryDayDtoCopyWith<$Res> {
  _$PlateHistoryDayDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateHistoryDayDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? skinScore = freezed,
    Object? plateScore = freezed,
    Object? grade = freezed,
    Object? targetScore = freezed,
    Object? aiComment = freezed,
    Object? plates = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      skinScore: freezed == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int?,
      plateScore: freezed == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      targetScore: freezed == targetScore
          ? _value.targetScore
          : targetScore // ignore: cast_nullable_to_non_nullable
              as int?,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as String?,
      plates: null == plates
          ? _value.plates
          : plates // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryItemDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateHistoryDayDtoImplCopyWith<$Res>
    implements $PlateHistoryDayDtoCopyWith<$Res> {
  factory _$$PlateHistoryDayDtoImplCopyWith(_$PlateHistoryDayDtoImpl value,
          $Res Function(_$PlateHistoryDayDtoImpl) then) =
      __$$PlateHistoryDayDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int? skinScore,
      int? plateScore,
      String? grade,
      int? targetScore,
      String? aiComment,
      List<PlateHistoryItemDto> plates});
}

/// @nodoc
class __$$PlateHistoryDayDtoImplCopyWithImpl<$Res>
    extends _$PlateHistoryDayDtoCopyWithImpl<$Res, _$PlateHistoryDayDtoImpl>
    implements _$$PlateHistoryDayDtoImplCopyWith<$Res> {
  __$$PlateHistoryDayDtoImplCopyWithImpl(_$PlateHistoryDayDtoImpl _value,
      $Res Function(_$PlateHistoryDayDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlateHistoryDayDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? skinScore = freezed,
    Object? plateScore = freezed,
    Object? grade = freezed,
    Object? targetScore = freezed,
    Object? aiComment = freezed,
    Object? plates = null,
  }) {
    return _then(_$PlateHistoryDayDtoImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      skinScore: freezed == skinScore
          ? _value.skinScore
          : skinScore // ignore: cast_nullable_to_non_nullable
              as int?,
      plateScore: freezed == plateScore
          ? _value.plateScore
          : plateScore // ignore: cast_nullable_to_non_nullable
              as int?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      targetScore: freezed == targetScore
          ? _value.targetScore
          : targetScore // ignore: cast_nullable_to_non_nullable
              as int?,
      aiComment: freezed == aiComment
          ? _value.aiComment
          : aiComment // ignore: cast_nullable_to_non_nullable
              as String?,
      plates: null == plates
          ? _value._plates
          : plates // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryItemDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateHistoryDayDtoImpl implements _PlateHistoryDayDto {
  const _$PlateHistoryDayDtoImpl(
      {required this.date,
      this.skinScore,
      this.plateScore,
      this.grade,
      this.targetScore,
      this.aiComment,
      final List<PlateHistoryItemDto> plates = const <PlateHistoryItemDto>[]})
      : _plates = plates;

  factory _$PlateHistoryDayDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateHistoryDayDtoImplFromJson(json);

  @override
  final DateTime date;

  /// **정상 응답에는 항상 온다.** 그날 얼굴을 안 찍었어도 서버가 그날 첫 기록의
  /// 채점 기준 분석 점수로 채운다(`PlateHistoryService`). 계약상 nullable 이라
  /// 그대로 열어 두는 것이지, 비는 날이 있어서가 아니다.
  @override
  final int? skinScore;

  /// 그날 기록들의 평균. 서버가 계산해서 준다.
  ///
  /// 서버 쪽 타입이 primitive `int` 라 이 키는 생략될 수 없고, 기록이 하나도
  /// 없는 날은 `days` 에 아예 안 들어온다. nullable 은 방어다.
  ///
  /// **그래도 기본값을 두지 않는다.** 0 으로 떨어뜨리면 홈이 "0점 · 주의" 를
  /// 그리는데, 0점은 "아주 나쁘게 먹었다"로 읽힌다 — 아직 안 먹은 것과 다른
  /// 상태다. null 이어야 카드가 시안대로 `OO점` 으로 빠진다.
  @override
  final int? plateScore;

  /// [plateScore] 의 등급. 서버가 매긴다 — 홈 히어로 배지가 이 값을 쓴다.
  @override
  final String? grade;

  /// 시안의 "목표 80점". **값은 서버가 정한다** — 앱에 80 을 박지 않는다.
  /// 지금은 모두에게 같은 상수지만 사용자별 목표가 생기는 날 앱 배포가 필요해진다.
  /// 서버가 안 보내면 목표 막대를 그릴 근거가 없으므로 null 로 둔다.
  @override
  final int? targetScore;

  /// "오늘의 AI 코멘트". 없으면 서버가 키를 빼고, 앱은 카드를 그리지 않는다.
  @override
  final String? aiComment;
  final List<PlateHistoryItemDto> _plates;
  @override
  @JsonKey()
  List<PlateHistoryItemDto> get plates {
    if (_plates is EqualUnmodifiableListView) return _plates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plates);
  }

  @override
  String toString() {
    return 'PlateHistoryDayDto(date: $date, skinScore: $skinScore, plateScore: $plateScore, grade: $grade, targetScore: $targetScore, aiComment: $aiComment, plates: $plates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateHistoryDayDtoImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.skinScore, skinScore) ||
                other.skinScore == skinScore) &&
            (identical(other.plateScore, plateScore) ||
                other.plateScore == plateScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.targetScore, targetScore) ||
                other.targetScore == targetScore) &&
            (identical(other.aiComment, aiComment) ||
                other.aiComment == aiComment) &&
            const DeepCollectionEquality().equals(other._plates, _plates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      skinScore,
      plateScore,
      grade,
      targetScore,
      aiComment,
      const DeepCollectionEquality().hash(_plates));

  /// Create a copy of PlateHistoryDayDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateHistoryDayDtoImplCopyWith<_$PlateHistoryDayDtoImpl> get copyWith =>
      __$$PlateHistoryDayDtoImplCopyWithImpl<_$PlateHistoryDayDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateHistoryDayDtoImplToJson(
      this,
    );
  }
}

abstract class _PlateHistoryDayDto implements PlateHistoryDayDto {
  const factory _PlateHistoryDayDto(
      {required final DateTime date,
      final int? skinScore,
      final int? plateScore,
      final String? grade,
      final int? targetScore,
      final String? aiComment,
      final List<PlateHistoryItemDto> plates}) = _$PlateHistoryDayDtoImpl;

  factory _PlateHistoryDayDto.fromJson(Map<String, dynamic> json) =
      _$PlateHistoryDayDtoImpl.fromJson;

  @override
  DateTime get date;

  /// **정상 응답에는 항상 온다.** 그날 얼굴을 안 찍었어도 서버가 그날 첫 기록의
  /// 채점 기준 분석 점수로 채운다(`PlateHistoryService`). 계약상 nullable 이라
  /// 그대로 열어 두는 것이지, 비는 날이 있어서가 아니다.
  @override
  int? get skinScore;

  /// 그날 기록들의 평균. 서버가 계산해서 준다.
  ///
  /// 서버 쪽 타입이 primitive `int` 라 이 키는 생략될 수 없고, 기록이 하나도
  /// 없는 날은 `days` 에 아예 안 들어온다. nullable 은 방어다.
  ///
  /// **그래도 기본값을 두지 않는다.** 0 으로 떨어뜨리면 홈이 "0점 · 주의" 를
  /// 그리는데, 0점은 "아주 나쁘게 먹었다"로 읽힌다 — 아직 안 먹은 것과 다른
  /// 상태다. null 이어야 카드가 시안대로 `OO점` 으로 빠진다.
  @override
  int? get plateScore;

  /// [plateScore] 의 등급. 서버가 매긴다 — 홈 히어로 배지가 이 값을 쓴다.
  @override
  String? get grade;

  /// 시안의 "목표 80점". **값은 서버가 정한다** — 앱에 80 을 박지 않는다.
  /// 지금은 모두에게 같은 상수지만 사용자별 목표가 생기는 날 앱 배포가 필요해진다.
  /// 서버가 안 보내면 목표 막대를 그릴 근거가 없으므로 null 로 둔다.
  @override
  int? get targetScore;

  /// "오늘의 AI 코멘트". 없으면 서버가 키를 빼고, 앱은 카드를 그리지 않는다.
  @override
  String? get aiComment;
  @override
  List<PlateHistoryItemDto> get plates;

  /// Create a copy of PlateHistoryDayDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateHistoryDayDtoImplCopyWith<_$PlateHistoryDayDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateHistoryDto _$PlateHistoryDtoFromJson(Map<String, dynamic> json) {
  return _PlateHistoryDto.fromJson(json);
}

/// @nodoc
mixin _$PlateHistoryDto {
  List<PlateHistoryDayDto> get days => throw _privateConstructorUsedError;

  /// Serializes this PlateHistoryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlateHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateHistoryDtoCopyWith<PlateHistoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateHistoryDtoCopyWith<$Res> {
  factory $PlateHistoryDtoCopyWith(
          PlateHistoryDto value, $Res Function(PlateHistoryDto) then) =
      _$PlateHistoryDtoCopyWithImpl<$Res, PlateHistoryDto>;
  @useResult
  $Res call({List<PlateHistoryDayDto> days});
}

/// @nodoc
class _$PlateHistoryDtoCopyWithImpl<$Res, $Val extends PlateHistoryDto>
    implements $PlateHistoryDtoCopyWith<$Res> {
  _$PlateHistoryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryDayDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateHistoryDtoImplCopyWith<$Res>
    implements $PlateHistoryDtoCopyWith<$Res> {
  factory _$$PlateHistoryDtoImplCopyWith(_$PlateHistoryDtoImpl value,
          $Res Function(_$PlateHistoryDtoImpl) then) =
      __$$PlateHistoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PlateHistoryDayDto> days});
}

/// @nodoc
class __$$PlateHistoryDtoImplCopyWithImpl<$Res>
    extends _$PlateHistoryDtoCopyWithImpl<$Res, _$PlateHistoryDtoImpl>
    implements _$$PlateHistoryDtoImplCopyWith<$Res> {
  __$$PlateHistoryDtoImplCopyWithImpl(
      _$PlateHistoryDtoImpl _value, $Res Function(_$PlateHistoryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlateHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? days = null,
  }) {
    return _then(_$PlateHistoryDtoImpl(
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<PlateHistoryDayDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateHistoryDtoImpl implements _PlateHistoryDto {
  const _$PlateHistoryDtoImpl(
      {final List<PlateHistoryDayDto> days = const <PlateHistoryDayDto>[]})
      : _days = days;

  factory _$PlateHistoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateHistoryDtoImplFromJson(json);

  final List<PlateHistoryDayDto> _days;
  @override
  @JsonKey()
  List<PlateHistoryDayDto> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'PlateHistoryDto(days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateHistoryDtoImpl &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_days));

  /// Create a copy of PlateHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateHistoryDtoImplCopyWith<_$PlateHistoryDtoImpl> get copyWith =>
      __$$PlateHistoryDtoImplCopyWithImpl<_$PlateHistoryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateHistoryDtoImplToJson(
      this,
    );
  }
}

abstract class _PlateHistoryDto implements PlateHistoryDto {
  const factory _PlateHistoryDto({final List<PlateHistoryDayDto> days}) =
      _$PlateHistoryDtoImpl;

  factory _PlateHistoryDto.fromJson(Map<String, dynamic> json) =
      _$PlateHistoryDtoImpl.fromJson;

  @override
  List<PlateHistoryDayDto> get days;

  /// Create a copy of PlateHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateHistoryDtoImplCopyWith<_$PlateHistoryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateSimulationDto _$PlateSimulationDtoFromJson(Map<String, dynamic> json) {
  return _PlateSimulationDto.fromJson(json);
}

/// @nodoc
mixin _$PlateSimulationDto {
  int get beforeScore => throw _privateConstructorUsedError;
  int get afterScore => throw _privateConstructorUsedError;
  List<String> get appliedActions => throw _privateConstructorUsedError;
  List<String> get removedRules => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;

  /// Serializes this PlateSimulationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlateSimulationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateSimulationDtoCopyWith<PlateSimulationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateSimulationDtoCopyWith<$Res> {
  factory $PlateSimulationDtoCopyWith(
          PlateSimulationDto value, $Res Function(PlateSimulationDto) then) =
      _$PlateSimulationDtoCopyWithImpl<$Res, PlateSimulationDto>;
  @useResult
  $Res call(
      {int beforeScore,
      int afterScore,
      List<String> appliedActions,
      List<String> removedRules,
      String summary});
}

/// @nodoc
class _$PlateSimulationDtoCopyWithImpl<$Res, $Val extends PlateSimulationDto>
    implements $PlateSimulationDtoCopyWith<$Res> {
  _$PlateSimulationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateSimulationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? beforeScore = null,
    Object? afterScore = null,
    Object? appliedActions = null,
    Object? removedRules = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      beforeScore: null == beforeScore
          ? _value.beforeScore
          : beforeScore // ignore: cast_nullable_to_non_nullable
              as int,
      afterScore: null == afterScore
          ? _value.afterScore
          : afterScore // ignore: cast_nullable_to_non_nullable
              as int,
      appliedActions: null == appliedActions
          ? _value.appliedActions
          : appliedActions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      removedRules: null == removedRules
          ? _value.removedRules
          : removedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateSimulationDtoImplCopyWith<$Res>
    implements $PlateSimulationDtoCopyWith<$Res> {
  factory _$$PlateSimulationDtoImplCopyWith(_$PlateSimulationDtoImpl value,
          $Res Function(_$PlateSimulationDtoImpl) then) =
      __$$PlateSimulationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int beforeScore,
      int afterScore,
      List<String> appliedActions,
      List<String> removedRules,
      String summary});
}

/// @nodoc
class __$$PlateSimulationDtoImplCopyWithImpl<$Res>
    extends _$PlateSimulationDtoCopyWithImpl<$Res, _$PlateSimulationDtoImpl>
    implements _$$PlateSimulationDtoImplCopyWith<$Res> {
  __$$PlateSimulationDtoImplCopyWithImpl(_$PlateSimulationDtoImpl _value,
      $Res Function(_$PlateSimulationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlateSimulationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? beforeScore = null,
    Object? afterScore = null,
    Object? appliedActions = null,
    Object? removedRules = null,
    Object? summary = null,
  }) {
    return _then(_$PlateSimulationDtoImpl(
      beforeScore: null == beforeScore
          ? _value.beforeScore
          : beforeScore // ignore: cast_nullable_to_non_nullable
              as int,
      afterScore: null == afterScore
          ? _value.afterScore
          : afterScore // ignore: cast_nullable_to_non_nullable
              as int,
      appliedActions: null == appliedActions
          ? _value._appliedActions
          : appliedActions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      removedRules: null == removedRules
          ? _value._removedRules
          : removedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateSimulationDtoImpl implements _PlateSimulationDto {
  const _$PlateSimulationDtoImpl(
      {required this.beforeScore,
      required this.afterScore,
      final List<String> appliedActions = const <String>[],
      final List<String> removedRules = const <String>[],
      this.summary = ''})
      : _appliedActions = appliedActions,
        _removedRules = removedRules;

  factory _$PlateSimulationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateSimulationDtoImplFromJson(json);

  @override
  final int beforeScore;
  @override
  final int afterScore;
  final List<String> _appliedActions;
  @override
  @JsonKey()
  List<String> get appliedActions {
    if (_appliedActions is EqualUnmodifiableListView) return _appliedActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appliedActions);
  }

  final List<String> _removedRules;
  @override
  @JsonKey()
  List<String> get removedRules {
    if (_removedRules is EqualUnmodifiableListView) return _removedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_removedRules);
  }

  @override
  @JsonKey()
  final String summary;

  @override
  String toString() {
    return 'PlateSimulationDto(beforeScore: $beforeScore, afterScore: $afterScore, appliedActions: $appliedActions, removedRules: $removedRules, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateSimulationDtoImpl &&
            (identical(other.beforeScore, beforeScore) ||
                other.beforeScore == beforeScore) &&
            (identical(other.afterScore, afterScore) ||
                other.afterScore == afterScore) &&
            const DeepCollectionEquality()
                .equals(other._appliedActions, _appliedActions) &&
            const DeepCollectionEquality()
                .equals(other._removedRules, _removedRules) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      beforeScore,
      afterScore,
      const DeepCollectionEquality().hash(_appliedActions),
      const DeepCollectionEquality().hash(_removedRules),
      summary);

  /// Create a copy of PlateSimulationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateSimulationDtoImplCopyWith<_$PlateSimulationDtoImpl> get copyWith =>
      __$$PlateSimulationDtoImplCopyWithImpl<_$PlateSimulationDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateSimulationDtoImplToJson(
      this,
    );
  }
}

abstract class _PlateSimulationDto implements PlateSimulationDto {
  const factory _PlateSimulationDto(
      {required final int beforeScore,
      required final int afterScore,
      final List<String> appliedActions,
      final List<String> removedRules,
      final String summary}) = _$PlateSimulationDtoImpl;

  factory _PlateSimulationDto.fromJson(Map<String, dynamic> json) =
      _$PlateSimulationDtoImpl.fromJson;

  @override
  int get beforeScore;
  @override
  int get afterScore;
  @override
  List<String> get appliedActions;
  @override
  List<String> get removedRules;
  @override
  String get summary;

  /// Create a copy of PlateSimulationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateSimulationDtoImplCopyWith<_$PlateSimulationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
