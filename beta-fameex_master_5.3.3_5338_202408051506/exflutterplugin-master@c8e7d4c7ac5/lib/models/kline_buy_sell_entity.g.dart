// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline_buy_sell_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KlineBuySellListEntity _$KlineBuySellListEntityFromJson(
        Map<String, dynamic> json) =>
    KlineBuySellListEntity()
      ..klineBuySellData = (json['KlineBuySellData'] as List<dynamic>?)
          ?.map((e) => KlineBuySellEntity.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$KlineBuySellListEntityToJson(
        KlineBuySellListEntity instance) =>
    <String, dynamic>{
      'KlineBuySellData': instance.klineBuySellData,
    };

KlineBuySellEntity _$KlineBuySellEntityFromJson(Map<String, dynamic> json) =>
    KlineBuySellEntity()
      ..price = json['price'] as String?
      ..ctime = json['ctime'] as int?
      ..isBuy = json['isBuy'] as bool?
      ..vol = json['vol'] as String?;

Map<String, dynamic> _$KlineBuySellEntityToJson(KlineBuySellEntity instance) =>
    <String, dynamic>{
      'price': instance.price,
      'ctime': instance.ctime,
      'isBuy': instance.isBuy,
      'vol': instance.vol,
    };
