import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/controller/base_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../page/common/task_center_common.dart';
import '../../utils/decimal.dart';

class TaskCenterTimedTaskItemController extends BaseController {
  final mTaskInfo = TaskInfoListEntity().obs;

  late BuildContext pageContext;

  final RxDouble progressLength = 0.0.obs;
  final RxInt firstLevelStatus = 0.obs;
  final RxInt secondLevelStatus = 0.obs;
  final RxInt thirdLevelStatus = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageContext = Get.context!;
      // calculateProgressLength(
      //     pageContext, mTaskInfo.value, progressKey, levelKeyList);
    });
  }

  void initLevelStatus(int index, int? status) {
    switch (index) {
      case 0:
        firstLevelStatus.value = status ?? 0;

        break;
      case 1:
        secondLevelStatus.value = status ?? 0;

        break;
      case 2:
        thirdLevelStatus.value = status ?? 0;

        break;
      default:
    }
  }

  int getStatus(int index) {
    int status = 0;
    switch (index) {
      case 0:
        status = firstLevelStatus.value;
        break;
      case 1:
        status = secondLevelStatus.value;
        break;
      case 2:
        status = thirdLevelStatus.value;
        break;
      default:
    }
    return status;
  }

  void changeStatus(int index, int status) {
    switch (index) {
      case 0:
        firstLevelStatus.value = status;
        break;
      case 1:
        secondLevelStatus.value = status;
        break;
      case 2:
        thirdLevelStatus.value = status;
        break;
      default:
    }
  }

  @override
  void loadNet() {}

  void receiveRewards() {}

  String handleDouble(String source, {bool needCutDecimal = false}) {
    double temp = double.parse(source);
    if (temp % 1 == 0) {
      return temp.toInt().toString();
    }
    if (needCutDecimal) {
      //截取小数点后两位
      temp = double.parse(
          TaskCenterCommon.truncateToSpecifiedDecimalPlaces(temp, 2));
      if (temp % 1 == 0) {
        return temp.toInt().toString();
      }
    }

    return temp.toString();
  }

  String getTaskDescByCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskDesc = "";
    String rewardAmount = getRewardAmount(mTaskInfo);
    rewardAmount = handleDouble(rewardAmount);

    var rewardCoin = mTaskInfo.rewardCoin.toString();
    switch (mTaskInfo.category) {
      case 0: //币币交易
        mTaskDesc = "task_center_timed_task_participate_in_spot".tr.trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 1: //杠杆
        mTaskDesc = "task_center_timed_task_participate_in_margin".tr.trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 2: //ETF
        mTaskDesc = "task_center_timed_task_participate_in_etf".tr.trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 3: //合约
        mTaskDesc = "task_center_timed_task_participate_in_futures".tr.trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
    }
    return mTaskDesc;
  }

  String getMaxReward(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    if (mTaskInfo.taskLevelRewards != null &&
        mTaskInfo.taskLevelRewards!.isNotEmpty) {
      TaskLevelRewardsEntity? levelRewardsEntity =
          mTaskInfo.taskLevelRewards!.last;
      mTaskTitle = (levelRewardsEntity != null &&
              levelRewardsEntity.targetAmount != null)
          ? levelRewardsEntity.targetAmount.toString()
          : "";
    }
    return mTaskTitle;
  }

  String getTimeDesc(int? status) {
    String desc = "task_center_timed_task_from_end".tr;
    if (status == 6) {
      //未开始
      desc = "task_center_timed_task_from_start".tr;
    }
    return desc;
  }

  String getRewardAmount(TaskInfoListEntity mTaskInfo) {
    String desc = "";
    if (mTaskInfo.taskLevelRewards != null) {
      Decimal total = Decimal.parse('0.0');
      for (var element in mTaskInfo.taskLevelRewards!) {
        if (element.rewardAmount != null) {
          Decimal rewardAmount =
              Decimal.parse(element.rewardAmount!.toString());
          total = rewardAmount + total;
        }
      }
      desc = total.toString();
    }
    return desc;
  }

