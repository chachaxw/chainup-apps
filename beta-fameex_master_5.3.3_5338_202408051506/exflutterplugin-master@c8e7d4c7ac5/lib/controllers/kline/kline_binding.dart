import 'package:get/get.dart';

import 'contract_kline_controller.dart';
import 'h_kline_controller.dart';
import 'kline_adjustment_controller.dart';
import 'kline_disclosure_controller.dart';
import 'kline_introduction_controller.dart';
import 'kline_order_book_controller.dart';
import 'kline_transaction_record_controller.dart';

class klineBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KlineController>(() => KlineController());
    Get.lazyPut<HKlineController>(() => HKlineController());
    Get.lazyPut<KLineOrderBookController>(() => KLineOrderBookController());
    Get.lazyPut<KLineTransactionRecordController>(
        () => KLineTransactionRecordController());
    Get.lazyPut<KLineIntroductionController>(
        () => KLineIntroductionController());
    Get.lazyPut<KLineDisclosureController>(() => KLineDisclosureController());
    Get.lazyPut<KLineAdjustmentController>(() => KLineAdjustmentController());
  }
}

class HorzonalKlineBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<KlineController>(() => KlineController());
    Get.lazyPut<HKlineController>(() => HKlineController());
    // Get.lazyPut<KLineOrderBookController>(() => KLineOrderBookController());
    // Get.lazyPut<KLineTransactionRecordController>(
    //     () => KLineTransactionRecordController());
    // Get.lazyPut<KLineIntroductionController>(
    //     () => KLineIntroductionController());
    // Get.lazyPut<KLineDisclosureController>(() => KLineDisclosureController());
    // Get.lazyPut<KLineAdjustmentController>(() => KLineAdjustmentController());
  }
}
