import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/kline_buy_sell_entity.dart';
import 'package:json_annotation/json_annotation.dart';


KlineBuySellListEntity $KlineBuySellListEntityFromJson(
    Map<String, dynamic> json) {
  final KlineBuySellListEntity klineBuySellListEntity = KlineBuySellListEntity();
  final List<
      KlineBuySellEntity>? klineBuySellData = (json['klineBuySellData'] as List<
      dynamic>?)
      ?.map(
          (e) =>
      jsonConvert.convert<KlineBuySellEntity>(e) as KlineBuySellEntity)
      .toList();
  if (klineBuySellData != null) {
    klineBuySellListEntity.klineBuySellData = klineBuySellData;
  }
  return klineBuySellListEntity;
}

Map<String, dynamic> $KlineBuySellListEntityToJson(
    KlineBuySellListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['klineBuySellData'] =
      entity.klineBuySellData?.map((v) => v.toJson()).toList();
  return data;
}

extension KlineBuySellListEntityExtension on KlineBuySellListEntity {
  KlineBuySellListEntity copyWith({
    List<KlineBuySellEntity>? klineBuySellData,
  }) {
    return KlineBuySellListEntity()
      ..klineBuySellData = klineBuySellData ?? this.klineBuySellData;
  }
}

KlineBuySellEntity $KlineBuySellEntityFromJson(Map<String, dynamic> json) {
  final KlineBuySellEntity klineBuySellEntity = KlineBuySellEntity();
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    klineBuySellEntity.price = price;
  }
  final int? ctime = jsonConvert.convert<int>(json['ctime']);
  if (ctime != null) {
    klineBuySellEntity.ctime = ctime;
  }
  final bool? isBuy = jsonConvert.convert<bool>(json['isBuy']);
  if (isBuy != null) {
    klineBuySellEntity.isBuy = isBuy;
  }
  final String? vol = jsonConvert.convert<String>(json['vol']);
  if (vol != null) {
    klineBuySellEntity.vol = vol;
  }
  return klineBuySellEntity;
}

Map<String, dynamic> $KlineBuySellEntityToJson(KlineBuySellEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['price'] = entity.price;
  data['ctime'] = entity.ctime;
  data['isBuy'] = entity.isBuy;
  data['vol'] = entity.vol;
  return data;
}

extension KlineBuySellEntityExtension on KlineBuySellEntity {
  KlineBuySellEntity copyWith({
    String? price,
    int? ctime,
    bool? isBuy,
    String? vol,
  }) {
    return KlineBuySellEntity()
      ..price = price ?? this.price
      ..ctime = ctime ?? this.ctime
      ..isBuy = isBuy ?? this.isBuy
      ..vol = vol ?? this.vol;
  }
}