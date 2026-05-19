// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_assets_location_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinAssetsLocationEntity _$CoinAssetsLocationEntityFromJson(
        Map<String, dynamic> json) =>
    CoinAssetsLocationEntity()
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) => SingleCoinAssetsLocationEntity.fromJson(
              e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CoinAssetsLocationEntityToJson(
        CoinAssetsLocationEntity instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

SingleCoinAssetsLocationEntity _$SingleCoinAssetsLocationEntityFromJson(
        Map<String, dynamic> json) =>
    SingleCoinAssetsLocationEntity()
      ..coinSymbol = json['coinSymbol'] as String?
      ..proportion = (json['proportion'] as num?)?.toDouble()
      ..amount = (json['amount'] as num?)?.toDouble()
      ..changeBtcAmount = (json['changeBtcAmount'] as num?)?.toDouble();

Map<String, dynamic> _$SingleCoinAssetsLocationEntityToJson(
        SingleCoinAssetsLocationEntity instance) =>
    <String, dynamic>{
      'coinSymbol': instance.coinSymbol,
      'proportion': instance.proportion,
      'amount': instance.amount,
      'changeBtcAmount': instance.changeBtcAmount,
    };
