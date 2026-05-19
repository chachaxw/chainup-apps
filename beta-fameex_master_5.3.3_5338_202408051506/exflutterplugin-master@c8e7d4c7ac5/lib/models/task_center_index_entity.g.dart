// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_center_index_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCenterIndexEntity _$TaskCenterIndexEntityFromJson(
        Map<String, dynamic> json) =>
    TaskCenterIndexEntity()
      ..rewardReceiveTerm = json['rewardReceiveTerm'] as int?
      ..signInInfo = json['signInInfo'] == null
          ? null
          : TaskCenterIndexSignInInfo.fromJson(
              json['signInInfo'] as Map<String, dynamic>)
      ..titleRewardAmount = json['titleRewardAmount'] as String?
      ..rewardReceiveType = json['rewardReceiveType'] as int?
      ..bannerImageUrl = json['bannerImageUrl'] as String?
      ..taskTypeSorts = (json['taskTypeSorts'] as List<dynamic>?)
          ?.map((e) =>
              TaskCenterIndexTaskTypeSorts.fromJson(e as Map<String, dynamic>))
          .toList()
      ..rewardUseKyc = json['rewardUseKyc'] as int?;

Map<String, dynamic> _$TaskCenterIndexEntityToJson(
        TaskCenterIndexEntity instance) =>
    <String, dynamic>{
      'rewardReceiveTerm': instance.rewardReceiveTerm,
      'signInInfo': instance.signInInfo,
      'titleRewardAmount': instance.titleRewardAmount,
      'rewardReceiveType': instance.rewardReceiveType,
      'bannerImageUrl': instance.bannerImageUrl,
      'taskTypeSorts': instance.taskTypeSorts,
      'rewardUseKyc': instance.rewardUseKyc,
    };

TaskCenterIndexSignInInfo _$TaskCenterIndexSignInInfoFromJson(
        Map<String, dynamic> json) =>
    TaskCenterIndexSignInInfo()
      ..rewards =
          (json['rewards'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..rewardCoin = json['rewardCoin'] as String?
      ..isKyc = json['isKyc'] as int?
      ..isTwoCheck = json['isTwoCheck'] as int?
      ..seriateSignInNum = json['seriateSignInNum'] as int?
      ..isSignIn = json['isSignIn'] as int?;

Map<String, dynamic> _$TaskCenterIndexSignInInfoToJson(
        TaskCenterIndexSignInInfo instance) =>
    <String, dynamic>{
      'rewards': instance.rewards,
      'rewardCoin': instance.rewardCoin,
      'isKyc': instance.isKyc,
      'isTwoCheck': instance.isTwoCheck,
      'seriateSignInNum': instance.seriateSignInNum,
      'isSignIn': instance.isSignIn,
    };

TaskCenterIndexTaskTypeSorts _$TaskCenterIndexTaskTypeSortsFromJson(
        Map<String, dynamic> json) =>
    TaskCenterIndexTaskTypeSorts()
      ..taskType = json['taskType'] as int?
      ..sort = json['sort'] as int?;

Map<String, dynamic> _$TaskCenterIndexTaskTypeSortsToJson(
        TaskCenterIndexTaskTypeSorts instance) =>
    <String, dynamic>{
      'taskType': instance.taskType,
      'sort': instance.sort,
    };
