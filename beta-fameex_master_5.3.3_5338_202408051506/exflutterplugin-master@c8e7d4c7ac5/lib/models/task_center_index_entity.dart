import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'task_center_index_entity.g.dart';

@JsonSerializable()
class TaskCenterIndexEntity {
  int? rewardReceiveTerm;
  TaskCenterIndexSignInInfo? signInInfo;
  String? titleRewardAmount;
  int? rewardReceiveType;
  String? bannerImageUrl;
  List<TaskCenterIndexTaskTypeSorts>? taskTypeSorts;
  int? rewardUseKyc;

  ///提现或使用赠金是否需要kyc ,1 是 0 否
  TaskCenterIndexEntity();

  factory TaskCenterIndexEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskCenterIndexEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCenterIndexEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TaskCenterIndexSignInInfo {
  List<String>? rewards;
  String? rewardCoin;
  int? isKyc;
  int? isTwoCheck;
  int? seriateSignInNum;
  int? isSignIn;

  TaskCenterIndexSignInInfo();

  factory TaskCenterIndexSignInInfo.fromJson(Map<String, dynamic> json) =>
      _$TaskCenterIndexSignInInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCenterIndexSignInInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TaskCenterIndexTaskTypeSorts {
  int? taskType;
  int? sort;

  TaskCenterIndexTaskTypeSorts();

  factory TaskCenterIndexTaskTypeSorts.fromJson(Map<String, dynamic> json) =>
      _$TaskCenterIndexTaskTypeSortsFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCenterIndexTaskTypeSortsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
