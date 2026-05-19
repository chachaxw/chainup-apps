import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:web_socket_channel/io.dart';
import 'package:archive/archive.dart';
import 'dart:convert' as convert;

import '../../event/deal_record_event.dart';
import '../../event/depth_step_event.dart';
import '../../event/event.dart';
import '../../event/net_event.dart';
import '../../event/ws_event.dart';
import '../../models/deal_record_entity.dart';
import '../../models/market_depth_entity.dart';
import '../../models/market_ticker_entity.dart';
import '../../models/ws_send_msg_entity.dart';
import '../../utils/log_utils.dart';
import 'package:library_kline/utils/storage_utils.dart';

enum MsgType {
  sub,
  unsub,
  req,
}

class SocketUtils {
  SocketUtils._internal() {}
  static SocketUtils _socketUtils = SocketUtils._internal();
  IOWebSocketChannel? _channel;
  final List<Map<String,String>> _subscribedStocks = [];
  String lastSubChannel = "";
  String wsUrl = "";
  Timer? _timer;

  factory SocketUtils() {
    return _socketUtils;
  }

  void initSocket(String wsUrl) {
    // this.wsUrl=wsUrl;
    this.wsUrl="wss://futuresws.coinr.vip/kline-api/ws";
    // this.wsUrl="wss://ws0001317.chainsprince.me/kline-api/ws";
    connectWs();
    startCountdownTimer();
  }

