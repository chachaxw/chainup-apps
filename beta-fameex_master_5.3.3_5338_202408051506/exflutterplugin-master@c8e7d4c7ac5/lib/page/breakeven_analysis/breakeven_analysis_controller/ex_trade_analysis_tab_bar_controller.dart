import 'package:get/get.dart';

class ExTradeAnalysisTabBarController extends GetxController {
  var selectedTabIndex = 0.obs;

  void updateCurrentTabIndex(int index) {
    selectedTabIndex.value = index;
  }
}
