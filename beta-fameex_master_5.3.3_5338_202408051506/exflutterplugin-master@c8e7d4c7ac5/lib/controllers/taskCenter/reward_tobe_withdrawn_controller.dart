import 'package:chainup_flutter_ex/controllers/taskCenter/reward_center_index_controller.dart';
import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/market_coin_entity.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/task_info_list_entity.dart';
import '../../models/withdraw_list_item_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import 'package:library_kline/utils/storage_utils.dart';

class RewardTobeWithdrawnController extends BaseController<ExchangeApi> {
  RewardTobeWithdrawnController();
  var isLoad = true.obs;
  var rewardReceiveType = 0.obs;
  var rewardReceiveTerm = 0.obs;
  var withdrawList = <WithdrawInfoListItemEntity>[].obs;
  int page = 1;
  int pageSize = 10;
  RxBool isEmpty = false.obs;
  Map? coinData;

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
  void loadNet() {}

  void getWithdrawInfoList({bool loadMore = false}) async {
    /*
    var requestBody = RequestParams();
    requestBody.put("page", page);
    requestBody.put("pageSize", pageSize);

    httpRequest<BaseResultVx<WithdrawInfoListEntity>>(
        api.getUserWithdrawList(requestBody.getRequestBody()), (value) {
      WithdrawInfoListEntity withdrawInfoListEntity = value.data!;
      if (withdrawInfoListEntity.list != null) {
        withdrawInfoListEntity.list!.map((e) => withdrawList.value.add(e));
      }
      if (!loadMore) {
        page = 1;
      } else {
        page++;
      }
      
    });
    */
    TaskCenterIndexController centerIndexController = Get.find();
    coinData = await centerIndexController.getCoinData();

    isLoad.value = false;
    RewardCenterIndexController controller = Get.find();
    List<WithdrawInfoListItemEntity>? tempList =
        controller.mRewardCenterData.value.withdrawInfoList ?? [];

    if (tempList.isNotEmpty) {
      for (var i = 0; i < tempList.length; i++) {
        WithdrawInfoListItemEntity entity = tempList[i];
        String simpleName = entity.coin ?? "";
        entity.showName =
            TaskCenterCommon.getCoinShowNameText(coinData, simpleName);
        if (entity.showName!.isEmpty) {
          entity.showName = simpleName;
        }
        entity.icon = TaskCenterCommon.getCoinIconText(coinData, simpleName);
      }
    }
    withdrawList.value = tempList;

    isEmpty.value = withdrawList.isEmpty;
  }

  void listenEvent() {
    addStremSub(Event.eventBus.on<TaskCenterWithdrawEvent>().listen((event) {
      getWithdrawInfoList();
    }));
  }
}
