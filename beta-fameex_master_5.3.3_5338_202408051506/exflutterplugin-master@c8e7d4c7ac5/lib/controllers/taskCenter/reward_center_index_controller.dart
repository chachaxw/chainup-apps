import 'dart:ui';

import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/reward_center_index_entity.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/user_info_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../routes/routes.dart';
import 'package:library_kline/utils/storage_utils.dart';

class RewardCenterIndexController extends BaseController<ExchangeApi> {
  RewardCenterIndexController();
  final PageController mPagerController = PageController();
  late TabController mTabController;
  var isCanWithdraw = false.obs;
  var remainWithdraw = "0".obs;
  var mTabData = [];
  var mRewardCenterData = RewardCenterIndexEntity().obs;

  late TaskCenterIndexEntity mTaskIndexData;
  late UserInfoEntity mUserInfoEntity;

  @override
  void onInit() {
    super.onInit();
    mTabData.add(BottomSheetEntity(
        showName: "timed_task_detail_text56".tr, extrasStr: "-1")); //待提现
    mTabData.add(BottomSheetEntity(
        showName: "timed_task_detail_text57".tr, extrasStr: "1")); //优惠券
    mTabData.add(BottomSheetEntity(
        showName: "timed_task_detail_text58".tr, extrasStr: "0")); //奖励明细
    mTabController = TabController(length: mTabData.length, vsync: this)
      ..addListener(() {
        if (!mTabController.indexIsChanging) {
          Event.eventBus.fire(TaskRewardTypeEvent());
        }
      });
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
    mPagerController.dispose();
    mTabController.dispose();
    super.onClose();
  }

  @override
  void loadNet() {
    getRewardCenterIndex();
    getUserInfo();
    getTaskCenterIndex();
  }

  void getRewardCenterIndex() {
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<RewardCenterIndexEntity>>(
        api.getRewardCenterIndex(requestBody), (value) {
      mRewardCenterData.value = value.data!;

      Event.eventBus.fire(TaskCenterWithdrawEvent());
      getRemainAmount();
    });
  }

  void getUserInfo() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    if (!isLogin) return;
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<UserInfoEntity>>(api.getUserInfo(requestBody),
        (value) {
      mUserInfoEntity = value.data!;
    });
  }

  void getTaskCenterIndex({bool? isTaskSignIn}) {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx<TaskCenterIndexEntity>>(
        isLogin
            ? api.getTaskCenterIndex(requestBody)
            : api.getTaskCenterIndexByNoToken(requestBody), (value) {
      mTaskIndexData = value.data!;
    });
  }

  void getRemainAmount() {
    double minWithdrawAmount =
        double.parse(mRewardCenterData.value.minWithdrawAmount!);
    double unWithdrawAmount =
        double.parse(mRewardCenterData.value.unWithdrawAmount!);
    if (unWithdrawAmount >= minWithdrawAmount) {
      isCanWithdraw.value = true;
    } else {
      remainWithdraw.value = (minWithdrawAmount - unWithdrawAmount).toString();
      isCanWithdraw.value = false;
    }
  }

  void doWithdrawdReward() {
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx>(api.doWithdrawdReward(requestBody), (value) {
      showToast("timed_task_detail_text33".tr);
    });
  }

  void withdrawClick() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
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

    Get.showCommonDialog(
      title: "timed_task_detail_text35".tr,
      content: "timed_task_detail_text36".tr,
      iconVisible: true,
      posiTap: () {
        doWithdrawdReward();
      },
    );
  }
}
