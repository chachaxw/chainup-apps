// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_ticker_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketTickerEntity _$MarketTickerEntityFromJson(Map<String, dynamic> json) =>
    MarketTickerEntity()
      ..eventRep = json['event_rep'] as String?
      ..channel = json['channel'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => MarketTickerData.fromJson(e as Map<String, dynamic>))
          .toList()
      ..tick = json['tick'] == null
          ? null
          : MarketTickerTick.fromJson(json['tick'] as Map<String, dynamic>)
      ..ts = json['ts']
      ..status = json['status'] as String?;

Map<String, dynamic> _$MarketTickerEntityToJson(MarketTickerEntity instance) =>
    <String, dynamic>{
      'event_rep': instance.eventRep,
      'channel': instance.channel,
      'data': instance.data,
      'tick': instance.tick,
      'ts': instance.ts,
      'status': instance.status,
    };

MarketTickerData _$MarketTickerDataFromJson(Map<String, dynamic> json) =>
    MarketTickerData()
      ..id = json['id'] as int?
      ..amount = (json['amount'] as num?)?.toDouble()
      ..vol = (json['vol'] as num?)?.toDouble()
      ..open = (json['open'] as num?)?.toDouble()
      ..close = (json['close'] as num?)?.toDouble()
      ..high = (json['high'] as num?)?.toDouble()
      ..low = (json['low'] as num?)?.toDouble();

Map<String, dynamic> _$MarketTickerDataToJson(MarketTickerData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'vol': instance.vol,
      'open': instance.open,
      'close': instance.close,
      'high': instance.high,
      'low': instance.low,
    };

MarketTickerTick _$MarketTickerTickFromJson(Map<String, dynamic> json) =>
    MarketTickerTick()
      ..amount = json['amount']
      ..close = json['close']
      ..high = json['high']
      ..low = json['low']
      ..open = json['open']
      ..rose = json['rose']
      ..vol = json['vol']
      ..id = json['id'];

Map<String, dynamic> _$MarketTickerTickToJson(MarketTickerTick instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'close': instance.close,
      'high': instance.high,
      'low': instance.low,
      'open': instance.open,
      'rose': instance.rose,
      'vol': instance.vol,
      'id': instance.id,
    };
