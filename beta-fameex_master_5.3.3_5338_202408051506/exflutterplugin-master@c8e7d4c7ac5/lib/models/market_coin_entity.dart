import 'dart:convert';

import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'market_coin_entity.g.dart';

@JsonSerializable()
class MarketCoinInfo {
  Market? market;
  Map? coinList;
  MarketCoinInfo();

  factory MarketCoinInfo.fromJson(Map<String, dynamic> json) =>
      _$MarketCoinInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketCoinInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class Market {
  Map? coinList;

  Market();

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);

  Map<String, dynamic> toJson() => _$MarketToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

// @JsonSerializable()
// class CoinInfo {
//   String? showName;
//   String? icon;
//   String? mainChainName;
//   String? otcOpen;
//   String? name;
//   String? longName;
//   String? tokenBase;

//   CoinInfo();

//   factory CoinInfo.fromJson(Map<String, dynamic> json) =>
//       _$CoinInfoFromJson(json);

//   Map<String, dynamic> toJson() => _$CoinInfoToJson(this);

//   @override
//   String toString() {
//     return jsonEncode(this);
//   }
// }
