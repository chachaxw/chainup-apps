import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:library_kline/utils/storage_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/task_center_reward_voucher.dart';
import '../../models/user_info_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../page/common/task_center_common.dart';

class RewardCouponController extends BaseController<ExchangeApi> {
  RewardCouponController();
  var isLoad = true.obs;
  var rewardReceiveType = 0.obs;
  var rewardReceiveTerm = 0.obs;
  var rewardVoucherList = <TaskCenterRewardVoucherItemEntity>[].obs;
  var isEmpty = false.obs;
  int page = 1;
  int pageSize = 10;
  RefreshController refreshController = RefreshController();

  late TaskCenterIndexEntity mTaskIndexData;
  late UserInfoEntity mUserInfoEntity;

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
    loadNet();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  void listenEvent() {
    addStremSub(Event.eventBus.on<TaskRewardTypeEvent>().listen((event) {}));
  }

  @override
  void loadNet() {
    getRewardVoucherList();
    getUserInfo();
    getTaskCenterIndex();
  }

  void getUserInfo() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
    if (!isLogin) return;
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<UserInfoEntity>>(api.getUserInfo(requestBody),
        (value) {
      mUserInfoEntity = value.data!;
    });
  }

  void getTaskCenterIndex({bool? isTaskSignIn}) {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<TaskCenterIndexEntity>>(
        isLogin
            ? api.getTaskCenterIndex(requestBody)
            : api.getTaskCenterIndexByNoToken(requestBody), (value) {
      mTaskIndexData = value.data!;
    });
  }

  void getRewardVoucherList({bool loadMore = false}) {
    if (!loadMore) {
      page = 1;
      rewardVoucherList.value = <TaskCenterRewardVoucherItemEntity>[];
    }
    var requestBody = RequestParams();
    requestBody.put("page", page.toString());
    requestBody.put("pageSize", pageSize.toString());
    requestBody.put("queryStatus", "0");

    httpRequest<BaseResultVx<TaskCenterRewardVoucherEntity>>(
        api.getRewardVoucherList(requestBody.getRequestBody()), (value) async {
      TaskCenterRewardVoucherEntity centerRewardVoucherEntity = value.data!;
      isLoad.value = false;

      if (centerRewardVoucherEntity.list != null) {
        if (centerRewardVoucherEntity.list!.isEmpty) {
          if (!loadMore) {
            isEmpty.value = true;

            refreshController.refreshCompleted();
          } else {
            refreshController.loadComplete();
          }
        } else {
          isEmpty.value = false;
          TaskCenterIndexController centerIndexController = Get.find();
          Map? coinData = await centerIndexController.getCoinData();

          for (var i = 0; i < centerRewardVoucherEntity.list!.length; i++) {
            TaskCenterRewardVoucherItemEntity entity =
                centerRewardVoucherEntity.list![i];
            String simpleName = entity.coin ?? "";
            entity.showName =
                TaskCenterCommon.getCoinShowNameText(coinData, simpleName);
            if (entity.showName!.isEmpty) {
              entity.showName = simpleName;
            }
            rewardVoucherList.add(entity);
          }
          refreshController.loadComplete();

          page = page + 1;
        }
      } else {
        refreshController.loadFailed();
      }
    });
  }

  bool isCanUse(TaskCenterRewardVoucherItemEntity entity) {
    if (entity.status == 0) {
      //状态 0未使用 1已失效 2已使用
      return true;
    }
    return false;
  }

  void userVoucherClick(TaskCenterRewardVoucherItemEntity entity) {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    if (!isLogin) {
      Routes.pushNvEvent(ev: NvEvent.login);
      return;
    }

    if (mTaskIndexData.rewardUseKyc != null &&
        mTaskIndexData.rewardUseKyc == 1) {
      var isKyc = mTaskIndexData.signInInfo?.isKyc;
      var isTwoCheck = mTaskIndexData.signInInfo?.isTwoCheck;
      var isOpenMobile = mUserInfoEntity.isOpenMobileCheck == 1;
      var isOpenGoogle = mUserInfoEntity.googleStatus == 1;
      var isOpenEmail = mUserInfoEntity.email?.length != 0;
      if (isKyc == 1 && mUserInfoEntity.authLevel != 1) {
        Get.showCommonDialog(
          title: "text83".tr,
          content: "task_centerk_08".tr,
          posiText: "task_centerk_09".tr,
          isNeedAutoDismiss: true,
          posiTap: () {
            Routes.pushNvEvent(ev: NvEvent.idAuth);
          },
        );
        return;
      }

      var bol = (isOpenMobile && isOpenGoogle) ||
          (isOpenMobile && isOpenEmail) ||
          (isOpenEmail && isOpenGoogle);
      if (isTwoCheck == 1) {
        if (!bol) {
          Get.showCommonDialog(
            title: "text83".tr,
            content: "task_centerk_08".tr,
            posiText: "task_centerk_09".tr,
            isNeedAutoDismiss: true,
            posiTap: () {
              Routes.pushNvEvent(ev: NvEvent.safe_set);
            },
          );

          return;
        }
      }
    }
    doWithdrawdReward(entity);
  }

  void doWithdrawdReward(TaskCenterRewardVoucherItemEntity entity) {
    var requestBody = RequestParams();
    requestBody.put("rewardId", entity.id.toString());
    httpRequest<BaseResultVx>(
      api.useRewardVoucher(requestBody.getRequestBody()),
      (value) {
        Get.showCommonDialog(
          title: "timed_task_detail_text39".tr,
          content:
              "${entity.amount!} ${entity.showName!} ${"timed_task_detail_text38".tr}",
          iconVisible: true,
          posiText: "timed_task_detail_text37".tr,
          posiTap: () {
            debugPrint("跳转查看资产");
            Routes.pushNvEvent(ev: NvEvent.balance_page);
          },
        );
        getRewardVoucherList();
      },
      errorV2: (code, msg) {
        getRewardVoucherList();
      },
    );
  }
}
