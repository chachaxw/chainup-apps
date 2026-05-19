import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../base/controller/base_controller.dart';
import '../../event/event.dart';
import '../../event/ws_event.dart';
import '../../models/kline_coin_introduce_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../routes/routes.dart';
import 'dart:convert' as convert;
class KLineIntroductionController extends BaseController<ExchangeApi> {
  KLineIntroductionController();

  var mCoinName = "BTC/USDT".obs;
  var mKlineCoinIntroduceEntity=KlineCoinIntroduceEntity().obs;

  @override
  bool useEventBus() => true;

  @override
  void onInit() {
    super.onInit();
    setEventListen();
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
    Routes.pushNvEvent(ev: NvEvent.kline_coin_intro);
  }

  void setEventListen() {
    addStremSub(Event.eventBus.on<WsMsgEvent>().listen((event) {
      if(event.state==WsMsgState.coinIntroData){
        try{
          Map<String, dynamic> result = convert.jsonDecode(event.msg['mCoinIntroData']);
          mKlineCoinIntroduceEntity.value = KlineCoinIntroduceEntity.fromJson(result);
        }catch(e){
          showToast(e.toString());
        }
      }
    }));
  }

  Future<void> GoWebUrl(String? url,String? title) async {
    Routes.pushNvEvent(ev: NvEvent.kline_go_webview,param: {"webUrl" :url,"webTitle":title});
  }
}
