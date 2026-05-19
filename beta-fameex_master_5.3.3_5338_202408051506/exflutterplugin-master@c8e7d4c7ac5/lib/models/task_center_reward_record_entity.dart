import 'dart:convert';

import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task_center_reward_record_entity.g.dart';

@JsonSerializable()
class TaskCenterRewardRecordEntity {
  int? count;
  List<TaskCenterRewardRecordItemEntity>? list;

  TaskCenterRewardRecordEntity();

  factory TaskCenterRewardRecordEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskCenterRewardRecordEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCenterRewardRecordEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TaskCenterRewardRecordItemEntity {
  int? id;
  String? showCoin; //
  String? coin; //奖励币种
  int? taskType; //任务类型 0每日 1新手 2进阶 3限时
  int? taskCategory; //任务类别
  String? amount; //奖励数量
  String? usdtAmount; //奖励金额
  int? rewardType; //奖励类型 0现金奖励 1合约赠金
  int? receiveTime; //发放时间

  TaskCenterRewardRecordItemEntity();

  factory TaskCenterRewardRecordItemEntity.fromJson(
          Map<String, dynamic> json) =>
      _$TaskCenterRewardRecordItemEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TaskCenterRewardRecordItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
