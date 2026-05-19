// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_depth_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketDepthEntity _$MarketDepthEntityFromJson(Map<String, dynamic> json) =>
    MarketDepthEntity()
      ..eventRep = json['event_rep'] as String?
      ..channel = json['channel'] as String?
      ..tick = json['tick'] == null
          ? null
          : MarketDepthTick.fromJson(json['tick'] as Map<String, dynamic>);

Map<String, dynamic> _$MarketDepthEntityToJson(MarketDepthEntity instance) =>
    <String, dynamic>{
      'event_rep': instance.eventRep,
      'channel': instance.channel,
      'tick': instance.tick,
    };

MarketDepthTick _$MarketDepthTickFromJson(Map<String, dynamic> json) =>
    MarketDepthTick()
      ..asks = (json['asks'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList()
      ..buys = (json['buys'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList();

Map<String, dynamic> _$MarketDepthTickToJson(MarketDepthTick instance) =>
    <String, dynamic>{
      'asks': instance.asks,
      'buys': instance.buys,
    };
