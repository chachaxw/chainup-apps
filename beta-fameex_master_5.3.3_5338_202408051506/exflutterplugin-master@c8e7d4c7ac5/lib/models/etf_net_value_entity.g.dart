// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etf_net_value_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EtfNetValueEntity _$EtfNetValueEntityFromJson(Map<String, dynamic> json) =>
    EtfNetValueEntity()
      ..marketName = json['marketName'] as String?
      ..price = json['price'] as String?
      ..timestamp = json['timestamp'] as int?
      ..realLeverValue = json['realLeverValue'] as String?
      ..maxLeverValue = json['maxLeverValue'] as String?;

Map<String, dynamic> _$EtfNetValueEntityToJson(EtfNetValueEntity instance) =>
    <String, dynamic>{
      'marketName': instance.marketName,
      'price': instance.price,
      'timestamp': instance.timestamp,
      'realLeverValue': instance.realLeverValue,
      'maxLeverValue': instance.maxLeverValue,
    };
