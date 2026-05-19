import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/market_coin_entity.dart';
import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';

import 'package:json_annotation/json_annotation.dart';


MarketCoinInfo $MarketCoinInfoFromJson(Map<String, dynamic> json) {
  final MarketCoinInfo marketCoinInfo = MarketCoinInfo();
  final Market? market = jsonConvert.convert<Market>(json['market']);
  if (market != null) {
    marketCoinInfo.market = market;
  }
  return marketCoinInfo;
}

Map<String, dynamic> $MarketCoinInfoToJson(MarketCoinInfo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['market'] = entity.market?.toJson();
  return data;
}

extension MarketCoinInfoExtension on MarketCoinInfo {
  MarketCoinInfo copyWith({
    Market? market,
  }) {
    return MarketCoinInfo()
      ..market = market ?? this.market;
  }
}

Market $MarketFromJson(Map<String, dynamic> json) {
  final Market market = Market();
  final Map? coinList =
  (json['coinList'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e == null ? null : e));
  if (coinList != null) {
    market.coinList = coinList;
  }
  return market;
}

Map<String, dynamic> $MarketToJson(Market entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coinList'] = entity.coinList;
  return data;
}

extension MarketExtension on Market {
  Market copyWith({
    Map? coinList,
  }) {
    return Market()
      ..coinList = coinList ?? this.coinList;
  }
}