  //开启心跳
  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 5);
    var callback = (timer) {
      if (_channel == null) {
        connectWs();
      } else {
        sendPong();
      }
    };
    _timer = Timer.periodic(oneSec, callback);
  }

  void connectWs() {
    if (_channel == null) {
      HttpClient? client =null;
      // if (ExStorageUtils.getBoolean(key: ExStorageUtils.PROXY_ENABLE)) {
      //   SecurityContext ctx = SecurityContext.defaultContext;
      //   client = HttpClient(context: ctx)
      //     ..findProxy = ((uri) {
      //       return "PROXY ${ExStorageUtils.getString(ExStorageUtils.DEBUG_IP)}:${ExStorageUtils.getString(ExStorageUtils.DEBUG_PORT)}";
      //     })
      //     ..badCertificateCallback =
      //         (X509Certificate cert, String host, int port) => true;
      // }
      WebSocket.connect(wsUrl,customClient: client).then((ws) {
        _channel = IOWebSocketChannel(ws);
        LogUtil.e("合约ws 连接成功");
        Event.eventBus.fire(WsNetEvent(WsNetEventState.connect));
        _channel?.stream.listen(this.onData, onError: onError, onDone: onDone);
        _subscribedStocks.forEach((element) {
          LogUtil.e("合约ws ${element['subMsg']}");
          _channel?.sink.add(element['subMsg']);
        });
      });
    }
  }


  // 请求K线历史
  void subKlineHistory(String symbol,String time) {
    var submsg =
        "{\"event\":\"req\",\"params\":{\"channel\":\"market_${symbol}_kline_${time}\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 订阅K线最新数据
  void subKlineLast(String symbol,String time) {
    var submsg =
        "{\"event\":\"sub\",\"params\":{\"channel\":\"market_${symbol}_kline_${time}\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 取消订阅K线最新数据
  void unSubKlineLast(String symbol,String time) {
    var submsg =
        "{\"event\":\"unsub\",\"params\":{\"channel\":\"market_${symbol}_kline_${time}\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 订阅24H行情
  void sub24HTicker(String symbol) {
    var submsg =
        "{\"event\":\"sub\",\"params\":{\"channel\":\"market_${symbol}_ticker\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 取消订阅24H行情
  void unSub24HTicker(String symbol) {
    var submsg =
        "{\"event\":\"unsub\",\"params\":{\"channel\":\"market_${symbol}_ticker\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 订阅深度
  void subTradeDepth(String symbol,int step) {
    var submsg =
        "{\"event\":\"sub\",\"params\":{\"channel\":\"market_${symbol}_depth_step${step}\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 取消订阅深度
  void unSubTradeDepth(String symbol,int step) {
    var submsg =
        "{\"event\":\"unsub\",\"params\":{\"channel\":\"market_${symbol}_depth_step${step}\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 订阅实时成交
  void subTradeTicker(String symbol) {
    var reqmsg =
        "{\"event\":\"req\",\"params\":{\"channel\":\"market_${symbol}_trade_ticker\",\"cb_id\":\"1\"}}";
    sendMessage(reqmsg);
    var submsg =
        "{\"event\":\"sub\",\"params\":{\"channel\":\"market_${symbol}_trade_ticker\",\"cb_id\":\"1\"}}";
    sendMessage(submsg);
  }

  // 取消订阅实时成交
  void unSubTradeTicker(String symbol) {
    var msg =
        "{\"event\":\"unsub\",\"params\":{\"channel\":\"market_${symbol}_trade_ticker\",\"cb_id\":\"1\"}}";
    sendMessage(msg);
  }

  void sendPong() {
    String pongStr =
        "{\"pong\":${DateTime.now().millisecondsSinceEpoch / 1000}}";
    sendMessage(pongStr);
  }

  void sendMessage(String msg) {
    if(msg.contains("pong")){
      _channel?.sink.add(msg);
      return;
    }
    Map<String, dynamic> sendMsg = convert.jsonDecode(msg);
    try {
      WsSendMsgEntity sendMsgWs = WsSendMsgEntity.fromJson(sendMsg);
      var sendMsgEvent = sendMsgWs.event;
      var sendMsgChannel = sendMsgWs.params.channel;
      if(sendMsgEvent=="sub"){
        if(_subscribedStocks.where((element) => (element['channel']==sendMsgChannel)).length==0){
          _subscribedStocks.add({"channel":sendMsgChannel,"subMsg":msg});
          _channel?.sink.add(msg);
          LogUtil.e("合约ws 发送消息${msg}");
        }
      }
      if(sendMsgEvent=="unsub"){
        if(_subscribedStocks.where((element) => (element['channel']==sendMsgChannel)).length!=0){
          _subscribedStocks.removeWhere((element) => (element['channel']==sendMsgChannel));
          _channel?.sink.add(msg);
          LogUtil.e("合约ws 发送消息${msg}");
        }
      }
      if(sendMsgEvent=="req"){
        _channel?.sink.add(msg);
        LogUtil.e("合约ws 发送消息${msg}");
      }
    } catch (e) {
      LogUtil.e("sendMessage--error:${e.toString()}");
    }
  }

  onDone() {
    LogUtil.e("合约ws 消息关闭");
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  onError(err) {
    LogUtil.e("合约ws 消息错误${err}");
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  onData(event) {
    try {
      List<int> gzipBytes = GZipDecoder().decodeBytes(event);
      String wsMsg = utf8.decode(gzipBytes);
      Map<String, dynamic> result = convert.jsonDecode(wsMsg);
      // LogUtil.e("ws 返回消息${result}");
      // LogUtil.e("ws 返回消息channel：${result['channel']} ts:${result['ts']} cb_id:${result['cb_id']}");
      //K线历史数据 / 成交记录
      if (result['event_rep'].toString() == "rep") {
        if (result['channel'].toString().endsWith("_trade_ticker")) {
          //成交记录
          DealRecordEntity quoteWs = DealRecordEntity.fromJson(result);
          Event.eventBus.fire(DealRecordEvent(quoteWs));
        } else {
          //K线历史数据
          MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
          Event.eventBus.fire(WsEvent(quoteWs, WsEventState.quote));
        }
      } else {
        if (result['channel'].toString().contains("_kline_")) {
          //k线详情 market_$symbol_kline_1min
          MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
          Event.eventBus.fire(WsEvent(quoteWs, WsEventState.quote));
        }
        if (result['channel'].toString().contains("_depth_step")) {
          //深度数据 market_$symbol_depth_step0
          MarketDepthEntity quoteWs = MarketDepthEntity.fromJson(result);
          Event.eventBus.fire(DepthStepEvent(quoteWs));
        }
        if (result['channel'].toString().contains("_ticker")) {
          if (result['channel'].toString().contains("trade") &&
              result['channel'].toString().contains("ticker")) {
            //实时成交数据
            DealRecordEntity quoteWs = DealRecordEntity.fromJson(result);
            Event.eventBus.fire(DealRecordEvent(quoteWs));
          } else {
            //24H行情ticker market_$symbol_ticker
            MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
            Event.eventBus.fire(WsEvent(quoteWs, WsEventState.quote));
          }
        }
      }
    } catch (e) {
      print("解析错误："+e.toString());
    }
  }

  void dispose() {
    if (_channel != null) {
      _channel?.sink.close();
      print("合约ws socket通道关闭");
      _channel = null;
    }
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  bool checkChannel(String channel,String symbol) {
    String tickerChannel= "market_${symbol}_ticker";
    //market_${symbol}_depth_step${step}
    //market_${symbol}_trade_ticker
    return tickerChannel==channel;
  }

  bool checkDepthChannel(String channel,String symbol,int step) {
    String tickerChannel= "market_${symbol}_depth_step${step}";
    //market_${symbol}_depth_step${step}
    //market_${symbol}_trade_ticker
    return tickerChannel==channel;
  }
}
