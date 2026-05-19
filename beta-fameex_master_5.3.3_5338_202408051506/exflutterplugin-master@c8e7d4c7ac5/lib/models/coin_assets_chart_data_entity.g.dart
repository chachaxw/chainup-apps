// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_assets_chart_data_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinAssetsChartListEntity _$CoinAssetsChartListEntityFromJson(
        Map<String, dynamic> json) =>
    CoinAssetsChartListEntity()
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) =>
              CoinAssetsChartDataEntity.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CoinAssetsChartListEntityToJson(
        CoinAssetsChartListEntity instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

CoinAssetsChartDataEntity _$CoinAssetsChartDataEntityFromJson(
        Map<String, dynamic> json) =>
    CoinAssetsChartDataEntity()
      ..date = json['date'] as String?
      ..profit = (json['profit'] as num?)?.toDouble()
      ..cumulativeIncome = (json['cumulativeIncome'] as num?)?.toDouble()
      ..cumulativeRageReturn =
          (json['cumulativeRageReturn'] as num?)?.toDouble()
      ..btcCumulativeRate = (json['btcCumulativeRate'] as num?)?.toDouble()
      ..totalBalance = (json['totalBalance'] as num?)?.toDouble();

Map<String, dynamic> _$CoinAssetsChartDataEntityToJson(
        CoinAssetsChartDataEntity instance) =>
    <String, dynamic>{
      'date': instance.date,
      'profit': instance.profit,
      'cumulativeIncome': instance.cumulativeIncome,
      'cumulativeRageReturn': instance.cumulativeRageReturn,
      'btcCumulativeRate': instance.btcCumulativeRate,
      'totalBalance': instance.totalBalance,
    };
