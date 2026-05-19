// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etf_position_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EtfPositionRecordEntity _$EtfPositionRecordEntityFromJson(
        Map<String, dynamic> json) =>
    EtfPositionRecordEntity()
      ..count = json['count'] as int?
      ..etfPositionRecordList =
          (json['etfPositionRecordList'] as List<dynamic>?)
              ?.map((e) => EtfPositionRecordEtfPositionRecordList.fromJson(
                  e as Map<String, dynamic>))
              .toList();

Map<String, dynamic> _$EtfPositionRecordEntityToJson(
        EtfPositionRecordEntity instance) =>
    <String, dynamic>{
      'count': instance.count,
      'etfPositionRecordList': instance.etfPositionRecordList,
    };

EtfPositionRecordEtfPositionRecordList
    _$EtfPositionRecordEtfPositionRecordListFromJson(
            Map<String, dynamic> json) =>
        EtfPositionRecordEtfPositionRecordList()
          ..symbol = json['symbol'] as String?
          ..base = json['base'] as String?
          ..quote = json['quote'] as String?
          ..beforeContractValue = json['beforeContractValue'] as String?
          ..afterContractValue = json['afterContractValue'] as String?
          ..beforeLever = json['beforeLever'] as String?
          ..afterLever = json['afterLever'] as String?
          ..netValue = json['netValue'] as String?
          ..adjustTime = json['adjustTime'] as int?
          ..type = json['type'] as int?;

Map<String, dynamic> _$EtfPositionRecordEtfPositionRecordListToJson(
        EtfPositionRecordEtfPositionRecordList instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'base': instance.base,
      'quote': instance.quote,
      'beforeContractValue': instance.beforeContractValue,
      'afterContractValue': instance.afterContractValue,
      'beforeLever': instance.beforeLever,
      'afterLever': instance.afterLever,
      'netValue': instance.netValue,
      'adjustTime': instance.adjustTime,
      'type': instance.type,
    };
