import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/task_info_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';


TaskInfoListEntity $TaskInfoListEntityFromJson(Map<String, dynamic> json) {
  final TaskInfoListEntity taskInfoListEntity = TaskInfoListEntity();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    taskInfoListEntity.id = id;
  }
  final int? type = jsonConvert.convert<int>(json['type']);
  if (type != null) {
    taskInfoListEntity.type = type;
  }
  final int? category = jsonConvert.convert<int>(json['category']);
  if (category != null) {
    taskInfoListEntity.category = category;
  }
  final String? targetValue = jsonConvert.convert<String>(json['targetValue']);
  if (targetValue != null) {
    taskInfoListEntity.targetValue = targetValue;
  }
  final String? targetCoin = jsonConvert.convert<String>(json['targetCoin']);
  if (targetCoin != null) {
    taskInfoListEntity.targetCoin = targetCoin;
  }
  final String? rewardAmount = jsonConvert.convert<String>(
      json['rewardAmount']);
  if (rewardAmount != null) {
    taskInfoListEntity.rewardAmount = rewardAmount;
  }
  final String? rewardCoin = jsonConvert.convert<String>(json['rewardCoin']);
  if (rewardCoin != null) {
    taskInfoListEntity.rewardCoin = rewardCoin;
  }
  final int? rewardType = jsonConvert.convert<int>(json['rewardType']);
  if (rewardType != null) {
    taskInfoListEntity.rewardType = rewardType;
  }
  final String? finishedAmount = jsonConvert.convert<String>(
      json['finishedAmount']);
  if (finishedAmount != null) {
    taskInfoListEntity.finishedAmount = finishedAmount;
  }
  final int? remindTime = jsonConvert.convert<int>(json['remindTime']);
  if (remindTime != null) {
    taskInfoListEntity.remindTime = remindTime;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    taskInfoListEntity.status = status;
  }
  final int? period = jsonConvert.convert<int>(json['period']);
  if (period != null) {
    taskInfoListEntity.period = period;
  }
  final String? logo = jsonConvert.convert<String>(json['logo']);
  if (logo != null) {
    taskInfoListEntity.logo = logo;
  }
  final int? statusSortValue = jsonConvert.convert<int>(
      json['statusSortValue']);
  if (statusSortValue != null) {
    taskInfoListEntity.statusSortValue = statusSortValue;
  }
  final String? exchangeSymbol = jsonConvert.convert<String>(
      json['exchangeSymbol']);
  if (exchangeSymbol != null) {
    taskInfoListEntity.exchangeSymbol = exchangeSymbol;
  }
  final String? etfSymbol = jsonConvert.convert<String>(json['etfSymbol']);
  if (etfSymbol != null) {
    taskInfoListEntity.etfSymbol = etfSymbol;
  }
  final String? levelSymbol = jsonConvert.convert<String>(json['levelSymbol']);
  if (levelSymbol != null) {
    taskInfoListEntity.levelSymbol = levelSymbol;
  }
  final List<
      TaskLevelRewardsEntity>? taskLevelRewards = (json['taskLevelRewards'] as List<
      dynamic>?)
      ?.map(
          (e) =>
      jsonConvert.convert<TaskLevelRewardsEntity>(e) as TaskLevelRewardsEntity)
      .toList();
  if (taskLevelRewards != null) {
    taskInfoListEntity.taskLevelRewards = taskLevelRewards;
  }
  final int? startTime = jsonConvert.convert<int>(json['startTime']);
  if (startTime != null) {
    taskInfoListEntity.startTime = startTime;
  }
  final int? endTime = jsonConvert.convert<int>(json['endTime']);
  if (endTime != null) {
    taskInfoListEntity.endTime = endTime;
  }
  final String? singleMinTarget = jsonConvert.convert<String>(
      json['singleMinTarget']);
  if (singleMinTarget != null) {
    taskInfoListEntity.singleMinTarget = singleMinTarget;
  }
  return taskInfoListEntity;
}

