
import 'package:flutter/widgets.dart';

class BottomSheetEntity {

	 int? id;
	 String? showName;
	 int? extras;
	 String? extrasStr;

  BottomSheetEntity({this.id, this.showName, this.extras, this.extrasStr});
}


class SecurityConfirmSheetEntity {

	String? loginPwd;
	String? smsCode;
	String? emailCode;
	String? newEmailCode;
	String? oldEmailCode;
	String? newSmsCode;
	String? oldSmsCode;
	String? gaCode;

	SecurityConfirmSheetEntity({this.loginPwd, this.smsCode, this.emailCode,  this.newEmailCode, this.oldEmailCode,this.newSmsCode, this.oldSmsCode, this.gaCode});
}


class ContractTypeEntity {

	 int classification;
	 String showName;

	 ContractTypeEntity(this.classification, this.showName);
}


class ContractOrderTypeEntity {

	 int? id;
	 String? showName;

	 ContractOrderTypeEntity({this.id, this.showName});
}


class ShareTypeSheetEntity {

	String showName;
	Image showImage;

	ShareTypeSheetEntity({ required this.showName, required this.showImage});
}

class LeverCoinEntity {

	String originalCoinName;
	String showCoinName;
	String balance;

	LeverCoinEntity({
		required this.originalCoinName,
		required this.showCoinName,
		required this.balance
	});
}

class KlineTimeEntity {

	int id;
	String subTime;
	String showTime;
	bool? isLine;

	KlineTimeEntity({
		required this.id,
		required this.subTime,
		required this.showTime,
		this.isLine,
	});
}

class ContractTypeTipsEntity {

	int id;
	String type;
	String title;
	String desc;

	ContractTypeTipsEntity({
		required this.id,
		required this.type,
		required this.title,
		required this.desc,
	});
}
