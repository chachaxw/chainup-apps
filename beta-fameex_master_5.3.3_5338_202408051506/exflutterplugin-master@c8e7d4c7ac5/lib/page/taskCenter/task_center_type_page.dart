import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/utils/num_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/taskCenter/task_center_type_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../widgets/custom_skeleton_view.dart';
import '../../widgets/empty_list_page.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/ex_progress_indicator.dart';
import '../../widgets/ex_task_center_timed_task_item.dart';
import '../../widgets/gaps.dart';
import '../../widgets/hor_dashed_line.dart';
import '../../widgets/skeleton_widget.dart';

class TaskCenterTypePage extends BaseStatelessWidget<TaskCenterTypeController> {
  TaskCenterTypePage({
    Key? key,
    required this.type,
  }) : super(key: key);
  String? type;

  late TaskCenterTypeController mTaskCenterTypeController;

  @override
  String get tag {
    return type.toString();
  }

  @override
  bool showTitleBar() => false;

  @override
  Widget build(BuildContext context) {
    mTaskCenterTypeController = Get.find<TaskCenterTypeController>(tag: type);
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
            return index == 0 && type != "-1"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 32,
                        margin: const EdgeInsets.only(
                            left: 16, right: 16, top: 12, bottom: 10),
                        padding: const EdgeInsets.only(
                            top: 12, left: 16, right: 16, bottom: 12),
                        decoration: BoxDecoration(
                          color: ExColors.fill_1(context),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        child: Text(
                            controller.rewardReceiveType.value == 0
                                ? "text10".tr
                                : type == "0"
                                    ? "text12".tr
                                    : "text11".trParams({
                                        "number": controller.rewardReceiveTerm
                                            .toString()
                                      }),
                            style: ExThemes.textstyle_sr_color2_12(context)
                                .copyWith(height: 1.5)),
                      ),
                      _buildItemView(context, index),
                    ],
                  )
                : _buildItemView(context, index);
          },
        ));
  }

  _buildItemView(BuildContext context, int index) {
    TaskInfoListEntity mTaskInfo = controller.transactionList[index];
    if ((mTaskInfo.category == 7 || mTaskInfo.category == 8)) {
      ///KYC 和 注册任务
      return _registerAndKYCItemWidget(context, mTaskInfo);
    }
    if (mTaskInfo.type == 3) {
      //限时任务
      return TaskCenterTimedTaskItem(
        mTaskInfo,
        index: index,
      );
    }

    return Container(
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
                Radius.circular(8),
              ))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TaskCenterCommon.getTaskIcon(mTaskInfo.category),
              Container(
                height: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 8, right: 2),
                decoration: BoxDecoration(
                    color: ExColors.main_1(context),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Text(
                      "${mTaskInfo.rewardAmount} ${mTaskInfo.rewardCoin}",
                      style: ExThemes.textstyle_sm_color1_12(context).copyWith(
                        color: ExColors.text_4(context),
                      ),
                    ),
                    Gaps.hGap4,
                    Container(
                      height: 23,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          color: ExColors.fill_2(context),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        "text15".tr,
                        style: ExThemes.textstyle_sm_color1_12(context),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Gaps.vGap20,
          Text(
            controller.getTaskTitleByCategory(mTaskInfo),
            style: ExThemes.textstyle_hm_color1_16(context),
          ),
          mTaskInfo.type == 1
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    controller.getTaskDescByCategory(mTaskInfo),
                    style: ExThemes.textstyle_hr_color2_12(context)
                        .copyWith(height: 1.5),
                  ),
                )
              : Gaps.empty,
          _timeWidget(context, mTaskInfo),
          mTaskInfo.type == 0
              ? Container(
                  margin: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ExProgressIndicator(
                          progressHeight: 8.0,
                          value: (double.tryParse(NumUtils.divideStr(
                                      mTaskInfo.finishedAmount,
                                      mTaskInfo.targetValue,
                                      2)) ??
                                  50.0) *
                              100,
                        ),
                      ),
                      Gaps.vGap8,
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text:
                              NumUtils.showSNormal(mTaskInfo.finishedAmount, 0),
                          style: ExThemes.textstyle_sr_color1_12(context),
                        ),
                        TextSpan(
                          text:
                              "/${mTaskInfo.targetValue} ${mTaskInfo.targetCoin}",
                          style: ExThemes.textstyle_sr_color2_12(context),
                        ),
                      ]))
                    ],
                  ),
                )
              : Gaps.empty,
          Gaps.vGap20,
          _buildActionBtn(context, mTaskInfo),
        ],
      ),
    );
  }

  Widget _timeWidget(BuildContext context, TaskInfoListEntity mTaskInfo) {
    bool showTime = false;
    if (mTaskInfo.type == 1) {
      if (mTaskInfo.category == 7) {
        //注册任务
        if (mTaskInfo.status == 5 ||
            mTaskInfo.status == 1 ||
            mTaskInfo.status == 2) {
          showTime = true;
        } else {
          showTime = false;
        }
      } else if (mTaskInfo.category == 8) {
        //KYC任务
        bool isLogin =
            ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
        if (!isLogin) {
          showTime = false;
        } else {
          if (mTaskInfo.status == 5 || //"奖励已过期"),
                  mTaskInfo.status == 1 || //"未领奖"),
                  mTaskInfo.status == 2 || //已领奖
                  mTaskInfo.status == 0 || //进行中、未完成
                  mTaskInfo.status == 4 //任务已过期
              ) {
            showTime = true;
          } else {
            showTime = false;
          }
        }
      } else {
        showTime = true;
      }
    }
    String time = "${long2date(mTaskInfo.remindTime)} (UTC+8)";
    if (type == "1") {
      bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).length != 0;
      if (!isLogin) {
        time = "--";
      }
    }
    return showTime
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.vGap24,
              DashedLine(
                height: 1,
                color: ExColors.fill_5(context),
              ),
              Gaps.vGap16,
              Text(
                controller.getTaskTimeStr(mTaskInfo),
                style: ExThemes.textstyle_sm_color2_12(context),
              ),
              Gaps.vGap4,
              Text(
                time,
                style: ExThemes.textstyle_sm_color1_14(context),
              ),
            ],
          )
        : Gaps.empty;
  }

  Widget _registerAndKYCItemWidget(
      BuildContext context, TaskInfoListEntity mTaskInfo) {
    return Container(
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
                Radius.circular(8),
              ))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TaskCenterCommon.getTaskIcon(mTaskInfo.category),
              Container(
                height: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 8, right: 2),
                decoration: BoxDecoration(
                    color: ExColors.main_1(context),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Text(
                      "${mTaskInfo.rewardAmount} ${mTaskInfo.rewardCoin}",
                      style: ExThemes.textstyle_sm_color1_12(context).copyWith(
                        color: ExColors.text_4(context),
                      ),
                    ),
                    Gaps.hGap4,
                    Container(
                      height: 23,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        mTaskInfo.rewardType == 0
                            ? "text15".tr
                            : "task_center_task_rewards_type_1".tr,
                        style: ExThemes.textstyle_sm_color1_12(context),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Gaps.vGap20,
          Text(
            controller.getTaskTitleByCategory(mTaskInfo),
            style: ExThemes.textstyle_hm_color1_16(context),
          ),
          Gaps.vGap20,
          Text(
            controller.getTaskDescByCategory(mTaskInfo),
            style:
                ExThemes.textstyle_hr_color2_12(context).copyWith(height: 1.5),
          ),
          _timeWidget(context, mTaskInfo),
          Gaps.vGap20,
          ExButton(
            initialEnable: controller.isKycOrRegisterTaskCanTap(mTaskInfo),
            text: controller.getTaskActionStatus(mTaskInfo),
            backgroundColor: ExColors.main_1(context),
            disabledBackgroundColor: ExColors.fill_5(context),
            textColor: controller.isKycOrRegisterTaskCanTap(mTaskInfo)
                ? ExColors.text_4(context)
                : ExColors.text_2(context),
            onPressed: () {
              controller.pushTaskActionStatus(mTaskInfo);
            },
          )
        ],
      ),
    );
  }

  /**
   * mTaskInfo.category =4 (首笔数字货币充值)只有一个按钮
   * mTaskInfo.category !=4 在未完成任务的时候存在两个按钮，其他状态都是一个按钮
   */
  _buildActionBtn(BuildContext context, TaskInfoListEntity mTaskInfo) {
    return mTaskInfo.category != 4
        ? ExButton(
            initialEnable: mTaskInfo.status == 0 || mTaskInfo.status == 1,
            text: controller.getTaskActionStatus(mTaskInfo),
            backgroundColor: ExColors.main_1(context),
            disabledBackgroundColor: ExColors.fill_5(context),
            textColor: mTaskInfo.status == 0 || mTaskInfo.status == 1
                ? ExColors.text_4(context)
                : ExColors.text_2(context),
            onPressed: () {
              controller.pushTaskActionStatus(mTaskInfo);
            },
          )
        : (mTaskInfo.status == 0
            ? Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      flex: 1,
                      child: ExButton(
                        text: "text16".tr,
                        disabledTextColor: ExColors.text_2(context),
                        disabledBackgroundColor: ExColors.fill_5(context),
                        backgroundColor: ExColors.main_1(context),
                        textColor: ExColors.text_4(context),
                        onPressed: () {
                          controller.pushTaskActionStatus(mTaskInfo,
                              isQuickMoney: true);
                        },
                      )),
                  Gaps.hGap8,
                  Expanded(
                      flex: 1,
                      child: ExButton(
                        text: "text17".tr,
                        disabledTextColor: ExColors.text_2(context),
                        disabledBackgroundColor: ExColors.fill_5(context),
                        backgroundColor: ExColors.main_1(context),
                        textColor: ExColors.text_4(context),
                        onPressed: () {
                          controller.pushTaskActionStatus(mTaskInfo);
                        },
                      ))
                ],
              )
            : ExButton(
                initialEnable: mTaskInfo.status == 1,
                text: controller.getTaskActionStatus(mTaskInfo),
                backgroundColor: ExColors.main_1(context),
                disabledBackgroundColor: ExColors.fill_5(context),
                textColor: mTaskInfo.status == 1
                    ? ExColors.text_4(context)
                    : ExColors.text_2(context),
                onPressed: () {
                  controller.pushTaskActionStatus(mTaskInfo);
                },
              ));
  }
}
