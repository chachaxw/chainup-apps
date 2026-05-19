// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline_coin_introduce_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KlineCoinIntroduceEntity _$KlineCoinIntroduceEntityFromJson(
        Map<String, dynamic> json) =>
    KlineCoinIntroduceEntity()
      ..publishTime = json['publishTime'] as int?
      ..currencyAmount = json['currencyAmount'] as String?
      ..mtime = json['mtime'] as int?
      ..publishAmount = json['publishAmount'] as String?
      ..officialUrl = json['officialUrl'] as String?
      ..publishTimeStr = json['publishTimeStr'] as String?
      ..companyId = json['companyId'] as int?
      ..coinSymbol = json['coinSymbol'] as String?
      ..langKey = json['langKey'] as String?
      ..blockchainUrl = json['blockchainUrl'] as String?
      ..ctime = json['ctime'] as int?
      ..id = json['id'] as int?
      ..shortName = json['shortName'] as String?
      ..introduction = json['introduction'] as String?
      ..longName = json['longName'] as String?;

Map<String, dynamic> _$KlineCoinIntroduceEntityToJson(
        KlineCoinIntroduceEntity instance) =>
    <String, dynamic>{
      'publishTime': instance.publishTime,
      'currencyAmount': instance.currencyAmount,
      'mtime': instance.mtime,
      'publishAmount': instance.publishAmount,
      'officialUrl': instance.officialUrl,
      'publishTimeStr': instance.publishTimeStr,
      'companyId': instance.companyId,
      'coinSymbol': instance.coinSymbol,
      'langKey': instance.langKey,
      'blockchainUrl': instance.blockchainUrl,
      'ctime': instance.ctime,
      'id': instance.id,
      'shortName': instance.shortName,
      'introduction': instance.introduction,
      'longName': instance.longName,
    };
