

import '../../base/controller/base_controller.dart';
import '../../net/http/apiservice/exchange_api.dart';

class klineIndicatorsSettingController extends BaseController<ExchangeApi> {
  klineIndicatorsSettingController();


  @override
  bool useEventBus() => true;

  @override
  void onInit() {
    super.onInit();
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
  }

  @override
  void loadNet() {}
}

