import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/kline_coin_introduce_entity.dart';
import 'package:json_annotation/json_annotation.dart';


KlineCoinIntroduceEntity $KlineCoinIntroduceEntityFromJson(
    Map<String, dynamic> json) {
  final KlineCoinIntroduceEntity klineCoinIntroduceEntity = KlineCoinIntroduceEntity();
  final int? publishTime = jsonConvert.convert<int>(json['publishTime']);
  if (publishTime != null) {
    klineCoinIntroduceEntity.publishTime = publishTime;
  }
  final String? currencyAmount = jsonConvert.convert<String>(
      json['currencyAmount']);
  if (currencyAmount != null) {
    klineCoinIntroduceEntity.currencyAmount = currencyAmount;
  }
  final int? mtime = jsonConvert.convert<int>(json['mtime']);
  if (mtime != null) {
    klineCoinIntroduceEntity.mtime = mtime;
  }
  final String? publishAmount = jsonConvert.convert<String>(
      json['publishAmount']);
  if (publishAmount != null) {
    klineCoinIntroduceEntity.publishAmount = publishAmount;
  }
  final String? officialUrl = jsonConvert.convert<String>(json['officialUrl']);
  if (officialUrl != null) {
    klineCoinIntroduceEntity.officialUrl = officialUrl;
  }
  final String? publishTimeStr = jsonConvert.convert<String>(
      json['publishTimeStr']);
  if (publishTimeStr != null) {
    klineCoinIntroduceEntity.publishTimeStr = publishTimeStr;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    klineCoinIntroduceEntity.companyId = companyId;
  }
  final String? coinSymbol = jsonConvert.convert<String>(json['coinSymbol']);
  if (coinSymbol != null) {
    klineCoinIntroduceEntity.coinSymbol = coinSymbol;
  }
  final String? langKey = jsonConvert.convert<String>(json['langKey']);
  if (langKey != null) {
    klineCoinIntroduceEntity.langKey = langKey;
  }
  final String? blockchainUrl = jsonConvert.convert<String>(
      json['blockchainUrl']);
  if (blockchainUrl != null) {
    klineCoinIntroduceEntity.blockchainUrl = blockchainUrl;
  }
  final int? ctime = jsonConvert.convert<int>(json['ctime']);
  if (ctime != null) {
    klineCoinIntroduceEntity.ctime = ctime;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    klineCoinIntroduceEntity.id = id;
  }
  final String? shortName = jsonConvert.convert<String>(json['shortName']);
  if (shortName != null) {
    klineCoinIntroduceEntity.shortName = shortName;
  }
  final String? introduction = jsonConvert.convert<String>(
      json['introduction']);
  if (introduction != null) {
    klineCoinIntroduceEntity.introduction = introduction;
  }
  final String? longName = jsonConvert.convert<String>(json['longName']);
  if (longName != null) {
    klineCoinIntroduceEntity.longName = longName;
  }
  return klineCoinIntroduceEntity;
}

Map<String, dynamic> $KlineCoinIntroduceEntityToJson(
    KlineCoinIntroduceEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['publishTime'] = entity.publishTime;
  data['currencyAmount'] = entity.currencyAmount;
  data['mtime'] = entity.mtime;
  data['publishAmount'] = entity.publishAmount;
  data['officialUrl'] = entity.officialUrl;
  data['publishTimeStr'] = entity.publishTimeStr;
  data['companyId'] = entity.companyId;
  data['coinSymbol'] = entity.coinSymbol;
  data['langKey'] = entity.langKey;
  data['blockchainUrl'] = entity.blockchainUrl;
  data['ctime'] = entity.ctime;
  data['id'] = entity.id;
  data['shortName'] = entity.shortName;
  data['introduction'] = entity.introduction;
  data['longName'] = entity.longName;
  return data;
}

extension KlineCoinIntroduceEntityExtension on KlineCoinIntroduceEntity {
  KlineCoinIntroduceEntity copyWith({
    int? publishTime,
    String? currencyAmount,
    int? mtime,
    String? publishAmount,
    String? officialUrl,
    String? publishTimeStr,
    int? companyId,
    String? coinSymbol,
    String? langKey,
    String? blockchainUrl,
    int? ctime,
    int? id,
    String? shortName,
    String? introduction,
    String? longName,
  }) {
    return KlineCoinIntroduceEntity()
      ..publishTime = publishTime ?? this.publishTime
      ..currencyAmount = currencyAmount ?? this.currencyAmount
      ..mtime = mtime ?? this.mtime
      ..publishAmount = publishAmount ?? this.publishAmount
      ..officialUrl = officialUrl ?? this.officialUrl
      ..publishTimeStr = publishTimeStr ?? this.publishTimeStr
      ..companyId = companyId ?? this.companyId
      ..coinSymbol = coinSymbol ?? this.coinSymbol
      ..langKey = langKey ?? this.langKey
      ..blockchainUrl = blockchainUrl ?? this.blockchainUrl
      ..ctime = ctime ?? this.ctime
      ..id = id ?? this.id
      ..shortName = shortName ?? this.shortName
      ..introduction = introduction ?? this.introduction
      ..longName = longName ?? this.longName;
  }
}