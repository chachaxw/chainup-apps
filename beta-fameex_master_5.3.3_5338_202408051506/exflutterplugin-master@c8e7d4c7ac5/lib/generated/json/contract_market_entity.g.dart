import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/contract_market_entity.dart';
import 'package:json_annotation/json_annotation.dart';


ContractMarketEntity $ContractMarketEntityFromJson(Map<String, dynamic> json) {
  final ContractMarketEntity contractMarketEntity = ContractMarketEntity();
  final dynamic currentFundRate = json['currentFundRate'];
  if (currentFundRate != null) {
    contractMarketEntity.currentFundRate = currentFundRate;
  }
  final dynamic indexPrice = json['indexPrice'];
  if (indexPrice != null) {
    contractMarketEntity.indexPrice = indexPrice;
  }
  final dynamic tagPrice = json['tagPrice'];
  if (tagPrice != null) {
    contractMarketEntity.tagPrice = tagPrice;
  }
  final dynamic nextFundRate = json['nextFundRate'];
  if (nextFundRate != null) {
    contractMarketEntity.nextFundRate = nextFundRate;
  }
  final String? showIndexPrice = jsonConvert.convert<String>(
      json['showIndexPrice']);
  if (showIndexPrice != null) {
    contractMarketEntity.showIndexPrice = showIndexPrice;
  }
  final String? showTagPrice = jsonConvert.convert<String>(
      json['showTagPrice']);
  if (showTagPrice != null) {
    contractMarketEntity.showTagPrice = showTagPrice;
  }
  final String? showNextFundRate = jsonConvert.convert<String>(
      json['showNextFundRate']);
  if (showNextFundRate != null) {
    contractMarketEntity.showNextFundRate = showNextFundRate;
  }
  final String? showCurrentFundRate = jsonConvert.convert<String>(
      json['showCurrentFundRate']);
  if (showCurrentFundRate != null) {
    contractMarketEntity.showCurrentFundRate = showCurrentFundRate;
  }
  return contractMarketEntity;
}

Map<String, dynamic> $ContractMarketEntityToJson(ContractMarketEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['currentFundRate'] = entity.currentFundRate;
  data['indexPrice'] = entity.indexPrice;
  data['tagPrice'] = entity.tagPrice;
  data['nextFundRate'] = entity.nextFundRate;
  data['showIndexPrice'] = entity.showIndexPrice;
  data['showTagPrice'] = entity.showTagPrice;
  data['showNextFundRate'] = entity.showNextFundRate;
  data['showCurrentFundRate'] = entity.showCurrentFundRate;
  return data;
}

extension ContractMarketEntityExtension on ContractMarketEntity {
  ContractMarketEntity copyWith({
    dynamic currentFundRate,
    dynamic indexPrice,
    dynamic tagPrice,
    dynamic nextFundRate,
    String? showIndexPrice,
    String? showTagPrice,
    String? showNextFundRate,
    String? showCurrentFundRate,
  }) {
    return ContractMarketEntity()
      ..currentFundRate = currentFundRate ?? this.currentFundRate
      ..indexPrice = indexPrice ?? this.indexPrice
      ..tagPrice = tagPrice ?? this.tagPrice
      ..nextFundRate = nextFundRate ?? this.nextFundRate
      ..showIndexPrice = showIndexPrice ?? this.showIndexPrice
      ..showTagPrice = showTagPrice ?? this.showTagPrice
      ..showNextFundRate = showNextFundRate ?? this.showNextFundRate
      ..showCurrentFundRate = showCurrentFundRate ?? this.showCurrentFundRate;
  }
}