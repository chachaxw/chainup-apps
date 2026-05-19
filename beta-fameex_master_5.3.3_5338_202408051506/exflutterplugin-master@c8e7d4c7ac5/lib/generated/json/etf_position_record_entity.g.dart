import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/etf_position_record_entity.dart';
import 'package:json_annotation/json_annotation.dart';


EtfPositionRecordEntity $EtfPositionRecordEntityFromJson(
    Map<String, dynamic> json) {
  final EtfPositionRecordEntity etfPositionRecordEntity = EtfPositionRecordEntity();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    etfPositionRecordEntity.count = count;
  }
  final List<
      EtfPositionRecordEtfPositionRecordList>? etfPositionRecordList = (json['etfPositionRecordList'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<EtfPositionRecordEtfPositionRecordList>(
          e) as EtfPositionRecordEtfPositionRecordList).toList();
  if (etfPositionRecordList != null) {
    etfPositionRecordEntity.etfPositionRecordList = etfPositionRecordList;
  }
  return etfPositionRecordEntity;
}

Map<String, dynamic> $EtfPositionRecordEntityToJson(
    EtfPositionRecordEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['etfPositionRecordList'] =
      entity.etfPositionRecordList?.map((v) => v.toJson()).toList();
  return data;
}

extension EtfPositionRecordEntityExtension on EtfPositionRecordEntity {
  EtfPositionRecordEntity copyWith({
    int? count,
    List<EtfPositionRecordEtfPositionRecordList>? etfPositionRecordList,
  }) {
    return EtfPositionRecordEntity()
      ..count = count ?? this.count
      ..etfPositionRecordList = etfPositionRecordList ??
          this.etfPositionRecordList;
  }
}

EtfPositionRecordEtfPositionRecordList $EtfPositionRecordEtfPositionRecordListFromJson(
    Map<String, dynamic> json) {
  final EtfPositionRecordEtfPositionRecordList etfPositionRecordEtfPositionRecordList = EtfPositionRecordEtfPositionRecordList();
  final String? symbol = jsonConvert.convert<String>(json['symbol']);
  if (symbol != null) {
    etfPositionRecordEtfPositionRecordList.symbol = symbol;
  }
  final String? base = jsonConvert.convert<String>(json['base']);
  if (base != null) {
    etfPositionRecordEtfPositionRecordList.base = base;
  }
  final String? quote = jsonConvert.convert<String>(json['quote']);
  if (quote != null) {
    etfPositionRecordEtfPositionRecordList.quote = quote;
  }
  final String? beforeContractValue = jsonConvert.convert<String>(
      json['beforeContractValue']);
  if (beforeContractValue != null) {
    etfPositionRecordEtfPositionRecordList.beforeContractValue =
        beforeContractValue;
  }
  final String? afterContractValue = jsonConvert.convert<String>(
      json['afterContractValue']);
  if (afterContractValue != null) {
    etfPositionRecordEtfPositionRecordList.afterContractValue =
        afterContractValue;
  }
  final String? beforeLever = jsonConvert.convert<String>(json['beforeLever']);
  if (beforeLever != null) {
    etfPositionRecordEtfPositionRecordList.beforeLever = beforeLever;
  }
  final String? afterLever = jsonConvert.convert<String>(json['afterLever']);
  if (afterLever != null) {
    etfPositionRecordEtfPositionRecordList.afterLever = afterLever;
  }
  final String? netValue = jsonConvert.convert<String>(json['netValue']);
  if (netValue != null) {
    etfPositionRecordEtfPositionRecordList.netValue = netValue;
  }
  final int? adjustTime = jsonConvert.convert<int>(json['adjustTime']);
  if (adjustTime != null) {
    etfPositionRecordEtfPositionRecordList.adjustTime = adjustTime;
  }
  final int? type = jsonConvert.convert<int>(json['type']);
  if (type != null) {
    etfPositionRecordEtfPositionRecordList.type = type;
  }
  return etfPositionRecordEtfPositionRecordList;
}

Map<String, dynamic> $EtfPositionRecordEtfPositionRecordListToJson(
    EtfPositionRecordEtfPositionRecordList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['symbol'] = entity.symbol;
  data['base'] = entity.base;
  data['quote'] = entity.quote;
  data['beforeContractValue'] = entity.beforeContractValue;
  data['afterContractValue'] = entity.afterContractValue;
  data['beforeLever'] = entity.beforeLever;
  data['afterLever'] = entity.afterLever;
  data['netValue'] = entity.netValue;
  data['adjustTime'] = entity.adjustTime;
  data['type'] = entity.type;
  return data;
}

extension EtfPositionRecordEtfPositionRecordListExtension on EtfPositionRecordEtfPositionRecordList {
  EtfPositionRecordEtfPositionRecordList copyWith({
    String? symbol,
    String? base,
    String? quote,
    String? beforeContractValue,
    String? afterContractValue,
    String? beforeLever,
    String? afterLever,
    String? netValue,
    int? adjustTime,
    int? type,
  }) {
    return EtfPositionRecordEtfPositionRecordList()
      ..symbol = symbol ?? this.symbol
      ..base = base ?? this.base
      ..quote = quote ?? this.quote
      ..beforeContractValue = beforeContractValue ?? this.beforeContractValue
      ..afterContractValue = afterContractValue ?? this.afterContractValue
      ..beforeLever = beforeLever ?? this.beforeLever
      ..afterLever = afterLever ?? this.afterLever
      ..netValue = netValue ?? this.netValue
      ..adjustTime = adjustTime ?? this.adjustTime
      ..type = type ?? this.type;
  }
}