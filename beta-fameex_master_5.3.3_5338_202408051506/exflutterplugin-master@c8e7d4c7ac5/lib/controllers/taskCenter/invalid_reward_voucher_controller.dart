import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../base/controller/base_controller.dart';
import '../../models/task_center_reward_voucher.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../page/common/task_center_common.dart';

class InvalidRewardVoucherController extends BaseController<ExchangeApi> {
  InvalidRewardVoucherController();
  var isLoad = true.obs;
  var rewardVoucherList = <TaskCenterRewardVoucherItemEntity>[].obs;
  var isEmpty = false.obs;
  int page = 1;
  int pageSize = 10;
  RefreshController refreshController = RefreshController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
    loadNet();
  }

  @override
  void onClose() {
    super.onClose();
    refreshController.dispose();
  }

  @override
  void loadNet() {
    getInvalidRewardVoucherList();
  }

  void getInvalidRewardVoucherList({bool loadMore = false}) {
    if (!loadMore) {
      page = 1;
      rewardVoucherList.value = <TaskCenterRewardVoucherItemEntity>[];
    }
    var requestBody = RequestParams();
    requestBody.put("page", page.toString());
    requestBody.put("pageSize", pageSize.toString());
    requestBody.put("queryStatus", "1");

    httpRequest<BaseResultVx<TaskCenterRewardVoucherEntity>>(
        api.getRewardVoucherList(requestBody.getRequestBody()), (value) async {
      TaskCenterRewardVoucherEntity centerRewardVoucherEntity = value.data!;
      isLoad.value = false;

      if (centerRewardVoucherEntity.list != null) {
        if (centerRewardVoucherEntity.list!.isEmpty) {
          if (!loadMore) {
            refreshController.refreshCompleted();
            isEmpty.value = true;
          } else {
            refreshController.loadNoData();
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

  String useText(TaskCenterRewardVoucherItemEntity entity) {
    if (entity.status == 1) {
      //状态 0未使用 1已失效 2已使用
      return "timed_task_detail_text29".tr;
    }
    if (entity.status == 2) {
      //状态 0未使用 1已失效 2已使用
      return "timed_task_detail_text28".tr;
    }
    return "timed_task_detail_text29".tr;
  }
}
