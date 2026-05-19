import 'package:chainup_flutter_ex/base/controller/base_controller.dart';
import 'package:chainup_flutter_ex/net/http/apiservice/exchange_api.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:library_kline/utils/storage_utils.dart';

import '../../../models/bottom_sheet_entity.dart';

class MaiginTradeBreakevenAnalysisController
    extends BaseController<ExchangeApi> {
  final PageController mPagerController = PageController();
  List<BottomSheetEntity> tabData = [];
  var currentSelectTab = 0.obs;
  var marginAnalysisType =
      0.obs; //1 选中全仓（全仓逐仓都展示），2 选中逐仓（全仓逐仓都展示），3 只有全仓， 4 只有逐仓
  var selectedTabIndex = 0.obs;

  var isSingleTitle = false.obs;
  @override
  void onInit() {
    super.onInit();

    Map? arguments = Get.arguments;
    String type = ExStorageUtils.getString(ExStorageUtils.MARGIN_ANALYSIS_TYPE);
    if (type.isEmpty) {
      if (arguments != null &&
          arguments[ExStorageUtils.MARGIN_ANALYSIS_TYPE] != null) {
        String type = arguments[ExStorageUtils.MARGIN_ANALYSIS_TYPE].toString();
        marginAnalysisType.value = int.tryParse(type) ?? 0;
      } else {
        marginAnalysisType.value = 1;
      }
    } else {
      marginAnalysisType.value = int.tryParse(type) ?? 1;
    }

    if (marginAnalysisType.value == 1 || marginAnalysisType.value == 2) {
      tabData.add(BottomSheetEntity(
          showName: "breakeven_analysis_text16".tr, extrasStr: "3")); //全仓
      tabData.add(BottomSheetEntity(
          showName: "breakeven_analysis_text17".tr, extrasStr: "2")); //逐仓
    } else if (marginAnalysisType.value == 3) {
      tabData.add(BottomSheetEntity(
          showName: "breakeven_analysis_text16".tr, extrasStr: "3")); //全仓
    } else if (marginAnalysisType.value == 4) {
      tabData.add(BottomSheetEntity(
          showName: "breakeven_analysis_text17".tr, extrasStr: "2")); //逐仓
    }
    selectedTabIndex.value = marginAnalysisType.value == 2 ? 1 : 0;
  }

  @override
  void onReady() {
    super.onReady();
    if ((marginAnalysisType.value == 1 || marginAnalysisType.value == 2) &&
        selectedTabIndex.value == 1) {
      mPagerController.jumpToPage(
        selectedTabIndex.value,
      );
    }
  }

  @override
  void onClose() {
    mPagerController.dispose();
    ExStorageUtils.removeObject(ExStorageUtils.MARGIN_ANALYSIS_TYPE);
    super.onClose();
  }

  void updateCurrentTabIndex(int index) {
    loadData(index);
    mPagerController.jumpToPage(
      index,
    );
    // Event.eventBus.fire(MarginTradeTabChangeEvent());
  }

  @override
  void loadNet() {}

  void loadData(int index) {}
}
