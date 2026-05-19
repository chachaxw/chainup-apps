// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfoEntity _$UserInfoEntityFromJson(Map<String, dynamic> json) =>
    UserInfoEntity()
      ..id = json['id'] as int?
      ..isSub = json['isSub'] as int?
      ..subUserDepositOpen = json['subUserDepositOpen'] as int?
      ..nickName = json['nickName'] as String?
      ..countryCode = json['countryCode'] as String?
      ..mobileNumber = json['mobileNumber'] as String?
      ..userAccount = json['userAccount'] as String?
      ..email = json['email'] as String?
      ..accountStatus = json['accountStatus'] as int?
      ..googleStatus = json['googleStatus'] as int?
      ..isOpenMobileCheck = json['isOpenMobileCheck'] as int?
      ..isCapitalPwordSet = json['isCapitalPwordSet'] as int?
      ..realName = json['realName'] as String?
      ..lastName = json['lastName'] as String?
      ..firstName = json['firstName'] as String?
      ..sumsubLevelName = json['sumsubLevelName'] as String?
      ..realAuthType = json['realAuthType'] as int?
      ..authLevel = json['authLevel'] as int?
      ..notPassReason = json['notPassReason'] as String?
      ..authCountryCode = json['authCountryCode'] as String?
      ..etfLocalLimit = json['etfLocalLimit'] as String?
      ..agentStatus = json['agentStatus'] as int?
      ..roleName = json['roleName'] as String?
      ..exportExcelAuth = json['exportExcelAuth'] as String?
      ..myMarket = json['myMarket'] as List<dynamic>?
      ..invitedCode = json['invitedCode'] as String?
      ..inviteCode = json['inviteCode'] as String?
      ..inviteUrl = json['inviteUrl'] as String?
      ..inviteQECode = json['inviteQECode'] as String?
      ..lastLoginIp = json['lastLoginIp'] as String?
      ..lastLoginTime = json['lastLoginTime'] as String?
      ..feeCoin = json['feeCoin'] as String?
      ..feeCoinRate = json['feeCoinRate'] as String?
      ..useFeeCoinOpen = json['useFeeCoinOpen'] as int?
      ..feeCoinOpen = json['fee_coin_open'] as String?
      ..otcSaveAdOnOff = json['otc_save_ad_on_off'] as int?
      ..otcCompanyInfo = json['otcCompanyInfo'] == null
          ? null
          : UserInfoOtcCompanyInfo.fromJson(
              json['otcCompanyInfo'] as Map<String, dynamic>)
      ..userCompanyInfo = json['userCompanyInfo'] == null
          ? null
          : UserInfoUserCompanyInfo.fromJson(
              json['userCompanyInfo'] as Map<String, dynamic>)
      ..useEtf = json['useEtf'] as String?
      ..hasFiatBank = json['hasFiatBank'] as String?
      ..openAuditReport = json['openAuditReport'] as bool?;

Map<String, dynamic> _$UserInfoEntityToJson(UserInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isSub': instance.isSub,
      'subUserDepositOpen': instance.subUserDepositOpen,
      'nickName': instance.nickName,
      'countryCode': instance.countryCode,
      'mobileNumber': instance.mobileNumber,
      'userAccount': instance.userAccount,
      'email': instance.email,
      'accountStatus': instance.accountStatus,
      'googleStatus': instance.googleStatus,
      'isOpenMobileCheck': instance.isOpenMobileCheck,
      'isCapitalPwordSet': instance.isCapitalPwordSet,
      'realName': instance.realName,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
      'sumsubLevelName': instance.sumsubLevelName,
      'realAuthType': instance.realAuthType,
      'authLevel': instance.authLevel,
      'notPassReason': instance.notPassReason,
      'authCountryCode': instance.authCountryCode,
      'etfLocalLimit': instance.etfLocalLimit,
      'agentStatus': instance.agentStatus,
      'roleName': instance.roleName,
      'exportExcelAuth': instance.exportExcelAuth,
      'myMarket': instance.myMarket,
      'invitedCode': instance.invitedCode,
      'inviteCode': instance.inviteCode,
      'inviteUrl': instance.inviteUrl,
      'inviteQECode': instance.inviteQECode,
      'lastLoginIp': instance.lastLoginIp,
      'lastLoginTime': instance.lastLoginTime,
      'feeCoin': instance.feeCoin,
      'feeCoinRate': instance.feeCoinRate,
      'useFeeCoinOpen': instance.useFeeCoinOpen,
      'fee_coin_open': instance.feeCoinOpen,
      'otc_save_ad_on_off': instance.otcSaveAdOnOff,
      'otcCompanyInfo': instance.otcCompanyInfo,
      'userCompanyInfo': instance.userCompanyInfo,
      'useEtf': instance.useEtf,
      'hasFiatBank': instance.hasFiatBank,
      'openAuditReport': instance.openAuditReport,
    };

UserInfoOtcCompanyInfo _$UserInfoOtcCompanyInfoFromJson(
        Map<String, dynamic> json) =>
    UserInfoOtcCompanyInfo()
      ..marginCoinSymbol = json['marginCoinSymbol'] as String?
      ..docAddr = json['docAddr'] as String?
      ..otcCompanyApplyEmail = json['otcCompanyApplyEmail'] as String?
      ..normalTradeLimit = json['normalTradeLimit'] as String?
      ..normalCompanyMarginNum = json['normalCompanyMarginNum'] as String?
      ..status = json['status'] as String?;

Map<String, dynamic> _$UserInfoOtcCompanyInfoToJson(
        UserInfoOtcCompanyInfo instance) =>
    <String, dynamic>{
      'marginCoinSymbol': instance.marginCoinSymbol,
      'docAddr': instance.docAddr,
      'otcCompanyApplyEmail': instance.otcCompanyApplyEmail,
      'normalTradeLimit': instance.normalTradeLimit,
      'normalCompanyMarginNum': instance.normalCompanyMarginNum,
      'status': instance.status,
    };

UserInfoUserCompanyInfo _$UserInfoUserCompanyInfoFromJson(
        Map<String, dynamic> json) =>
    UserInfoUserCompanyInfo()
      ..otcCompanyMarginNum = json['otcCompanyMarginNum'] as String?
      ..applyStatus = json['applyStatus'] as String?
      ..status = json['status'] as String?;

Map<String, dynamic> _$UserInfoUserCompanyInfoToJson(
        UserInfoUserCompanyInfo instance) =>
    <String, dynamic>{
      'otcCompanyMarginNum': instance.otcCompanyMarginNum,
      'applyStatus': instance.applyStatus,
      'status': instance.status,
    };
