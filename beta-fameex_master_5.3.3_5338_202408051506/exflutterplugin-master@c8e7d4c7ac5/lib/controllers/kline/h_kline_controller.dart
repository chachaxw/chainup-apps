import 'dart:math';

import 'package:chainup_flutter_ex/controllers/kline/contract_kline_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:library_kline/k_chart_widget.dart';
import 'package:library_kline/utils/storage_utils.dart';

class HKlineController extends KlineController {
  final main = ["MA", "EMA", "BOLL"];
  final sub = ["VOL", "MACD", "KDJ", "RSI", "WR"];
  final double titleBarHeight = 44.0;
  final double klineTimeBarHeight = 22.25;
  final double klineBottomPadding = 20.0;
  var isVolUIVisible = false.obs;
  var secondaryUIList = <String>[].obs;
  var mainUIList = <String>[].obs;
  @override
  void onInit() {
    super.onInit();
    setLandscape();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    initData();
  }

  @override
  void onResumed() {
    super.onResumed();
  }

  @override
  void onClose() {
    super.onClose();
    if (isLandscape) setPortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  void clickSecondaryIndex(String index) {
    mKChartKey.currentState?.clickSecondaryIndex(index);
    secondaryUIList.value.clear();
    secondaryUIList.value.addAll(mKChartKey.currentState!.secondaryUIList);
    secondaryUIList.refresh();
  }

  void clickMainIndex(String index) {
    mKChartKey.currentState?.clickMainIndex(index);
    mainUIList.value.clear();
    mainUIList.value.addAll(mKChartKey.currentState!.mainUIList);
    mainUIList.refresh();
  }

  void initData() {
    itemChartHeight = 64.0;
    getSelectedIndexInfo();
  }

  @override
  void changeKlineHeight(Map<String, dynamic> messageMap) {
    VolState volState = messageMap["volState"] as VolState;
    int secondaryCount = messageMap["secondaryUIListCount"] as int;
    isVolUIVisible.value = volState==VolState.NONE ? false : true;
    updateHeight(secondaryCount);
    super.changeKlineHeight(messageMap);
  }

  void updateHeight(int secondaryCount) {
    final height = Get.height;
    final width = Get.width;
    final hScreenHeight = min(height, width);
    final visualRect = hScreenHeight - titleBarHeight - klineTimeBarHeight - klineBottomPadding;
    if((!isVolUIVisible.value) && secondaryCount<=0){
      mainChartHeight = visualRect;
    }else{
      mainChartHeight = visualRect - itemChartHeight;
    }
  }

  void getSelectedIndexInfo() {
    var mainUIStr = ExStorageUtils.getString(
        ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST);
    var secUIStr = ExStorageUtils.getString(
        ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST);
    bool volStatus = ExStorageUtils.getBoolean(
        key: ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS);
    List<String> mainUIList = mainUIStr.split(",");
    mainUIList = mainUIList.where((element) => element != "").toList();
    List<String> secUIList = secUIStr.split(",");
    secUIList = secUIList.where((element) => element != "").toList();
    isVolUIVisible.value = volStatus;
    this.mainUIList.clear();
    secondaryUIList.clear();
    this.mainUIList.addAll(mainUIList);
    secondaryUIList.addAll(secUIList);
  }
}
