import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'coin_assets_chart_data_entity.g.dart';

@JsonSerializable()
class CoinAssetsChartListEntity {
  List<CoinAssetsChartDataEntity>? list;

  CoinAssetsChartListEntity();

  factory CoinAssetsChartListEntity.fromJson(Map<String, dynamic> json) =>
      _$CoinAssetsChartListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CoinAssetsChartListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class CoinAssetsChartDataEntity {
  ///日期："2022-03-28 00:00:00"
  String? date;

  ///收益金额
  double? profit;

  ///累计收益
  double? cumulativeIncome;

  ///累计收益率
  double? cumulativeRageReturn;

  ///btc累计涨幅率
  double? btcCumulativeRate;

  ///总资产
  double? totalBalance;

  CoinAssetsChartDataEntity();

  factory CoinAssetsChartDataEntity.fromJson(Map<String, dynamic> json) =>
      _$CoinAssetsChartDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CoinAssetsChartDataEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
