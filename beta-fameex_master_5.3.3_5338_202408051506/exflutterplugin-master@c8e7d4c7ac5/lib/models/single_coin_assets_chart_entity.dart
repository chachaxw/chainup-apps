import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'single_coin_assets_chart_entity.g.dart';

@JsonSerializable()
class SingleCoinAssetsChartEntity {
  ///日期 yyyy-MM-dd
  String? date;

  ///资产总值 (usdt)
  double? totalBalance;

  ///每日收益 (usdt)
  double? profit;

  ///累计收益 (usdt)
  double? cumulativeIncome;

  ///累计收益率
  double? cumulativeRageReturn;

  ///总流入
  double? totalInflow;

  ///总流出
  double? totalOutflow;

  ///btc累计涨幅率
  double? btcCumulativeRate;

  SingleCoinAssetsChartEntity();

  factory SingleCoinAssetsChartEntity.fromJson(Map<String, dynamic> json) =>
      _$SingleCoinAssetsChartEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SingleCoinAssetsChartEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
