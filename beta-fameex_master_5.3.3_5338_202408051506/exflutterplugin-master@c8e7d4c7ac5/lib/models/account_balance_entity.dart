import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'account_balance_entity.g.dart';

@JsonSerializable()
class AccountBalanceEntity {
  ///总资产折合单位
  String? totalBalanceSymbol;

  ///总资产折合 单位BTC
  String? totalBalance;

  String? yesterdayProfit;

  String? yesterdayProfitRate;

  Map? allCoinMap;

  AccountBalanceEntity();

  factory AccountBalanceEntity.fromJson(Map<String, dynamic> json) =>
      _$AccountBalanceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBalanceEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
