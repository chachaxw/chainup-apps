import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_asset_profit_loss_data_lever_entity.g.dart';

@JsonSerializable()
class UserAssetProfitLossDataListEntity {
  ///时间string
  List<UserAssetProfitLossDataLeverEntity>? userAssetProfitLossDataLeverList;

  UserAssetProfitLossDataListEntity();

  factory UserAssetProfitLossDataListEntity.fromJson(
          Map<String, dynamic> json) =>
      _$UserAssetProfitLossDataListEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserAssetProfitLossDataListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserAssetProfitLossDataLeverEntity {
  ///时间时间戳
  int? curDate;

  ///时间string
  String? curDateStr;

  ///单日盈亏(usdt)
  double? curProfit;

  ///单日盈亏(btc)
  String? curProfitBTC;

  ///单日盈亏(USDT)
  String? curProfitUSDT;

  ///累计盈亏(usdt)
  double? cumulativeProfit;

  ///累计盈亏(btc)
  String? cumulativeProfitBTC;

  ///累计盈亏(USDT)
  String? cumulativeProfitUSDT;

  ///累计盈亏比
  double? cumulativeProfitRatio;

  ///净划入(usdt)
  double? pureCome;

  ///净划入(btc)
  String? pureComeBTC;

  ///净划入(usdt)
  String? pureComeUSDT;

  ///账户权益(usdt)
  double? accountEquity;

  ///账户权益(btc)
  String? accountEquityBTC;

  ///账户权益(usdt)
  String? accountEquityUSDT;

  ///总负债(usdt)
  double? totalDebt;

  ///总负债(btc)
  double? totalDebtBTC;

  ///无用
  double? sumTotalBeginUsdt;

  ///期间总流入(usdt)
  double? sumTotalTransferComeUsdt;

  ///总资产(usdt)
  double? totalBalance;

  UserAssetProfitLossDataLeverEntity();

  factory UserAssetProfitLossDataLeverEntity.fromJson(
          Map<String, dynamic> json) =>
      _$UserAssetProfitLossDataLeverEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserAssetProfitLossDataLeverEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
