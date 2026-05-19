
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'contract_market_entity.g.dart';
@JsonSerializable()
class ContractMarketEntity {

	dynamic? currentFundRate;
	dynamic? indexPrice;
	dynamic? tagPrice;
	dynamic? nextFundRate;
	String? showIndexPrice;
	String? showTagPrice;
	String? showNextFundRate;
	String? showCurrentFundRate;

  ContractMarketEntity();

  factory ContractMarketEntity.fromJson(Map<String, dynamic> json) => _$ContractMarketEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ContractMarketEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}