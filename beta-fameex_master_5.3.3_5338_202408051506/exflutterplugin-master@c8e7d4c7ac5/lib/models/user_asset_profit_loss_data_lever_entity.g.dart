// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_asset_profit_loss_data_lever_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAssetProfitLossDataListEntity _$UserAssetProfitLossDataListEntityFromJson(
        Map<String, dynamic> json) =>
    UserAssetProfitLossDataListEntity()
      ..userAssetProfitLossDataLeverList =
          (json['userAssetProfitLossDataLeverList'] as List<dynamic>?)
              ?.map((e) => UserAssetProfitLossDataLeverEntity.fromJson(
                  e as Map<String, dynamic>))
              .toList();

Map<String, dynamic> _$UserAssetProfitLossDataListEntityToJson(
        UserAssetProfitLossDataListEntity instance) =>
    <String, dynamic>{
      'userAssetProfitLossDataLeverList':
          instance.userAssetProfitLossDataLeverList,
    };

UserAssetProfitLossDataLeverEntity _$UserAssetProfitLossDataLeverEntityFromJson(
        Map<String, dynamic> json) =>
    UserAssetProfitLossDataLeverEntity()
      ..curDate = json['curDate'] as int?
      ..curDateStr = json['curDateStr'] as String?
      ..curProfit = (json['curProfit'] as num?)?.toDouble()
      ..curProfitBTC = json['curProfitBTC'] as String?
      ..curProfitUSDT = json['curProfitUSDT'] as String?
      ..cumulativeProfit = (json['cumulativeProfit'] as num?)?.toDouble()
      ..cumulativeProfitBTC = json['cumulativeProfitBTC'] as String?
      ..cumulativeProfitUSDT = json['cumulativeProfitUSDT'] as String?
      ..cumulativeProfitRatio =
          (json['cumulativeProfitRatio'] as num?)?.toDouble()
      ..pureCome = (json['pureCome'] as num?)?.toDouble()
      ..pureComeBTC = json['pureComeBTC'] as String?
      ..pureComeUSDT = json['pureComeUSDT'] as String?
      ..accountEquity = (json['accountEquity'] as num?)?.toDouble()
      ..accountEquityBTC = json['accountEquityBTC'] as String?
      ..accountEquityUSDT = json['accountEquityUSDT'] as String?
      ..totalDebt = (json['totalDebt'] as num?)?.toDouble()
      ..totalDebtBTC = (json['totalDebtBTC'] as num?)?.toDouble()
      ..sumTotalBeginUsdt = (json['sumTotalBeginUsdt'] as num?)?.toDouble()
      ..sumTotalTransferComeUsdt =
          (json['sumTotalTransferComeUsdt'] as num?)?.toDouble()
      ..totalBalance = (json['totalBalance'] as num?)?.toDouble();

Map<String, dynamic> _$UserAssetProfitLossDataLeverEntityToJson(
        UserAssetProfitLossDataLeverEntity instance) =>
    <String, dynamic>{
      'curDate': instance.curDate,
      'curDateStr': instance.curDateStr,
      'curProfit': instance.curProfit,
      'curProfitBTC': instance.curProfitBTC,
      'curProfitUSDT': instance.curProfitUSDT,
      'cumulativeProfit': instance.cumulativeProfit,
      'cumulativeProfitBTC': instance.cumulativeProfitBTC,
      'cumulativeProfitUSDT': instance.cumulativeProfitUSDT,
      'cumulativeProfitRatio': instance.cumulativeProfitRatio,
      'pureCome': instance.pureCome,
      'pureComeBTC': instance.pureComeBTC,
      'pureComeUSDT': instance.pureComeUSDT,
      'accountEquity': instance.accountEquity,
      'accountEquityBTC': instance.accountEquityBTC,
      'accountEquityUSDT': instance.accountEquityUSDT,
      'totalDebt': instance.totalDebt,
      'totalDebtBTC': instance.totalDebtBTC,
      'sumTotalBeginUsdt': instance.sumTotalBeginUsdt,
      'sumTotalTransferComeUsdt': instance.sumTotalTransferComeUsdt,
      'totalBalance': instance.totalBalance,
    };
