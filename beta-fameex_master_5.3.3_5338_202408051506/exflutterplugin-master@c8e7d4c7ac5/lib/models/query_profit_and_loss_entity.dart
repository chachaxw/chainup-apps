import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'query_profit_and_loss_entity.g.dart';

@JsonSerializable()
class ProfitAndLossDataResListEntity {
  List<SingleCoinAssetsChartEntity>? profitAndLossDataResList;

  ProfitAndLossDataResListEntity();

  factory ProfitAndLossDataResListEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfitAndLossDataResListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfitAndLossDataResListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SingleCoinProfitEntity {
  SingleCoinAssetsChartEntity? profitAndLossDataRes;

  SingleCoinProfitEntity();

  factory SingleCoinProfitEntity.fromJson(Map<String, dynamic> json) =>
      _$SingleCoinProfitEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SingleCoinProfitEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SingleCoinAssetsChartEntity {
  ///盈亏金额  (除了单币种都是USDT)
  double? amountOfProfitOrLoss;

  ///盈亏比
  double? profitAndLossRatio;

  ///盈亏单位(除了单币种都是USDT)
  String? valuationCoinSymbol;

  double? sumTotalBegin;

  double? sumTotalTransferCome;

  int? statisticsStartTime;

  String? statisticsStartTimeUtc;

  SingleCoinAssetsChartEntity();

  factory SingleCoinAssetsChartEntity.fromJson(Map<String, dynamic> json) =>
      _$SingleCoinAssetsChartEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SingleCoinAssetsChartEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
