import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/task_event.dart';
import '../../models/task_center_index_entity.dart';
import '../../models/task_center_reward_record_entity.dart';
import '../../models/task_info_list_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/http/request_params.dart';
import '../../net/http/result/base_result_vx.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../page/common/task_center_common.dart';

class RewardDetailsController extends BaseController<ExchangeApi> {
  RewardDetailsController();
  var isLoad = true.obs;
  var rewardReceiveType = 0.obs;
  var rewardReceiveTerm = 0.obs;
  var rewardRecordList = <TaskCenterRewardRecordItemEntity>[].obs;
  RefreshController refreshController = RefreshController();

  var isEmpty = false.obs;
  int page = 1;
  int pageSize = 10;

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
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  @override
  void loadNet() {
    getRewardRecordList();
  }

  void getRewardRecordList({bool loadMore = false}) {
    if (!loadMore) {
      page = 1;
      rewardRecordList.value = <TaskCenterRewardRecordItemEntity>[];
    }
    var requestBody = RequestParams();
    requestBody.put("page", page.toString());
    requestBody.put("pageSize", pageSize.toString());

    httpRequest<BaseResultVx<TaskCenterRewardRecordEntity>>(
        api.getRewardRecordList(requestBody.getRequestBody()), (value) async {
      TaskCenterRewardRecordEntity? taskCenterRewardRecordEntity = value.data;
      isLoad.value = false;

      TaskCenterIndexController centerIndexController = Get.find();
      Map? coinData = await centerIndexController.getCoinData();
      if (taskCenterRewardRecordEntity?.list != null) {
        if (taskCenterRewardRecordEntity!.list!.isEmpty) {
          if (!loadMore) {
            isEmpty.value = true;

            refreshController.refreshCompleted();
          } else {
            refreshController.loadComplete();
          }
        } else {
          isEmpty.value = false;
          for (var i = 0; i < taskCenterRewardRecordEntity.list!.length; i++) {
            TaskCenterRewardRecordItemEntity entity =
                taskCenterRewardRecordEntity.list![i];
            entity.showCoin =
                TaskCenterCommon.getCoinShowNameText(coinData, entity.coin);

            rewardRecordList.add(taskCenterRewardRecordEntity.list![i]);
          }
          refreshController.loadComplete();
          page = page + 1;
        }
      } else {
        if (!loadMore) {
          isEmpty.value = true;

          refreshController.refreshCompleted();
        } else {
          refreshController.loadNoData();
        }
      }
    });
  }

  String getTaskTitle(TaskCenterRewardRecordItemEntity recordItemEntity) {
    String title = "";
    switch (recordItemEntity.taskType) {
      case 0: //每日
        {
          switch (recordItemEntity.taskCategory) {
            case 0: //每日现货交易
              title = "text35_1".tr;
              break;
            case 1: //每日杠杆交易
              title = "text36_1".tr;
              break;
            case 2: //每日ETF交易
              title = "text37_1".tr;
              break;
            case 3: //每日合约交易
              title = "text38_1".tr;
              break;
            case 6: //每日签到
              title = "text39".tr;
              break;
            default:
          }
        }
        break;
      case 1: //新手
        {
          switch (recordItemEntity.taskCategory) {
            case 0: //首笔现货交易
              title = "text40_1".tr;
              break;
            case 1: //首笔杠杆交易
              title = "text42_1".tr;
              break;
            case 2: //首笔ETF交易
              title = "text44_1".tr;
              break;
            case 3: //首笔合约交易
              title = "text46_1".tr;
              break;
            case 4: //首笔数字货币充值
              title = "timed_task_detail_text42".tr;
              break;
            case 7: //注册
              title = "timed_task_detail_text43".tr;
              break;
            case 8: //KYC
              title = "KYC";
              break;
            default:
          }
        }
        break;
      case 2: //进阶
        {
          switch (recordItemEntity.taskCategory) {
            case 0: //现货交易
              title = "task_center_timed_task_spot".tr;
              break;
            case 1: //1 杠杆交易
              title = "task_center_timed_task_margin".tr;
              break;
            case 2: //1 杠杆交易
              title = "task_center_timed_task_etf".tr;
              break;
            case 3: //3 合约交易
              title = "task_center_timed_task_futures".tr;
              break;
            case 4: //4 数字货币充值
              title = "timed_task_detail_text40".tr;
              break;
            case 5: //法币充值
              title = "timed_task_detail_text41".tr;
              break;
            default:
          }
        }
        break;
      case 3: //限时
        {
          switch (recordItemEntity.taskCategory) {
            case 0: //现货交易
              title = "timed_task_detail_text48".tr;
              break;
            case 1: // 杠杆交易
              title = "timed_task_detail_text50".tr;
              break;
            case 2: //ETF交易
              title = "timed_task_detail_text51".tr;
              break;
            case 3: //合约交易
              title = "timed_task_detail_text49".tr;
              break;
            default:
          }
        }
        break;
      default:
    }

    return title;
  }

  void listenEvent() {
    addStremSub(Event.eventBus.on<TaskRewardTypeEvent>().listen((event) {}));
  }
}
