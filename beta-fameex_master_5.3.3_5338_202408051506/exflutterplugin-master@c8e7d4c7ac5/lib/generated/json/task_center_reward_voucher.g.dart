import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/task_center_reward_voucher.dart';
import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';

import 'package:json_annotation/json_annotation.dart';


TaskCenterRewardVoucherEntity $TaskCenterRewardVoucherEntityFromJson(
    Map<String, dynamic> json) {
  final TaskCenterRewardVoucherEntity taskCenterRewardVoucherEntity = TaskCenterRewardVoucherEntity();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    taskCenterRewardVoucherEntity.count = count;
  }
  final List<TaskCenterRewardVoucherItemEntity>? list = (json['list'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<TaskCenterRewardVoucherItemEntity>(
          e) as TaskCenterRewardVoucherItemEntity).toList();
  if (list != null) {
    taskCenterRewardVoucherEntity.list = list;
  }
  return taskCenterRewardVoucherEntity;
}

Map<String, dynamic> $TaskCenterRewardVoucherEntityToJson(
    TaskCenterRewardVoucherEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['list'] = entity.list?.map((v) => v.toJson()).toList();
  return data;
}

extension TaskCenterRewardVoucherEntityExtension on TaskCenterRewardVoucherEntity {
  TaskCenterRewardVoucherEntity copyWith({
    int? count,
    List<TaskCenterRewardVoucherItemEntity>? list,
  }) {
    return TaskCenterRewardVoucherEntity()
      ..count = count ?? this.count
      ..list = list ?? this.list;
  }
}

TaskCenterRewardVoucherItemEntity $TaskCenterRewardVoucherItemEntityFromJson(
    Map<String, dynamic> json) {
  final TaskCenterRewardVoucherItemEntity taskCenterRewardVoucherItemEntity = TaskCenterRewardVoucherItemEntity();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    taskCenterRewardVoucherItemEntity.id = id;
  }
  final String? coin = jsonConvert.convert<String>(json['coin']);
  if (coin != null) {
    taskCenterRewardVoucherItemEntity.coin = coin;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    taskCenterRewardVoucherItemEntity.amount = amount;
  }
  final int? rewardType = jsonConvert.convert<int>(json['rewardType']);
  if (rewardType != null) {
    taskCenterRewardVoucherItemEntity.rewardType = rewardType;
  }
  final int? receiveTime = jsonConvert.convert<int>(json['receiveTime']);
  if (receiveTime != null) {
    taskCenterRewardVoucherItemEntity.receiveTime = receiveTime;
  }
  final int? expireTime = jsonConvert.convert<int>(json['expireTime']);
  if (expireTime != null) {
    taskCenterRewardVoucherItemEntity.expireTime = expireTime;
  }
  final int? rewardTerm = jsonConvert.convert<int>(json['rewardTerm']);
  if (rewardTerm != null) {
    taskCenterRewardVoucherItemEntity.rewardTerm = rewardTerm;
  }
  final int? rewardRecoveryTerm = jsonConvert.convert<int>(
      json['rewardRecoveryTerm']);
  if (rewardRecoveryTerm != null) {
    taskCenterRewardVoucherItemEntity.rewardRecoveryTerm = rewardRecoveryTerm;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    taskCenterRewardVoucherItemEntity.status = status;
  }
  final String? showName = jsonConvert.convert<String>(json['showName']);
  if (showName != null) {
    taskCenterRewardVoucherItemEntity.showName = showName;
  }
  return taskCenterRewardVoucherItemEntity;
}

Map<String, dynamic> $TaskCenterRewardVoucherItemEntityToJson(
    TaskCenterRewardVoucherItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['coin'] = entity.coin;
  data['amount'] = entity.amount;
  data['rewardType'] = entity.rewardType;
  data['receiveTime'] = entity.receiveTime;
  data['expireTime'] = entity.expireTime;
  data['rewardTerm'] = entity.rewardTerm;
  data['rewardRecoveryTerm'] = entity.rewardRecoveryTerm;
  data['status'] = entity.status;
  data['showName'] = entity.showName;
  return data;
}

extension TaskCenterRewardVoucherItemEntityExtension on TaskCenterRewardVoucherItemEntity {
  TaskCenterRewardVoucherItemEntity copyWith({
    int? id,
    String? coin,
    String? amount,
    int? rewardType,
    int? receiveTime,
    int? expireTime,
    int? rewardTerm,
    int? rewardRecoveryTerm,
    int? status,
    String? showName,
  }) {
    return TaskCenterRewardVoucherItemEntity()
      ..id = id ?? this.id
      ..coin = coin ?? this.coin
      ..amount = amount ?? this.amount
      ..rewardType = rewardType ?? this.rewardType
      ..receiveTime = receiveTime ?? this.receiveTime
      ..expireTime = expireTime ?? this.expireTime
      ..rewardTerm = rewardTerm ?? this.rewardTerm
      ..rewardRecoveryTerm = rewardRecoveryTerm ?? this.rewardRecoveryTerm
      ..status = status ?? this.status
      ..showName = showName ?? this.showName;
  }
}