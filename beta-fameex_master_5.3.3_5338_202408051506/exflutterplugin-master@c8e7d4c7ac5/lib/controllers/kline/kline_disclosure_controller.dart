import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:library_kline/entity/k_line_entity.dart';
import 'package:library_kline/flutter_k_chart.dart';
import 'package:library_kline/k_chart_widget.dart';
import 'package:library_kline/utils/data_util.dart';

import '../../base/controller/base_controller.dart';
import '../../constants/color_constant.dart';
import '../../event/event.dart';
import '../../event/ws_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/contract_market_entity.dart';
import '../../models/deal_record_entity.dart';
import '../../models/etf_net_value_entity.dart';
import '../../models/kline_buy_sell_entity.dart';
import '../../models/market_depth_entity.dart';
import '../../models/market_ticker_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../routes/routes.dart';
import '../../utils/log_utils.dart';
import '../../utils/num_utils.dart';
import 'dart:convert' as convert;

import 'package:library_kline/utils/storage_utils.dart';
import '../../widgets/ex_kline_loading.dart';

class KLineDisclosureController extends BaseController<ExchangeApi> {
  KLineDisclosureController();
  var mEtfDesc = "".obs;
  var mEtfName = "".obs;
  var mFundRate = "".obs;
  var mEtfNetValueEntity = EtfNetValueEntity().obs;
  @override
  bool useEventBus() => true;


  @override
  void onInit() {
    super.onInit();
    setEventListen();
  }

  void handleNext({bool? isSwitchContract}) {
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
    loadNet();
  }

  @override
  void loadNet() {
    Routes.pushNvEvent(ev: NvEvent.kline_coin_info);
    Routes.pushNvEvent(ev: NvEvent.kline_etf_coin_intro);
  }

  void setEventListen() {
    addStremSub(Event.eventBus.on<WsMsgEvent>().listen((event) {
      if(event.state==WsMsgState.coinInfo){
        mEtfDesc.value=event.msg['etf_coin_desc'];
        mEtfName.value=event.msg['etf_coin_name'];
        mFundRate.value=event.msg['FundRate'];
      }
      if(event.state==WsMsgState.ETFIntroData){
        Map<String, dynamic> result = convert.jsonDecode(event.msg['mCoinETFData']);
        mEtfNetValueEntity.value = EtfNetValueEntity.fromJson(result);
      }
    }));
  }
}
