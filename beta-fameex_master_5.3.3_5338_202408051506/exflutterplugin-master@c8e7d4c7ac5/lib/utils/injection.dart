
import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';

import '../net/http/apiservice/exchange_api.dart';

///初始化注入对象
class Injection extends GetxService {
  Future<void> init() async {
    Get.lazyPut(() => ExchangeApi(), fenix: true);
    Get.lazyPut(() => EventBus(), fenix: true);
  }
}
