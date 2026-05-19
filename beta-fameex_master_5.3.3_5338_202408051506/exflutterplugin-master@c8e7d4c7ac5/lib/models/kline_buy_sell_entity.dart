
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'kline_buy_sell_entity.g.dart';

@JsonSerializable()
class KlineBuySellListEntity {

  @JsonKey(name: "KlineBuySellData")
  List<KlineBuySellEntity>? klineBuySellData;

  KlineBuySellListEntity();

  factory KlineBuySellListEntity.fromJson(Map<String, dynamic> json) => _$KlineBuySellListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KlineBuySellListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class KlineBuySellEntity {

	String? price;
	int? ctime;
	bool? isBuy;
	String? vol;
  
  KlineBuySellEntity();

  factory KlineBuySellEntity.fromJson(Map<String, dynamic> json) => _$KlineBuySellEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KlineBuySellEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}