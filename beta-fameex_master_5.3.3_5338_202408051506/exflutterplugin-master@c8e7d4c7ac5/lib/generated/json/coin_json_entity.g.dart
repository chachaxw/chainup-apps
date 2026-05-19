import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/coin_json_entity.dart';

CoinJsonEntity $CoinJsonEntityFromJson(Map<String, dynamic> json) {
  final CoinJsonEntity coinJsonEntity = CoinJsonEntity();
  final double? limitVolumeMin = jsonConvert.convert<double>(
      json['limitVolumeMin']);
  if (limitVolumeMin != null) {
    coinJsonEntity.limitVolumeMin = limitVolumeMin;
  }
  final int? isOpenLever = jsonConvert.convert<int>(json['isOpenLever']);
  if (isOpenLever != null) {
    coinJsonEntity.isOpenLever = isOpenLever;
  }
  final String? symbol = jsonConvert.convert<String>(json['symbol']);
  if (symbol != null) {
    coinJsonEntity.symbol = symbol;
  }
  final String? baseLongName = jsonConvert.convert<String>(
      json['baseLongName']);
  if (baseLongName != null) {
    coinJsonEntity.baseLongName = baseLongName;
  }
  final String? etfSide = jsonConvert.convert<String>(json['etfSide']);
  if (etfSide != null) {
    coinJsonEntity.etfSide = etfSide;
  }
  final double? marketBuyMin = jsonConvert.convert<double>(
      json['marketBuyMin']);
  if (marketBuyMin != null) {
    coinJsonEntity.marketBuyMin = marketBuyMin;
  }
  final String? fundRate = jsonConvert.convert<String>(json['fundRate']);
  if (fundRate != null) {
    coinJsonEntity.fundRate = fundRate;
  }
  final double? marketSellMin = jsonConvert.convert<double>(
      json['marketSellMin']);
  if (marketSellMin != null) {
    coinJsonEntity.marketSellMin = marketSellMin;
  }
  final int? etfOpen = jsonConvert.convert<int>(json['etfOpen']);
  if (etfOpen != null) {
    coinJsonEntity.etfOpen = etfOpen;
  }
  final String? etfBase = jsonConvert.convert<String>(json['etfBase']);
  if (etfBase != null) {
    coinJsonEntity.etfBase = etfBase;
  }
  final int? isOvercharge = jsonConvert.convert<int>(json['isOvercharge']);
  if (isOvercharge != null) {
    coinJsonEntity.isOvercharge = isOvercharge;
  }
  final int? isOpenCross = jsonConvert.convert<int>(json['isOpenCross']);
  if (isOpenCross != null) {
    coinJsonEntity.isOpenCross = isOpenCross;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    coinJsonEntity.price = price;
  }
  final int? daySellLimit = jsonConvert.convert<int>(json['daySellLimit']);
  if (daySellLimit != null) {
    coinJsonEntity.daySellLimit = daySellLimit;
  }
  final String? etfMultiple = jsonConvert.convert<String>(json['etfMultiple']);
  if (etfMultiple != null) {
    coinJsonEntity.etfMultiple = etfMultiple;
  }
  final String? showName = jsonConvert.convert<String>(json['showName']);
  if (showName != null) {
    coinJsonEntity.showName = showName;
  }
  final int? isGridOpen = jsonConvert.convert<int>(json['is_grid_open']);
  if (isGridOpen != null) {
    coinJsonEntity.isGridOpen = isGridOpen;
  }
  final int? multiple = jsonConvert.convert<int>(json['multiple']);
  if (multiple != null) {
    coinJsonEntity.multiple = multiple;
  }
  final int? sort = jsonConvert.convert<int>(json['sort']);
  if (sort != null) {
    coinJsonEntity.sort = sort;
  }
  final int? newcoinFlag = jsonConvert.convert<int>(json['newcoinFlag']);
  if (newcoinFlag != null) {
    coinJsonEntity.newcoinFlag = newcoinFlag;
  }
  final int? volume = jsonConvert.convert<int>(json['volume']);
  if (volume != null) {
    coinJsonEntity.volume = volume;
  }
  final int? dayBuyLimit = jsonConvert.convert<int>(json['dayBuyLimit']);
  if (dayBuyLimit != null) {
    coinJsonEntity.dayBuyLimit = dayBuyLimit;
  }
  final String? depth = jsonConvert.convert<String>(json['depth']);
  if (depth != null) {
    coinJsonEntity.depth = depth;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    coinJsonEntity.name = name;
  }
  final double? limitPriceMin = jsonConvert.convert<double>(
      json['limitPriceMin']);
  if (limitPriceMin != null) {
    coinJsonEntity.limitPriceMin = limitPriceMin;
  }
  final bool? isEdited = jsonConvert.convert<bool>(json['isEdited']);
  if (isEdited != null) {
    coinJsonEntity.isEdited = isEdited;
  }
  return coinJsonEntity;
}

