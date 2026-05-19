// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_coin_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketCoinInfo _$MarketCoinInfoFromJson(Map<String, dynamic> json) =>
    MarketCoinInfo()
      ..market = json['market'] == null
          ? null
          : Market.fromJson(json['market'] as Map<String, dynamic>)
      ..coinList = json['coinList'] as Map<String, dynamic>?;

Map<String, dynamic> _$MarketCoinInfoToJson(MarketCoinInfo instance) =>
    <String, dynamic>{
      'market': instance.market,
      'coinList': instance.coinList,
    };

Market _$MarketFromJson(Map<String, dynamic> json) =>
    Market()..coinList = json['coinList'] as Map<String, dynamic>?;

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
      'coinList': instance.coinList,
    };
