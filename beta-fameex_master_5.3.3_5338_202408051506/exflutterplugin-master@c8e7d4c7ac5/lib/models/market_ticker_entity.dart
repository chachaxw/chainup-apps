import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'market_ticker_entity.g.dart';
@JsonSerializable()
class MarketTickerEntity {

  @JsonKey(name: "event_rep")
  String? eventRep;
  String? channel;
  List<MarketTickerData>? data;
  MarketTickerTick? tick;
  dynamic? ts;
  String? status;

  MarketTickerEntity();

  factory MarketTickerEntity.fromJson(Map<String, dynamic> json) => _$MarketTickerEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTickerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MarketTickerData {

  int? id;
  double? amount;
  double? vol;
  double? open;
  double? close;
  double? high;
  double? low;

  MarketTickerData();

  factory MarketTickerData.fromJson(Map<String, dynamic> json) => _$MarketTickerDataFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTickerDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MarketTickerTick {

   dynamic? amount;
   dynamic? close;
   dynamic? high;
   dynamic? low;
   dynamic? open;
   dynamic? rose;
   dynamic? vol;
   dynamic? id;

  MarketTickerTick();

  factory MarketTickerTick.fromJson(Map<String, dynamic> json) => _$MarketTickerTickFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTickerTickToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

