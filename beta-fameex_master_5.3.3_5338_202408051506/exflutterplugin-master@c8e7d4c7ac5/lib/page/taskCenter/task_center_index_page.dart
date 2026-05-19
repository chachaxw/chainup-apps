import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/utils/app_utils.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/storage_utils.dart';
import '../../base/pageWidget/base_stateless_widget.dart';
import '../../controllers/taskCenter/task_center_timed_type_controller.dart';
import '../../controllers/taskCenter/task_center_type_controller.dart';
import '../../controllers/taskCenter/task_center_index_controller.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/task_center_index_entity.dart';
import '../../routes/routes.dart';
import '../../utils/sticky_tabbar_delegate.dart';
import '../../widgets/ex_progress_indicator.dart';
import '../../widgets/ex_tab_indicator.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/skeleton_widget.dart';
import 'task_center_timed_type_page.dart';
import 'task_center_type_page.dart';

class TaskCenterIndexPage
    extends BaseStatelessWidget<TaskCenterIndexController> {
  TaskCenterIndexPage({Key? key}) : super(key: key);

  @override
  String titleString() => "text".tr;

  @override
  bool useLoadSir() => false;

  @override
  bool showTitleBar() => true;

  @override
  Widget? rightWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtil.isDebug()
            ? Routes.pushPage(routeName: Routes.DEBUG)
            : Routes.pushNvEvent(
                ev: NvEvent.task_center_share,
                param: {
                  "symbol": "USDT",
                  "amount": controller.mTaskIndexData.value.titleRewardAmount,
                },
              );
      },
      child: SizedBox(
        width: 20,
        height: 20,
        child:
            AppUtil.isDebug() ? ExIcon.icDialogTips() : ExIcon.icTradeShare(),
      ),
    );
  }

  @override
  VoidCallback? onBack() {
    controller.closePage();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: ExColors.fill_2(context),
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

  Container listitem(BuildContext context, int index, String v, String? v_) {
    var seriateSignInNum =
        controller.mTaskIndexData.value.signInInfo?.seriateSignInNum;
    var isSign = ((index + 1) <= seriateSignInNum!);
    var colorArr1 = [
      Color(0xFFEDE110),
      Color(0xFFF7CA1B),
    ];
    var colorArr2 = [
      Color(0xFFF6F8FF),
      Color(0xFFF6F8FF),
    ];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: isSign ? colorArr1 : colorArr2,
        // ),
        color: Colors.white,
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    v,
                    style: ExThemes.textstyle_sm_color1_14(context),
                  ),
                  Text(
                    v_ ?? "",
                    style: ExThemes.textstyle_sr_color1_8(context),
                  )
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                child: isSign ? ExIcon.icSignInMark() : ExIcon.icSignNoMark(),
              ),
              Positioned(
                  left: 6,
                  top: 0,
                  child: Text((index + 1).toString(),
                      style: ExThemes.textstyle_sm_color1_8(context).copyWith(
                        color: isSign
                            ? Colors.white
                            : ExColors.text_color_2(context),
                        fontStyle: FontStyle.italic,
                      ))),
              Positioned(
                right: 0,
                bottom: 0,
                child: isSign ? ExIcon.icSignInYes() : ExIcon.icSignInNo(),
              )
            ],
          )),
    );
  }

  Widget _buildCheckInTask(BuildContext context, bool showSign) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        showSign
            ? Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    controller.taskSignIn();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 8, right: 12, left: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF0F2FF),
                          Color(0x00F0F2FF),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "task_center_01".tr,
                          style: ExThemes.textstyle_sm_color1_14(context),
                        ),
                        Gaps.vGap2,
                        Text(
                          controller.isSignIn.value
                              ? "task_center_03".tr
                              : "task_center_02".tr,
                          style: ExThemes.textstyle_sm_color3_12(context),
                        ),
                        Gaps.vGap8,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ExIcon.icCheckinCenter(),
                            ExIcon.icCheckinCenterRight()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        showSign ? Gaps.hGap12 : Container(),
        Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                bool isLogin =
                    ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
                if (!isLogin) {
                  Routes.pushNvEvent(ev: NvEvent.login);
                  return;
                }
                Routes.pushPage(routeName: Routes.REWARD_CENTER);
              },
              child: Container(
                padding: showSign
                    ? const EdgeInsets.only(
                        top: 12, bottom: 8, right: 12, left: 12)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF4C9),
                        Color(0x00FFF4C9),
                      ],
                    )),
                child: showSign
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "text80".tr,
                            style: ExThemes.textstyle_sm_color1_14(context),
                          ),
                          Gaps.vGap2,
                          Text(
                            "task_center_04".tr,
                            style: ExThemes.textstyle_sm_color3_12(context),
                          ),
                          Gaps.vGap8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ExIcon.icRewardsCenter(),
                              ExIcon.icRewardsCenterRight()
                            ],
                          )
                        ],
                      )
                    : Row(
                        children: [
                          ExIcon.icRewardsCenter(),
                          Gaps.hGap12,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "text80".tr,
                                style: ExThemes.textstyle_sm_color1_14(context),
                              ),
                              Gaps.vGap2,
                              Text(
                                "task_center_04".tr,
                                style: ExThemes.textstyle_sm_color3_12(context),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ExIcon.icRewardsCenterRight()
                        ],
                      ),
              ),
            ))
      ],
    );
  }

  _buildSignView(BuildContext context) {
    return Obx(
      () => SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x80CCD4FF),
                Color(0x50F6F8FF),
                Color(0x00F6F8FF),
                // Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Column(
            children: [
              Container(
                // height: 190,
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 0,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 39),
                          Text(
                            "“${controller.mTaskIndexData.value.titleRewardAmount ?? "--"} ${"USDT"}”",
                            style: ExThemes.textstyle_sb_color1_24(context)
                                .copyWith(color: ExColorsDark.main_4),
                          ),
                          Gaps.vGap2,
                          Text("text1".tr,
                              style: ExThemes.textstyle_sb_color1_24(context)),
                          Gaps.vGap12,
                          Text("task_centerk_05".tr,
                              style: ExThemes.textstyle_hm_color1_14(context))
                        ],
                      ),
                    ),
                    ExIcon.icTaskTopIllustration()
                  ],
                ),
              ),
              Gaps.vGap12,
              Obx(
                () {
                  bool showSign =
                      controller.mTaskIndexData.value.signInInfo != null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCheckInTask(context, showSign),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
            child: Obx(() => TabBar(
                  tabs: controller.mTabData
                      .map((element) => Tab(
                            text: element.showName,
                          ))
                      .toList(),
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  labelStyle: ExThemes.textstyle_hm_color1_14(context),
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
                )),
          )),
    );
  }

  _buildPageView(BuildContext context) {
    return Obx(
      () => KeepAliveWrapper(
        child: PageView(
          controller: controller.mPagerController,
          onPageChanged: (index) {
            controller.mTabController.index = index;
          },
          children: _buildPageItem(context),
        ),
      ),
    );
  }

  List<Widget> _buildPageItem(BuildContext context) {
    List<Widget> listPage = [];
    for (var i = 0; i < controller.mTabData.length; i++) {
      BottomSheetEntity element = controller.mTabData[i];
      if (element.extrasStr != "3") {
        Get.lazyPut(() => TaskCenterTypeController(element.extrasStr),
            tag: element.extrasStr);
        listPage.add(TaskCenterTypePage(
          type: element.extrasStr,
        ));
      } else {
        Get.lazyPut(() => TaskCenterTimedTypeController(element.extrasStr));
        listPage.add(TaskCenterTimedTypePage());
      }
    }
    // controller.mTabData.forEach((element) {
    //   if(element.extrasStr!="2"){
    //     Get.lazyPut(() => TaskCenterTypeController(element.extrasStr),
    //         tag: element.extrasStr);
    //     listPage.add(TaskCenterTypePage(type: element.extrasStr,));
    //   }else{
    //     Get.lazyPut(() => TaskCenterTimedTypeController());
    //     listPage.add(TaskCenterTimedTypePage());
    //   }
    // });
    return listPage;
  }
}
