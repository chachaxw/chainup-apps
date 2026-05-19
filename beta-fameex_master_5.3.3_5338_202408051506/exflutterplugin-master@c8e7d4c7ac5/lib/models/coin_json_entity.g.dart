// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_json_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinJsonEntity _$CoinJsonEntityFromJson(Map<String, dynamic> json) =>
    CoinJsonEntity()
      ..limitVolumeMin = (json['limitVolumeMin'] as num?)?.toDouble()
      ..isOpenLever = json['isOpenLever'] as int?
      ..symbol = json['symbol'] as String?
      ..baseLongName = json['baseLongName'] as String?
      ..etfSide = json['etfSide'] as String?
      ..marketBuyMin = (json['marketBuyMin'] as num?)?.toDouble()
      ..fundRate = json['fundRate'] as String?
      ..marketSellMin = (json['marketSellMin'] as num?)?.toDouble()
      ..etfOpen = json['etfOpen'] as int?
      ..etfBase = json['etfBase'] as String?
      ..isOvercharge = json['isOvercharge'] as int?
      ..isOpenCross = json['isOpenCross'] as int?
      ..price = json['price'] as int?
      ..daySellLimit = json['daySellLimit'] as int?
      ..etfMultiple = json['etfMultiple'] as String?
      ..showName = json['showName'] as String?
      ..isGridOpen = json['is_grid_open'] as int?
      ..multiple = json['multiple'] as int?
      ..sort = json['sort'] as int?
      ..newcoinFlag = json['newcoinFlag'] as int?
      ..volume = json['volume'] as int?
      ..dayBuyLimit = json['dayBuyLimit'] as int?
      ..depth = json['depth'] as String?
      ..name = json['name'] as String?
      ..limitPriceMin = (json['limitPriceMin'] as num?)?.toDouble()
      ..isEdited = json['isEdited'] as bool?;

Map<String, dynamic> _$CoinJsonEntityToJson(CoinJsonEntity instance) =>
    <String, dynamic>{
      'limitVolumeMin': instance.limitVolumeMin,
      'isOpenLever': instance.isOpenLever,
      'symbol': instance.symbol,
      'baseLongName': instance.baseLongName,
      'etfSide': instance.etfSide,
      'marketBuyMin': instance.marketBuyMin,
      'fundRate': instance.fundRate,
      'marketSellMin': instance.marketSellMin,
      'etfOpen': instance.etfOpen,
      'etfBase': instance.etfBase,
      'isOvercharge': instance.isOvercharge,
      'isOpenCross': instance.isOpenCross,
      'price': instance.price,
      'daySellLimit': instance.daySellLimit,
      'etfMultiple': instance.etfMultiple,
      'showName': instance.showName,
      'is_grid_open': instance.isGridOpen,
      'multiple': instance.multiple,
      'sort': instance.sort,
      'newcoinFlag': instance.newcoinFlag,
      'volume': instance.volume,
      'dayBuyLimit': instance.dayBuyLimit,
      'depth': instance.depth,
      'name': instance.name,
      'limitPriceMin': instance.limitPriceMin,
      'isEdited': instance.isEdited,
    };
