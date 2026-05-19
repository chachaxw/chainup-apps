import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/market_ticker_entity.dart';
import 'package:json_annotation/json_annotation.dart';


MarketTickerEntity $MarketTickerEntityFromJson(Map<String, dynamic> json) {
  final MarketTickerEntity marketTickerEntity = MarketTickerEntity();
  final String? eventRep = jsonConvert.convert<String>(json['eventRep']);
  if (eventRep != null) {
    marketTickerEntity.eventRep = eventRep;
  }
  final String? channel = jsonConvert.convert<String>(json['channel']);
  if (channel != null) {
    marketTickerEntity.channel = channel;
  }
  final List<MarketTickerData>? data = (json['data'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<MarketTickerData>(e) as MarketTickerData)
      .toList();
  if (data != null) {
    marketTickerEntity.data = data;
  }
  final MarketTickerTick? tick = jsonConvert.convert<MarketTickerTick>(
      json['tick']);
  if (tick != null) {
    marketTickerEntity.tick = tick;
  }
  final dynamic ts = json['ts'];
  if (ts != null) {
    marketTickerEntity.ts = ts;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    marketTickerEntity.status = status;
  }
  return marketTickerEntity;
}

Map<String, dynamic> $MarketTickerEntityToJson(MarketTickerEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['eventRep'] = entity.eventRep;
  data['channel'] = entity.channel;
  data['data'] = entity.data?.map((v) => v.toJson()).toList();
  data['tick'] = entity.tick?.toJson();
  data['ts'] = entity.ts;
  data['status'] = entity.status;
  return data;
}

extension MarketTickerEntityExtension on MarketTickerEntity {
  MarketTickerEntity copyWith({
    String? eventRep,
    String? channel,
    List<MarketTickerData>? data,
    MarketTickerTick? tick,
    dynamic ts,
    String? status,
  }) {
    return MarketTickerEntity()
      ..eventRep = eventRep ?? this.eventRep
      ..channel = channel ?? this.channel
      ..data = data ?? this.data
      ..tick = tick ?? this.tick
      ..ts = ts ?? this.ts
      ..status = status ?? this.status;
  }
}

MarketTickerData $MarketTickerDataFromJson(Map<String, dynamic> json) {
  final MarketTickerData marketTickerData = MarketTickerData();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    marketTickerData.id = id;
  }
  final double? amount = jsonConvert.convert<double>(json['amount']);
  if (amount != null) {
    marketTickerData.amount = amount;
  }
  final double? vol = jsonConvert.convert<double>(json['vol']);
  if (vol != null) {
    marketTickerData.vol = vol;
  }
  final double? open = jsonConvert.convert<double>(json['open']);
  if (open != null) {
    marketTickerData.open = open;
  }
  final double? close = jsonConvert.convert<double>(json['close']);
  if (close != null) {
    marketTickerData.close = close;
  }
  final double? high = jsonConvert.convert<double>(json['high']);
  if (high != null) {
    marketTickerData.high = high;
  }
  final double? low = jsonConvert.convert<double>(json['low']);
  if (low != null) {
    marketTickerData.low = low;
  }
  return marketTickerData;
}

Map<String, dynamic> $MarketTickerDataToJson(MarketTickerData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['amount'] = entity.amount;
  data['vol'] = entity.vol;
  data['open'] = entity.open;
  data['close'] = entity.close;
  data['high'] = entity.high;
  data['low'] = entity.low;
  return data;
}

extension MarketTickerDataExtension on MarketTickerData {
  MarketTickerData copyWith({
    int? id,
    double? amount,
    double? vol,
    double? open,
    double? close,
    double? high,
    double? low,
  }) {
    return MarketTickerData()
      ..id = id ?? this.id
      ..amount = amount ?? this.amount
      ..vol = vol ?? this.vol
      ..open = open ?? this.open
      ..close = close ?? this.close
      ..high = high ?? this.high
      ..low = low ?? this.low;
  }
}

MarketTickerTick $MarketTickerTickFromJson(Map<String, dynamic> json) {
  final MarketTickerTick marketTickerTick = MarketTickerTick();
  final dynamic amount = json['amount'];
  if (amount != null) {
    marketTickerTick.amount = amount;
  }
  final dynamic close = json['close'];
  if (close != null) {
    marketTickerTick.close = close;
  }
  final dynamic high = json['high'];
  if (high != null) {
    marketTickerTick.high = high;
  }
  final dynamic low = json['low'];
  if (low != null) {
    marketTickerTick.low = low;
  }
  final dynamic open = json['open'];
  if (open != null) {
    marketTickerTick.open = open;
  }
  final dynamic rose = json['rose'];
  if (rose != null) {
    marketTickerTick.rose = rose;
  }
  final dynamic vol = json['vol'];
  if (vol != null) {
    marketTickerTick.vol = vol;
  }
  final dynamic id = json['id'];
  if (id != null) {
    marketTickerTick.id = id;
  }
  return marketTickerTick;
}

Map<String, dynamic> $MarketTickerTickToJson(MarketTickerTick entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['close'] = entity.close;
  data['high'] = entity.high;
  data['low'] = entity.low;
  data['open'] = entity.open;
  data['rose'] = entity.rose;
  data['vol'] = entity.vol;
  data['id'] = entity.id;
  return data;
}

extension MarketTickerTickExtension on MarketTickerTick {
  MarketTickerTick copyWith({
    dynamic amount,
    dynamic close,
    dynamic high,
    dynamic low,
    dynamic open,
    dynamic rose,
    dynamic vol,
    dynamic id,
  }) {
    return MarketTickerTick()
      ..amount = amount ?? this.amount
      ..close = close ?? this.close
      ..high = high ?? this.high
      ..low = low ?? this.low
      ..open = open ?? this.open
      ..rose = rose ?? this.rose
      ..vol = vol ?? this.vol
      ..id = id ?? this.id;
  }
}