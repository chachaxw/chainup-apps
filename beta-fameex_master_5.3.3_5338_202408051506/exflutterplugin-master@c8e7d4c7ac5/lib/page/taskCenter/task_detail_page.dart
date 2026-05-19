import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/ex_button.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/pageWidget/base_stateless_widget.dart';
import '../../controllers/taskCenter/task_center_index_controller.dart';
import '../../controllers/taskCenter/task_detail_controller.dart';
import '../../models/task_info_list_entity.dart';
import '../../routes/routes.dart';
import '../../utils/sticky_tabbar_delegate.dart';
import '../../widgets/ex_count_down_timer.dart';
import '../../widgets/ex_progress_indicator.dart';
import '../../widgets/ex_tab_indicator.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../common/task_center_common.dart';

class TaskDetailPage extends BaseStatelessWidget<TaskDetailController> {
  TaskDetailPage({Key? key}) : super(key: key);

  @override
  String titleString() => "timed_task_detail_text54".tr;

  @override
  bool useLoadSir() => false;

  @override
  bool showTitleBar() => true;

  @override
  Color backgroundColor(BuildContext context) {
    return Colors.white;
  }

  @override
  Widget? rightWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TaskCenterIndexController taskCenterIndexController = Get.find();

        Routes.pushNvEvent(
          ev: NvEvent.task_center_share,
          param: {
            "symbol": "USDT",
            "amount": taskCenterIndexController
                .mTaskIndexData.value.titleRewardAmount,
          },
        );
      },
      child: SizedBox(
        width: 20,
        height: 20,
        child: ExIcon.icTradeShare(),
      ),
    );
  }

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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSign ? colorArr1 : colorArr2,
          )),
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

  _buildSignView(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xCCCCD4FF),
          Color(0x80F6F8FF),
          Color(0xF6F8FF),
        ],
      )),
      child: Column(
        children: [
          Container(
            height: 40,
            color: ExColors.warning_2(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExIcon.icSubtract(),
                Gaps.hGap8,
                Text(
                  "${TaskCenterCommon.getTimeDesc(controller.mTaskInfo.value.status)}: ",
                  style: ExThemes.textstyle_sr_color1_14(context),
                ),
                EXCountDownTimerWidget(
                  textStyle: ExThemes.textstyle_sr_color1_14(context)
                      .copyWith(color: ExColors.warning_1(context)),
                  isEnd: controller.mTaskInfo.value.status == 8,
                  initTime: TaskCenterCommon.getCountDownTime(
                      controller.mTaskInfo.value),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TaskCenterCommon.getTaskCategory(
                          controller.mTaskInfo.value),
                      style: ExThemes.textstyle_hb_color1_24(context)
                          .copyWith(color: ExColors.main_4(context)),
                    ),
                    Text(
                      "task_center_timed_task_challenge".tr,
                      style: ExThemes.textstyle_hb_color1_24(context),
                    ),
                    Gaps.vGap8,
                    Text(
                      "timed_task_detail_text1".tr,
                      style: ExThemes.textstyle_hm_color2_12(context),
                    ),
                  ],
                )),
                ExIcon.icRewardTopIllustration()
              ],
            ),
          ),
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
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: ExColors.fill_2(context),
              child: TabBar(
                tabs: controller.mTabData
                    .map((element) => Tab(
                          text: element.showName,
                        ))
                    .toList(),
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
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
            ),
            Positioned(
              left: 140,
              top: 4,
              child: _canReceivedTagWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _canReceivedTagWidget(BuildContext context) {
    return Obx(
      () => controller.isHaveCanReceivedReward.value
          ? Container(
              padding:
                  const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF16782),
                    Color(0xFFD1425E),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  "timed_task_detail_text20".tr,
                  style: ExThemes.textstyle_sr_color1_10(context)
                      .copyWith(color: Colors.white),
                ),
              ),
            )
          : Container(),
    );
  }

  _buildPageView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: KeepAliveWrapper(
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
    listPage.add(taskDetailsPage(context));
    listPage.add(taskSchedulePage(context));
    return listPage;
  }

  Widget taskDetailsPage(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2 +
                    (controller.mTaskInfo.value.taskLevelRewards != null
                        ? controller.mTaskInfo.value.taskLevelRewards!.length
                        : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return descWidget(context);
                  }
                  if (index == 1) {
                    return Text(
                      "timed_task_detail_text8".tr,
                      style: ExThemes.textstyle_sm_color1_16(context),
                    );
                  }
                  return levelListItem(context, index - 2);
                },
              ),
            ),
            Gaps.vGap10,
            ExButton(
              initialEnable: TaskCenterCommon.taskBtnCanCLick(
                  controller.mTaskInfo.value.status),
              textColor: TaskCenterCommon.taskBtnCanCLick(
                      controller.mTaskInfo.value.status)
                  ? ExColors.text_4(context)
                  : ExColors.text_2(context),
              disabledBackgroundColor: const Color(0xFFD5D7DA),
              text: TaskCenterCommon.getTaskActionStatus(
                  controller.mTaskInfo.value.status),
              onPressed: () {
                TaskCenterCommon.pushTaskActionStatus(
                    controller.mTaskInfo.value);
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            )
          ],
        ),
      ),
    );
  }

  Widget descWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "timed_task_detail_text7".tr,
          style: ExThemes.textstyle_sm_color1_16(context),
        ),
        Gaps.vGap12,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ExThemes.getBoxFill1Radius4(context),
          child: Text(
            controller.getDesc(),
            style:
                ExThemes.textstyle_sm_color2_12(context).copyWith(height: 1.8),
          ),
        ),
        Gaps.vGap32,
      ],
    );
  }

  List<Widget> levelList(BuildContext context) {
    List<Widget> list = List.generate(
      controller.mTaskInfo.value.taskLevelRewards != null
          ? controller.mTaskInfo.value.taskLevelRewards!.length
          : 0,
      (index) {
        return levelListItem(context, index);
      },
    );

    return list;
  }

  Widget levelListItem(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.vGap26,
        Text(
          controller.getLevelDesc(index),
          style: ExThemes.textstyle_sm_color2_14(context),
        ),
        Gaps.vGap14,
        Row(
          children: [
            ExIcon.icCheckinCoinSmall(),
            Gaps.hGap8,
            Text(
              controller.getLevelRewardDesc(index),
              style: ExThemes.textstyle_sm_color1_14(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget taskSchedulePage(BuildContext context) {
    return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          itemCount: controller.mTaskInfo.value.taskLevelRewards!.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildTaskScheduleItem(context, index);
          },
        ));
  }

  Widget _buildTaskScheduleItem(BuildContext context, int index) {
    TaskLevelRewardsEntity taskLevelRewardsEntity =
        controller.mTaskInfo.value.taskLevelRewards![index];
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: ExColors.main_1(context),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  (index + 1).toString(),
                  style: ExThemes.textstyle_sm_color1_12(context).copyWith(
                    color: ExColors.text_4(context),
                  ),
                ),
              ),
              (controller.mTaskInfo.value.taskLevelRewards!.length - 1) == index
                  ? Container()
                  : Container(
                      width: 1,
                      height: 195,
                      color: ExColors.fill_5(context),
                    )
            ],
          ),
          Gaps.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TaskCenterCommon.getLevelText(index) +
                      ": " +
                      TaskCenterCommon.getTaskTitleByCategory(
                          controller.mTaskInfo.value),
                  style: ExThemes.textstyle_sm_color1_16(context),
                ),
                Gaps.vGap4,
                countDownWidget(context, taskLevelRewardsEntity),
                Gaps.vGap24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "timed_task_detail_text15".tr,
                      style: ExThemes.textstyle_sm_color2_12(context),
                    ),
                    Text(
                      "timed_task_detail_text16".tr,
                      style: ExThemes.textstyle_sm_color2_12(context),
                    )
                  ],
                ),
                Gaps.vGap8,
                ExProgressIndicator(
                  progressHeight: 4.0,
                  value: controller.calculateProgress(
                      context, taskLevelRewardsEntity),
                ),
                Gaps.vGap8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: controller.getLeftNum(taskLevelRewardsEntity),
                        style: ExThemes.textstyle_sr_color1_12(context),
                      ),
                      TextSpan(
                        text:
                            "/${taskLevelRewardsEntity.targetAmount} ${controller.mTaskInfo.value.targetCoin!}",
                        style: ExThemes.textstyle_sr_color2_12(context),
                      ),
                    ])),
                    Text(
                      controller.getRewardProgressDesc(taskLevelRewardsEntity),
                      style: ExThemes.textstyle_sm_color1_12(context),
                    )
                  ],
                ),
                Gaps.vGap24,
                Container(
                  alignment: Alignment.centerRight,
                  child: ExButton(
                    initialEnable: controller
                        .isLevelItemBtnCanClick(taskLevelRewardsEntity),
                    textColor: controller
                            .isLevelItemBtnCanClick(taskLevelRewardsEntity)
                        ? ExColors.text_4(context)
                        : ExColors.text_2(context),
                    disabledBackgroundColor: ExColors.fill_5(context),
                    backgroundColor: ExColors.main_1(context),
                    text: TaskCenterCommon.getTaskActionStatus(
                        taskLevelRewardsEntity.status),
                    minHeight: 36,
                    minWidth: 140,
                    onPressed: () {
                      controller.btnClick(taskLevelRewardsEntity, index);
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget countDownWidget(
      BuildContext context, TaskLevelRewardsEntity taskLevelRewardsEntity) {
    if (controller.isShowRewardCountDown(taskLevelRewardsEntity)) {
      return Row(
        children: [
          Text(
            "${"timed_task_detail_text17".tr} :",
            style: ExThemes.textstyle_sr_color2_12(context),
          ),
          EXCountDownTimerWidget(
            initTime:
                TaskCenterCommon.getLevelCountDownTime(taskLevelRewardsEntity),
            textStyle: ExThemes.textstyle_sr_color1_12(context),
            isEnd: false,
          ),
        ],
      );
    }
    return Container();
  }
}
