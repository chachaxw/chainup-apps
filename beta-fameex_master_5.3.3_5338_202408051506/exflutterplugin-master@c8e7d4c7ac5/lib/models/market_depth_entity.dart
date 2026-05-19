import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'market_depth_entity.g.dart';
@JsonSerializable()
class MarketDepthEntity {

  @JsonKey(name: "event_rep")
  String? eventRep;
	String? channel;
	MarketDepthTick? tick;
  
  MarketDepthEntity();

  factory MarketDepthEntity.fromJson(Map<String, dynamic> json) => _$MarketDepthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MarketDepthEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MarketDepthTick {

	List<List>? asks;
	List<List>? buys;
  
  MarketDepthTick();

  factory MarketDepthTick.fromJson(Map<String, dynamic> json) => _$MarketDepthTickFromJson(json);

  Map<String, dynamic> toJson() => _$MarketDepthTickToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
class DepthTick {

	num price;
  num vol;

  DepthTick(this.price, this.vol);
}