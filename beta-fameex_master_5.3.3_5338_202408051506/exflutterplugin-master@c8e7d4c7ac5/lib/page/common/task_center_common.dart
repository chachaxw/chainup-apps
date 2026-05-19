import 'dart:ffi';
import 'dart:math';

import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/utils/decimal.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/decimal_util.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../constants/icon_constant.dart';
import '../../controllers/taskCenter/task_center_index_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../routes/routes.dart';

class TaskCenterCommon {
  static int getCountDownTime(TaskInfoListEntity mTaskInfo) {
    int time = 0;
    if (mTaskInfo.status != null) {
      if (mTaskInfo.status == 6) {
        time = mTaskInfo.startTime!;
      } else {
        time = mTaskInfo.endTime!;
      }
    }
    return time;
  }

  static int getLevelCountDownTime(TaskLevelRewardsEntity levelRewardsEntity) {
    int time = 0;
    if (levelRewardsEntity.receiveExpireTime != null) {
      time = int.parse(levelRewardsEntity.receiveExpireTime!.toString());
    }
    return time;
  }

  static String getTimeDesc(int? status) {
    String desc = "task_center_timed_task_from_end".tr;
    if (status == 6) {
      //未开始
      desc = "task_center_timed_task_from_start".tr;
    }
    return desc;
  }

