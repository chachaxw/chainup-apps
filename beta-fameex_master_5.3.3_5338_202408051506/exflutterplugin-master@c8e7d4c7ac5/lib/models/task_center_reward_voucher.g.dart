// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_center_reward_voucher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCenterRewardVoucherEntity _$TaskCenterRewardVoucherEntityFromJson(
        Map<String, dynamic> json) =>
    TaskCenterRewardVoucherEntity()
      ..count = json['count'] as int?
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) => TaskCenterRewardVoucherItemEntity.fromJson(
              e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TaskCenterRewardVoucherEntityToJson(
        TaskCenterRewardVoucherEntity instance) =>
    <String, dynamic>{
      'count': instance.count,
      'list': instance.list,
    };

TaskCenterRewardVoucherItemEntity _$TaskCenterRewardVoucherItemEntityFromJson(
        Map<String, dynamic> json) =>
    TaskCenterRewardVoucherItemEntity()
      ..id = json['id'] as int?
      ..coin = json['coin'] as String?
      ..amount = json['amount'] as String?
      ..rewardType = json['rewardType'] as int?
      ..receiveTime = json['receiveTime'] as int?
      ..expireTime = json['expireTime'] as int?
      ..rewardTerm = json['rewardTerm'] as int?
      ..rewardRecoveryTerm = json['rewardRecoveryTerm'] as int?
      ..status = json['status'] as int?
      ..showName = json['showName'] as String?;

Map<String, dynamic> _$TaskCenterRewardVoucherItemEntityToJson(
        TaskCenterRewardVoucherItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coin': instance.coin,
      'amount': instance.amount,
      'rewardType': instance.rewardType,
      'receiveTime': instance.receiveTime,
      'expireTime': instance.expireTime,
      'rewardTerm': instance.rewardTerm,
      'rewardRecoveryTerm': instance.rewardRecoveryTerm,
      'status': instance.status,
      'showName': instance.showName,
    };
