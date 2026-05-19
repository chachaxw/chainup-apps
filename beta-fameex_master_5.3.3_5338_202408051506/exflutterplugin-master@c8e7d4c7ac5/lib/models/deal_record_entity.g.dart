// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DealRecordEntity _$DealRecordEntityFromJson(Map<String, dynamic> json) =>
    DealRecordEntity()
      ..eventRep = json['event_rep'] as String?
      ..channel = json['channel'] as String?
      ..cbId = json['cb_id'] as int?
      ..ts = json['ts'] as int?
      ..status = json['status'] as String?
      ..tick = json['tick'] == null
          ? null
          : DealRecordTick.fromJson(json['tick'] as Map<String, dynamic>)
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => DealRecordData.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$DealRecordEntityToJson(DealRecordEntity instance) =>
    <String, dynamic>{
      'event_rep': instance.eventRep,
      'channel': instance.channel,
      'cb_id': instance.cbId,
      'ts': instance.ts,
      'status': instance.status,
      'tick': instance.tick,
      'data': instance.data,
    };

DealRecordTick _$DealRecordTickFromJson(Map<String, dynamic> json) =>
    DealRecordTick()
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => DealRecordData.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$DealRecordTickToJson(DealRecordTick instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

DealRecordTickData _$DealRecordTickDataFromJson(Map<String, dynamic> json) =>
    DealRecordTickData()
      ..side = json['side'] as String?
      ..price = json['price'] as String?
      ..vol = json['vol'] as int?
      ..amount = json['amount'] as int?
      ..ds = json['ds'] as String?
      ..ts = json['ts'] as int?;

Map<String, dynamic> _$DealRecordTickDataToJson(DealRecordTickData instance) =>
    <String, dynamic>{
      'side': instance.side,
      'price': instance.price,
      'vol': instance.vol,
      'amount': instance.amount,
      'ds': instance.ds,
      'ts': instance.ts,
    };

DealRecordData _$DealRecordDataFromJson(Map<String, dynamic> json) =>
    DealRecordData()
      ..side = json['side'] as String?
      ..price = json['price'] as String?
      ..vol = json['vol'] as String?
      ..amount = json['amount'] as String?
      ..ds = json['ds'] as String?
      ..ts = json['ts'] as int?;

Map<String, dynamic> _$DealRecordDataToJson(DealRecordData instance) =>
    <String, dynamic>{
      'side': instance.side,
      'price': instance.price,
      'vol': instance.vol,
      'amount': instance.amount,
      'ds': instance.ds,
      'ts': instance.ts,
    };
