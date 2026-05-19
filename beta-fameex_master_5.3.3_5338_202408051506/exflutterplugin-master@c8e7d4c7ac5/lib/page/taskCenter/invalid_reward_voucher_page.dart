import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/widgets/custom_skeleton_view.dart';
import 'package:chainup_flutter_ex/widgets/empty_list_page.dart';
import 'package:chainup_flutter_ex/widgets/ex_count_down_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/taskCenter/invalid_reward_voucher_controller.dart';
import '../../models/task_center_reward_voucher.dart';
import '../../themes/Themes.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/gaps.dart';
import '../../widgets/skeleton_widget.dart';
import '../../widgets/ver_dashed_line.dart';

class InvalidRewardVoucherPage
    extends BaseStatelessWidget<InvalidRewardVoucherController> {
  InvalidRewardVoucherPage({
    Key? key,
  }) : super(key: key);

  @override
  bool showTitleBar() => true;

  @override
  String titleString() => "timed_task_detail_text27".tr;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildContent(BuildContext context) {
    return _buildFlowListWidget(context);
  }

  Widget _buildFlowListWidget(BuildContext context) {
    return Obx(
      () => SmartRefresher(
        enablePullDown: false,
        onLoading: () {
          controller.getInvalidRewardVoucherList(loadMore: true);
        },
        controller: controller.refreshController,
        child: ListView.builder(
          itemCount: controller.isLoad.value
              ? 7
              : controller.isEmpty.value
                  ? 1
                  : controller.rewardVoucherList.length,
          itemBuilder: (BuildContext context, int index) {
            if (controller.isLoad.value) {
              return CustomSkeleton();
            }
            if (controller.isEmpty.value) {
              return const EmptyListWidget(
                iconTopPadding: 200,
              );
            }
            return _buildItemView(context, controller.rewardVoucherList[index]);
          },
        ),
      ),
    );
  }

  _buildItemView(BuildContext context,
      TaskCenterRewardVoucherItemEntity voucherItemEntity) {
    bool isExpired = voucherItemEntity.status != 2;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.only(right: 16),
      height: 93,
      decoration: ExThemes.getBoxWhiteRadius12(context).copyWith(
        boxShadow: [
          const BoxShadow(
            color: Color(0x10000000),
            offset: Offset(0.0, 3.0), // 阴影在X轴和Y轴上的偏移
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  isExpired
                      ? Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 93,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFD5D7DA),
                                    Color(0x00D5D7DA),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    voucherItemEntity.amount!,
                                    style:
                                        ExThemes.textstyle_hb_color1_28(context)
                                            .copyWith(
                                                color:
                                                    ExColors.text_3(context)),
                                  ),
                                  Text(
                                    voucherItemEntity.showName!,
                                    style:
                                        ExThemes.textstyle_hm_color1_14(context)
                                            .copyWith(
                                                color:
                                                    ExColors.text_3(context)),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: VerticalDashedLine(
                                height: 93,
                                width: 1.0,
                                color: ExColors.fill_4(context),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 93,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFF4C9),
                                    Color(0x00fff4c9),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    voucherItemEntity.amount!,
                                    style:
                                        ExThemes.textstyle_hb_color1_28(context)
                                            .copyWith(
                                      color: ExColors.warning_1(context),
                                    ),
                                  ),
                                  Text(
                                    voucherItemEntity.showName!,
                                    style: ExThemes.textstyle_hm_color1_14(
                                            context)
                                        .copyWith(
                                            color: ExColors.warning_1(context)),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: VerticalDashedLine(
                                height: 93,
                                width: 1.0,
                                color: ExColors.fill_4(context),
                              ),
                            ),
                          ],
                        ),
                  Gaps.hGap12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.showCommonDialog(
                            title: "timed_task_detail_text30".tr,
                            content: "timed_task_detail_text26".trParams({
                              "day": voucherItemEntity.rewardRecoveryTerm
                                  .toString()
                            }).tr,
                            negaVisible: false,
                            okBtnTextColor: ExColors.fill_2(context),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "timed_task_detail_text23".tr,
                              style: ExThemes.textstyle_sm_color1_16(context),
                            ),
                            Gaps.hGap2,
                            ExIcon.icArrowRight()
                          ],
                        ),
                      ),
                      Gaps.vGap8,
                      Text(
                        "${"timed_task_detail_text24".tr}:",
                        style: ExThemes.textstyle_sm_color2_12(context),
                      ),
                      Gaps.vGap4,
                      EXCountDownTimerWidget(
                        initTime: voucherItemEntity.expireTime,
                        isEnd: true,
                        textStyle: ExThemes.textstyle_sm_color1_14(
                          context,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              ExButton(
                initialEnable: false,
                textColor: ExColors.text_2(context),
                disabledBackgroundColor: ExColors.fill_5(context),
                minWidth: 60,
                minHeight: 36,
                text: controller.useText(voucherItemEntity),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}
