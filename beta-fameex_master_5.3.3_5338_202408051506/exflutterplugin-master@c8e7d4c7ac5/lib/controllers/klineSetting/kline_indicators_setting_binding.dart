import 'package:get/get.dart';

import 'kline_indicators_modify_controller.dart';
import 'kline_indicators_setting_controller.dart';

class klineIndicatorsSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<klineIndicatorsSettingController>(
        () => klineIndicatorsSettingController());
    Get.lazyPut<KlineIndicatorsModifyController>(
        () => KlineIndicatorsModifyController());
  }
}
