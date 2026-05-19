import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/market_coin_entity.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/user_info_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../routes/routes.dart';
import 'package:library_kline/utils/storage_utils.dart';

class TaskCenterIndexController extends BaseController<ExchangeApi> {
  TaskCenterIndexController();
  final PageController mPagerController = PageController();
  late TabController mTabController;
  var mTabData = <BottomSheetEntity>[].obs;
  var isSignIn = false.obs;

  var mTaskIndexData = TaskCenterIndexEntity().obs;
  late UserInfoEntity mUserInfoEntity;
  var rewards = <String>[
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  ].obs;

  Map? _coinData;

  @override
  void onInit() {
    super.onInit();
    mTabData.value = [
      BottomSheetEntity(showName: "text32".tr, extrasStr: "-1") //全部进行中
    ];
    mTabController = TabController(length: mTabData.length, vsync: this);
    mTabController.addListener(() {
      if (!mTabController.indexIsChanging) {
        BottomSheetEntity entity = mTabData[mTabController.index];
        Event.eventBus.fire(TaskTypeEvent(entity.extrasStr));
      }
    });
  }

  void resetTabController() {
    if (mTaskIndexData.value.taskTypeSorts != null) {
      List<BottomSheetEntity> temp = [
        BottomSheetEntity(showName: "text32".tr, extrasStr: "-1")
      ];

      int n = mTaskIndexData.value.taskTypeSorts!.length;
      if (n == 0) {
        defaultTab();
        return;
      }
      for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
          TaskCenterIndexTaskTypeSorts firstSort =
              mTaskIndexData.value.taskTypeSorts![j];
          int first = firstSort.sort ?? 0;
          TaskCenterIndexTaskTypeSorts secondSort =
              mTaskIndexData.value.taskTypeSorts![j + 1];
          int second = secondSort.sort ?? 0;
          if (first > second) {
            // 交换
            TaskCenterIndexTaskTypeSorts temp = firstSort;
            mTaskIndexData.value.taskTypeSorts![j] =
                mTaskIndexData.value.taskTypeSorts![j + 1];
            mTaskIndexData.value.taskTypeSorts![j + 1] = temp;
          }
        }
      }
      for (var i = 0; i < n; i++) {
        TaskCenterIndexTaskTypeSorts typeSorts =
            mTaskIndexData.value.taskTypeSorts![i];
        if (typeSorts.taskType == 0) {
          temp.add(
              BottomSheetEntity(showName: "text34".tr, extrasStr: "0")); //每日任务
        }
        if (typeSorts.taskType == 1) {
          temp.add(
              BottomSheetEntity(showName: "text33".tr, extrasStr: "1")); //新手任务
        }
        if (typeSorts.taskType == 3) {
          temp.add(BottomSheetEntity(
              showName: "timed_task_detail_text59".tr, extrasStr: "3")); //限时任务
        }
      }

      mTabData.value = temp;

      mTabController.dispose();

