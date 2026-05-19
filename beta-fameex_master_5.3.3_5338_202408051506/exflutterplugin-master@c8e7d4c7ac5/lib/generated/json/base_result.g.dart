import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/net/http/result/base_result.dart';
import 'package:json_annotation/json_annotation.dart';


BaseResult $BaseResultFromJson(Map<String, dynamic> json) {
  final BaseResult baseResult = BaseResult();
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    baseResult.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    baseResult.msg = msg;
  }
  final T? data = jsonConvert.convert<T>(json['data']);
  if (data != null) {
    baseResult.data = data;
  }
  return baseResult;
}

Map<String, dynamic> $BaseResultToJson(BaseResult entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['data'] = entity.data?.toJson();
  return data;
}

extension BaseResultExtension on BaseResult {
  BaseResult copyWith({
    String? code,
    String? msg,
    T? data,
  }) {
    return BaseResult()
      ..code = code ?? this.code
      ..msg = msg ?? this.msg
      ..data = data ?? this.data;
  }
}