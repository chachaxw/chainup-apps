import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'task_info_list_entity.g.dart';

@JsonSerializable()
class TaskInfoListEntity {
  int? id;
  int? type;
  int? category;
  String? targetValue;
  String? targetCoin;
  String? rewardAmount;
  String? rewardCoin;
  int? rewardType;
  String? finishedAmount;
  int? remindTime;
  int? status;
  int? period;
  String? logo;
  int? statusSortValue;
  String? exchangeSymbol;
  String? etfSymbol;
  String? levelSymbol;
  List<TaskLevelRewardsEntity>? taskLevelRewards;
  int? startTime;
  int? endTime;
  String? singleMinTarget;

  TaskInfoListEntity();

  factory TaskInfoListEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskInfoListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskInfoListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TaskLevelRewardsEntity {
  int? level;
  String? targetAmount;
  String? rewardAmount;
  int? status;
  dynamic receiveExpireTime;

  TaskLevelRewardsEntity();

  factory TaskLevelRewardsEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskLevelRewardsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLevelRewardsEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
