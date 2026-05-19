import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/utils/date_utils.dart';
import 'package:chainup_flutter_ex/utils/num_utils.dart';
import 'package:chainup_flutter_ex/widgets/custom_skeleton_view.dart';
import 'package:chainup_flutter_ex/widgets/empty_list_page.dart';
import 'package:chainup_flutter_ex/widgets/ex_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/taskCenter/reward_details_controller.dart';
import '../../controllers/taskCenter/reward_tobe_withdrawn_controller.dart';
import '../../controllers/taskCenter/task_center_type_controller.dart';
import '../../models/task_center_reward_record_entity.dart';
import '../../models/task_info_list_entity.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/ex_progress_indicator.dart';
import '../../widgets/gaps.dart';
import '../../widgets/skeleton_widget.dart';

class RewardDetailsPage extends BaseStatelessWidget<RewardDetailsController> {
  RewardDetailsPage({
    Key? key,
  }) : super(key: key);

  late TaskCenterTypeController mTaskCenterTypeController;

  @override
  bool showTitleBar() => false;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildContent(BuildContext context) {
    return _buildFlowListWidget(context);
  }

  Widget _buildFlowListWidget(BuildContext context) {
    return SmartRefresher(
      controller: controller.refreshController,
      enablePullDown: false,
      enablePullUp: true,
      onLoading: () {
        controller.getRewardRecordList(loadMore: true);
      },
      child: _listView(),
    );
  }

  Widget _listView() {
    return ListView.builder(
      itemCount: controller.isLoad.value
          ? 7
          : controller.isEmpty.value == true
              ? 1
              : controller.rewardRecordList.length,
      itemBuilder: (BuildContext context, int index) {
        if (controller.isLoad.value) {
          return const CustomSkeleton();
        }
        if (controller.isEmpty.value) {
          return const EmptyListWidget();
        }
        return _buildItemView(context, controller.rewardRecordList[index]);
      },
    );
  }

  _buildItemView(BuildContext context,
      TaskCenterRewardRecordItemEntity rewardRecordItemEntity) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.getTaskTitle(rewardRecordItemEntity),
                style: ExThemes.textstyle_sm_color1_16(context),
              ),
              Gaps.vGap2,
              Text(
                EXDateUtils.formateTimestampToString(
                    rewardRecordItemEntity.receiveTime!),
                style: ExThemes.textstyle_sm_color2_12(context),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${rewardRecordItemEntity.amount!} ${rewardRecordItemEntity.showCoin!}",
                style: ExThemes.textstyle_sm_color1_16(context),
              ),
              rewardRecordItemEntity.rewardType == 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Gaps.vGap2,
                        Text(
                          "task_center_task_rewards_type_1".tr,
                          style: ExThemes.textstyle_sm_color2_12(context),
                        )
                      ],
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }
}

// class Footer extends IndicatorBuilder {}