/*
  void calculateProgressLength(
      BuildContext context,
      TaskInfoListEntity? mTaskInfo,
      GlobalKey progressKey,
      List<GlobalKey> levelKeyList) {
    if (mTaskInfo == null || mTaskInfo.taskLevelRewards == null) {
      progressLength.value = 0.0;
      return;
    }
    double initDx = getPositionX(progressKey);
    double finishedAmount = mTaskInfo.finishedAmount != null
        ? double.parse(mTaskInfo.finishedAmount!)
        : 0.0;
    double totalWidth = getTotalWidth(progressKey);
    double scale = 100 / totalWidth;
    debugPrint("totalWidth :: $totalWidth");
    if (finishedAmount == 0 || mTaskInfo.status == 6) {
      progressLength.value = 0;
      return;
    }
    if (mTaskInfo.taskLevelRewards!.length == 1) {
      //只有一级
      TaskLevelRewardsEntity currentLevelRewardsEntity =
          mTaskInfo.taskLevelRewards![0];
      double totalAmount = currentLevelRewardsEntity.targetAmount != null
          ? double.parse(currentLevelRewardsEntity.targetAmount!)
          : 0.0;
      if (finishedAmount < totalAmount) {
        progressLength.value = (totalWidth - initDx) / 2.0 * scale;
        debugPrint("1 --==totalWidth :: $progressLength --- $initDx :");
      } else {
        progressLength.value = 100;
        debugPrint("1 ==totalWidth :: $progressLength --- $totalWidth ");
      }
    }

    if (mTaskInfo.taskLevelRewards!.length == 2) {
      TaskLevelRewardsEntity secondLevelRewardsEntity =
          mTaskInfo.taskLevelRewards![1];
      double firstLevelDx = getPositionX(levelKeyList[0]);
      double secondLevelDx = getPositionX(levelKeyList[1]);
      //只有两级
      double firstLevelAmount =
          mTaskInfo.taskLevelRewards![0].targetAmount != null
              ? double.parse(mTaskInfo.taskLevelRewards![0].targetAmount!)
              : 0.0;
      double secondAmount = secondLevelRewardsEntity.targetAmount != null
          ? double.parse(secondLevelRewardsEntity.targetAmount!)
          : 0.0;
      if (finishedAmount < firstLevelAmount) {
        progressLength.value = (firstLevelDx - initDx) / 2.0 * scale;
      } else if (finishedAmount >= firstLevelAmount &&
          finishedAmount < secondAmount) {
        progressLength.value = (firstLevelDx - initDx) +
            (secondLevelDx - firstLevelDx) / 2.0 * scale;
      } else {
        progressLength.value = 100;
      }
    }

    if (mTaskInfo.taskLevelRewards!.length == 3) {
      //三级
      double firstLevelDx = getPositionX(levelKeyList[0]);
      double secondLevelDx = getPositionX(levelKeyList[1]);
      double thirdLevelDx = getPositionX(levelKeyList[2]);
      double firstLevelAmount =
          mTaskInfo.taskLevelRewards![0].targetAmount != null
              ? double.parse(mTaskInfo.taskLevelRewards![0].targetAmount!)
              : 0.0;
      double secondAmount = mTaskInfo.taskLevelRewards![1].targetAmount != null
          ? double.parse(mTaskInfo.taskLevelRewards![1].targetAmount!)
          : 0.0;
      double thirdAmount = mTaskInfo.taskLevelRewards![2].targetAmount != null
          ? double.parse(mTaskInfo.taskLevelRewards![2].targetAmount!)
          : 0.0;
      if (finishedAmount < firstLevelAmount) {
        debugPrint("totalWidth :: $finishedAmount  : $firstLevelAmount");
        progressLength.value = (firstLevelDx - initDx) / 2.0;
        debugPrint(
            "3 ==totalWidth :: $progressLength --- $firstLevelDx : $secondLevelDx : $thirdLevelDx");
      } else if (finishedAmount >= firstLevelAmount &&
          finishedAmount < secondAmount) {
        debugPrint("totalWidth :: $finishedAmount  : $firstLevelAmount");

        progressLength.value = (firstLevelDx - initDx) +
            (secondLevelDx - firstLevelDx) / 2.0 * scale;
      } else if (finishedAmount >= secondAmount &&
          finishedAmount < thirdAmount) {
        debugPrint("3 ==totalWidth :: $finishedAmount  : $firstLevelAmount");

        progressLength.value = (secondLevelDx - initDx) +
            (thirdLevelDx - secondLevelDx) / 2.0 * scale;
      } else {
        debugPrint("3 ==totalWidth ==:: $finishedAmount  : $firstLevelAmount");

        progressLength.value = 100;
      }
    }
  }
*/
  double getProgressLength(TaskInfoListEntity? mTaskInfo) {
    if (mTaskInfo == null || mTaskInfo.taskLevelRewards == null) {
      progressLength.value = 0.0;
      return 0.0;
    }
    double finishedAmount = mTaskInfo.finishedAmount != null
        ? double.parse(mTaskInfo.finishedAmount!)
        : 0.0;
    double totalWidth = 100.0;
    if (finishedAmount == 0 || mTaskInfo.status == 6) {
      return 0.0;
    }
    if (mTaskInfo.taskLevelRewards!.length == 1) {
      //只有一级
      TaskLevelRewardsEntity currentLevelRewardsEntity =
          mTaskInfo.taskLevelRewards![0];
      double totalAmount = currentLevelRewardsEntity.targetAmount != null
          ? double.parse(currentLevelRewardsEntity.targetAmount!.toString())
          : 0.0;
      if (finishedAmount < totalAmount) {
        return 45;
      } else {
        return totalWidth;
      }
    }
    if (mTaskInfo.taskLevelRewards!.length == 2) {
      //只有两级
      double firstLevelAmount =
          mTaskInfo.taskLevelRewards![0].targetAmount != null
              ? double.parse(
                  mTaskInfo.taskLevelRewards![0].targetAmount!.toString())
              : 0.0;
      double secondAmount = mTaskInfo.taskLevelRewards![1].targetAmount != null
          ? double.parse(
              mTaskInfo.taskLevelRewards![1].targetAmount!.toString())
          : 0.0;
      if (finishedAmount < firstLevelAmount) {
        return 15;
      } else if (finishedAmount >= firstLevelAmount &&
          finishedAmount < secondAmount) {
        return 40;
      } else {
        return 100;
      }
    }
    if (mTaskInfo.taskLevelRewards!.length == 3) {
      //三级

      double firstLevelAmount =
          mTaskInfo.taskLevelRewards![0].targetAmount != null
              ? double.parse(
                  mTaskInfo.taskLevelRewards![0].targetAmount!.toString())
              : 0.0;
      double secondAmount = mTaskInfo.taskLevelRewards![1].targetAmount != null
          ? double.parse(
              mTaskInfo.taskLevelRewards![1].targetAmount!.toString())
          : 0.0;
      double thirdAmount = mTaskInfo.taskLevelRewards![2].targetAmount != null
          ? double.parse(
              mTaskInfo.taskLevelRewards![2].targetAmount!.toString())
          : 0.0;
      if (finishedAmount < firstLevelAmount) {
        return 7;
      } else if (finishedAmount >= firstLevelAmount &&
          finishedAmount < secondAmount) {
        return 28;
      } else if (finishedAmount >= secondAmount &&
          finishedAmount < thirdAmount) {
        return 55;
      } else {
        return 100;
      }
    }
    return 0.0;
  }

  double getPositionX(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset progressPosition = renderBox.localToGlobal(Offset.zero);
    return progressPosition.dx;
  }

  double getTotalWidth(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return size.width;
  }

  String levelRewardDesc(
    TaskInfoListEntity mTaskInfo,
    TaskLevelRewardsEntity levelRewardsEntity,
  ) {
    String temp = "${levelRewardsEntity.rewardAmount} ${mTaskInfo.rewardCoin} ";
    if (mTaskInfo.rewardType == 0) {
      temp = temp + "task_center_task_rewards_type_0".tr;
    }
    if (mTaskInfo.rewardType == 1) {
      temp = temp + "task_center_task_rewards_type_1".tr;
    }
    return temp;
  }
}
