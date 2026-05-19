
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';


part 'deal_record_entity.g.dart';
@JsonSerializable()
class DealRecordEntity {
  @JsonKey(name: "event_rep")
  String? eventRep;
  String? channel;
  @JsonKey(name: "cb_id")
  int? cbId;
  int? ts;
  String? status;
  DealRecordTick? tick;
  List<DealRecordData>? data;
  
  DealRecordEntity();

  factory DealRecordEntity.fromJson(Map<String, dynamic> json) => _$DealRecordEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DealRecordEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DealRecordTick {

	List<DealRecordData>? data;
  
  DealRecordTick();

  factory DealRecordTick.fromJson(Map<String, dynamic> json) => _$DealRecordTickFromJson(json);

  Map<String, dynamic> toJson() => _$DealRecordTickToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DealRecordTickData {

	String? side;
  String? price;
	int? vol;
	int? amount;
	String? ds;
	int? ts;
  
  DealRecordTickData();

  factory DealRecordTickData.fromJson(Map<String, dynamic> json) => _$DealRecordTickDataFromJson(json);

  Map<String, dynamic> toJson() => _$DealRecordTickDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DealRecordData {

	String? side;
  String? price;
  String? vol;
  String? amount;
	String? ds;
  int? ts;
  
  DealRecordData();

  factory DealRecordData.fromJson(Map<String, dynamic> json) => _$DealRecordDataFromJson(json);

  Map<String, dynamic> toJson() => _$DealRecordDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}