
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'kline_coin_introduce_entity.g.dart';
@JsonSerializable()
class KlineCoinIntroduceEntity {

	int? publishTime;
	String? currencyAmount;
	int? mtime;
	String? publishAmount;
	String? officialUrl;
	String? publishTimeStr;
	int? companyId;
	String? coinSymbol;
	String? langKey;
	String? blockchainUrl;
	int? ctime;
	int? id;
	String? shortName;
	String? introduction;
	String? longName;
  
  KlineCoinIntroduceEntity();

  factory KlineCoinIntroduceEntity.fromJson(Map<String, dynamic> json) => _$KlineCoinIntroduceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KlineCoinIntroduceEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}