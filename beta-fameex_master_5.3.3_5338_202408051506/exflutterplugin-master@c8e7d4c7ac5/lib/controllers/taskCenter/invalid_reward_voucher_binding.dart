import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_index_controller.dart';
import 'package:get/get.dart';

import 'invalid_reward_voucher_controller.dart';

class InvalidRewardVoucherBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvalidRewardVoucherController>(
        () => InvalidRewardVoucherController());
  }
}
