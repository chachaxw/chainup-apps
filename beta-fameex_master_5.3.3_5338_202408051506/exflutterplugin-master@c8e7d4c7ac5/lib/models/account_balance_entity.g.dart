// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_balance_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBalanceEntity _$AccountBalanceEntityFromJson(
        Map<String, dynamic> json) =>
    AccountBalanceEntity()
      ..totalBalanceSymbol = json['totalBalanceSymbol'] as String?
      ..totalBalance = json['totalBalance'] as String?
      ..yesterdayProfit = json['yesterdayProfit'] as String?
      ..yesterdayProfitRate = json['yesterdayProfitRate'] as String?
      ..allCoinMap = json['allCoinMap'] as Map<String, dynamic>?;

Map<String, dynamic> _$AccountBalanceEntityToJson(
        AccountBalanceEntity instance) =>
    <String, dynamic>{
      'totalBalanceSymbol': instance.totalBalanceSymbol,
      'totalBalance': instance.totalBalance,
      'yesterdayProfit': instance.yesterdayProfit,
      'yesterdayProfitRate': instance.yesterdayProfitRate,
      'allCoinMap': instance.allCoinMap,
    };
