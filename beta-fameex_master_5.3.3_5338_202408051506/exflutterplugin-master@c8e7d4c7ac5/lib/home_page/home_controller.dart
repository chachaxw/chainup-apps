import 'package:chainup_flutter_ex/base/controller/base_controller.dart';

import '../net/http/apiservice/exchange_api.dart';

class HomeController extends BaseController<ExchangeApi> {
  HomeController();
  @override
  void loadNet() {}
}
