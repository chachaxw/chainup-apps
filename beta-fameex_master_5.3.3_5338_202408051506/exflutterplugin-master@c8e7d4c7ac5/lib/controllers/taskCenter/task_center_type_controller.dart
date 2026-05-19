import 'package:chainup_flutter_ex/controllers/taskCenter/reward_center_index_controller.dart';
import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

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

class TaskCenterTypeController extends BaseController<ExchangeApi> {
  final String? type;
  TaskCenterTypeController(this.type);
  var isLoad = true.obs;
  var rewardReceiveType = 0.obs;
  var rewardReceiveTerm = 0.obs;
  var transactionList = <TaskInfoListEntity>[].obs;
  var isEmpty = false.obs;
  var isLogin = false.obs;
  var isKyc = 0.obs;

  @override
  void onInit() {
    super.onInit();
    isLogin.value = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
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
    var requestBody = RequestParams();
    if (type != "-1") {
      requestBody.put("type", type);
    }
    httpRequest<BaseResultVx<List<TaskInfoListEntity>>>(
        isLogin.value
            ? api.getTaskInfoList(requestBody.getRequestBody())
            : api.getTaskInfoListByNoToken(requestBody.getRequestBody()),
        (value) {
      transactionList.value = value.data ?? [];
      isLoad.value = false;
      isEmpty.value = transactionList.isEmpty;
    });
  }

  void claimTaskReward(TaskInfoListEntity mTaskInfo) {
    var requestBody = RequestParams();
    requestBody.put("taskId", mTaskInfo.id.toString());
    httpRequest<BaseResultVx>(api.claimTaskReward(requestBody.getRequestBody()),
        (value) {
      Get.showReceivedSuccessBox(
        mTaskInfo.rewardCoin,
        mTaskInfo.rewardAmount,
        rewardType: mTaskInfo.rewardType == 0
            ? "task_center_task_rewards_type_0".tr
            : "task_center_task_rewards_type_1".tr,
        viewMoreText: "text9".tr,
        viewMoreCallback: () {
          Routes.pushPage(routeName: Routes.REWARD_CENTER);
        },
      );
      getTaskInfoList();
    });
  }

  void getTaskCenterIndex() {
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<TaskCenterIndexEntity>>(
        isLogin.value
            ? api.getTaskCenterIndex(requestBody)
            : api.getTaskCenterIndexByNoToken(requestBody), (value) {
      rewardReceiveType.value = value.data?.rewardReceiveType ?? 0;
      rewardReceiveTerm.value = value.data?.rewardReceiveTerm ?? 0;
      isKyc.value = value.data?.signInInfo?.isKyc ?? 0;
    });
  }

