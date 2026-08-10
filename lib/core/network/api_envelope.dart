import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// 서버 공통 응답 래퍼.
///   { "success": true, "data": {...}, "error": null }
@Freezed(genericArgumentFactories: true)
class ApiEnvelope<T> with _$ApiEnvelope<T> {
  const factory ApiEnvelope({
    required bool success,
    T? data,
    ApiErrorBody? error,
  }) = _ApiEnvelope<T>;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiEnvelopeFromJson(json, fromJsonT);
}

@freezed
class ApiErrorBody with _$ApiErrorBody {
  const factory ApiErrorBody({
    required String code,
    required String message,
  }) = _ApiErrorBody;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorBodyFromJson(json);
}
