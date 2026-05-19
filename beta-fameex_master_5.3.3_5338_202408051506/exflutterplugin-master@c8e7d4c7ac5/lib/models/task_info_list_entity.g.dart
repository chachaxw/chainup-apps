// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_info_list_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskInfoListEntity _$TaskInfoListEntityFromJson(Map<String, dynamic> json) =>
    TaskInfoListEntity()
      ..id = json['id'] as int?
      ..type = json['type'] as int?
      ..category = json['category'] as int?
      ..targetValue = json['targetValue'] as String?
      ..targetCoin = json['targetCoin'] as String?
      ..rewardAmount = json['rewardAmount'] as String?
      ..rewardCoin = json['rewardCoin'] as String?
      ..rewardType = json['rewardType'] as int?
      ..finishedAmount = json['finishedAmount'] as String?
      ..remindTime = json['remindTime'] as int?
      ..status = json['status'] as int?
      ..period = json['period'] as int?
      ..logo = json['logo'] as String?
      ..statusSortValue = json['statusSortValue'] as int?
      ..exchangeSymbol = json['exchangeSymbol'] as String?
      ..etfSymbol = json['etfSymbol'] as String?
      ..levelSymbol = json['levelSymbol'] as String?
      ..taskLevelRewards = (json['taskLevelRewards'] as List<dynamic>?)
          ?.map(
              (e) => TaskLevelRewardsEntity.fromJson(e as Map<String, dynamic>))
          .toList()
      ..startTime = json['startTime'] as int?
      ..endTime = json['endTime'] as int?
      ..singleMinTarget = json['singleMinTarget'] as String?;

Map<String, dynamic> _$TaskInfoListEntityToJson(TaskInfoListEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'category': instance.category,
      'targetValue': instance.targetValue,
      'targetCoin': instance.targetCoin,
      'rewardAmount': instance.rewardAmount,
      'rewardCoin': instance.rewardCoin,
      'rewardType': instance.rewardType,
      'finishedAmount': instance.finishedAmount,
      'remindTime': instance.remindTime,
      'status': instance.status,
      'period': instance.period,
      'logo': instance.logo,
      'statusSortValue': instance.statusSortValue,
      'exchangeSymbol': instance.exchangeSymbol,
      'etfSymbol': instance.etfSymbol,
      'levelSymbol': instance.levelSymbol,
      'taskLevelRewards': instance.taskLevelRewards,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'singleMinTarget': instance.singleMinTarget,
    };

TaskLevelRewardsEntity _$TaskLevelRewardsEntityFromJson(
        Map<String, dynamic> json) =>
    TaskLevelRewardsEntity()
      ..level = json['level'] as int?
      ..targetAmount = json['targetAmount'] as String?
      ..rewardAmount = json['rewardAmount'] as String?
      ..status = json['status'] as int?
      ..receiveExpireTime = json['receiveExpireTime'];

Map<String, dynamic> _$TaskLevelRewardsEntityToJson(
        TaskLevelRewardsEntity instance) =>
    <String, dynamic>{
      'level': instance.level,
      'targetAmount': instance.targetAmount,
      'rewardAmount': instance.rewardAmount,
      'status': instance.status,
      'receiveExpireTime': instance.receiveExpireTime,
    };
