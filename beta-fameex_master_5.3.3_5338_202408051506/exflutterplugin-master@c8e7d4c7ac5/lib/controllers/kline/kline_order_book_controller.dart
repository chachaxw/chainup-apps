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
import '../../event/depth_step_event.dart';
import '../../event/event.dart';
import '../../event/ws_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/contract_market_entity.dart';
import '../../models/deal_record_entity.dart';
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

class KLineOrderBookController extends BaseController<ExchangeApi> {
  KLineOrderBookController();

  var bidDatas = <DepthEntity>[].obs;
  var askDatas = <DepthEntity>[].obs;

  var buysDepthdatas = <DepthTick>[].obs;
  var buysDepthTotalVol = 0.0;
  var sellsDepthdatas = <DepthTick>[].obs;
  var sellsDepthTotalVol = 0.0;

  //币种精度
  var mSymbolPricePrecision=0;
  //数量精度
  var mSymbolAmountPrecision=0;
  //面值币种
  var mMultiplierCoin="";
  //面值精度
  var mMultiplierPrecision=0;
  //面值
  var mMultiplier="0";
  //显示数量单位
  var mQuantityUnit="--".obs;
  //显示价格单位
  var mPriceUnit="--".obs;
  //是否为张
  var isCont=false;
  //是否是合约
  var isContractKline = false.obs;

  var symbol = "e_btcusdt";

  @override
  bool useEventBus() => true;


  @override
  void onInit() {
    super.onInit();
    setEventListen();
    for(int i = 0; i < 20; i++) {
      sellsDepthdatas.add(DepthTick(-1, 0));
    }
    for(int i = 0; i < 20; i++) {
      buysDepthdatas.add(DepthTick(-1, 0));
    }
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
    Routes.pushNvEvent(ev: NvEvent.kline_order_book);
  }

  String VolDisplayConversion(dynamic vol)  {
  // return isCont?vol.toString():NumUtils.mulStr(vol.toString(), mMultiplier, mMultiplierPrecision);
  return vol.toString();
  }

  /**
   * 获取深度显示宽度
   * 当前 数量
   * 类型 0 买 1卖
   */
  double getDepthWidthTx(
      List<DepthTick> data, int index, BuildContext context) {
    var width = 0.0;

    if(data[index].vol==-1){
      return width;
    }

    var curVol = 0.0;
    for (int a = 0; a <= index; a++) {
      curVol += data[a].vol;
    }
    if(curVol==0){
      return MediaQuery.of(context).size.width * 0.5 ;
    }
    width = (curVol / (index == 0 ? buysDepthTotalVol : sellsDepthTotalVol)) *
        MediaQuery.of(context).size.width *
        0.5;
    return width;
  }

  void setEventListen() {
    addStremSub(Event.eventBus.on<WsMsgEvent>().listen((event) {
      if(event.state==WsMsgState.coinInfo){
        mSymbolPricePrecision= event.msg['mSymbolPricePrecision']??0;
        mSymbolAmountPrecision= event.msg['mSymbolAmountPrecision']??0;
        mQuantityUnit.value= event.msg['mAmountUnit']??"";
        mPriceUnit.value= event.msg['mPriceUnit']??"";
        if (event.msg.containsKey("isContractKline")) {
          isContractKline.value = event.msg['isContractKline'];
        }
        print("mSymbolPricePrecision-----$mSymbolPricePrecision");
      }
      if(event.state==WsMsgState.orderBook){
        Map<String, dynamic> result = convert.jsonDecode(event.msg['mOrderBookData']);
        MarketDepthEntity mMarketDepthEntity = MarketDepthEntity.fromJson(result);
        if (mMarketDepthEntity == null) {
          return;
        }
        var mMarketDepthTick = mMarketDepthEntity.tick;
        var asksArr = mMarketDepthTick?.asks;
        var buysArr = mMarketDepthTick?.buys;

        var buffDepthdatas = <DepthTick>[];
        buffDepthdatas.clear();
        buysDepthTotalVol = 0.0;
        for (var buff in buysArr!) {
          buffDepthdatas.add(DepthTick(buff[0], buff[1]));
          buysDepthTotalVol += buff[1];
        }
        buffDepthdatas.sort((left, right) => left.price.compareTo(right.price));
        var _buffbuy= buffDepthdatas.reversed.toList();
        // var _buffbuy= buffDepthdatas.sublist(
        //     0, buffDepthdatas.length > 20 ? 20 : buffDepthdatas.length - 1);
        for(int i = _buffbuy.length; i < 20; i++) {
          _buffbuy.add(DepthTick(-1, -1));
        }
        buysDepthdatas.value = _buffbuy;

        buffDepthdatas.clear();
        sellsDepthTotalVol = 0.0;
        for (var buff in asksArr!) {
          buffDepthdatas.add(DepthTick(buff[0], buff[1]));
          sellsDepthTotalVol += buff[1];
        }
        buffDepthdatas.sort((left, right) => left.price.compareTo(right.price));
        // var _buffsell= buffDepthdatas.reversed.toList();
        var _buffsell= buffDepthdatas;
        for(int i = _buffsell.length; i < 20; i++) {
          _buffsell.add(DepthTick(-1, -1));
        }
        sellsDepthdatas.value = _buffsell;
      }
    }));
    addStremSub(Event.eventBus.on<DepthStepEvent>().listen((event) {
      MarketDepthEntity mMarketDepthEntity = event.quoteWs;
      if (mMarketDepthEntity == null) {
        return;
      }
      var channelBuff = "market_${symbol}_depth_step0";
      if (channelBuff != mMarketDepthEntity.channel) {
        return;
      }
      var mMarketDepthTick = mMarketDepthEntity.tick;
      var asksArr = mMarketDepthTick?.asks;
      var buysArr = mMarketDepthTick?.buys;

      var buffDepthdatas = <DepthTick>[];
      buffDepthdatas.clear();
      buysDepthTotalVol = 0.0;
      for (var buff in buysArr!) {
        buffDepthdatas.add(DepthTick(buff[0], buff[1]));
        buysDepthTotalVol += buff[1];
      }
      buffDepthdatas.sort((left, right) => left.price.compareTo(right.price));
      var _buffbuy= buffDepthdatas.reversed.toList();
      // var _buffbuy= buffDepthdatas.sublist(
      //     0, buffDepthdatas.length > 20 ? 20 : buffDepthdatas.length - 1);
      for(int i = _buffbuy.length; i < 20; i++) {
        _buffbuy.add(DepthTick(0, 0));
      }
      buysDepthdatas.value = _buffbuy;

      buffDepthdatas.clear();
      sellsDepthTotalVol = 0.0;
      for (var buff in asksArr!) {
        buffDepthdatas.add(DepthTick(buff[0], buff[1]));
        sellsDepthTotalVol += buff[1];
      }
      buffDepthdatas.sort((left, right) => left.price.compareTo(right.price));
      // var _buffsell= buffDepthdatas.reversed.toList();
      var _buffsell= buffDepthdatas;
      for(int i = _buffsell.length; i < 20; i++) {
        _buffsell.add(DepthTick(0, 0));
      }
      sellsDepthdatas.value = _buffsell;
    }));
  }
}
