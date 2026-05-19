import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

import '../../base/controller/base_controller.dart';
import '../../event/deal_record_event.dart';
import '../../event/event.dart';
import '../../event/ws_event.dart';
import '../../models/deal_record_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../routes/routes.dart';
import '../../utils/num_utils.dart';
import 'dart:convert' as convert;


class KLineTransactionRecordController extends BaseController<ExchangeApi> {
  KLineTransactionRecordController();

  var dealRecorddatas = <DealRecordData>[].obs;

  //币种精度
  var mSymbolPricePrecision=0.obs;
  //数量精度
  var mSymbolAmountPrecision=0.obs;
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
  var isCont=true;
  //是否是合约
  var isContractKline = false.obs;

  @override
  bool useEventBus() => true;


  @override
  void onInit() {
    super.onInit();
    setEventListen();
    for(int i = 0; i < 20; i++) {
      dealRecorddatas.add(DealRecordData());
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
    Routes.pushNvEvent(ev: NvEvent.kline_transaction_record);
  }

  String VolDisplayConversion(dynamic vol)  {
    if(vol==null){
      return "--";
    }
    return isCont?vol.toString():NumUtils.mulStr(vol.toString(), mMultiplier, mMultiplierPrecision);
  }

  void setEventListen() {
    addStremSub(Event.eventBus.on<WsMsgEvent>().listen((event) {
      if(event.state==WsMsgState.coinInfo){
        if (kDebugMode) {
          debugPrint("WsMsgState.coinInfo>>>"+event.msg.toString());
        }
        mSymbolPricePrecision.value= event.msg['mSymbolPricePrecision']??0;
        mSymbolAmountPrecision.value= event.msg['mSymbolAmountPrecision']??0;
        mQuantityUnit.value= event.msg['mAmountUnit'].toString();
        mPriceUnit.value= event.msg['mPriceUnit'].toString();
        if (event.msg.containsKey("isContractKline")) {
          isContractKline.value = event.msg['isContractKline'];
        }
        if (kDebugMode) {
          debugPrint("WsMsgState.coinInfo>>>"+mQuantityUnit.value);
        }
        mQuantityUnit.refresh();
        mPriceUnit.refresh();
      }
      if(event.state==WsMsgState.transactionRecord){
        Map<String, dynamic> result = convert.jsonDecode(event.msg['mRecordData']);
        DealRecordEntity mDealRecordEntity = DealRecordEntity.fromJson(result);
        if (mDealRecordEntity == null) {
          return;
        }
        var buffDealRecorddatas = <DealRecordData>[];
        buffDealRecorddatas.addAll(dealRecorddatas.value);
        if (mDealRecordEntity.data != null) {
          buffDealRecorddatas.insertAll(0, mDealRecordEntity.data!);
        }
        if (mDealRecordEntity.tick != null) {
          buffDealRecorddatas.insertAll(0, mDealRecordEntity.tick!.data!);
        }
        if (buffDealRecorddatas.length != 0) {
          buffDealRecorddatas.removeRange(20, buffDealRecorddatas.length);
        }
        buffDealRecorddatas.reversed;
        dealRecorddatas.value = buffDealRecorddatas;
      }

      if(event.state==WsMsgState.clearTransactionRecord){
        dealRecorddatas.value.clear();
        for(int i = 0; i < 20; i++) {
          dealRecorddatas.add(DealRecordData());
        }
      }
    }));

    addStremSub(Event.eventBus.on<DealRecordEvent>().listen((event) {
      DealRecordEntity mDealRecordEntity = event.quoteWs;
      if (mDealRecordEntity == null) {
        return;
      }
      var buffDealRecorddatas = <DealRecordData>[];
      buffDealRecorddatas.addAll(dealRecorddatas.value);
      if (mDealRecordEntity.data != null) {
        buffDealRecorddatas.insertAll(0, mDealRecordEntity.data!);
      }
      if (mDealRecordEntity.tick != null) {
        buffDealRecorddatas.insertAll(0, mDealRecordEntity.tick!.data!);
      }
      if (buffDealRecorddatas.length != 0) {
        buffDealRecorddatas.removeRange(20, buffDealRecorddatas.length);
      }
      buffDealRecorddatas.reversed;
      dealRecorddatas.value = buffDealRecorddatas;
    }));
  }
}
