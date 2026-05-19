import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/etf_net_value_entity.dart';
import 'package:json_annotation/json_annotation.dart';


EtfNetValueEntity $EtfNetValueEntityFromJson(Map<String, dynamic> json) {
  final EtfNetValueEntity etfNetValueEntity = EtfNetValueEntity();
  final String? marketName = jsonConvert.convert<String>(json['marketName']);
  if (marketName != null) {
    etfNetValueEntity.marketName = marketName;
  }
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    etfNetValueEntity.price = price;
  }
  final int? timestamp = jsonConvert.convert<int>(json['timestamp']);
  if (timestamp != null) {
    etfNetValueEntity.timestamp = timestamp;
  }
  final String? realLeverValue = jsonConvert.convert<String>(
      json['realLeverValue']);
  if (realLeverValue != null) {
    etfNetValueEntity.realLeverValue = realLeverValue;
  }
  final String? maxLeverValue = jsonConvert.convert<String>(
      json['maxLeverValue']);
  if (maxLeverValue != null) {
    etfNetValueEntity.maxLeverValue = maxLeverValue;
  }
  return etfNetValueEntity;
}

Map<String, dynamic> $EtfNetValueEntityToJson(EtfNetValueEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['marketName'] = entity.marketName;
  data['price'] = entity.price;
  data['timestamp'] = entity.timestamp;
  data['realLeverValue'] = entity.realLeverValue;
  data['maxLeverValue'] = entity.maxLeverValue;
  return data;
}

extension EtfNetValueEntityExtension on EtfNetValueEntity {
  EtfNetValueEntity copyWith({
    String? marketName,
    String? price,
    int? timestamp,
    String? realLeverValue,
    String? maxLeverValue,
  }) {
    return EtfNetValueEntity()
      ..marketName = marketName ?? this.marketName
      ..price = price ?? this.price
      ..timestamp = timestamp ?? this.timestamp
      ..realLeverValue = realLeverValue ?? this.realLeverValue
      ..maxLeverValue = maxLeverValue ?? this.maxLeverValue;
  }
}