  static String getTaskTitleByCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    switch (mTaskInfo.category) {
      case 0:
        //现货交易挑战
        mTaskTitle = "timed_task_detail_text48".tr;
        break;
      case 1:
        //杠杆交易挑战
        mTaskTitle = "timed_task_detail_text50".tr;
        break;
      case 2:
        //etf交易挑战
        mTaskTitle = "timed_task_detail_text51".tr;
        break;
      case 3:
        //合约交易挑战
        mTaskTitle = "timed_task_detail_text49".tr;
        break;
    }
    return mTaskTitle;
  }

  static String getTaskCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    switch (mTaskInfo.category) {
      case 0:
        //现货交易
        mTaskTitle = "task_center_timed_task_spot".tr;
        break;
      case 1:
        //杠杆
        mTaskTitle = "task_center_timed_task_margin".tr;
        break;
      case 2:
        //etf
        mTaskTitle = "task_center_timed_task_etf".tr;
        break;
      case 3:
        //合约
        mTaskTitle = "task_center_timed_task_futures".tr;
        break;
    }
    return mTaskTitle;
  }

  static bool taskBtnCanCLick(int? status) {
    if (status == null || status == 6 || status == 7 || status == 8) {
      //未开始，已完成，已结束，则不可点击
      return false;
    }
    return true;
  }

  static String getTaskActionStatus(int? status) {
    var mTaskTitle = "";
    switch (status) {
      case 0: //进行中，未完成，去交易
        mTaskTitle = "task_center_timed_task_trade".tr;
        break;
      case 1: //未领奖，已完成
        mTaskTitle = "text51".tr;
        break;
      case 2: //已领奖
        mTaskTitle = "task_center_timed_task_finished".tr;
        break;
      case 3: //失败
        mTaskTitle = "text53".tr;
        break;
      case 4: //已过期
        mTaskTitle = "text54".tr;
        break;
      case 5: //奖励已过期
        mTaskTitle = "text55".tr;
        break;
      case 6: //未开始
        mTaskTitle = "task_center_timed_task_unstart".tr;
        break;
      case 7: //已完成
        mTaskTitle = "task_center_timed_task_finished".tr;
        break;
      case 8: //已结束
        mTaskTitle = "task_center_timed_task_end".tr;
        break;
    }
    return mTaskTitle;
  }

  static void pushTaskActionStatus(TaskInfoListEntity mTaskInfo,
      {bool? isQuickMoney}) {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    if (!isLogin) {
      Routes.pushNvEvent(ev: NvEvent.login);
      return;
    }
    if (mTaskInfo.status == 0) {
      switch (mTaskInfo.category) {
        case 0:
          //币币交易
          Routes.pushNvEvent(
              ev: NvEvent.spot_trading,
              param: {"symbol": mTaskInfo.exchangeSymbol});
          break;
        case 1:
          //杠杆交易
          Routes.pushNvEvent(
              ev: NvEvent.lever_trading,
              param: {"symbol": mTaskInfo.levelSymbol});
          break;
        case 2:
          //ETF交易
          Routes.pushNvEvent(
              ev: NvEvent.etf_trading, param: {"symbol": mTaskInfo.etfSymbol});
          break;
        case 3:
          //合约交易
          Routes.pushNvEvent(ev: NvEvent.futures_trading);
          break;
        case 4:
          //入金
          Routes.pushNvEvent(
              ev: isQuickMoney ?? false
                  ? NvEvent.quick_money
                  : NvEvent.coinmap_depositing,
              param: {"symbol": "usdt"});
          break;
        case 7:
          //注册
          Routes.pushNvEvent(ev: NvEvent.login);
          break;
        case 8:
          //KYC
          {
            Routes.pushNvEvent(ev: NvEvent.idAuth);
          }
          break;
      }
    }
  }

  static getLevelText(int index) {
    String temp = "";
    switch (index) {
      case 0:
        temp = "timed_task_detail_text12".tr;
        break;
      case 1:
        temp = "timed_task_detail_text13".tr;
        break;
      case 2:
        temp = "timed_task_detail_text14".tr;
        break;
      default:
    }
    return temp;
  }

  static String getCoinShowNameText(Map? coinData, String? simpleName) {
    String showName = "";
    if (coinData != null &&
        simpleName != null &&
        coinData[simpleName] != null) {
      Map info = coinData[simpleName] ?? {};
      showName = info["showName"] ?? simpleName;
    }

    return showName;
  }

  static String getCoinIconText(Map? coinData, String? simpleName) {
    String icon = "";
    if (coinData != null &&
        simpleName != null &&
        coinData[simpleName] != null) {
      Map info = coinData[simpleName];
      icon = info["icon"];
    }
    return icon;
  }

  /// 给指定数字保留小数点后指定长度length的小数,不四舍五入,小数长度不足length，如果需要补0，则补足，否则 直接返回原值
  /// value，原始值
  /// leng  要保留的小数点长度
  /// needAddZero 小数部分不够的是否自动补0
  /// example：
  /// double a = truncateToTwoDecimalPlaces(3.1415926,2);
  /// a  = 3.14
  /// double a = truncateToTwoDecimalPlaces(3.1415926,4);
  /// a = 3.1415
  /// double a = truncateToTwoDecimalPlaces(3.1,2);
  /// a = 3.10
  static String truncateToSpecifiedDecimalPlaces(dynamic value, int? length,
      {bool needAddZero = false}) {
    // int decimalLength = countDecimalPlaces(value);
    if (value == null) {
      return "0";
    }
    if (length == null || length < 0) {
      if(value.endsWith(".")){
        value = value.replaceAll(".", "");
      }
      return value.toString();
    }
    if (value is double && value.toString().contains("e")) {
      ///如果value是1e-8, 1.5e-7这种科学计数法的数字
      String numLengthStr = value.toString().split("-").last;
      String prefixStr = value.toString().split("e").first;
      prefixStr = prefixStr.replaceFirst(RegExp(r'\.'), "");
      int sourceLength = int.tryParse(numLengthStr) ?? length;
      int prefixlength = prefixStr.length;

      value = value.toStringAsFixed(sourceLength + prefixlength);
    }
    String numberString = value is! String ? value.toString() : value;

    int decimalPlaces = 0;
    int dotIndex = numberString.indexOf('.');

    if (dotIndex != -1) {
      decimalPlaces = numberString.length - dotIndex - 1;
    } else {
      if (needAddZero) {
        String result = "$numberString.";
        for (var i = 0; i < length; i++) {
          result = "${result}0";
        }
        if(result.endsWith(".")){
          result = result.replaceAll(".", "");
        }
        return result;
      }
      if(numberString.endsWith(".")){
        numberString = numberString.replaceAll(".", "");
      }
      return numberString;
    }

    if (decimalPlaces < length) {
      if (needAddZero) {
        int temp = length - decimalPlaces;
        for (var i = 0; i < temp; i++) {
          numberString = "${numberString}0";
        }
      }
      if(numberString.endsWith(".")){
        numberString = numberString.replaceAll(".", "");
      }
      return numberString;
    } else {
      String leftStr = numberString.substring(0, dotIndex);
      String rightStr = numberString.substring(dotIndex, dotIndex + length + 1);
      String resultStr = leftStr + rightStr;
      if (double.tryParse(resultStr) == 0 && resultStr.contains("-")) {
        resultStr = resultStr.replaceFirst(RegExp(r'-'), "");
      }
      if(resultStr.endsWith(".")){
        resultStr = resultStr.replaceAll(".", "");
      }
      return resultStr;
    }
  }

  ///判断有几位小数
  static int countDecimalPlaces(dynamic number) {
    if (number == null) {
      return 0;
    }
    String numberString = "";
    if (number is num) {
      numberString = number.toString();
    } else if (number is String) {
      numberString = number;
    } else {
      return 0;
    }

    int decimalPlaces = 0;
    int dotIndex = numberString.indexOf('.');

    if (dotIndex != -1) {
      decimalPlaces = numberString.length - dotIndex - 1;
    }

    String rightStr = numberString.substring(dotIndex, numberString.length);

    return decimalPlaces;
  }

  /// taskCategory 0 首笔现货交易
  /// taskCategory 1 首笔杠杆交易
  /// taskCategory 2 首笔ETF交易
  /// taskCategory 3 首笔合约交易
  /// taskCategory 4 首笔数字货币充值
  /// taskCategory 5 法币充值
  /// taskCategory 7 注册
  /// taskCategory 8 KYC
  static Widget getTaskIcon(int? taskCategory) {
    Widget icon = ExIcon.icTask1();
    if (taskCategory == null) {
      return icon;
    }
    switch (taskCategory) {
      case 0: //现货
        icon = ExIcon.taskCurrency(width: 32, height: 32);
        break;
      case 1: //杠杆
        icon = ExIcon.taskMargin(width: 32, height: 32);
        break;
      case 2: //etf
        icon = ExIcon.taskEtf(width: 32, height: 32);
        break;
      case 3: //合约
        icon = ExIcon.taskFutures(width: 32, height: 32);
        break;
      case 4: //数字货币充值
        icon = ExIcon.taskRecharge(width: 32, height: 32);
        break;
      case 5: //法币充值
        icon = ExIcon.taskRecharge(width: 32, height: 32);
        break;
      case 7: //注册
        icon = ExIcon.taskRegistrationRewards(width: 32, height: 32);
        break;
      case 8: //kyc
        icon = ExIcon.taskKycCertificationRewards(width: 32, height: 32);
        break;
      default:
    }

    return icon;
  }

  static double handleBigNumToSuitableNum({required double value}) {
    double result = 0.0;
    if (value > 100000000000) {
      Decimal decimalResult =
          Decimal.parse(value.toString()) / Decimal.parse("10000000");
      String decimalResultStr =
          truncateToSpecifiedDecimalPlaces(decimalResult, 2);
      result = double.tryParse(decimalResultStr) ?? 0;
    } else if (value > 10000000) {
      Decimal decimalResult =
          Decimal.parse(value.toString()) / Decimal.parse("100000");
      String aa = truncateToSpecifiedDecimalPlaces(decimalResult, 2);
      result = double.tryParse(aa) ?? 0;
    } else {
      return value;
    }

    return result;
  }
}
