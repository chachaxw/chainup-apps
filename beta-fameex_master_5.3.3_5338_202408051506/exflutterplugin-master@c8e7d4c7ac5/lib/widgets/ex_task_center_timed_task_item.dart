import 'package:chainup_flutter_ex/controllers/taskCenter/task_center_timed_type_item_controller.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/widgets/reward_live_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../controllers/taskCenter/task_center_timed_type_controller.dart';
import '../models/task_info_list_entity.dart';
import '../page/common/task_center_common.dart';
import '../routes/routes.dart';
import '../themes/Themes.dart';
import 'custom_skeleton_view.dart';
import 'ex_button.dart';
import 'ex_count_down_timer.dart';
import 'ex_progress_indicator.dart';
import 'gaps.dart';
import 'hor_dashed_line.dart';

class TaskCenterTimedTaskItem extends StatefulWidget {
  final TaskInfoListEntity mTaskInfo;
  final int? index;

  const TaskCenterTimedTaskItem(
    this.mTaskInfo, {
    super.key,
    this.index,
  });
  @override
  State<TaskCenterTimedTaskItem> createState() =>
      _TaskCenterTimedTaskItemState();
}

class _TaskCenterTimedTaskItemState extends State<TaskCenterTimedTaskItem> {
  final GlobalKey<State<StatefulWidget>> _progressKey =
      GlobalKey<State<StatefulWidget>>();

  final List<GlobalKey<State<StatefulWidget>>> _levelKeyList = [];

