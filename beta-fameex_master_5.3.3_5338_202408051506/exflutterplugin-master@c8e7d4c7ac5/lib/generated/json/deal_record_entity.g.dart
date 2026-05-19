import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/deal_record_entity.dart';
import 'package:json_annotation/json_annotation.dart';


DealRecordEntity $DealRecordEntityFromJson(Map<String, dynamic> json) {
  final DealRecordEntity dealRecordEntity = DealRecordEntity();
  final String? eventRep = jsonConvert.convert<String>(json['eventRep']);
  if (eventRep != null) {
    dealRecordEntity.eventRep = eventRep;
  }
  final String? channel = jsonConvert.convert<String>(json['channel']);
  if (channel != null) {
    dealRecordEntity.channel = channel;
  }
  final int? cbId = jsonConvert.convert<int>(json['cbId']);
  if (cbId != null) {
    dealRecordEntity.cbId = cbId;
  }
  final int? ts = jsonConvert.convert<int>(json['ts']);
  if (ts != null) {
    dealRecordEntity.ts = ts;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    dealRecordEntity.status = status;
  }
  final DealRecordTick? tick = jsonConvert.convert<DealRecordTick>(
      json['tick']);
  if (tick != null) {
    dealRecordEntity.tick = tick;
  }
  final List<DealRecordData>? data = (json['data'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<DealRecordData>(e) as DealRecordData)
      .toList();
  if (data != null) {
    dealRecordEntity.data = data;
  }
  return dealRecordEntity;
}

Map<String, dynamic> $DealRecordEntityToJson(DealRecordEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['eventRep'] = entity.eventRep;
  data['channel'] = entity.channel;
  data['cbId'] = entity.cbId;
  data['ts'] = entity.ts;
  data['status'] = entity.status;
  data['tick'] = entity.tick?.toJson();
  data['data'] = entity.data?.map((v) => v.toJson()).toList();
  return data;
}

extension DealRecordEntityExtension on DealRecordEntity {
  DealRecordEntity copyWith({
    String? eventRep,
    String? channel,
    int? cbId,
    int? ts,
    String? status,
    DealRecordTick? tick,
    List<DealRecordData>? data,
  }) {
    return DealRecordEntity()
      ..eventRep = eventRep ?? this.eventRep
      ..channel = channel ?? this.channel
      ..cbId = cbId ?? this.cbId
      ..ts = ts ?? this.ts
      ..status = status ?? this.status
      ..tick = tick ?? this.tick
      ..data = data ?? this.data;
  }
}

DealRecordTick $DealRecordTickFromJson(Map<String, dynamic> json) {
  final DealRecordTick dealRecordTick = DealRecordTick();
  final List<DealRecordData>? data = (json['data'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<DealRecordData>(e) as DealRecordData)
      .toList();
  if (data != null) {
    dealRecordTick.data = data;
  }
  return dealRecordTick;
}

Map<String, dynamic> $DealRecordTickToJson(DealRecordTick entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data?.map((v) => v.toJson()).toList();
  return data;
}

extension DealRecordTickExtension on DealRecordTick {
  DealRecordTick copyWith({
    List<DealRecordData>? data,
  }) {
    return DealRecordTick()
      ..data = data ?? this.data;
  }
}

DealRecordTickData $DealRecordTickDataFromJson(Map<String, dynamic> json) {
  final DealRecordTickData dealRecordTickData = DealRecordTickData();
  final String? side = jsonConvert.convert<String>(json['side']);
  if (side != null) {
    dealRecordTickData.side = side;
  }
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    dealRecordTickData.price = price;
  }
  final int? vol = jsonConvert.convert<int>(json['vol']);
  if (vol != null) {
    dealRecordTickData.vol = vol;
  }
  final int? amount = jsonConvert.convert<int>(json['amount']);
  if (amount != null) {
    dealRecordTickData.amount = amount;
  }
  final String? ds = jsonConvert.convert<String>(json['ds']);
  if (ds != null) {
    dealRecordTickData.ds = ds;
  }
  final int? ts = jsonConvert.convert<int>(json['ts']);
  if (ts != null) {
    dealRecordTickData.ts = ts;
  }
  return dealRecordTickData;
}

Map<String, dynamic> $DealRecordTickDataToJson(DealRecordTickData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['side'] = entity.side;
  data['price'] = entity.price;
  data['vol'] = entity.vol;
  data['amount'] = entity.amount;
  data['ds'] = entity.ds;
  data['ts'] = entity.ts;
  return data;
}

extension DealRecordTickDataExtension on DealRecordTickData {
  DealRecordTickData copyWith({
    String? side,
    String? price,
    int? vol,
    int? amount,
    String? ds,
    int? ts,
  }) {
    return DealRecordTickData()
      ..side = side ?? this.side
      ..price = price ?? this.price
      ..vol = vol ?? this.vol
      ..amount = amount ?? this.amount
      ..ds = ds ?? this.ds
      ..ts = ts ?? this.ts;
  }
}

DealRecordData $DealRecordDataFromJson(Map<String, dynamic> json) {
  final DealRecordData dealRecordData = DealRecordData();
  final String? side = jsonConvert.convert<String>(json['side']);
  if (side != null) {
    dealRecordData.side = side;
  }
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    dealRecordData.price = price;
  }
  final String? vol = jsonConvert.convert<String>(json['vol']);
  if (vol != null) {
    dealRecordData.vol = vol;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    dealRecordData.amount = amount;
  }
  final String? ds = jsonConvert.convert<String>(json['ds']);
  if (ds != null) {
    dealRecordData.ds = ds;
  }
  final int? ts = jsonConvert.convert<int>(json['ts']);
  if (ts != null) {
    dealRecordData.ts = ts;
  }
  return dealRecordData;
}

Map<String, dynamic> $DealRecordDataToJson(DealRecordData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['side'] = entity.side;
  data['price'] = entity.price;
  data['vol'] = entity.vol;
  data['amount'] = entity.amount;
  data['ds'] = entity.ds;
  data['ts'] = entity.ts;
  return data;
}

extension DealRecordDataExtension on DealRecordData {
  DealRecordData copyWith({
    String? side,
    String? price,
    String? vol,
    String? amount,
    String? ds,
    int? ts,
  }) {
    return DealRecordData()
      ..side = side ?? this.side
      ..price = price ?? this.price
      ..vol = vol ?? this.vol
      ..amount = amount ?? this.amount
      ..ds = ds ?? this.ds
      ..ts = ts ?? this.ts;
  }
}