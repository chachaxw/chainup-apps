import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/reward_center_index_entity.dart';
import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';

import 'package:json_annotation/json_annotation.dart';


RewardCenterIndexEntity $RewardCenterIndexEntityFromJson(
    Map<String, dynamic> json) {
  final RewardCenterIndexEntity rewardCenterIndexEntity = RewardCenterIndexEntity();
  final String? unWithdrawAmount = jsonConvert.convert<String>(
      json['unWithdrawAmount']);
  if (unWithdrawAmount != null) {
    rewardCenterIndexEntity.unWithdrawAmount = unWithdrawAmount;
  }
  final String? withdrewAmount = jsonConvert.convert<String>(
      json['withdrewAmount']);
  if (withdrewAmount != null) {
    rewardCenterIndexEntity.withdrewAmount = withdrewAmount;
  }
  final String? minWithdrawAmount = jsonConvert.convert<String>(
      json['minWithdrawAmount']);
  if (minWithdrawAmount != null) {
    rewardCenterIndexEntity.minWithdrawAmount = minWithdrawAmount;
  }
  final List<
      WithdrawInfoListItemEntity>? withdrawInfoList = (json['withdrawInfoList'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<WithdrawInfoListItemEntity>(
          e) as WithdrawInfoListItemEntity).toList();
  if (withdrawInfoList != null) {
    rewardCenterIndexEntity.withdrawInfoList = withdrawInfoList;
  }
  return rewardCenterIndexEntity;
}

Map<String, dynamic> $RewardCenterIndexEntityToJson(
    RewardCenterIndexEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['unWithdrawAmount'] = entity.unWithdrawAmount;
  data['withdrewAmount'] = entity.withdrewAmount;
  data['minWithdrawAmount'] = entity.minWithdrawAmount;
  data['withdrawInfoList'] =
      entity.withdrawInfoList?.map((v) => v.toJson()).toList();
  return data;
}

extension RewardCenterIndexEntityExtension on RewardCenterIndexEntity {
  RewardCenterIndexEntity copyWith({
    String? unWithdrawAmount,
    String? withdrewAmount,
    String? minWithdrawAmount,
    List<WithdrawInfoListItemEntity>? withdrawInfoList,
  }) {
    return RewardCenterIndexEntity()
      ..unWithdrawAmount = unWithdrawAmount ?? this.unWithdrawAmount
      ..withdrewAmount = withdrewAmount ?? this.withdrewAmount
      ..minWithdrawAmount = minWithdrawAmount ?? this.minWithdrawAmount
      ..withdrawInfoList = withdrawInfoList ?? this.withdrawInfoList;
  }
}

WithdrawInfoList $WithdrawInfoListFromJson(Map<String, dynamic> json) {
  final WithdrawInfoList withdrawInfoList = WithdrawInfoList();
  final String? coin = jsonConvert.convert<String>(json['coin']);
  if (coin != null) {
    withdrawInfoList.coin = coin;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    withdrawInfoList.amount = amount;
  }
  return withdrawInfoList;
}

Map<String, dynamic> $WithdrawInfoListToJson(WithdrawInfoList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coin'] = entity.coin;
  data['amount'] = entity.amount;
  return data;
}

extension WithdrawInfoListExtension on WithdrawInfoList {
  WithdrawInfoList copyWith({
    String? coin,
    String? amount,
  }) {
    return WithdrawInfoList()
      ..coin = coin ?? this.coin
      ..amount = amount ?? this.amount;
  }
}