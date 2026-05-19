
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'etf_net_value_entity.g.dart';
@JsonSerializable()
class EtfNetValueEntity {

	String? marketName;
	String? price;
	int? timestamp;
	String? realLeverValue;
	String? maxLeverValue;
  
  EtfNetValueEntity();

  factory EtfNetValueEntity.fromJson(Map<String, dynamic> json) => _$EtfNetValueEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EtfNetValueEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}