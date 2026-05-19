import 'dart:convert';

import 'package:chainup_flutter_ex/event/event.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/models/indicators_entity.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../base/controller/base_controller.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../page/klineSetting/kline_indicator_manager.dart';

enum NumericOperations { adding, subtracting }

class KlineIndicatorsModifyController extends BaseController<ExchangeApi> {
  KlineIndicatorsModifyController();
  List<TextEditingController> mTextEditingControllers = [];
  List<FocusNode> mFocusNodes = [];
  var listData = <IndicatorsEntity>[].obs;
  var indicatorType = KlineIndicatorType.ma;
  @override
  bool useEventBus() => true;

  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic> params = Get.arguments;
    indicatorType = params['type'] as KlineIndicatorType;
    LogUtil.e("type:$indicatorType");
    setIndicatorData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
  }

  @override
  void loadNet() {}

  void setIndicatorData() {
    mFocusNodes.clear();
    mTextEditingControllers.clear();
    listData.clear();
    final list = indicatorType.getIndicatorData();
    listData.addAll(list);
    for (int i = 0; i < listData.length; i++) {
      mTextEditingControllers.add(TextEditingController());
      mTextEditingControllers[i].text = listData[i].num.toString();
    }
    for (int i = 0; i < listData.length; i++) {
      mFocusNodes.add(FocusNode());
    }
  }

  //重置
  void reset() {
    indicatorType.setDefaultData();
    setIndicatorData();
    listData.refresh();
  }

  //保存
  void saveIndicators() {
    var indicatorsMap = listData.map((s) => s.toJson()).toList();

    // print("indicatorsMap = ${indicatorsMap}");
    final storeKey = indicatorType.getStoreKey();
    // print("storeKey = ${storeKey}");

    ExStorageUtils.putObject(storeKey, jsonEncode(indicatorsMap));
    Event.eventBus.fire(MessageEvent(MessageEvent.klineIndicatorUpdated));
    Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex,param: {storeKey:jsonEncode(indicatorsMap)});
  }

  // text action sub add
  void numbersOperations(NumericOperations operation, int index) {
    var entity = listData[index];
    var editController = mTextEditingControllers[index];
    var text = editController.text;
    if (text.isEmpty) {
      editController.text = (entity.type?.minNumber ?? "1").toString();
      entity.num = int.parse(editController.text);
      return;
    }
    var count = int.parse(text);
    if (operation == NumericOperations.adding) {
      count++;
    } else if (operation == NumericOperations.subtracting) {
      count--;
    }
    digitalLegalVerification(index, countTx: count);
  }

  //数据校验
  void digitalLegalVerification(int index, {int? countTx}) {
    var entity = listData[index];
    var type = entity.type ?? KlineIndicatorType.ma;
    var editController = mTextEditingControllers[index];
    var text = editController.text;
    text = text.trim();
    if(text=="") text="0";
    var count = int.parse(text);
    if (countTx != null) {
      count = countTx;
    }
    if (count > type.maxNumber) {
      count = type.maxNumber;
    } else if (count < type.minNumber) {
      count = type.minNumber;
    }
    editController.text = count.toString();
    entity.num = int.parse(editController.text);
    final value = count.toString(); //光标移动到最后
    editController.value =TextEditingValue(
        text: value,
        selection: TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream,
                offset: value.length)
        )
    );


  }
}
