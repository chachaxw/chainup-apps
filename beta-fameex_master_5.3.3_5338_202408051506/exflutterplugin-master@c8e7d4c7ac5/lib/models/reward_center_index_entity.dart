import 'dart:convert';

import 'package:chainup_flutter_ex/models/withdraw_list_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'reward_center_index_entity.g.dart';

@JsonSerializable()
class RewardCenterIndexEntity {
  String? unWithdrawAmount;
  String? withdrewAmount;
  String? minWithdrawAmount;
  List<WithdrawInfoListItemEntity>? withdrawInfoList;

  RewardCenterIndexEntity();

  factory RewardCenterIndexEntity.fromJson(Map<String, dynamic> json) =>
      _$RewardCenterIndexEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RewardCenterIndexEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WithdrawInfoList {
  String? coin;
  String? amount;

  WithdrawInfoList();

  factory WithdrawInfoList.fromJson(Map<String, dynamic> json) =>
      _$WithdrawInfoListFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawInfoListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
