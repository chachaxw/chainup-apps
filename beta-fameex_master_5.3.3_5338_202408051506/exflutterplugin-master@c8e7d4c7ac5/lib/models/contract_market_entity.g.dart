// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_market_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractMarketEntity _$ContractMarketEntityFromJson(
        Map<String, dynamic> json) =>
    ContractMarketEntity()
      ..currentFundRate = json['currentFundRate']
      ..indexPrice = json['indexPrice']
      ..tagPrice = json['tagPrice']
      ..nextFundRate = json['nextFundRate']
      ..showIndexPrice = json['showIndexPrice'] as String?
      ..showTagPrice = json['showTagPrice'] as String?
      ..showNextFundRate = json['showNextFundRate'] as String?
      ..showCurrentFundRate = json['showCurrentFundRate'] as String?;

Map<String, dynamic> _$ContractMarketEntityToJson(
        ContractMarketEntity instance) =>
    <String, dynamic>{
      'currentFundRate': instance.currentFundRate,
      'indexPrice': instance.indexPrice,
      'tagPrice': instance.tagPrice,
      'nextFundRate': instance.nextFundRate,
      'showIndexPrice': instance.showIndexPrice,
      'showTagPrice': instance.showTagPrice,
      'showNextFundRate': instance.showNextFundRate,
      'showCurrentFundRate': instance.showCurrentFundRate,
    };