Map<String, dynamic> $CoinJsonEntityToJson(CoinJsonEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['limitVolumeMin'] = entity.limitVolumeMin;
  data['isOpenLever'] = entity.isOpenLever;
  data['symbol'] = entity.symbol;
  data['baseLongName'] = entity.baseLongName;
  data['etfSide'] = entity.etfSide;
  data['marketBuyMin'] = entity.marketBuyMin;
  data['fundRate'] = entity.fundRate;
  data['marketSellMin'] = entity.marketSellMin;
  data['etfOpen'] = entity.etfOpen;
  data['etfBase'] = entity.etfBase;
  data['isOvercharge'] = entity.isOvercharge;
  data['isOpenCross'] = entity.isOpenCross;
  data['price'] = entity.price;
  data['daySellLimit'] = entity.daySellLimit;
  data['etfMultiple'] = entity.etfMultiple;
  data['showName'] = entity.showName;
  data['is_grid_open'] = entity.isGridOpen;
  data['multiple'] = entity.multiple;
  data['sort'] = entity.sort;
  data['newcoinFlag'] = entity.newcoinFlag;
  data['volume'] = entity.volume;
  data['dayBuyLimit'] = entity.dayBuyLimit;
  data['depth'] = entity.depth;
  data['name'] = entity.name;
  data['limitPriceMin'] = entity.limitPriceMin;
  data['isEdited'] = entity.isEdited;
  return data;
}

extension CoinJsonEntityExtension on CoinJsonEntity {
  CoinJsonEntity copyWith({
    double? limitVolumeMin,
    int? isOpenLever,
    String? symbol,
    String? baseLongName,
    String? etfSide,
    double? marketBuyMin,
    String? fundRate,
    double? marketSellMin,
    int? etfOpen,
    String? etfBase,
    int? isOvercharge,
    int? isOpenCross,
    int? price,
    int? daySellLimit,
    String? etfMultiple,
    String? showName,
    int? isGridOpen,
    int? multiple,
    int? sort,
    int? newcoinFlag,
    int? volume,
    int? dayBuyLimit,
    String? depth,
    String? name,
    double? limitPriceMin,
    bool? isEdited,
  }) {
    return CoinJsonEntity()
      ..limitVolumeMin = limitVolumeMin ?? this.limitVolumeMin
      ..isOpenLever = isOpenLever ?? this.isOpenLever
      ..symbol = symbol ?? this.symbol
      ..baseLongName = baseLongName ?? this.baseLongName
      ..etfSide = etfSide ?? this.etfSide
      ..marketBuyMin = marketBuyMin ?? this.marketBuyMin
      ..fundRate = fundRate ?? this.fundRate
      ..marketSellMin = marketSellMin ?? this.marketSellMin
      ..etfOpen = etfOpen ?? this.etfOpen
      ..etfBase = etfBase ?? this.etfBase
      ..isOvercharge = isOvercharge ?? this.isOvercharge
      ..isOpenCross = isOpenCross ?? this.isOpenCross
      ..price = price ?? this.price
      ..daySellLimit = daySellLimit ?? this.daySellLimit
      ..etfMultiple = etfMultiple ?? this.etfMultiple
      ..showName = showName ?? this.showName
      ..isGridOpen = isGridOpen ?? this.isGridOpen
      ..multiple = multiple ?? this.multiple
      ..sort = sort ?? this.sort
      ..newcoinFlag = newcoinFlag ?? this.newcoinFlag
      ..volume = volume ?? this.volume
      ..dayBuyLimit = dayBuyLimit ?? this.dayBuyLimit
      ..depth = depth ?? this.depth
      ..name = name ?? this.name
      ..limitPriceMin = limitPriceMin ?? this.limitPriceMin
      ..isEdited = isEdited ?? this.isEdited;
  }
}