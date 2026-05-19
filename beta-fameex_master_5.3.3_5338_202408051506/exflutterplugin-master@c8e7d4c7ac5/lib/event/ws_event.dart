


import '../models/bottom_sheet_entity.dart';
import '../models/market_ticker_entity.dart';

class WsEvent {
  MarketTickerEntity quoteWs;
  WsEventState state;

  WsEvent(this.quoteWs, this.state);
}

enum WsEventState {
  quote
}

class WsMsgEvent {
  Map<String, dynamic> msg;
  WsMsgState state;

  WsMsgEvent(this.msg, this.state);
}

enum WsMsgState {
  coinInfo,
  orderBook,
  transactionRecord,
  clearTransactionRecord,
  coinIntroData,
  ETFIntroData,
  ETFRuleData,
}


class SwitchKlineTimeEvent {
  KlineTimeEntity klineTime;

  SwitchKlineTimeEvent(this.klineTime);
}