import 'dart:convert';

import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task_center_reward_voucher.g.dart';

@JsonSerializable()
class TaskCenterRewardVoucherEntity {
  int? count;
  List<TaskCenterRewardVoucherItemEntity>? list;

  TaskCenterRewardVoucherEntity();

  factory TaskCenterRewardVoucherEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskCenterRewardVoucherEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCenterRewardVoucherEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TaskCenterRewardVoucherItemEntity {
  int? id;
  String? coin; //币种
  String? amount; //数量
  int? rewardType; //奖励类型 1合约赠金券,2 现金
  int? receiveTime;
  int? expireTime;
  int? rewardTerm; //奖励有效期限/天
  int? rewardRecoveryTerm; //奖励回收期限/天
  int? status; //状态 0未使用 1已失效 2已使用
  String? showName;
  TaskCenterRewardVoucherItemEntity();

  factory TaskCenterRewardVoucherItemEntity.fromJson(
          Map<String, dynamic> json) =>
      _$TaskCenterRewardVoucherItemEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TaskCenterRewardVoucherItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