  String getTaskTitleByCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    var target = "${mTaskInfo.targetValue} ${mTaskInfo.targetCoin}";
    switch (mTaskInfo.category) {
      case 0:
        mTaskTitle = mTaskInfo.type == 1
            ? "${"text40".tr} ≥$target"
            : "${"text35".tr} ≥$target";
        break;
      case 1:
        mTaskTitle = mTaskInfo.type == 1
            ? "${"text42".tr} ≥$target"
            : "${"text36".tr} ≥$target";
        break;
      case 2:
        mTaskTitle = mTaskInfo.type == 1
            ? "${"text44".tr} ≥$target"
            : "${"text37".tr} ≥$target";
        break;
      case 3:
        mTaskTitle = mTaskInfo.type == 1
            ? "${"text46".tr} ≥$target"
            : "${"text38".tr} ≥$target";
        break;
      case 4:
        mTaskTitle = "${"text48".tr} ≥$target";
        break;
      case 7: //注册
        mTaskTitle = "timed_task_detail_text46".tr;
        break;
      case 8: //KYC
        mTaskTitle = "timed_task_detail_text47".tr;
        break;
    }
    return mTaskTitle;
  }

  bool isKycOrRegisterTaskCanTap(TaskInfoListEntity mTaskInfo) {
    bool result = false;
    if (mTaskInfo.category == 7) {
      //注册
      if (!isLogin.value) {
        result = true;
      } else {
        if (mTaskInfo.status == 1 || mTaskInfo.status == 0) {
          result = true;
        }
      }
    }
    if (mTaskInfo.category == 8) {
      //kyc
      if (!isLogin.value) {
        result = true;
      } else {
        TaskCenterIndexController centerIndexController = Get.find();
        var isKyc =
            centerIndexController.mTaskIndexData.value.signInInfo?.isKyc;
        var isTwoCheck =
            centerIndexController.mTaskIndexData.value.signInInfo?.isTwoCheck;
        var isOpenMobile =
            centerIndexController.mUserInfoEntity.isOpenMobileCheck == 1;
        var isOpenGoogle =
            centerIndexController.mUserInfoEntity.googleStatus == 1;
        var isOpenEmail =
            centerIndexController.mUserInfoEntity.email?.length != 0;
        if (isKyc == 1 &&
            centerIndexController.mUserInfoEntity.authLevel != 1) {
          result = true;
        }

        var bol = (isOpenMobile && isOpenGoogle) ||
            (isOpenMobile && isOpenEmail) ||
            (isOpenEmail && isOpenGoogle);
        if (isTwoCheck == 1) {
          if (!bol) {
            result = true;
          }
        }
        if (mTaskInfo.status == 1 || mTaskInfo.status == 0) {
          result = true;
        } else {
          result = false;
        }
      }
    }

    return result;
  }

  String getTaskDescByCategory(TaskInfoListEntity mTaskInfo) {
    var mTaskTitle = "";
    var target = "${mTaskInfo.targetValue} ${mTaskInfo.targetCoin}";
    var period = mTaskInfo.period.toString();
    switch (mTaskInfo.category) {
      case 0: //币币交易
        mTaskTitle = "${"text41".trParams({"number": period})} ≥$target";
        break;
      case 1: //杠杆
        mTaskTitle = "${"text43".trParams({"number": period})} ≥$target";
        break;
      case 2: //ETF
        mTaskTitle = "${"text45".trParams({"number": period})} ≥$target";
        break;
      case 3: //合约
        mTaskTitle = "${"text47".trParams({"number": period})} ≥$target";
        break;
      case 4: //充值
        mTaskTitle = "${"text49".trParams({"number": period})} ≥$target";
        break;
      case 7: //注册
        {
          if (mTaskInfo.rewardType == 0) {
            //现金奖励
            mTaskTitle = ("timed_task_detail_text44"
                .trParams({"amount": mTaskInfo.rewardAmount!}).trParams({
              "coin": mTaskInfo.rewardCoin!
            }).trParams({"type": "task_center_task_rewards_type_0".tr})).tr;

            ;
          } else {
            //合约赠金
            mTaskTitle = ("timed_task_detail_text44"
                    .trParams({"amount": mTaskInfo.rewardAmount!}).trParams(
                        {"coin": mTaskInfo.rewardCoin!}))
                .tr
                .trParams({"type": "task_center_task_rewards_type_1".tr}).tr;
          }
        }
        break;
      case 8: //KYC
        {
          if (mTaskInfo.rewardType == 0) {
            //现金奖励
            mTaskTitle = ("timed_task_detail_text45"
                .trParams({"number": mTaskInfo.period.toString()}).trParams({
              "amount": mTaskInfo.rewardAmount!
            }).trParams({"coin": mTaskInfo.rewardCoin!}).trParams(
                    {"type": "task_center_task_rewards_type_0".tr})).tr;
          } else {
            //合约赠金
            mTaskTitle = ("timed_task_detail_text45"
                .trParams({"number": mTaskInfo.period!.toString()}).trParams({
              "amount": mTaskInfo.rewardAmount!
            }).trParams({"coin": mTaskInfo.rewardCoin!}).trParams(
                    {"type": "task_center_task_rewards_type_1".tr})).tr;
          }
        }
        break;
    }
    return mTaskTitle;
  }

  /**
   * /** 进行中、未完成 */
      RUNNING(0, "进行中"),
      /** 未领奖、已完成 */
      UN_RECEIVE_REWARD(1, "未领奖"),
      /** 已领奖 */
      RECEIVED_REWARD(2, "已领奖"),
      /** 已失败 */
      FAILED(3, "已失败"),
      /** 任务已过期 */
      EXPIRED(4, "任务已过期"),
      /** 奖励已过期 */
      REWARD_EXPIRED(5, "奖励已过期")
   */
  String getTaskActionStatus(TaskInfoListEntity mTaskInfo) {
    if (mTaskInfo.category == 7 && !isLogin.value) {
      //注册任务
      return "timed_task_detail_text43".tr;
    }
    if (mTaskInfo.category == 8) {
      //KYC 任务
      if (!isLogin.value || mTaskInfo.status == 0) {
        return "timed_task_detail_text55".tr; //认证
      }
    }
    String mTaskTitle = "";

    switch (mTaskInfo.status) {
      case 0: //去完成
        mTaskTitle = "text50".tr;
        break;
      case 1: //去领奖
        mTaskTitle = "text51".tr;
        break;
      case 2: //已领奖
        mTaskTitle = "text52".tr;
        break;
      case 3: //失败
        {
          if (mTaskInfo.category == 7) {
            mTaskTitle = "timed_task_detail_text29".tr; //已失效
          } else {
            mTaskTitle = "text53".tr;
          }
        }
        break;
      case 4: //任务已过期
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
      case 0: //进行中、未完成
      case 3: //已失败
      case 4: //任务已过期
        if (mTaskInfo.category == 7) {
          //注册
          mTaskTitle = "";
        } else {
          mTaskTitle = "${"text56".tr}：";
        }
        break;
      case 1: //未领奖、已完成
      case 5: //奖励已过期
        mTaskTitle = "${"text57".tr}：";
        break;
      case 2: //已领奖
        mTaskTitle = "${"text58".tr}：";
        break;
    }
    return mTaskTitle;
  }

  void pushTaskActionStatus(TaskInfoListEntity mTaskInfo,
      {bool? isQuickMoney}) {
    if (mTaskInfo.status == 0) {
      TaskCenterCommon.pushTaskActionStatus(mTaskInfo,
          isQuickMoney: isQuickMoney);
    }
    if (mTaskInfo.status == 1) {
      claimTaskReward(mTaskInfo);
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