  @override
  void initState() {
    super.initState();
    Get.put(TaskCenterTimedTaskItemController());
    if (widget.mTaskInfo.taskLevelRewards != null) {
      for (var i = 0; i < widget.mTaskInfo.taskLevelRewards!.length; i++) {
        _levelKeyList.add(GlobalKey<State<StatefulWidget>>());
      }
    }
    // _getInitLocation();
  }
/*
  void _getInitLocation() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        try {
          TaskCenterTimedTaskItemController controller = Get.find();
          controller.calculateProgressLength(
              context, widget.mTaskInfo, _progressKey, _levelKeyList);
        } catch (e) {
          debugPrint(" 计算错误： $e ");
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskCenterTimedTaskItemController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            bool isLogin =
                ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
            if (!isLogin) {
              Routes.pushNvEvent(ev: NvEvent.login);
              return;
            }
            Routes.pushPage(
              routeName: Routes.TASK_DETAIL,
              params: {"data": widget.mTaskInfo},
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: ExColors.fill_2(context),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: ExColors.fill_5(context),
                    width: 1,
                    style: BorderStyle.solid),
                borderRadius: const BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${TaskCenterCommon.getTaskTitleByCategory(widget.mTaskInfo)}(",
                        style: ExThemes.textstyle_hm_color1_16(context),
                      ),
                      TextSpan(
                        text: widget.mTaskInfo.finishedAmount != null
                            ? controller.handleDouble(
                                widget.mTaskInfo.finishedAmount.toString(),
                                needCutDecimal: true)
                            : "0",
                        style: ExThemes.textstyle_hm_color1_16(context)
                            .copyWith(color: ExColors.main_4(context)),
                      ),
                      TextSpan(
                        text: "/${controller.getMaxReward(widget.mTaskInfo)})",
                        style: ExThemes.textstyle_hm_color1_16(context),
                      ),
                    ],
                  ),
                ),
                Text(
                  controller.getTaskDescByCategory(widget.mTaskInfo),
                  style: ExThemes.textstyle_hr_color2_12(context)
                      .copyWith(height: 1.5),
                ),
                Gaps.vGap24,
                Stack(
                  children: [
                    Positioned(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      bottom: 45,
                      child: ExProgressIndicator(
                        progressHeight: 2.0,
                        key: _progressKey,
                        value: controller.getProgressLength(widget.mTaskInfo),
                      ),
                    ),
                    Row(
                      children: buildPointTaskWidget(
                          context, widget.mTaskInfo, controller),
                    ),
                  ],
                ),
                Gaps.vGap24,
                DashedLine(
                  height: 1,
                  color: ExColors.fill_5(context),
                ),
                Gaps.vGap16,
                Text(
                  controller.getTimeDesc(widget.mTaskInfo.status),
                  style: ExThemes.textstyle_sm_color2_12(context),
                ),
                Gaps.vGap4,
                EXCountDownTimerWidget(
                  isEnd: widget.mTaskInfo.status == 8,
                  initTime: TaskCenterCommon.getCountDownTime(widget.mTaskInfo),
                ),
                Gaps.vGap20,
                ExButton(
                  initialEnable:
                      TaskCenterCommon.taskBtnCanCLick(widget.mTaskInfo.status),
                  textColor:
                      TaskCenterCommon.taskBtnCanCLick(widget.mTaskInfo.status)
                          ? ExColors.text_4(context)
                          : ExColors.text_2(context),
                  disabledBackgroundColor: ExColors.fill_5(context),
                  backgroundColor: ExColors.main_1(context),
                  text: TaskCenterCommon.getTaskActionStatus(
                      widget.mTaskInfo.status),
                  onPressed: () {
                    final taskController =
                        Get.find<TaskCenterTimedTypeController>();
                    taskController.pushTaskActionStatus(
                        widget.index!, widget.mTaskInfo);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildPointTaskWidget(
      BuildContext context,
      TaskInfoListEntity mTaskInfo,
      TaskCenterTimedTaskItemController controller) {
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

        controller.initLevelStatus(i, taskLevelRewardsEntity.status);
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
                rewardIcon(i, taskLevelRewardsEntity),
                Gaps.vGap8,
                buildPointWidget(i, context, _levelKeyList[i]),
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

  Widget rewardIcon(
    int index,
    TaskLevelRewardsEntity levelRewardsEntity,
  ) {
    return GetBuilder<TaskCenterTimedTaskItemController>(
      builder: (controller) {
        int status = controller.getStatus(index);

        Widget icon = ExIcon.timedRewardGray();

        switch (status) {
          case 1: //未领奖、已完成
            icon = const RewardLiveIcon();
            break;
          case 2: //已领奖
            icon = ExIcon.icCheckinCoin();
            break;
          default:
        }
        return GestureDetector(
          onTap: () {
            if (status == 0) {
              //未完成
              Get.showCommonDialog(
                title: "task_center_task_rewards_include".tr,
                content: controller.levelRewardDesc(
                    widget.mTaskInfo, levelRewardsEntity),
                posiText: "task_center_ok".tr,
                negaVisible: false,
              );
            }
            if (status == 1) {
              TaskCenterTimedTypeController taskCenterTimedTypeController =
                  Get.find();
              taskCenterTimedTypeController.claimTaskReward(
                index,
                widget.mTaskInfo,
                callback: () {
                  // levelRewardsEntity.status = 2;
                  // controller.changeStatus(index, 2);
                  //已完成，未领奖
                  Get.showReceivedSuccessBox(
                    widget.mTaskInfo.rewardCoin,
                    levelRewardsEntity.rewardAmount.toString(),
                    rewardType: widget.mTaskInfo.rewardType == 0
                        ? "task_center_task_rewards_type_0".tr
                        : "task_center_task_rewards_type_1".tr,
                    viewMoreText: "text9".tr,
                    viewMoreCallback: () {
                      Get.dismiss();
                      Routes.pushPage(routeName: Routes.REWARD_CENTER);
                    },
                  );
                },
              );
            }
            if (status == 2) {
              //已领奖
              Get.showCommonDialog(
                title: "task_center_task_rewards_include".tr,
                content: controller.levelRewardDesc(
                    widget.mTaskInfo, levelRewardsEntity),
                posiText: "task_center_ok".tr,
                negaVisible: false,
              );
            }
          },
          child: icon,
        );
      },
    );
  }

  Widget buildPointWidget(
    int index,
    BuildContext context,
    GlobalKey key,
  ) {
    return GetBuilder<TaskCenterTimedTaskItemController>(
      builder: (controller) {
        int status = controller.getStatus(index);
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Align(
              alignment: AlignmentDirectional.center,
              child: CircleAvatar(
                radius: 6,
                key: key,
                backgroundColor:
                    (status == 1 || status == 2 || status == 5 || status == 7)
                        ? ExColors.main_1(context)
                        : ExColors.fill_5(context),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.center,
              child: status != 2
                  ? const CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.white,
                    )
                  : ExIcon.rewardsHaveReceived(),
            ),
          ],
        );
      },
    );
  }
}
