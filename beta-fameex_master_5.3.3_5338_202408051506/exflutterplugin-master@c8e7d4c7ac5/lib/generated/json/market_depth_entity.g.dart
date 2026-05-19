import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/market_depth_entity.dart';
import 'package:json_annotation/json_annotation.dart';


MarketDepthEntity $MarketDepthEntityFromJson(Map<String, dynamic> json) {
  final MarketDepthEntity marketDepthEntity = MarketDepthEntity();
  final String? eventRep = jsonConvert.convert<String>(json['eventRep']);
  if (eventRep != null) {
    marketDepthEntity.eventRep = eventRep;
  }
  final String? channel = jsonConvert.convert<String>(json['channel']);
  if (channel != null) {
    marketDepthEntity.channel = channel;
  }
  final MarketDepthTick? tick = jsonConvert.convert<MarketDepthTick>(
      json['tick']);
  if (tick != null) {
    marketDepthEntity.tick = tick;
  }
  return marketDepthEntity;
}

Map<String, dynamic> $MarketDepthEntityToJson(MarketDepthEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['eventRep'] = entity.eventRep;
  data['channel'] = entity.channel;
  data['tick'] = entity.tick?.toJson();
  return data;
}

extension MarketDepthEntityExtension on MarketDepthEntity {
  MarketDepthEntity copyWith({
    String? eventRep,
    String? channel,
    MarketDepthTick? tick,
  }) {
    return MarketDepthEntity()
      ..eventRep = eventRep ?? this.eventRep
      ..channel = channel ?? this.channel
      ..tick = tick ?? this.tick;
  }
}

MarketDepthTick $MarketDepthTickFromJson(Map<String, dynamic> json) {
  final MarketDepthTick marketDepthTick = MarketDepthTick();
  final List<List>? asks = (json['asks'] as List<dynamic>?)?.map(
          (e) =>
          (e as List<dynamic>).map(
                  (e) => e).toList()).toList();
  if (asks != null) {
    marketDepthTick.asks = asks;
  }
  final List<List>? buys = (json['buys'] as List<dynamic>?)?.map(
          (e) =>
          (e as List<dynamic>).map(
                  (e) => e).toList()).toList();
  if (buys != null) {
    marketDepthTick.buys = buys;
  }
  return marketDepthTick;
}

Map<String, dynamic> $MarketDepthTickToJson(MarketDepthTick entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['asks'] = entity.asks;
  data['buys'] = entity.buys;
  return data;
}

extension MarketDepthTickExtension on MarketDepthTick {
  MarketDepthTick copyWith({
    List<List>? asks,
    List<List>? buys,
  }) {
    return MarketDepthTick()
      ..asks = asks ?? this.asks
      ..buys = buys ?? this.buys;
  }
}