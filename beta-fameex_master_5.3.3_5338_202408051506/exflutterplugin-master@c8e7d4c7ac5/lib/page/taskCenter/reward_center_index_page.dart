import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/ex_button.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/pageWidget/base_stateless_widget.dart';
import '../../controllers/taskCenter/reward_center_index_controller.dart';
import '../../controllers/taskCenter/reward_coupon_controller.dart';
import '../../controllers/taskCenter/reward_details_controller.dart';
import '../../controllers/taskCenter/reward_tobe_withdrawn_controller.dart';
import '../../utils/sticky_tabbar_delegate.dart';
import '../../widgets/ex_tab_indicator.dart';
import '../../widgets/keep_alive_wrapper.dart';
import 'reward_coupon_page.dart';
import 'reward_details_page.dart';
import 'reward_tobe_withdrawn_page.dart';

class RewardCenterIndexPage
    extends BaseStatelessWidget<RewardCenterIndexController> {
  RewardCenterIndexPage({Key? key}) : super(key: key);

  @override
  String titleString() => "text80".tr;

  @override
  bool useLoadSir() => false;

  @override
  bool showTitleBar() => true;

  @override
  Widget buildContent(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: _buildSignView(context),
              ),
              _buildTabBar(context),
            ];
          },
          body: _buildPageView(context),
        ));
  }

  _buildSignView(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${"rewards_center_text1".tr}：",
                    style: ExThemes.textstyle_sm_color1_14(context),
                  ),
                  Gaps.vGap4,
                  Obx(() {
                    String amountStr = "";
                    double amount = double.parse(
                        controller.mRewardCenterData.value.unWithdrawAmount ??
                            "0");
                    amount = double.parse(
                        TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                            amount, 4));
                    if (amount % 1 == 0) {
                      int a = amount.round();
                      amountStr = a.toString();
                    } else {
                      amountStr = amount.toString();
                    }
                    return Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: amountStr,
                          style:
                              ExThemes.textstyle_sm_color1_28(context).copyWith(
                            color: ExColors.main_4(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextSpan(
                          text: " USDT",
                          style: ExThemes.textstyle_sm_color1_16(context),
                        ),
                      ]),
                    );
                  })
                ],
              ),
              Obx(() => ExButton(
                    text: "text27".tr,
                    textColor: controller.isCanWithdraw.value
                        ? ExColors.text_4(context)
                        : ExColors.text_2(context),
                    disabledBackgroundColor: ExColors.fill_5(context),
                    backgroundColor: ExColors.main_1(context),
                    initialEnable: controller.isCanWithdraw.value,
                    minWidth: 100,
                    minHeight: 36,
                    onPressed: () {
                      controller.withdrawClick();
                    },
                  )),
            ],
          ),
          Gaps.vGap8,
          Obx(
            () {
              String amountStr = "";
              double amount = double.parse(controller.remainWithdraw.value);
              amount = double.parse(
                  TaskCenterCommon.truncateToSpecifiedDecimalPlaces(amount, 4));
              if (amount % 1 == 0) {
                int a = amount.round();
                amountStr = a.toString();
              } else {
                amountStr = amount.toString();
              }
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "timed_task_detail_text31".tr,
                      style: ExThemes.textstyle_sm_color2_12(context),
                    ),
                    TextSpan(
                      text: " $amountStr USDT ",
                      style: ExThemes.textstyle_sm_color1_12(context),
                    ),
                    TextSpan(
                      text: "timed_task_detail_text32".tr,
                      style: ExThemes.textstyle_sm_color2_12(context),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    ));
  }

  _buildTabBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: StickyTabBarDelegate(
          minHeight: 48,
          maxHeight: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: ExColors.fill_2(context),
            ),
            child: TabBar(
              tabs: controller.mTabData
                  .map((element) => Tab(
                        text: element.showName,
                      ))
                  .toList(),
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              labelStyle: ExThemes.textstyle_sm_color1_14(context),
              unselectedLabelColor: ExColors.text_color_2(context),
              indicator: TabSizeIndicator(
                borderSide: BorderSide(
                  width: 4.0,
                  color: ExColors.main_1(context),
                ),
              ),
              controller: controller.mTabController,
              onTap: (index) {
                controller.mPagerController.jumpToPage(index);
              },
            ),
          )),
    );
  }

  _buildPageView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: KeepAliveWrapper(
        child: PageView(
          controller: controller.mPagerController,
          onPageChanged: (index) {
            controller.mTabController.index = index;
          },
          children: _buildPageItem(),
        ),
      ),
    );
  }

  List<Widget> _buildPageItem() {
    List<Widget> listPage = [];
    Get.lazyPut(() => RewardTobeWithdrawnController());
    Get.lazyPut(() => RewardDetailsController());
    Get.lazyPut(() => RewardCouponController());
    listPage.add(RewardTobeWithdrawnPage());
    listPage.add(RewardCouponPage());
    listPage.add(
      RewardDetailsPage(),
    );
    return listPage;
  }
}
