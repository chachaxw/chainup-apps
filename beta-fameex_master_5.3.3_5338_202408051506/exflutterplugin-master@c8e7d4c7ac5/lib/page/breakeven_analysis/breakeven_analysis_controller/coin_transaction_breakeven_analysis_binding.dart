import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:get/get.dart';

class CoinTransactionBreakevenAnalysisBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CoinTransactionBreakevenAnalysisController());
  }
}
