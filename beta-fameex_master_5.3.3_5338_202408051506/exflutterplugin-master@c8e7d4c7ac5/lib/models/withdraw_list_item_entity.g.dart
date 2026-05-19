// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_list_item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawInfoListEntity _$WithdrawInfoListEntityFromJson(
        Map<String, dynamic> json) =>
    WithdrawInfoListEntity()
      ..count = json['count'] as int?
      ..list = (json['list'] as List<dynamic>?)
          ?.map((e) =>
              WithdrawInfoListItemEntity.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WithdrawInfoListEntityToJson(
        WithdrawInfoListEntity instance) =>
    <String, dynamic>{
      'count': instance.count,
      'list': instance.list,
    };

WithdrawInfoListItemEntity _$WithdrawInfoListItemEntityFromJson(
        Map<String, dynamic> json) =>
    WithdrawInfoListItemEntity()
      ..coin = json['coin'] as String?
      ..amount = json['amount'] as String?
      ..usdtAmount = json['usdtAmount'] as String?
      ..status = json['status'] as int?
      ..withdrawTime = json['withdrawTime'] as int?
      ..icon = json['icon'] as String?
      ..showName = json['showName'] as String?;

Map<String, dynamic> _$WithdrawInfoListItemEntityToJson(
        WithdrawInfoListItemEntity instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'amount': instance.amount,
      'usdtAmount': instance.usdtAmount,
      'status': instance.status,
      'withdrawTime': instance.withdrawTime,
      'icon': instance.icon,
      'showName': instance.showName,
    };
