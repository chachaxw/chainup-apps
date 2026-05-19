import 'package:chainup_flutter_ex/base/controller/base_controller.dart';
import 'package:get/get.dart';

class FlutterDateTimePickerController extends BaseController {
  var startTimeStr = "".obs;
  var endTimeStr = "".obs;

  var isSelectingStartDate = true.obs;
  var isSelectingEndDate = false.obs;
  var title = "breakeven_analysis_text14".tr.obs;

  @override
  void loadNet() {
    // TODO: implement loadNet
  }
  @override
  void onClose() {
    isSelectingStartDate.value = true;
    isSelectingEndDate.value = false;
    super.onClose();
  }

  void changeTitle(int index) {
    title.value = index == 0
        ? "breakeven_analysis_text14".tr
        : "breakeven_analysis_text38".tr;
  }
}
