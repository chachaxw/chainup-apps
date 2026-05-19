

import '../models/market_depth_entity.dart';

class DepthStepEvent {
  MarketDepthEntity quoteWs;

  DepthStepEvent(this.quoteWs);
}
