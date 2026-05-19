// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_center_index_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardCenterIndexEntity _$RewardCenterIndexEntityFromJson(
        Map<String, dynamic> json) =>
    RewardCenterIndexEntity()
      ..unWithdrawAmount = json['unWithdrawAmount'] as String?
      ..withdrewAmount = json['withdrewAmount'] as String?
      ..minWithdrawAmount = json['minWithdrawAmount'] as String?
      ..withdrawInfoList = (json['withdrawInfoList'] as List<dynamic>?)
          ?.map((e) =>
              WithdrawInfoListItemEntity.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$RewardCenterIndexEntityToJson(
        RewardCenterIndexEntity instance) =>
    <String, dynamic>{
      'unWithdrawAmount': instance.unWithdrawAmount,
      'withdrewAmount': instance.withdrewAmount,
      'minWithdrawAmount': instance.minWithdrawAmount,
      'withdrawInfoList': instance.withdrawInfoList,
    };

WithdrawInfoList _$WithdrawInfoListFromJson(Map<String, dynamic> json) =>
    WithdrawInfoList()
      ..coin = json['coin'] as String?
      ..amount = json['amount'] as String?;

Map<String, dynamic> _$WithdrawInfoListToJson(WithdrawInfoList instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'amount': instance.amount,
    };
