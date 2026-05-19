import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';


WithdrawInfoListEntity $WithdrawInfoListEntityFromJson(
    Map<String, dynamic> json) {
  final WithdrawInfoListEntity withdrawInfoListEntity = WithdrawInfoListEntity();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    withdrawInfoListEntity.count = count;
  }
  final List<WithdrawInfoListItemEntity>? list = (json['list'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<WithdrawInfoListItemEntity>(
          e) as WithdrawInfoListItemEntity).toList();
  if (list != null) {
    withdrawInfoListEntity.list = list;
  }
  return withdrawInfoListEntity;
}

Map<String, dynamic> $WithdrawInfoListEntityToJson(
    WithdrawInfoListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['list'] = entity.list?.map((v) => v.toJson()).toList();
  return data;
}

extension WithdrawInfoListEntityExtension on WithdrawInfoListEntity {
  WithdrawInfoListEntity copyWith({
    int? count,
    List<WithdrawInfoListItemEntity>? list,
  }) {
    return WithdrawInfoListEntity()
      ..count = count ?? this.count
      ..list = list ?? this.list;
  }
}

WithdrawInfoListItemEntity $WithdrawInfoListItemEntityFromJson(
    Map<String, dynamic> json) {
  final WithdrawInfoListItemEntity withdrawInfoListItemEntity = WithdrawInfoListItemEntity();
  final String? coin = jsonConvert.convert<String>(json['coin']);
  if (coin != null) {
    withdrawInfoListItemEntity.coin = coin;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    withdrawInfoListItemEntity.amount = amount;
  }
  final String? usdtAmount = jsonConvert.convert<String>(json['usdtAmount']);
  if (usdtAmount != null) {
    withdrawInfoListItemEntity.usdtAmount = usdtAmount;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    withdrawInfoListItemEntity.status = status;
  }
  final int? withdrawTime = jsonConvert.convert<int>(json['withdrawTime']);
  if (withdrawTime != null) {
    withdrawInfoListItemEntity.withdrawTime = withdrawTime;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    withdrawInfoListItemEntity.icon = icon;
  }
  final String? showName = jsonConvert.convert<String>(json['showName']);
  if (showName != null) {
    withdrawInfoListItemEntity.showName = showName;
  }
  return withdrawInfoListItemEntity;
}

Map<String, dynamic> $WithdrawInfoListItemEntityToJson(
    WithdrawInfoListItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coin'] = entity.coin;
  data['amount'] = entity.amount;
  data['usdtAmount'] = entity.usdtAmount;
  data['status'] = entity.status;
  data['withdrawTime'] = entity.withdrawTime;
  data['icon'] = entity.icon;
  data['showName'] = entity.showName;
  return data;
}

extension WithdrawInfoListItemEntityExtension on WithdrawInfoListItemEntity {
  WithdrawInfoListItemEntity copyWith({
    String? coin,
    String? amount,
    String? usdtAmount,
    int? status,
    int? withdrawTime,
    String? icon,
    String? showName,
  }) {
    return WithdrawInfoListItemEntity()
      ..coin = coin ?? this.coin
      ..amount = amount ?? this.amount
      ..usdtAmount = usdtAmount ?? this.usdtAmount
      ..status = status ?? this.status
      ..withdrawTime = withdrawTime ?? this.withdrawTime
      ..icon = icon ?? this.icon
      ..showName = showName ?? this.showName;
  }
}