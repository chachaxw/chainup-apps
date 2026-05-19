// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_center_reward_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCenterRewardRecordEntity _$TaskCenterRewardRecordEntityFromJson(
        Map<String, dynamic> json) =>
    TaskCenterRewardRecordEntity()
      ..count = json['count'] as int?
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) => TaskCenterRewardRecordItemEntity.fromJson(
              e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TaskCenterRewardRecordEntityToJson(
        TaskCenterRewardRecordEntity instance) =>
    <String, dynamic>{
      'count': instance.count,
      'list': instance.list,
    };

TaskCenterRewardRecordItemEntity _$TaskCenterRewardRecordItemEntityFromJson(
        Map<String, dynamic> json) =>
    TaskCenterRewardRecordItemEntity()
      ..id = json['id'] as int?
      ..showCoin = json['showCoin'] as String?
      ..coin = json['coin'] as String?
      ..taskType = json['taskType'] as int?
      ..taskCategory = json['taskCategory'] as int?
      ..amount = json['amount'] as String?
      ..usdtAmount = json['usdtAmount'] as String?
      ..rewardType = json['rewardType'] as int?
      ..receiveTime = json['receiveTime'] as int?;

Map<String, dynamic> _$TaskCenterRewardRecordItemEntityToJson(
        TaskCenterRewardRecordItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'showCoin': instance.showCoin,
      'coin': instance.coin,
      'taskType': instance.taskType,
      'taskCategory': instance.taskCategory,
      'amount': instance.amount,
      'usdtAmount': instance.usdtAmount,
      'rewardType': instance.rewardType,
      'receiveTime': instance.receiveTime,
    };
