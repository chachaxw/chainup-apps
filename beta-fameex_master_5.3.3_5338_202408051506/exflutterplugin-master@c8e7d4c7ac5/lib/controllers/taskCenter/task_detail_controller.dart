import 'dart:ui';

import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_timed_type_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/task_info_list_entity.dart';
import '../../models/user_info_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../page/common/task_center_common.dart';
import '../../routes/routes.dart';
import 'package:library_kline/utils/storage_utils.dart';

class TaskDetailController extends BaseController<ExchangeApi> {
  TaskDetailController();

  final PageController mPagerController = PageController();
  late TabController mTabController;
  var mTabData = [];
  var mTaskIndexData = TaskCenterIndexEntity().obs;
  var mTaskInfo = TaskInfoListEntity().obs;
  var isHaveCanReceivedReward = false.obs;

  @override
  void onInit() {
    super.onInit();
    mTabData.add(BottomSheetEntity(
        showName: "timed_task_detail_text52".tr, extrasStr: "-1")); //任务详情
    mTabData.add(BottomSheetEntity(
        showName: "timed_task_detail_text53".tr, extrasStr: "1")); //任务进度
    mTabController = TabController(length: mTabData.length, vsync: this);
    mTaskInfo.value = Get.arguments["data"];
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
    loadNet();
    isHaveCanReceivedRewardFunc();
  }

  void isHaveCanReceivedRewardFunc() {
    for (TaskLevelRewardsEntity element in mTaskInfo.value.taskLevelRewards!) {
      if (element.status == 1) {
        isHaveCanReceivedReward.value = true;
        break;
      }
    }
  }

  @override
  void loadNet() {}

  String getDesc() {
    String temp =
        "${"timed_task_detail_text2".tr}\n${"timed_task_detail_text3".tr}";

    TaskCenterIndexController taskCenterIndexController = Get.find();
    if (taskCenterIndexController.mTaskIndexData.value.rewardReceiveType == 0) {
      //自动领取
      temp = "$temp\n${"timed_task_detail_text4".tr}";
    } else {
      //手动
      temp = "$temp\n${"timed_task_detail_text5".trParams({
            "day": taskCenterIndexController
                .mTaskIndexData.value.rewardReceiveTerm
                .toString()
          }).tr}";
    }
    if (mTaskInfo.value.category == 3) {
      double singleMinTarget =
          double.parse(mTaskInfo.value.singleMinTarget ?? "0");
      if (singleMinTarget != 0) {
        //合约交易
        temp = "$temp\n${"timed_task_detail_text6".trParams({
              "num": mTaskInfo.value.singleMinTarget.toString()
            }).tr}";
      }
    }
    return temp;
  }

  String getLevelDesc(int index) {
    String temp = "";
    switch (index) {
      case 0:
        temp = "timed_task_detail_text9".tr;
        break;
      case 1:
        temp = "timed_task_detail_text10".tr;
        break;
      case 2:
        temp = "timed_task_detail_text11".tr;
        break;
      default:
    }
    return temp;
  }

  String getLevelRewardDesc(int index) {
    if (mTaskInfo.value.taskLevelRewards == null) {
      return "";
    }

    TaskLevelRewardsEntity taskLevelRewardsEntity =
        mTaskInfo.value.taskLevelRewards![index];
    String temp =
        "${taskLevelRewardsEntity.rewardAmount} ${mTaskInfo.value.rewardCoin} "
            .tr;
    if (mTaskInfo.value.rewardType == 0) {
      temp = temp + "task_center_task_rewards_type_0".tr;
    } else {
      temp = temp + "task_center_task_rewards_type_1".tr;
    }

    return temp;
  }

  String getRewardProgressDesc(TaskLevelRewardsEntity taskLevelRewardsEntity) {
    String percentStr = "0%";
    double finishedAmount = double.parse(mTaskInfo.value.finishedAmount!);
    double targetAmount =
        double.parse(taskLevelRewardsEntity.targetAmount!.toString());
    if (finishedAmount >= targetAmount) {
      percentStr = "100%";
    } else {
      if (targetAmount != 0) {
        percentStr =
            "${(finishedAmount / targetAmount * 100).toStringAsFixed(2)}%";
      } else {
        percentStr = "0%";
      }
    }
    return percentStr;
  }

  String getLeftNum(TaskLevelRewardsEntity taskLevelRewardsEntity) {
    double finishedAmount = double.parse(mTaskInfo.value.finishedAmount!);
    double targetAmount =
        double.parse(taskLevelRewardsEntity.targetAmount!.toString());
    if (finishedAmount >= targetAmount) {
      return taskLevelRewardsEntity.targetAmount!.toString();
    } else {
      double amount = double.parse(
          TaskCenterCommon.truncateToSpecifiedDecimalPlaces(finishedAmount, 2));
      String result = mTaskInfo.value.finishedAmount ?? "0";
      if (amount % 1 == 0) {
        int a = amount.round();
        result = a.toString();
      } else {
        result = amount.toString();
      }

      return result;
    }
  }

  bool isLevelItemBtnCanClick(TaskLevelRewardsEntity taskLevelRewardsEntity) {
    bool result = false;
    if (taskLevelRewardsEntity.status == 0 ||
        taskLevelRewardsEntity.status == 1) {
      result = true;
    }

    return result;
  }

  bool isShowRewardCountDown(TaskLevelRewardsEntity taskLevelRewardsEntity) {
    TaskCenterIndexController taskCenterIndexController = Get.find();
    if (taskCenterIndexController.mTaskIndexData.value.rewardReceiveType == 1 &&
        taskLevelRewardsEntity.status == 1) {
      //手动领取且已完成未领奖
      return true;
    }
    return false;
  }

  void btnClick(TaskLevelRewardsEntity taskLevelRewardsEntity, int index) {
    if (taskLevelRewardsEntity.status == 0) {
      final taskController = Get.find<TaskCenterTimedTypeController>();
      taskController.pushTaskActionStatus(index, mTaskInfo.value);
    }
    if (taskLevelRewardsEntity.status == 1) {
      //领奖
      final taskController = Get.find<TaskCenterTimedTypeController>();
      taskController.claimTaskReward(
        index,
        mTaskInfo.value,
        callback: () {
          mTaskInfo.value.taskLevelRewards![index].status = 2;
          isHaveCanReceivedRewardFunc();
          //已完成，未领奖
          Get.showReceivedSuccessBox(
            mTaskInfo.value.rewardCoin,
            taskLevelRewardsEntity.rewardAmount.toString(),
            rewardType: mTaskInfo.value.rewardType == 0
                ? "task_center_task_rewards_type_0".tr
                : "task_center_task_rewards_type_1".tr,
            viewMoreText: "text9".tr,
            viewMoreCallback: () {
              Routes.popPage();
              Routes.pushPage(
                routeName: Routes.REWARD_CENTER,
                isFinish: true,
              );
            },
            okCallback: () {
              Routes.popPage();
            },
          );
        },
      );
    }
  }

  double calculateProgress(
      BuildContext context, TaskLevelRewardsEntity taskLevelRewardsEntity) {
    try {
      double leftAmount = double.parse(getLeftNum(taskLevelRewardsEntity));
      double targetAmount =
          double.parse(taskLevelRewardsEntity.targetAmount!.toString());
      return leftAmount / targetAmount * 100;
    } catch (e) {
      return 0;
    }
  }
}
