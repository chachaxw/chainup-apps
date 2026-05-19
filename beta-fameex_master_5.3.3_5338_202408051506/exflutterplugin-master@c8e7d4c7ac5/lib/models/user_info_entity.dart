
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_info_entity.g.dart';
@JsonSerializable()
class UserInfoEntity {

	int? id;
	int? isSub;
	int? subUserDepositOpen;
	String? nickName;
	String? countryCode;
	String? mobileNumber;
	String? userAccount;
	String? email;
	int? accountStatus;
	int? googleStatus;
	int? isOpenMobileCheck;
	int? isCapitalPwordSet;
	String? realName;
	String? lastName;
	String? firstName;
	String? sumsubLevelName;
	int? realAuthType;
	int? authLevel;
	String? notPassReason;
	String? authCountryCode;
	String? etfLocalLimit;
	int? agentStatus;
	String? roleName;
	String? exportExcelAuth;
	List<dynamic>? myMarket;
	String? invitedCode;
	String? inviteCode;
	String? inviteUrl;
	String? inviteQECode;
	String? lastLoginIp;
	String? lastLoginTime;
	String? feeCoin;
	String? feeCoinRate;
	int? useFeeCoinOpen;
	@JsonKey(name: "fee_coin_open")
	String? feeCoinOpen;
	@JsonKey(name: "otc_save_ad_on_off")
	int? otcSaveAdOnOff;
	UserInfoOtcCompanyInfo? otcCompanyInfo;
	UserInfoUserCompanyInfo? userCompanyInfo;
	String? useEtf;
	String? hasFiatBank;
	bool? openAuditReport;
  
  UserInfoEntity();

  factory UserInfoEntity.fromJson(Map<String, dynamic> json) => _$UserInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserInfoOtcCompanyInfo {

	String? marginCoinSymbol;
	String? docAddr;
	String? otcCompanyApplyEmail;
	String? normalTradeLimit;
	String? normalCompanyMarginNum;
	String? status;
  
  UserInfoOtcCompanyInfo();

  factory UserInfoOtcCompanyInfo.fromJson(Map<String, dynamic> json) => _$UserInfoOtcCompanyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoOtcCompanyInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserInfoUserCompanyInfo {

	String? otcCompanyMarginNum;
	String? applyStatus;
	String? status;
  
  UserInfoUserCompanyInfo();

  factory UserInfoUserCompanyInfo.fromJson(Map<String, dynamic> json) => _$UserInfoUserCompanyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoUserCompanyInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}