// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiEnvelopeImpl<T> _$$ApiEnvelopeImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    _$ApiEnvelopeImpl<T>(
      success: json['success'] as bool,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      error: json['error'] == null
          ? null
          : ApiErrorBody.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ApiEnvelopeImplToJson<T>(
  _$ApiEnvelopeImpl<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'error': instance.error,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

_$ApiErrorBodyImpl _$$ApiErrorBodyImplFromJson(Map<String, dynamic> json) =>
    _$ApiErrorBodyImpl(
      code: json['code'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$ApiErrorBodyImplToJson(_$ApiErrorBodyImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
