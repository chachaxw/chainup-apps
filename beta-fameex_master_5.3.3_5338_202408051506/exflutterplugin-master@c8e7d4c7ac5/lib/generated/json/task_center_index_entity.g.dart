import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/task_center_index_entity.dart';
import 'package:json_annotation/json_annotation.dart';


TaskCenterIndexEntity $TaskCenterIndexEntityFromJson(
    Map<String, dynamic> json) {
  final TaskCenterIndexEntity taskCenterIndexEntity = TaskCenterIndexEntity();
  final int? rewardReceiveTerm = jsonConvert.convert<int>(
      json['rewardReceiveTerm']);
  if (rewardReceiveTerm != null) {
    taskCenterIndexEntity.rewardReceiveTerm = rewardReceiveTerm;
  }
  final TaskCenterIndexSignInInfo? signInInfo = jsonConvert.convert<
      TaskCenterIndexSignInInfo>(json['signInInfo']);
  if (signInInfo != null) {
    taskCenterIndexEntity.signInInfo = signInInfo;
  }
  final String? titleRewardAmount = jsonConvert.convert<String>(
      json['titleRewardAmount']);
  if (titleRewardAmount != null) {
    taskCenterIndexEntity.titleRewardAmount = titleRewardAmount;
  }
  final int? rewardReceiveType = jsonConvert.convert<int>(
      json['rewardReceiveType']);
  if (rewardReceiveType != null) {
    taskCenterIndexEntity.rewardReceiveType = rewardReceiveType;
  }
  final String? bannerImageUrl = jsonConvert.convert<String>(
      json['bannerImageUrl']);
  if (bannerImageUrl != null) {
    taskCenterIndexEntity.bannerImageUrl = bannerImageUrl;
  }
  final List<
      TaskCenterIndexTaskTypeSorts>? taskTypeSorts = (json['taskTypeSorts'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<TaskCenterIndexTaskTypeSorts>(
          e) as TaskCenterIndexTaskTypeSorts).toList();
  if (taskTypeSorts != null) {
    taskCenterIndexEntity.taskTypeSorts = taskTypeSorts;
  }
  final int? rewardUseKyc = jsonConvert.convert<int>(json['rewardUseKyc']);
  if (rewardUseKyc != null) {
    taskCenterIndexEntity.rewardUseKyc = rewardUseKyc;
  }
  return taskCenterIndexEntity;
}

Map<String, dynamic> $TaskCenterIndexEntityToJson(
    TaskCenterIndexEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['rewardReceiveTerm'] = entity.rewardReceiveTerm;
  data['signInInfo'] = entity.signInInfo?.toJson();
  data['titleRewardAmount'] = entity.titleRewardAmount;
  data['rewardReceiveType'] = entity.rewardReceiveType;
  data['bannerImageUrl'] = entity.bannerImageUrl;
  data['taskTypeSorts'] = entity.taskTypeSorts?.map((v) => v.toJson()).toList();
  data['rewardUseKyc'] = entity.rewardUseKyc;
  return data;
}

extension TaskCenterIndexEntityExtension on TaskCenterIndexEntity {
  TaskCenterIndexEntity copyWith({
    int? rewardReceiveTerm,
    TaskCenterIndexSignInInfo? signInInfo,
    String? titleRewardAmount,
    int? rewardReceiveType,
    String? bannerImageUrl,
    List<TaskCenterIndexTaskTypeSorts>? taskTypeSorts,
    int? rewardUseKyc,
  }) {
    return TaskCenterIndexEntity()
      ..rewardReceiveTerm = rewardReceiveTerm ?? this.rewardReceiveTerm
      ..signInInfo = signInInfo ?? this.signInInfo
      ..titleRewardAmount = titleRewardAmount ?? this.titleRewardAmount
      ..rewardReceiveType = rewardReceiveType ?? this.rewardReceiveType
      ..bannerImageUrl = bannerImageUrl ?? this.bannerImageUrl
      ..taskTypeSorts = taskTypeSorts ?? this.taskTypeSorts
      ..rewardUseKyc = rewardUseKyc ?? this.rewardUseKyc;
  }
}

TaskCenterIndexSignInInfo $TaskCenterIndexSignInInfoFromJson(
    Map<String, dynamic> json) {
  final TaskCenterIndexSignInInfo taskCenterIndexSignInInfo = TaskCenterIndexSignInInfo();
  final List<String>? rewards = (json['rewards'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (rewards != null) {
    taskCenterIndexSignInInfo.rewards = rewards;
  }
  final String? rewardCoin = jsonConvert.convert<String>(json['rewardCoin']);
  if (rewardCoin != null) {
    taskCenterIndexSignInInfo.rewardCoin = rewardCoin;
  }
  final int? isKyc = jsonConvert.convert<int>(json['isKyc']);
  if (isKyc != null) {
    taskCenterIndexSignInInfo.isKyc = isKyc;
  }
  final int? isTwoCheck = jsonConvert.convert<int>(json['isTwoCheck']);
  if (isTwoCheck != null) {
    taskCenterIndexSignInInfo.isTwoCheck = isTwoCheck;
  }
  final int? seriateSignInNum = jsonConvert.convert<int>(
      json['seriateSignInNum']);
  if (seriateSignInNum != null) {
    taskCenterIndexSignInInfo.seriateSignInNum = seriateSignInNum;
  }
  final int? isSignIn = jsonConvert.convert<int>(json['isSignIn']);
  if (isSignIn != null) {
    taskCenterIndexSignInInfo.isSignIn = isSignIn;
  }
  return taskCenterIndexSignInInfo;
}

Map<String, dynamic> $TaskCenterIndexSignInInfoToJson(
    TaskCenterIndexSignInInfo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['rewards'] = entity.rewards;
  data['rewardCoin'] = entity.rewardCoin;
  data['isKyc'] = entity.isKyc;
  data['isTwoCheck'] = entity.isTwoCheck;
  data['seriateSignInNum'] = entity.seriateSignInNum;
  data['isSignIn'] = entity.isSignIn;
  return data;
}

extension TaskCenterIndexSignInInfoExtension on TaskCenterIndexSignInInfo {
  TaskCenterIndexSignInInfo copyWith({
    List<String>? rewards,
    String? rewardCoin,
    int? isKyc,
    int? isTwoCheck,
    int? seriateSignInNum,
    int? isSignIn,
  }) {
    return TaskCenterIndexSignInInfo()
      ..rewards = rewards ?? this.rewards
      ..rewardCoin = rewardCoin ?? this.rewardCoin
      ..isKyc = isKyc ?? this.isKyc
      ..isTwoCheck = isTwoCheck ?? this.isTwoCheck
      ..seriateSignInNum = seriateSignInNum ?? this.seriateSignInNum
      ..isSignIn = isSignIn ?? this.isSignIn;
  }
}

TaskCenterIndexTaskTypeSorts $TaskCenterIndexTaskTypeSortsFromJson(
    Map<String, dynamic> json) {
  final TaskCenterIndexTaskTypeSorts taskCenterIndexTaskTypeSorts = TaskCenterIndexTaskTypeSorts();
  final int? taskType = jsonConvert.convert<int>(json['taskType']);
  if (taskType != null) {
    taskCenterIndexTaskTypeSorts.taskType = taskType;
  }
  final int? sort = jsonConvert.convert<int>(json['sort']);
  if (sort != null) {
    taskCenterIndexTaskTypeSorts.sort = sort;
  }
  return taskCenterIndexTaskTypeSorts;
}

Map<String, dynamic> $TaskCenterIndexTaskTypeSortsToJson(
    TaskCenterIndexTaskTypeSorts entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['taskType'] = entity.taskType;
  data['sort'] = entity.sort;
  return data;
}

extension TaskCenterIndexTaskTypeSortsExtension on TaskCenterIndexTaskTypeSorts {
  TaskCenterIndexTaskTypeSorts copyWith({
    int? taskType,
    int? sort,
  }) {
    return TaskCenterIndexTaskTypeSorts()
      ..taskType = taskType ?? this.taskType
      ..sort = sort ?? this.sort;
  }
}