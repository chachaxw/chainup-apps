import 'package:get/get.dart';

import 'ex_trade_analysis_tab_bar_controller.dart';
import 'margin_trade_breakeven_analysis_controller.dart';

class MaiginTradeBreakevenAnalysisBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaiginTradeBreakevenAnalysisController());
    Get.lazyPut(() => ExTradeAnalysisTabBarController());
  }
}
