import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/task_center_reward_record_entity.dart';
import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';

import 'package:json_annotation/json_annotation.dart';


TaskCenterRewardRecordEntity $TaskCenterRewardRecordEntityFromJson(
    Map<String, dynamic> json) {
  final TaskCenterRewardRecordEntity taskCenterRewardRecordEntity = TaskCenterRewardRecordEntity();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    taskCenterRewardRecordEntity.count = count;
  }
  final List<TaskCenterRewardRecordItemEntity>? list = (json['list'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<TaskCenterRewardRecordItemEntity>(
          e) as TaskCenterRewardRecordItemEntity).toList();
  if (list != null) {
    taskCenterRewardRecordEntity.list = list;
  }
  return taskCenterRewardRecordEntity;
}

Map<String, dynamic> $TaskCenterRewardRecordEntityToJson(
    TaskCenterRewardRecordEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['list'] = entity.list?.map((v) => v.toJson()).toList();
  return data;
}

extension TaskCenterRewardRecordEntityExtension on TaskCenterRewardRecordEntity {
  TaskCenterRewardRecordEntity copyWith({
    int? count,
    List<TaskCenterRewardRecordItemEntity>? list,
  }) {
    return TaskCenterRewardRecordEntity()
      ..count = count ?? this.count
      ..list = list ?? this.list;
  }
}

TaskCenterRewardRecordItemEntity $TaskCenterRewardRecordItemEntityFromJson(
    Map<String, dynamic> json) {
  final TaskCenterRewardRecordItemEntity taskCenterRewardRecordItemEntity = TaskCenterRewardRecordItemEntity();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    taskCenterRewardRecordItemEntity.id = id;
  }
  final String? showCoin = jsonConvert.convert<String>(json['showCoin']);
  if (showCoin != null) {
    taskCenterRewardRecordItemEntity.showCoin = showCoin;
  }
  final String? coin = jsonConvert.convert<String>(json['coin']);
  if (coin != null) {
    taskCenterRewardRecordItemEntity.coin = coin;
  }
  final int? taskType = jsonConvert.convert<int>(json['taskType']);
  if (taskType != null) {
    taskCenterRewardRecordItemEntity.taskType = taskType;
  }
  final int? taskCategory = jsonConvert.convert<int>(json['taskCategory']);
  if (taskCategory != null) {
    taskCenterRewardRecordItemEntity.taskCategory = taskCategory;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    taskCenterRewardRecordItemEntity.amount = amount;
  }
  final String? usdtAmount = jsonConvert.convert<String>(json['usdtAmount']);
  if (usdtAmount != null) {
    taskCenterRewardRecordItemEntity.usdtAmount = usdtAmount;
  }
  final int? rewardType = jsonConvert.convert<int>(json['rewardType']);
  if (rewardType != null) {
    taskCenterRewardRecordItemEntity.rewardType = rewardType;
  }
  final int? receiveTime = jsonConvert.convert<int>(json['receiveTime']);
  if (receiveTime != null) {
    taskCenterRewardRecordItemEntity.receiveTime = receiveTime;
  }
  return taskCenterRewardRecordItemEntity;
}

Map<String, dynamic> $TaskCenterRewardRecordItemEntityToJson(
    TaskCenterRewardRecordItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['showCoin'] = entity.showCoin;
  data['coin'] = entity.coin;
  data['taskType'] = entity.taskType;
  data['taskCategory'] = entity.taskCategory;
  data['amount'] = entity.amount;
  data['usdtAmount'] = entity.usdtAmount;
  data['rewardType'] = entity.rewardType;
  data['receiveTime'] = entity.receiveTime;
  return data;
}

extension TaskCenterRewardRecordItemEntityExtension on TaskCenterRewardRecordItemEntity {
  TaskCenterRewardRecordItemEntity copyWith({
    int? id,
    String? showCoin,
    String? coin,
    int? taskType,
    int? taskCategory,
    String? amount,
    String? usdtAmount,
    int? rewardType,
    int? receiveTime,
  }) {
    return TaskCenterRewardRecordItemEntity()
      ..id = id ?? this.id
      ..showCoin = showCoin ?? this.showCoin
      ..coin = coin ?? this.coin
      ..taskType = taskType ?? this.taskType
      ..taskCategory = taskCategory ?? this.taskCategory
      ..amount = amount ?? this.amount
      ..usdtAmount = usdtAmount ?? this.usdtAmount
      ..rewardType = rewardType ?? this.rewardType
      ..receiveTime = receiveTime ?? this.receiveTime;
  }
}