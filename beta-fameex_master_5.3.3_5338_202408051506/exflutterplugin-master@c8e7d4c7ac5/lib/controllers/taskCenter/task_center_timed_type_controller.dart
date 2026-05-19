import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/task_info_list_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../page/common/task_center_common.dart';
import '../../routes/routes.dart';

class TaskCenterTimedTypeController extends BaseController<ExchangeApi> {
  TaskCenterTimedTypeController(this.type);
  final String? type;

  var isLoad = true.obs;
  var rewardReceiveType = 0.obs;
  var rewardReceiveTerm = 0.obs;
  var transactionList = <TaskInfoListEntity>[].obs;
  var isEmpty = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenEvent();
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
    loadNet();
  }

  @override
  void onResumed() {
    super.onResumed();
    getTaskCenterIndex();
    getTaskInfoList();
  }

  @override
  void loadNet() {
    getTaskCenterIndex();
    getTaskInfoList();
  }

  void getTaskInfoList() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    var requestBody = RequestParams();

    requestBody.put("type", type);
    try {
      httpRequest<BaseResultVx<List<TaskInfoListEntity>>>(
          isLogin
              ? api.getTaskInfoList(requestBody.getRequestBody())
              : api.getTaskInfoListByNoToken(requestBody.getRequestBody()),
          (value) {
        transactionList.value = value.data ?? [];

        isEmpty.value = transactionList.isEmpty;

        isLoad.value = false;
      });
    } catch (e) {
      debugPrint("====111 $e");
    }
  }

  void claimTaskReward(int index, TaskInfoListEntity mTaskInfo,
      {VoidCallback? callback}) {
    var requestBody = RequestParams();
    requestBody.put("taskId", mTaskInfo.id.toString());
    requestBody.put("rewardLevel", (index + 1).toString());

    httpRequest<BaseResultVx>(
      api.claimTaskReward(requestBody.getRequestBody()),
      (value) {
        callback?.call();
        getTaskInfoList();
      },
      errorV2: (code, msg) {
        getTaskInfoList();
      },
    );
  }

  void getTaskCenterIndex() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<TaskCenterIndexEntity>>(
        isLogin
            ? api.getTaskCenterIndex(requestBody)
            : api.getTaskCenterIndexByNoToken(requestBody), (value) {
      rewardReceiveType.value = value.data?.rewardReceiveType ?? 0;
      rewardReceiveTerm.value = value.data?.rewardReceiveTerm ?? 0;
    });
  }

  String getTaskDescByCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskDesc = "";
    var rewardAmount = mTaskInfo.rewardAmount.toString();
    var rewardCoin = mTaskInfo.rewardCoin.toString();
    switch (mTaskInfo.category) {
      case 0: //币币交易
        mTaskDesc = "task_center_timed_task_participate_in_spot".trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 1: //杠杆
        mTaskDesc = "task_center_timed_task_participate_in_margin".trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 2: //ETF
        mTaskDesc = "task_center_timed_task_participate_in_etf".trParams(
            {"number": rewardAmount}).trParams({"string": rewardCoin});
        break;
      case 3: //合约
        mTaskDesc = "task_center_timed_task_participate_in_futures".trParams(
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

  bool taskBtnCanCLick(int? status) {
    if (status == null || status == 6 || status == 7 || status == 8) {
      //未开始，已完成，已结束，则不可点击
      return false;
    }
    return true;
  }

  String getTaskActionStatus(int? status) {
    var mTaskTitle = "";
    switch (status) {
      case 0: //进行中，未完成，去交易
        mTaskTitle = "task_center_timed_task_trade".tr;
        break;
      case 1: //未领奖，已完成
        mTaskTitle = "task_center_timed_task_finished".tr;
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

  String getTaskTimeStr(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    switch (mTaskInfo.status) {
      case 0:
      case 3:
      case 4:
        mTaskTitle = "${"text56".tr}：";
        break;
      case 1:
      case 5:
        mTaskTitle = "${"text57".tr}：";
        break;
      case 2:
        mTaskTitle = "${"text58".tr}：";
        break;
    }
    return mTaskTitle;
  }

  void pushTaskActionStatus(int index, TaskInfoListEntity mTaskInfo,
      {bool? isQuickMoney}) {
    if (mTaskInfo.status == 0) {
      TaskCenterCommon.pushTaskActionStatus(mTaskInfo,
          isQuickMoney: isQuickMoney);
    }
    if (mTaskInfo.status == 1) {
      claimTaskReward(index, mTaskInfo);
    }
  }

  void listenEvent() {
    addStremSub(Event.eventBus.on<TaskTypeEvent>().listen((event) {
      if (event.type == type) {
        getTaskInfoList();
      }
    }));
    addStremSub(Event.eventBus.on<MessageEvent>().listen((event) {
      getTaskInfoList();
    }));
  }
}