      mTabController = TabController(length: mTabData.length, vsync: this);
      mTabController.addListener(() {
        if (!mTabController.indexIsChanging) {
          BottomSheetEntity entity = mTabData[mTabController.index];
          Event.eventBus.fire(TaskTypeEvent(entity.extrasStr));
        }
      });
    } else {
      defaultTab();
    }
  }

  void defaultTab() {
    List<BottomSheetEntity> temp = [
      BottomSheetEntity(showName: "text32".tr, extrasStr: "-1"), //全部任务
      BottomSheetEntity(showName: "text34".tr, extrasStr: "0"), //每日任务
      BottomSheetEntity(showName: "text33".tr, extrasStr: "1"), //新手任务
      BottomSheetEntity(
          showName: "timed_task_detail_text59".tr, extrasStr: "3") //限时任务
    ];
    mTabData.value = temp;

    mTabController.dispose();

    mTabController = TabController(length: mTabData.length, vsync: this);
    mTabController.addListener(() {
      if (!mTabController.indexIsChanging) {
        BottomSheetEntity entity = mTabData[mTabController.index];
        Event.eventBus.fire(TaskTypeEvent(entity.extrasStr));
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
    loadNet();
    getPublicInfoMarket();
  }

  @override
  void loadNet() {
    getUserInfo();
    getTaskCenterIndex();
  }

  @override
  void onClose() {
    super.onClose();
    mTabController.removeListener(() {});
    mTabController.dispose();
    mPagerController.dispose();
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
          : api.getTaskCenterIndexByNoToken(requestBody),
      (value) {
        mTaskIndexData.value = value.data!;
        if (mTaskIndexData.value.signInInfo != null &&
            mTaskIndexData.value.signInInfo?.isSignIn != null) {
          isSignIn.value = mTaskIndexData.value.signInInfo!.isSignIn! == 1;
        }
        rewards.value = mTaskIndexData.value.signInInfo?.rewards ?? [];

        resetTabController();

        if (isTaskSignIn == true) {
          Get.showCheckInBox(mTaskIndexData.value.signInInfo, () {});
        }
      },
      errorV2: (code, msg) {},
    );
  }

  void taskSignIn() {
    // Get.showKycCheckBox(mUserInfoEntity);
    // return;
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
    if (!isLogin) {
      Routes.pushNvEvent(ev: NvEvent.login);
      return;
    }
    var isKyc = mTaskIndexData.value.signInInfo?.isKyc;
    var isTwoCheck = mTaskIndexData.value.signInInfo?.isTwoCheck;
    var isOpenMobile = mUserInfoEntity.isOpenMobileCheck == 1;
    var isOpenGoogle = mUserInfoEntity.googleStatus == 1;
    var isOpenEmail = mUserInfoEntity.email?.length != 0;
    if (isKyc == 1 && mUserInfoEntity.authLevel != 1) {
      Get.showKycCheckBox(mUserInfoEntity, () {
        Routes.pushNvEvent(ev: NvEvent.idAuth);
      });
      return;
    }
    var bol = (isOpenMobile && isOpenGoogle) ||
        (isOpenMobile && isOpenEmail) ||
        (isOpenEmail && isOpenGoogle);
    if (isTwoCheck == 1) {
      if (!bol) {
        Get.showKycCheckBox(mUserInfoEntity, () {
          Routes.pushNvEvent(ev: NvEvent.safe_set);
        });
        return;
      }
    }
    if (isSignIn.value) {
      Get.showCheckInBox(mTaskIndexData.value.signInInfo, () {});
      return;
    }
    var requestBody = RequestParams().getRequestBody();
    httpRequest<BaseResultVx>(api.taskSignIn(requestBody), showLoading: true,
        (value) {
      var seriateSignInNum =
          mTaskIndexData.value.signInInfo?.seriateSignInNum ?? 0;
      // Get.showReceivedSuccessBox(
      //     mTaskIndexData.value.signInInfo?.rewardCoin,
      //     rewards.value[seriateSignInNum]
      // );
      isSignIn.value = true;
      getTaskCenterIndex(isTaskSignIn: true);
    });
  }

  void closePage() {
    // MethodChannel("ex.chainup.app").invokeMethod("closePage");
    Routes.pushNvEvent(ev: NvEvent.closePage);
  }

  Future<Map?> getCoinData({bool needRefresh = false}) async {
    if (_coinData != null && needRefresh == false) {
      return _coinData;
    }
    await getPublicInfoMarket();
    return _coinData;
  }

  Future<void> getPublicInfoMarket() async {
    var requestBody = RequestParams();
    await httpRequest<BaseResultVx<MarketCoinInfo>>(
        api.getPublicInfoMarket(requestBody.getRequestBody()), (value) {
      MarketCoinInfo data = value.data!;
      _coinData = data.market!.coinList;
    });
  }
}
