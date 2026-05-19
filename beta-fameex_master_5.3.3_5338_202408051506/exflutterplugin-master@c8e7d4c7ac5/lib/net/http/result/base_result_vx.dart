import 'package:json_annotation/json_annotation.dart';

part 'base_result_vx.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResultVx<T> {
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "msg")
  String? msg;
  @JsonKey(name: "data")
  T? data;

  BaseResultVx({this.code, this.msg, this.data});

  factory BaseResultVx.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BaseResultVxFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$BaseResultVxToJson(this, toJsonT);
}
