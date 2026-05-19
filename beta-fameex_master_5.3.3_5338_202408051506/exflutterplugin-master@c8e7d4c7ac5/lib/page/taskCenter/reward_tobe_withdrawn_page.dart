import 'package:cached_network_image/cached_network_image.dart';
import 'package:chainup_flutter_ex/utils/num_utils.dart';
import 'package:chainup_flutter_ex/widgets/empty_list_page.dart';
import 'package:chainup_flutter_ex/widgets/ex_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/taskCenter/reward_center_index_controller.dart';
import '../../controllers/taskCenter/reward_tobe_withdrawn_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../models/withdraw_list_item_entity.dart';
import '../../themes/Themes.dart';
import '../../widgets/custom_skeleton_view.dart';
import '../../widgets/gaps.dart';
import '../../widgets/skeleton_widget.dart';

class RewardTobeWithdrawnPage
    extends BaseStatelessWidget<RewardTobeWithdrawnController> {
  RewardTobeWithdrawnPage({
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
    return _buildFlowListWidget(context);
  }

  Widget _buildFlowListWidget(BuildContext context) {
    return Obx(() => MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            itemCount: controller.isLoad.value
                ? 7
                : controller.isEmpty.value
                    ? 1
                    : controller.withdrawList.length,
            itemBuilder: (BuildContext context, int index) {
              if (controller.isLoad.value) {
                return const CustomSkeleton();
              }
              if (controller.isEmpty.value) {
                return const EmptyListWidget();
              }
              return _buildItemView(context, controller.withdrawList[index]);
            },
          ),
        ));
  }

  _buildItemView(BuildContext context,
      WithdrawInfoListItemEntity withdrawInfoListItemEntity) {
    debugPrint(withdrawInfoListItemEntity.icon);
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ExNetworkImage(
                withdrawInfoListItemEntity.icon ?? "",
                width: 20.0,
                height: 20.0,
              ),
              Gaps.hGap8,
              Text(
                withdrawInfoListItemEntity.showName ?? "",
                style: ExThemes.textstyle_sm_color1_16(context),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                withdrawInfoListItemEntity.amount ?? "",
                style: ExThemes.textstyle_sm_color1_16(context),
              ),
              Gaps.vGap2,
              Text(
                withdrawInfoListItemEntity.usdtAmount != null
                    ? "${withdrawInfoListItemEntity.usdtAmount} USDT"
                    : "", // "2.98 USDT",
                style: ExThemes.textstyle_sm_color2_12(context),
              ),
            ],
          )
        ],
      ),
    );
  }
}
