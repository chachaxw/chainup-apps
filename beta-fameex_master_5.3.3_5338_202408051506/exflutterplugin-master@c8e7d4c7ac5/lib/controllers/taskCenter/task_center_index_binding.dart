import 'package:chainup_flutter_ex/controllers/taskCenter/reward_center_index_controller.dart';
import 'package:get/get.dart';

import 'task_center_type_controller.dart';
import 'task_center_index_controller.dart';
import 'task_detail_controller.dart';

class TaskCenterIndexBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskCenterIndexController>(() => TaskCenterIndexController());
    Get.lazyPut<TaskDetailController>(() => TaskDetailController());
    Get.lazyPut<RewardCenterIndexController>(
        () => RewardCenterIndexController());
  }
}
