import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/user_info_entity.dart';
import 'package:json_annotation/json_annotation.dart';


UserInfoEntity $UserInfoEntityFromJson(Map<String, dynamic> json) {
  final UserInfoEntity userInfoEntity = UserInfoEntity();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    userInfoEntity.id = id;
  }
  final int? isSub = jsonConvert.convert<int>(json['isSub']);
  if (isSub != null) {
    userInfoEntity.isSub = isSub;
  }
  final int? subUserDepositOpen = jsonConvert.convert<int>(
      json['subUserDepositOpen']);
  if (subUserDepositOpen != null) {
    userInfoEntity.subUserDepositOpen = subUserDepositOpen;
  }
  final String? nickName = jsonConvert.convert<String>(json['nickName']);
  if (nickName != null) {
    userInfoEntity.nickName = nickName;
  }
  final String? countryCode = jsonConvert.convert<String>(json['countryCode']);
  if (countryCode != null) {
    userInfoEntity.countryCode = countryCode;
  }
  final String? mobileNumber = jsonConvert.convert<String>(
      json['mobileNumber']);
  if (mobileNumber != null) {
    userInfoEntity.mobileNumber = mobileNumber;
  }
  final String? userAccount = jsonConvert.convert<String>(json['userAccount']);
  if (userAccount != null) {
    userInfoEntity.userAccount = userAccount;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    userInfoEntity.email = email;
  }
  final int? accountStatus = jsonConvert.convert<int>(json['accountStatus']);
  if (accountStatus != null) {
    userInfoEntity.accountStatus = accountStatus;
  }
  final int? googleStatus = jsonConvert.convert<int>(json['googleStatus']);
  if (googleStatus != null) {
    userInfoEntity.googleStatus = googleStatus;
  }
  final int? isOpenMobileCheck = jsonConvert.convert<int>(
      json['isOpenMobileCheck']);
  if (isOpenMobileCheck != null) {
    userInfoEntity.isOpenMobileCheck = isOpenMobileCheck;
  }
  final int? isCapitalPwordSet = jsonConvert.convert<int>(
      json['isCapitalPwordSet']);
  if (isCapitalPwordSet != null) {
    userInfoEntity.isCapitalPwordSet = isCapitalPwordSet;
  }
  final String? realName = jsonConvert.convert<String>(json['realName']);
  if (realName != null) {
    userInfoEntity.realName = realName;
  }
  final String? lastName = jsonConvert.convert<String>(json['lastName']);
  if (lastName != null) {
    userInfoEntity.lastName = lastName;
  }
  final String? firstName = jsonConvert.convert<String>(json['firstName']);
  if (firstName != null) {
    userInfoEntity.firstName = firstName;
  }
  final String? sumsubLevelName = jsonConvert.convert<String>(
      json['sumsubLevelName']);
  if (sumsubLevelName != null) {
    userInfoEntity.sumsubLevelName = sumsubLevelName;
  }
  final int? realAuthType = jsonConvert.convert<int>(json['realAuthType']);
  if (realAuthType != null) {
    userInfoEntity.realAuthType = realAuthType;
  }
  final int? authLevel = jsonConvert.convert<int>(json['authLevel']);
  if (authLevel != null) {
    userInfoEntity.authLevel = authLevel;
  }
  final String? notPassReason = jsonConvert.convert<String>(
      json['notPassReason']);
  if (notPassReason != null) {
    userInfoEntity.notPassReason = notPassReason;
  }
  final String? authCountryCode = jsonConvert.convert<String>(
      json['authCountryCode']);
  if (authCountryCode != null) {
    userInfoEntity.authCountryCode = authCountryCode;
  }
  final String? etfLocalLimit = jsonConvert.convert<String>(
      json['etfLocalLimit']);
  if (etfLocalLimit != null) {
    userInfoEntity.etfLocalLimit = etfLocalLimit;
  }
  final int? agentStatus = jsonConvert.convert<int>(json['agentStatus']);
  if (agentStatus != null) {
    userInfoEntity.agentStatus = agentStatus;
  }
  final String? roleName = jsonConvert.convert<String>(json['roleName']);
  if (roleName != null) {
    userInfoEntity.roleName = roleName;
  }
  final String? exportExcelAuth = jsonConvert.convert<String>(
      json['exportExcelAuth']);
  if (exportExcelAuth != null) {
    userInfoEntity.exportExcelAuth = exportExcelAuth;
  }
  final List<dynamic>? myMarket = (json['myMarket'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (myMarket != null) {
    userInfoEntity.myMarket = myMarket;
  }
  final String? invitedCode = jsonConvert.convert<String>(json['invitedCode']);
  if (invitedCode != null) {
    userInfoEntity.invitedCode = invitedCode;
  }
  final String? inviteCode = jsonConvert.convert<String>(json['inviteCode']);
  if (inviteCode != null) {
    userInfoEntity.inviteCode = inviteCode;
  }
  final String? inviteUrl = jsonConvert.convert<String>(json['inviteUrl']);
  if (inviteUrl != null) {
    userInfoEntity.inviteUrl = inviteUrl;
  }
  final String? inviteQECode = jsonConvert.convert<String>(
      json['inviteQECode']);
  if (inviteQECode != null) {
    userInfoEntity.inviteQECode = inviteQECode;
  }
  final String? lastLoginIp = jsonConvert.convert<String>(json['lastLoginIp']);
  if (lastLoginIp != null) {
    userInfoEntity.lastLoginIp = lastLoginIp;
  }
  final String? lastLoginTime = jsonConvert.convert<String>(
      json['lastLoginTime']);
  if (lastLoginTime != null) {
    userInfoEntity.lastLoginTime = lastLoginTime;
  }
  final String? feeCoin = jsonConvert.convert<String>(json['feeCoin']);
  if (feeCoin != null) {
    userInfoEntity.feeCoin = feeCoin;
  }
  final String? feeCoinRate = jsonConvert.convert<String>(json['feeCoinRate']);
  if (feeCoinRate != null) {
    userInfoEntity.feeCoinRate = feeCoinRate;
  }
  final int? useFeeCoinOpen = jsonConvert.convert<int>(json['useFeeCoinOpen']);
  if (useFeeCoinOpen != null) {
    userInfoEntity.useFeeCoinOpen = useFeeCoinOpen;
  }
  final String? feeCoinOpen = jsonConvert.convert<String>(json['feeCoinOpen']);
  if (feeCoinOpen != null) {
    userInfoEntity.feeCoinOpen = feeCoinOpen;
  }
  final int? otcSaveAdOnOff = jsonConvert.convert<int>(json['otcSaveAdOnOff']);
  if (otcSaveAdOnOff != null) {
    userInfoEntity.otcSaveAdOnOff = otcSaveAdOnOff;
  }
  final UserInfoOtcCompanyInfo? otcCompanyInfo = jsonConvert.convert<
      UserInfoOtcCompanyInfo>(json['otcCompanyInfo']);
  if (otcCompanyInfo != null) {
    userInfoEntity.otcCompanyInfo = otcCompanyInfo;
  }
  final UserInfoUserCompanyInfo? userCompanyInfo = jsonConvert.convert<
      UserInfoUserCompanyInfo>(json['userCompanyInfo']);
  if (userCompanyInfo != null) {
    userInfoEntity.userCompanyInfo = userCompanyInfo;
  }
  final String? useEtf = jsonConvert.convert<String>(json['useEtf']);
  if (useEtf != null) {
    userInfoEntity.useEtf = useEtf;
  }
  final String? hasFiatBank = jsonConvert.convert<String>(json['hasFiatBank']);
  if (hasFiatBank != null) {
    userInfoEntity.hasFiatBank = hasFiatBank;
  }
  final bool? openAuditReport = jsonConvert.convert<bool>(
      json['openAuditReport']);
  if (openAuditReport != null) {
    userInfoEntity.openAuditReport = openAuditReport;
  }
  return userInfoEntity;
}

Map<String, dynamic> $UserInfoEntityToJson(UserInfoEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['isSub'] = entity.isSub;
  data['subUserDepositOpen'] = entity.subUserDepositOpen;
  data['nickName'] = entity.nickName;
  data['countryCode'] = entity.countryCode;
  data['mobileNumber'] = entity.mobileNumber;
  data['userAccount'] = entity.userAccount;
  data['email'] = entity.email;
  data['accountStatus'] = entity.accountStatus;
  data['googleStatus'] = entity.googleStatus;
  data['isOpenMobileCheck'] = entity.isOpenMobileCheck;
  data['isCapitalPwordSet'] = entity.isCapitalPwordSet;
  data['realName'] = entity.realName;
  data['lastName'] = entity.lastName;
  data['firstName'] = entity.firstName;
  data['sumsubLevelName'] = entity.sumsubLevelName;
  data['realAuthType'] = entity.realAuthType;
  data['authLevel'] = entity.authLevel;
  data['notPassReason'] = entity.notPassReason;
  data['authCountryCode'] = entity.authCountryCode;
  data['etfLocalLimit'] = entity.etfLocalLimit;
  data['agentStatus'] = entity.agentStatus;
  data['roleName'] = entity.roleName;
  data['exportExcelAuth'] = entity.exportExcelAuth;
  data['myMarket'] = entity.myMarket;
  data['invitedCode'] = entity.invitedCode;
  data['inviteCode'] = entity.inviteCode;
  data['inviteUrl'] = entity.inviteUrl;
  data['inviteQECode'] = entity.inviteQECode;
  data['lastLoginIp'] = entity.lastLoginIp;
  data['lastLoginTime'] = entity.lastLoginTime;
  data['feeCoin'] = entity.feeCoin;
  data['feeCoinRate'] = entity.feeCoinRate;
  data['useFeeCoinOpen'] = entity.useFeeCoinOpen;
  data['feeCoinOpen'] = entity.feeCoinOpen;
  data['otcSaveAdOnOff'] = entity.otcSaveAdOnOff;
  data['otcCompanyInfo'] = entity.otcCompanyInfo?.toJson();
  data['userCompanyInfo'] = entity.userCompanyInfo?.toJson();
  data['useEtf'] = entity.useEtf;
  data['hasFiatBank'] = entity.hasFiatBank;
  data['openAuditReport'] = entity.openAuditReport;
  return data;
}

extension UserInfoEntityExtension on UserInfoEntity {
  UserInfoEntity copyWith({
    int? id,
    int? isSub,
    int? subUserDepositOpen,
    String? nickName,
    String? countryCode,
    String? mobileNumber,
    String? userAccount,
    String? email,
    int? accountStatus,
    int? googleStatus,
    int? isOpenMobileCheck,
    int? isCapitalPwordSet,
    String? realName,
    String? lastName,
    String? firstName,
    String? sumsubLevelName,
    int? realAuthType,
    int? authLevel,
    String? notPassReason,
    String? authCountryCode,
    String? etfLocalLimit,
    int? agentStatus,
    String? roleName,
    String? exportExcelAuth,
    List<dynamic>? myMarket,
    String? invitedCode,
    String? inviteCode,
    String? inviteUrl,
    String? inviteQECode,
    String? lastLoginIp,
    String? lastLoginTime,
    String? feeCoin,
    String? feeCoinRate,
    int? useFeeCoinOpen,
    String? feeCoinOpen,
    int? otcSaveAdOnOff,
    UserInfoOtcCompanyInfo? otcCompanyInfo,
    UserInfoUserCompanyInfo? userCompanyInfo,
    String? useEtf,
    String? hasFiatBank,
    bool? openAuditReport,
  }) {
    return UserInfoEntity()
      ..id = id ?? this.id
      ..isSub = isSub ?? this.isSub
      ..subUserDepositOpen = subUserDepositOpen ?? this.subUserDepositOpen
      ..nickName = nickName ?? this.nickName
      ..countryCode = countryCode ?? this.countryCode
      ..mobileNumber = mobileNumber ?? this.mobileNumber
      ..userAccount = userAccount ?? this.userAccount
      ..email = email ?? this.email
      ..accountStatus = accountStatus ?? this.accountStatus
      ..googleStatus = googleStatus ?? this.googleStatus
      ..isOpenMobileCheck = isOpenMobileCheck ?? this.isOpenMobileCheck
      ..isCapitalPwordSet = isCapitalPwordSet ?? this.isCapitalPwordSet
      ..realName = realName ?? this.realName
      ..lastName = lastName ?? this.lastName
      ..firstName = firstName ?? this.firstName
      ..sumsubLevelName = sumsubLevelName ?? this.sumsubLevelName
      ..realAuthType = realAuthType ?? this.realAuthType
      ..authLevel = authLevel ?? this.authLevel
      ..notPassReason = notPassReason ?? this.notPassReason
      ..authCountryCode = authCountryCode ?? this.authCountryCode
      ..etfLocalLimit = etfLocalLimit ?? this.etfLocalLimit
      ..agentStatus = agentStatus ?? this.agentStatus
      ..roleName = roleName ?? this.roleName
      ..exportExcelAuth = exportExcelAuth ?? this.exportExcelAuth
      ..myMarket = myMarket ?? this.myMarket
      ..invitedCode = invitedCode ?? this.invitedCode
      ..inviteCode = inviteCode ?? this.inviteCode
      ..inviteUrl = inviteUrl ?? this.inviteUrl
      ..inviteQECode = inviteQECode ?? this.inviteQECode
      ..lastLoginIp = lastLoginIp ?? this.lastLoginIp
      ..lastLoginTime = lastLoginTime ?? this.lastLoginTime
      ..feeCoin = feeCoin ?? this.feeCoin
      ..feeCoinRate = feeCoinRate ?? this.feeCoinRate
      ..useFeeCoinOpen = useFeeCoinOpen ?? this.useFeeCoinOpen
      ..feeCoinOpen = feeCoinOpen ?? this.feeCoinOpen
      ..otcSaveAdOnOff = otcSaveAdOnOff ?? this.otcSaveAdOnOff
      ..otcCompanyInfo = otcCompanyInfo ?? this.otcCompanyInfo
      ..userCompanyInfo = userCompanyInfo ?? this.userCompanyInfo
      ..useEtf = useEtf ?? this.useEtf
      ..hasFiatBank = hasFiatBank ?? this.hasFiatBank
      ..openAuditReport = openAuditReport ?? this.openAuditReport;
  }
}

UserInfoOtcCompanyInfo $UserInfoOtcCompanyInfoFromJson(
    Map<String, dynamic> json) {
  final UserInfoOtcCompanyInfo userInfoOtcCompanyInfo = UserInfoOtcCompanyInfo();
  final String? marginCoinSymbol = jsonConvert.convert<String>(
      json['marginCoinSymbol']);
  if (marginCoinSymbol != null) {
    userInfoOtcCompanyInfo.marginCoinSymbol = marginCoinSymbol;
  }
  final String? docAddr = jsonConvert.convert<String>(json['docAddr']);
  if (docAddr != null) {
    userInfoOtcCompanyInfo.docAddr = docAddr;
  }
  final String? otcCompanyApplyEmail = jsonConvert.convert<String>(
      json['otcCompanyApplyEmail']);
  if (otcCompanyApplyEmail != null) {
    userInfoOtcCompanyInfo.otcCompanyApplyEmail = otcCompanyApplyEmail;
  }
  final String? normalTradeLimit = jsonConvert.convert<String>(
      json['normalTradeLimit']);
  if (normalTradeLimit != null) {
    userInfoOtcCompanyInfo.normalTradeLimit = normalTradeLimit;
  }
  final String? normalCompanyMarginNum = jsonConvert.convert<String>(
      json['normalCompanyMarginNum']);
  if (normalCompanyMarginNum != null) {
    userInfoOtcCompanyInfo.normalCompanyMarginNum = normalCompanyMarginNum;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    userInfoOtcCompanyInfo.status = status;
  }
  return userInfoOtcCompanyInfo;
}

Map<String, dynamic> $UserInfoOtcCompanyInfoToJson(
    UserInfoOtcCompanyInfo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['marginCoinSymbol'] = entity.marginCoinSymbol;
  data['docAddr'] = entity.docAddr;
  data['otcCompanyApplyEmail'] = entity.otcCompanyApplyEmail;
  data['normalTradeLimit'] = entity.normalTradeLimit;
  data['normalCompanyMarginNum'] = entity.normalCompanyMarginNum;
  data['status'] = entity.status;
  return data;
}

extension UserInfoOtcCompanyInfoExtension on UserInfoOtcCompanyInfo {
  UserInfoOtcCompanyInfo copyWith({
    String? marginCoinSymbol,
    String? docAddr,
    String? otcCompanyApplyEmail,
    String? normalTradeLimit,
    String? normalCompanyMarginNum,
    String? status,
  }) {
    return UserInfoOtcCompanyInfo()
      ..marginCoinSymbol = marginCoinSymbol ?? this.marginCoinSymbol
      ..docAddr = docAddr ?? this.docAddr
      ..otcCompanyApplyEmail = otcCompanyApplyEmail ?? this.otcCompanyApplyEmail
      ..normalTradeLimit = normalTradeLimit ?? this.normalTradeLimit
      ..normalCompanyMarginNum = normalCompanyMarginNum ??
          this.normalCompanyMarginNum
      ..status = status ?? this.status;
  }
}

UserInfoUserCompanyInfo $UserInfoUserCompanyInfoFromJson(
    Map<String, dynamic> json) {
  final UserInfoUserCompanyInfo userInfoUserCompanyInfo = UserInfoUserCompanyInfo();
  final String? otcCompanyMarginNum = jsonConvert.convert<String>(
      json['otcCompanyMarginNum']);
  if (otcCompanyMarginNum != null) {
    userInfoUserCompanyInfo.otcCompanyMarginNum = otcCompanyMarginNum;
  }
  final String? applyStatus = jsonConvert.convert<String>(json['applyStatus']);
  if (applyStatus != null) {
    userInfoUserCompanyInfo.applyStatus = applyStatus;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    userInfoUserCompanyInfo.status = status;
  }
  return userInfoUserCompanyInfo;
}

Map<String, dynamic> $UserInfoUserCompanyInfoToJson(
    UserInfoUserCompanyInfo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['otcCompanyMarginNum'] = entity.otcCompanyMarginNum;
  data['applyStatus'] = entity.applyStatus;
  data['status'] = entity.status;
  return data;
}

extension UserInfoUserCompanyInfoExtension on UserInfoUserCompanyInfo {
  UserInfoUserCompanyInfo copyWith({
    String? otcCompanyMarginNum,
    String? applyStatus,
    String? status,
  }) {
    return UserInfoUserCompanyInfo()
      ..otcCompanyMarginNum = otcCompanyMarginNum ?? this.otcCompanyMarginNum
      ..applyStatus = applyStatus ?? this.applyStatus
      ..status = status ?? this.status;
  }
}