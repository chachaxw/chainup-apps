// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_coin_assets_chart_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleCoinAssetsChartEntity _$SingleCoinAssetsChartEntityFromJson(
        Map<String, dynamic> json) =>
    SingleCoinAssetsChartEntity()
      ..date = json['date'] as String?
      ..totalBalance = (json['totalBalance'] as num?)?.toDouble()
      ..profit = (json['profit'] as num?)?.toDouble()
      ..cumulativeIncome = (json['cumulativeIncome'] as num?)?.toDouble()
      ..cumulativeRageReturn =
          (json['cumulativeRageReturn'] as num?)?.toDouble()
      ..totalInflow = (json['totalInflow'] as num?)?.toDouble()
      ..totalOutflow = (json['totalOutflow'] as num?)?.toDouble()
      ..btcCumulativeRate = (json['btcCumulativeRate'] as num?)?.toDouble();

Map<String, dynamic> _$SingleCoinAssetsChartEntityToJson(
        SingleCoinAssetsChartEntity instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalBalance': instance.totalBalance,
      'profit': instance.profit,
      'cumulativeIncome': instance.cumulativeIncome,
      'cumulativeRageReturn': instance.cumulativeRageReturn,
      'totalInflow': instance.totalInflow,
      'totalOutflow': instance.totalOutflow,
      'btcCumulativeRate': instance.btcCumulativeRate,
    };
