// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_profit_and_loss_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfitAndLossDataResListEntity _$ProfitAndLossDataResListEntityFromJson(
        Map<String, dynamic> json) =>
    ProfitAndLossDataResListEntity()
      ..profitAndLossDataResList = (json['profitAndLossDataResList']
              as List<dynamic>?)
          ?.map((e) =>
              SingleCoinAssetsChartEntity.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ProfitAndLossDataResListEntityToJson(
        ProfitAndLossDataResListEntity instance) =>
    <String, dynamic>{
      'profitAndLossDataResList': instance.profitAndLossDataResList,
    };

SingleCoinProfitEntity _$SingleCoinProfitEntityFromJson(
        Map<String, dynamic> json) =>
    SingleCoinProfitEntity()
      ..profitAndLossDataRes = json['profitAndLossDataRes'] == null
          ? null
          : SingleCoinAssetsChartEntity.fromJson(
              json['profitAndLossDataRes'] as Map<String, dynamic>);

Map<String, dynamic> _$SingleCoinProfitEntityToJson(
        SingleCoinProfitEntity instance) =>
    <String, dynamic>{
      'profitAndLossDataRes': instance.profitAndLossDataRes,
    };

SingleCoinAssetsChartEntity _$SingleCoinAssetsChartEntityFromJson(
        Map<String, dynamic> json) =>
    SingleCoinAssetsChartEntity()
      ..amountOfProfitOrLoss =
          (json['amountOfProfitOrLoss'] as num?)?.toDouble()
      ..profitAndLossRatio = (json['profitAndLossRatio'] as num?)?.toDouble()
      ..valuationCoinSymbol = json['valuationCoinSymbol'] as String?
      ..sumTotalBegin = (json['sumTotalBegin'] as num?)?.toDouble()
      ..sumTotalTransferCome =
          (json['sumTotalTransferCome'] as num?)?.toDouble()
      ..statisticsStartTime = json['statisticsStartTime'] as int?
      ..statisticsStartTimeUtc = json['statisticsStartTimeUtc'] as String?;

Map<String, dynamic> _$SingleCoinAssetsChartEntityToJson(
        SingleCoinAssetsChartEntity instance) =>
    <String, dynamic>{
      'amountOfProfitOrLoss': instance.amountOfProfitOrLoss,
      'profitAndLossRatio': instance.profitAndLossRatio,
      'valuationCoinSymbol': instance.valuationCoinSymbol,
      'sumTotalBegin': instance.sumTotalBegin,
      'sumTotalTransferCome': instance.sumTotalTransferCome,
      'statisticsStartTime': instance.statisticsStartTime,
      'statisticsStartTimeUtc': instance.statisticsStartTimeUtc,
    };
