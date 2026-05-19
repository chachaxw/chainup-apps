import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/net/http/result/base_result_vx.dart';
import 'package:json_annotation/json_annotation.dart';


BaseResultVx $BaseResultVxFromJson(Map<String, dynamic> json) {
  final BaseResultVx baseResultVx = BaseResultVx();
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    baseResultVx.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    baseResultVx.msg = msg;
  }
  final T? data = jsonConvert.convert<T>(json['data']);
  if (data != null) {
    baseResultVx.data = data;
  }
  return baseResultVx;
}

Map<String, dynamic> $BaseResultVxToJson(BaseResultVx entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['data'] = entity.data?.toJson();
  return data;
}

extension BaseResultVxExtension on BaseResultVx {
  BaseResultVx copyWith({
    String? code,
    String? msg,
    T? data,
  }) {
    return BaseResultVx()
      ..code = code ?? this.code
      ..msg = msg ?? this.msg
      ..data = data ?? this.data;
  }
}