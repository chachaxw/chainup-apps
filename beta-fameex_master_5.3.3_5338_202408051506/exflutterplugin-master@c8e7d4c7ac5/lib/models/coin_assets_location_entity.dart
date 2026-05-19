import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'coin_assets_location_entity.g.dart';

@JsonSerializable()
class CoinAssetsLocationEntity {
  ///币种资产分布列表
  List<SingleCoinAssetsLocationEntity>? list;

  CoinAssetsLocationEntity();

  factory CoinAssetsLocationEntity.fromJson(Map<String, dynamic> json) =>
      _$CoinAssetsLocationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CoinAssetsLocationEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SingleCoinAssetsLocationEntity {
  ///币种
  String? coinSymbol;

  ///百分比  已经乘100之后的值
  double? proportion;

  ///币种金额
  double? amount;

  ///折算btc之后的金额
  double? changeBtcAmount;

  SingleCoinAssetsLocationEntity();

  factory SingleCoinAssetsLocationEntity.fromJson(Map<String, dynamic> json) =>
      _$SingleCoinAssetsLocationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SingleCoinAssetsLocationEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
