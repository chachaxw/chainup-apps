
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'coin_json_entity.g.dart';
@JsonSerializable()
class CoinJsonEntity {
	double? limitVolumeMin;
	int? isOpenLever;
	String? symbol;
	String? baseLongName;
	String? etfSide;
	double? marketBuyMin;
	String? fundRate;
	double? marketSellMin;
	int? etfOpen;
	String? etfBase;
	int? isOvercharge;
	int? isOpenCross;
	int? price;
	int? daySellLimit;
	String? etfMultiple;
	String? showName;
	@JsonKey(name: "is_grid_open")
	int? isGridOpen;
	int? multiple;
	int? sort;
	int? newcoinFlag;
	int? volume;
	int? dayBuyLimit;
	String? depth;
	String? name;
	double? limitPriceMin;
	bool? isEdited;

	CoinJsonEntity();

	factory CoinJsonEntity.fromJson(Map<String, dynamic> json) => _$CoinJsonEntityFromJson(json);

	Map<String, dynamic> toJson() => _$CoinJsonEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}