
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'etf_position_record_entity.g.dart';
@JsonSerializable()
class EtfPositionRecordEntity {

	int? count;
	List<EtfPositionRecordEtfPositionRecordList>? etfPositionRecordList;
  
  EtfPositionRecordEntity();

  factory EtfPositionRecordEntity.fromJson(Map<String, dynamic> json) => _$EtfPositionRecordEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EtfPositionRecordEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class EtfPositionRecordEtfPositionRecordList {

	String? symbol;
	String? base;
	String? quote;
	String? beforeContractValue;
	String? afterContractValue;
	String? beforeLever;
	String? afterLever;
	String? netValue;
	int? adjustTime;
	int? type;
  
  EtfPositionRecordEtfPositionRecordList();

  factory EtfPositionRecordEtfPositionRecordList.fromJson(Map<String, dynamic> json) => _$EtfPositionRecordEtfPositionRecordListFromJson(json);

  Map<String, dynamic> toJson() => _$EtfPositionRecordEtfPositionRecordListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}