import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/utils/num_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/taskCenter/task_center_timed_type_controller.dart';
import '../../controllers/taskCenter/task_center_timed_type_item_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../routes/routes.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../widgets/custom_skeleton_view.dart';
import '../../widgets/empty_list_page.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/ex_count_down_timer.dart';
import '../../widgets/ex_progress_indicator.dart';
import '../../widgets/ex_task_center_timed_task_item.dart';
import '../../widgets/gaps.dart';
import '../../widgets/skeleton_widget.dart';
import '../common/task_center_common.dart';

class TaskCenterTimedTypePage
    extends BaseStatelessWidget<TaskCenterTimedTypeController> {
  TaskCenterTimedTypePage({
    Key? key,
  }) : super(key: key);

  @override
  bool showTitleBar() => false;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      color: ExColors.fill_2(context),
      child: _buildFlowListWidget(context),
    );
  }

  Widget _buildFlowListWidget(BuildContext context) {
    return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          itemCount: controller.isLoad.value
              ? 7
              : controller.isEmpty.value
                  ? 1
                  : controller.transactionList.length,
          itemBuilder: (BuildContext context, int index) {
            if (controller.isLoad.value) {
              return const CustomSkeleton();
            }
            if (controller.isEmpty.value) {
              return EmptyListWidget(
                text: "timed_task_detail_text21".tr,
              );
            }
            return TaskCenterTimedTaskItem(
              controller.transactionList[index],
              index: index,
            );
          },
        ));
  }

  Widget buildPointWidget(BuildContext context) => Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: ExColors.main_1(context),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: ExColors.fill_2(context),
            ),
          ),
        ],
      );

  List<Widget> buildPointTaskWidget(
      BuildContext context, TaskInfoListEntity mTaskInfo) {
    List<Widget> list = [];
    if (mTaskInfo.taskLevelRewards != null) {
      for (int i = 0; i < mTaskInfo.taskLevelRewards!.length; i++) {
        if (mTaskInfo.taskLevelRewards!.length == 1) {
          list.add(
            const Spacer(),
          );
          list.add(
            const Spacer(),
          );
        }
        TaskLevelRewardsEntity taskLevelRewardsEntity =
            mTaskInfo.taskLevelRewards![i];
        list.add(
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: ExThemes.getBoxFill1Radius100(context),
                  child: Text(
                    "${taskLevelRewardsEntity.rewardAmount} ${mTaskInfo.rewardCoin}",
                    style: ExThemes.textstyle_sm_color1_12(context),
                  ),
                ),
                Gaps.vGap8,
                ExIcon.icCheckinCoin(),
                Gaps.vGap8,
                buildPointWidget(context),
                Gaps.vGap8,
                Text(
                  "task_center_timed_task_trade".tr,
                  style: ExThemes.textstyle_sm_color2_12(context),
                ),
                Gaps.vGap4,
                Text(
                  "${taskLevelRewardsEntity.targetAmount} ${mTaskInfo.targetCoin}",
                  style: ExThemes.textstyle_sm_color1_12(context),
                ),
              ],
            ),
          ),
        );
      }
    }

    return list;
  }
}