Map<String, dynamic> $TaskInfoListEntityToJson(TaskInfoListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['type'] = entity.type;
  data['category'] = entity.category;
  data['targetValue'] = entity.targetValue;
  data['targetCoin'] = entity.targetCoin;
  data['rewardAmount'] = entity.rewardAmount;
  data['rewardCoin'] = entity.rewardCoin;
  data['rewardType'] = entity.rewardType;
  data['finishedAmount'] = entity.finishedAmount;
  data['remindTime'] = entity.remindTime;
  data['status'] = entity.status;
  data['period'] = entity.period;
  data['logo'] = entity.logo;
  data['statusSortValue'] = entity.statusSortValue;
  data['exchangeSymbol'] = entity.exchangeSymbol;
  data['etfSymbol'] = entity.etfSymbol;
  data['levelSymbol'] = entity.levelSymbol;
  data['taskLevelRewards'] =
      entity.taskLevelRewards?.map((v) => v.toJson()).toList();
  data['startTime'] = entity.startTime;
  data['endTime'] = entity.endTime;
  data['singleMinTarget'] = entity.singleMinTarget;
  return data;
}

extension TaskInfoListEntityExtension on TaskInfoListEntity {
  TaskInfoListEntity copyWith({
    int? id,
    int? type,
    int? category,
    String? targetValue,
    String? targetCoin,
    String? rewardAmount,
    String? rewardCoin,
    int? rewardType,
    String? finishedAmount,
    int? remindTime,
    int? status,
    int? period,
    String? logo,
    int? statusSortValue,
    String? exchangeSymbol,
    String? etfSymbol,
    String? levelSymbol,
    List<TaskLevelRewardsEntity>? taskLevelRewards,
    int? startTime,
    int? endTime,
    String? singleMinTarget,
  }) {
    return TaskInfoListEntity()
      ..id = id ?? this.id
      ..type = type ?? this.type
      ..category = category ?? this.category
      ..targetValue = targetValue ?? this.targetValue
      ..targetCoin = targetCoin ?? this.targetCoin
      ..rewardAmount = rewardAmount ?? this.rewardAmount
      ..rewardCoin = rewardCoin ?? this.rewardCoin
      ..rewardType = rewardType ?? this.rewardType
      ..finishedAmount = finishedAmount ?? this.finishedAmount
      ..remindTime = remindTime ?? this.remindTime
      ..status = status ?? this.status
      ..period = period ?? this.period
      ..logo = logo ?? this.logo
      ..statusSortValue = statusSortValue ?? this.statusSortValue
      ..exchangeSymbol = exchangeSymbol ?? this.exchangeSymbol
      ..etfSymbol = etfSymbol ?? this.etfSymbol
      ..levelSymbol = levelSymbol ?? this.levelSymbol
      ..taskLevelRewards = taskLevelRewards ?? this.taskLevelRewards
      ..startTime = startTime ?? this.startTime
      ..endTime = endTime ?? this.endTime
      ..singleMinTarget = singleMinTarget ?? this.singleMinTarget;
  }
}

TaskLevelRewardsEntity $TaskLevelRewardsEntityFromJson(
    Map<String, dynamic> json) {
  final TaskLevelRewardsEntity taskLevelRewardsEntity = TaskLevelRewardsEntity();
  final int? level = jsonConvert.convert<int>(json['level']);
  if (level != null) {
    taskLevelRewardsEntity.level = level;
  }
  final String? targetAmount = jsonConvert.convert<String>(
      json['targetAmount']);
  if (targetAmount != null) {
    taskLevelRewardsEntity.targetAmount = targetAmount;
  }
  final String? rewardAmount = jsonConvert.convert<String>(
      json['rewardAmount']);
  if (rewardAmount != null) {
    taskLevelRewardsEntity.rewardAmount = rewardAmount;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    taskLevelRewardsEntity.status = status;
  }
  final dynamic receiveExpireTime = json['receiveExpireTime'];
  if (receiveExpireTime != null) {
    taskLevelRewardsEntity.receiveExpireTime = receiveExpireTime;
  }
  return taskLevelRewardsEntity;
}

Map<String, dynamic> $TaskLevelRewardsEntityToJson(
    TaskLevelRewardsEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['level'] = entity.level;
  data['targetAmount'] = entity.targetAmount;
  data['rewardAmount'] = entity.rewardAmount;
  data['status'] = entity.status;
  data['receiveExpireTime'] = entity.receiveExpireTime;
  return data;
}

extension TaskLevelRewardsEntityExtension on TaskLevelRewardsEntity {
  TaskLevelRewardsEntity copyWith({
    int? level,
    String? targetAmount,
    String? rewardAmount,
    int? status,
    dynamic receiveExpireTime,
  }) {
    return TaskLevelRewardsEntity()
      ..level = level ?? this.level
      ..targetAmount = targetAmount ?? this.targetAmount
      ..rewardAmount = rewardAmount ?? this.rewardAmount
      ..status = status ?? this.status
      ..receiveExpireTime = receiveExpireTime ?? this.receiveExpireTime;
  }
}