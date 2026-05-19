import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'withdraw_list_item_entity.g.dart';

@JsonSerializable()
class WithdrawInfoListEntity {
  int? count;
  List<WithdrawInfoListItemEntity>? list;

  WithdrawInfoListEntity();

  factory WithdrawInfoListEntity.fromJson(Map<String, dynamic> json) =>
      _$WithdrawInfoListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawInfoListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WithdrawInfoListItemEntity {
  String? coin;
  String? amount;
  String? usdtAmount;
  int? status;
  int? withdrawTime;
  String? icon;
  String? showName;

  WithdrawInfoListItemEntity();

  factory WithdrawInfoListItemEntity.fromJson(Map<String, dynamic> json) =>
      _$WithdrawInfoListItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawInfoListItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
