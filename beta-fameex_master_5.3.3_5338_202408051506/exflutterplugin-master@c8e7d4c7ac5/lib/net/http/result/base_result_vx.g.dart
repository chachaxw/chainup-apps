// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_result_vx.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResultVx<T> _$BaseResultVxFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BaseResultVx<T>(
      code: json['code'] as String?,
      msg: json['msg'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$BaseResultVxToJson<T>(
  BaseResultVx<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
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
