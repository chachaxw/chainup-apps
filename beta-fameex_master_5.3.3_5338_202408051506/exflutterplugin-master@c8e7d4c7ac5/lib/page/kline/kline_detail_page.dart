import 'dart:async';
import 'dart:math';

import 'package:chainup_flutter_ex/ext/String_ext.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/utils/date_format_util.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_block_selector.dart';
import 'package:chainup_flutter_ex/widgets/ex_smart_refresher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:library_kline/depth_chart.dart';
import 'package:library_kline/k_chart_widget.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../caseview/showcase.dart';
import '../../caseview/showcase_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/kline/contract_kline_controller.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../routes/routes.dart';
import '../../utils/sticky_tabbar_delegate.dart';
import '../../widgets/ExTextHighlight.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/ex_kline_loading.dart';
import '../../widgets/ex_tab_indicator.dart';
import '../../widgets/gaps.dart';
import '../../widgets/keep_alive_wrapper.dart';
import 'main_state.dart';

class KLineDetailPage extends BaseStatelessWidget<KlineController> {
  KLineDetailPage({Key? key}) : super(key: key);
  Timer? mTimer = null;
  double safeBottomPaddingHeight = 0.0;
  late KumiPopupWindow? mKumiPopupWindow;
  KumiPopupWindow? mGuideKumiPopupWindow = null;

  @override
  Color backgroundColor(BuildContext context) {
    return ExColors.card_bg_color_1(context);
  }

  @override
  String titleString() => "";

  @override
  bool showTitleBar() => true;

  @override
  bool isCustomTitleBar() => true;

  @override
  bool useLoadSir() => false;

  @override
  VoidCallback? onBack() {
    controller.closePage();
  }

  @override
  Widget? backWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.closePage(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        height: double.maxFinite,
        color: Colors.transparent,
        child: ExIcon.icBack(),
      ),
    );
  }

  @override
  Widget? titleWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routes.pushNvEvent(ev: NvEvent.kline_coin_sidebar);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        height: 44.0,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 18,
              child: Gaps.vLine,
            ),
            Gaps.hGap8,
            ExIcon.icSidebar(),
            Gaps.hGap4,
            Obx(() => Flexible(
                  child: Text(
                    controller.mCoinName.value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: ExThemes.textstyle_sm_color1_18(context),
                  ),
                )),
            Obx(
              () => _buildMarketTag(context, controller.leverMultiple.value),
            ),
            Obx(
              () => _buildMarketTag(context, controller.marketTag.value),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? rightWidget(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Routes.pushNvEvent(ev: NvEvent.kline_coin_share);
          },
          child: Container(
            color: Colors.transparent,
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(8),
            child: ExIcon.icShare(),
          ),
        ),
        GestureDetector(
          onTap: () {
            Routes.pushNvEvent(ev: NvEvent.kline_coin_collect);
            controller.isCollect.value = !controller.isCollect.value;
          },
          child: Container(
            color: Colors.transparent,
            width: 16,
            height: 32,
            margin: const EdgeInsets.only(left: 4, right: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Obx(() => controller.isCollect.value
                ? ExIcon.icFavorites()
                : ExIcon.icNoFavorites()),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return ShowCaseWidget(
        builder: Builder(
          builder: (context) => Stack(
            children: [
              ExSmartRefresher(
                controller:controller.refreshController,
                onRefresh: (){
                  if(controller.isInitRefresh){
                     Routes.pushNvEventFuture(ev: NvEvent.kline_detail_page_refreshing)
                       .then((value) {
                          if(value is bool){
                            if(value){
                              controller.refreshController.refreshCompleted();
                            }else{
                              controller.refreshController.refreshFailed();
                            }
                          }else if(value is String){
                            if(value=="1"){
                              controller.refreshController.refreshCompleted();
                            }else{
                              controller.refreshController.refreshFailed();
                            }
                          }
                       });
                  }else{
                    Future.delayed(const Duration(milliseconds: 800),(){
                      controller.refreshController.refreshCompleted();
                    });
                  }
                },
                child: CustomScrollView(
                  controller: controller.scrollViewControl,
                  slivers: [
                    _buildSliverView(context),
                    _buildTabBar(context),
                    _buildPageView(context)
                  ],
                ),
              ),
              _buildBottomCtrl(context),
            ],
          ),
        )
    );
  }

  _buildSliverView(BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(
          children: [
            Obx(() => Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0,top: 9.0),
                  width: double.infinity,
                  child: _buildCoinTicker(context),
                )),
            _buildFundRate(context),
            //合约k线时间刻度
            _buildTimeCtrl(context),
            Gaps.hLineHalf,
            _buildKlineDepth(context),
            Obx(() =>
                controller.isShowDepth.value ? const SizedBox() : Gaps.hLineHalf),
            Obx(() => _buildEtfRiskNote(context)),
            Container(
              color: ExColors.fill_2(context),
              height: 12.0,
            ),
          ],
        )
    );
  }

  /// K线和深度图
  Widget _buildKlineDepth(BuildContext context) {
    return Obx(() => Container(
          child: controller.isOpen.value
              ? _buildCountdown(context)
              : controller.isShowDepth.value
                  ? Column(
                      children: [
                        Container(
                          height: Get.width * 0.907,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 4),
                          color: ExColors.fill_2(context),
                          // decoration: BoxDecoration(
                          // gradient: LinearGradient(
                          //     begin: Alignment.topCenter,
                          //     end: Alignment.bottomCenter,
                          //     colors: [
                          //       ExColors.kline_bg_top_gradient_color(context),
                          //       ExColors.kline_bg_bottom_gradient_color(context),
                          //     ]),
                          // ),
                          child: Obx(() => DepthChart(
                                controller.bidDatas.value,
                                controller.askDatas.value,
                                symbolPricePrecision:
                                    controller.mSymbolPricePrecision.value,
                              )),
                        )
                      ],
                    )
                  : Container(
                      height: controller.klineHeight.value,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
                      color: ExColors.fill_2(context),
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //       begin: Alignment.topCenter,
                      //       end: Alignment.bottomCenter,
                      //       colors: [
                      //         ExColors.kline_bg_top_gradient_color(context),
                      //         ExColors.kline_bg_bottom_gradient_color(context),
                      //       ]),
                      // ),
                      child: Obx(() => Stack(children: [
                            KChartWidget(
                              key: controller.mKChartKey,
                              controller.klineDatas.value,
                              controller.infoNames,
                              isLine: controller.isLine.value,
                              isShowOrder: controller.isShowOrder.value,
                              mainState: controller.klineMainCurState.value,
                              secondaryState: controller.klineSubCurState.value,
                              fractionDigits:
                                  controller.mSymbolPricePrecision.value,
                              waterLogoPath: controller.waterLogoPath.value,
                              positionList: controller.positionList,
                              entrustList: controller.entrustList,
                              onMore: () {
                                controller.getMoreHistoryKlineData();
                              },
                              onScroll: (b) {
                                Routes.pushNvEvent(
                                    ev: NvEvent.kline_scroll,
                                    param: {"isScroll": b});
                              },
                              isDay: controller.isSkinDay.value,
                            ),
                            KlineLoadingDialog(
                              isSmallKline: false,
                              key: controller.mKLoadingKey,
                              height: controller.KlinePageState.value ==
                                      KlineState.LOADING
                                  ? controller.mainChartHeight
                                  : controller.klineHeight.value,
                              mState: controller.KlinePageState.value,
                              onReload: () {
                                controller.reloadKlineData();
                              },
                            ),
                          ])),
                    ),
        ));
  }

  /// etf risk风险提示
  Widget _buildEtfRiskNote(BuildContext context) {
    if (controller.etfRisk.value.isEmpty) {
      return const SizedBox();
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 16,  right: 16,top: 8),
       padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
       decoration: ExThemes.getBoxMain3Radius4(context),
        child: ExTextHighlight(
          controller.etfRisk.value,
            controller.mHighlightStr,
            ExThemes.textstyle_sm_color2_12(context).copyWith(height: 1.3),
           ExThemes.textstyle_sm_color1_12(context).copyWith(color: ExColors.main_1(context),height: 1.3),
        ),
      );
    }
  }

  /// market tag
  Widget _buildMarketTag(BuildContext context, String text) {
    if (text.trim().isNullOrEmpty()) {
      return Gaps.empty;
    }
    return Row(
      children: [
        Gaps.hGap4,
        Container(
          decoration: BoxDecoration(
            color: ExColors.main_color_3(context),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: Text(
            text,
            style: ExThemes.textstyle_sm_color2_12(context)
                .copyWith(color: ExColors.main_4(context)),
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildCoinTicker(BuildContext context) {
    // final amount24 = double.tryParse(controller.amount24.value);
    // final String amount24Value =
    //     amount24 != null ? NumberUtil.volFormat(amount24) : "--";

    return Row(
      children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.latestPrice.value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: ExThemes.textstyle_sm_color_red_28(context).copyWith(
                  color: ExColors.rise_fall_text_color(
                      controller.latestRoseDou.value)),
            ),
            Gaps.vGap4,
            Row(
              children: [
                Text(
                  controller.latestLegalPrice.value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: ExThemes.textstyle_sr_color2_14(context),
                ),
                Gaps.hGap4,
                Text(
                  controller.latestRose.value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: ExThemes.textstyle_sr_color_red_14(context).copyWith(
                    color: ExColors.rise_fall_text_color(
                      controller.latestRoseDou.value,
                    ),
                  ),
                )
              ],
            ),
          ],
        )),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildTickerItem(context, "cp_extra_text111".tr),
                // _buildTickerItem(context, "cp_extra_text112".tr),
                // _buildTickerItem(context, "cp_24vol_label".tr),
                _buildTickerVerticalItem(context, "cp_extra_text111".tr,
                    controller.high24Price.value),
                Gaps.vGap8,
                _buildTickerVerticalItem(context, "cp_extra_text112".tr,
                    controller.low24Price.value),
              ],
            ),
            Gaps.hGap12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildTickerItem(context, controller.high24Price.value,
                //     isTicker: true),
                // _buildTickerItem(context, controller.low24Price.value,
                //     isTicker: true),
                // _buildTickerItem(context, controller.vol24.value,
                //     isTicker: true),
                _buildTickerVerticalItem(
                    context, "cp_24vol_label".tr, controller.vol24.value,
                    unit: controller.mQuantityUnit.value),
                Gaps.vGap8,
                _buildTickerVerticalItem(
                    context, "cp_24amount_label".tr, controller.amount24.value,
                    unit: controller.mPriceUnit.value),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTickerItem(BuildContext context, String value,
      {bool isTicker = false}) {
    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          value,
          maxLines: 1,
          style: isTicker
              ? ExThemes.textstyle_sm_color1_12(context)
              : ExThemes.textstyle_sm_color2_12(context),
        ),
      ),
    );
  }

  Widget _buildTickerVerticalItem(
      BuildContext context, String title, String value,
      {String unit = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12,
          child: Row(
            children: [
              Text(
                title,
                maxLines: 1,
                style: ExThemes.textstyle_sr_color2_10(context),
              ),
              unit.isNullOrEmpty()
                  ? Gaps.empty
                  : Text(
                      "($unit)",
                      maxLines: 1,
                      style: ExThemes.textstyle_sr_color2_10(context),
                    ),
            ],
          ),
        ),
        Gaps.vGap4,
        SizedBox(
          height: 12,
          child: Text(
            value,
            maxLines: 1,
            style: ExThemes.textstyle_sr_color1_10(context),
          ),
        )
      ],
    );
  }

  /// 资金费率&&当前净值
  Widget _buildFundRate(BuildContext context) {
    return Obx(() => controller.isContractKline.value
        ? Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8.0),
            padding:
                const EdgeInsets.only(left: 14, right: 14, bottom: 8, top: 8),
            decoration: ShapeDecoration(
              color: ExColors.card_bg_color_2(context),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(4.0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ExIcon.icMarkPrice(),
                    Gaps.hGap6,
                    Text(
                      "cp_overview_text20".tr,
                      style: ExThemes.textstyle_sr_color2_12(context),
                    ),
                    Gaps.hGap4,
                    Text(
                      controller.mMarkPrice.value,
                      style: ExThemes.textstyle_sr_color1_12(context),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "cp_overview_text26".tr,
                      style: ExThemes.textstyle_sr_color2_10(context),
                    ),
                    Gaps.hGap4,
                    Text(
                      controller.mFundRate.value,
                      style: ExThemes.textstyle_sr_color2_10(context),
                    )
                  ],
                )
              ],
            ),
          )
        : Gaps.empty);
  }

  Widget _buildTimeCtrl(BuildContext context) {
    return Obx(() {
      return Container(
        key: controller.moreTimeCtrlKey,
        margin: const EdgeInsets.only(left: 6, right: 16, bottom: 2, top: 8),
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: controller.klineDefaultTimeData.length + 2,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    var totalLength =
                        controller.klineDefaultTimeData.length + 2;
                    if (index == (totalLength - 1)) {
                      return _buildDepthItem("kline_action_depth".tr, context);
                    } else if (index == (totalLength - 2)) {
                      return _buildMoreTimeItem(
                          "common_action_showMore".tr, context);
                    } else {
                      return _buildTimeItem(
                          controller.klineDefaultTimeData[index], context);
                    }
                  }),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showMoreKlineCtrl(context, 1);
                  },
                  child: ShowGuide(
                    controller.timeCtrlSettingGuideKey,
                    context,
                    Container(
                      height: 36,
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: controller.isMoreTargetOpen.value
                          ? ExIcon.icKlineToolsCheck()
                          : ExIcon.icKlineTools(),
                    ),
                  ),
                ),
                Gaps.hGap2,
                GestureDetector(
                  onTap: () {
                    Routes.pushNvEvent(ev: NvEvent.kline_enlarge);
                    var result = Routes.pushPageBackParams(
                        routeName: Routes.KLINE_HORIZONTAL);
                    result.then((value) {
                      controller.onResumeHandler();
                    });
                  },
                  child: Container(
                    height: 36,
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(left: 6, right: 2),
                    child: ExIcon.icKlineFullscreen(),
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  _buildTabBar(BuildContext context) {
    return Obx(() => SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: StickyTabBarDelegate(
              minHeight: 44,
              maxHeight: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44.0,
                    width: double.infinity,
                    color: ExColors.card_bg_color_1(context),
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      tabs: controller.orderTypeTabListData.value
                          .map((element) => Tab(
                                text: element,
                              ))
                          .toList(),
                      isScrollable: true,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                      labelStyle: ExThemes.textstyle_sm_color1_16(context),
                      unselectedLabelStyle:
                          ExThemes.textstyle_sm_color1_16(context),
                      labelColor: ExColors.text_color_1(context),
                      unselectedLabelColor: ExColors.text_color_2(context),
                      indicator: TabSizeIndicator(
                        wantWidth: 24,
                        borderSide: BorderSide(
                          width: 4,
                          color: ExColors.main_1(context),
                        ),
                      ),
                      dividerHeight: 0.0,
                      controller: controller.orderTypeTabController,
                      onTap: (index) {
                        controller.orderTypePagerController.jumpToPage(index);
                      },
                    ),
                  ),
                  // Gaps.hLineHalf,
                ],
              )),
        ));
  }

  Widget _buildPageView(BuildContext context) {
    if (safeBottomPaddingHeight == 0.0) safeBottomPaddingHeight = Get.mediaQuery.padding.bottom;
    return Obx(() => SliverPadding(
      padding: EdgeInsets.only(bottom: 60.0 + safeBottomPaddingHeight),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
            height: Get.height - Get.statusBarHeight - 88.0,
            child: KeepAliveWrapper(
              child: PageView(
                controller: controller.orderTypePagerController,
                children: controller.orderTypeTabListPage.value,
                onPageChanged: (index) {
                  controller.orderTypeTabController.index = index;
                  controller.switchPageView(index);
                },
              ),
            ),
        ),
      ),
    ));
  }

  Widget _buildMoreTimeCtrl() {
    return StatefulBuilder(
        key: GlobalKey(),
        builder: (popContext, popState) {
          return Obx(
            () => Container(
              width: MediaQuery.of(popContext).size.width,
              color:
                  ExColorsDark.fill_7.withOpacity(controller.overOpacity.value),
              height: 1000,
              alignment: Alignment.topLeft,
              child: buildIntervalsDialogContent(popContext),
            ),
          );
        });
  }

  //Customize Intervals
  Widget buildIntervalsDialogContent(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Obx(() => Container(
                width: double.infinity,
                color: ExColors.card_bg_color_1(context),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: controller.moreTimeDialogHeight.value,
                child: Stack(
                  children: [
                    Visibility(
                      visible: controller.isShowOtherLayout.value &&
                          controller.moreTimeDialogHeight.value >=
                              controller.mMoreTimeAnimationEndDefaultValue,
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 5,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.5 / 1,
                            children: _buildMoreTimeList(
                                controller.showKlineMoreTimeOtherData.length,
                                context),
                          ),
                          Gaps.hLineHalf,
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "kline_Intervals1".tr,
                                    style: ExThemes.textstyle_sm_color2_14(
                                        context),
                                  ),
                                  ExIcon.icArrowRight()
                                ],
                              ),
                            ),
                            onTap: () {
                              controller.isShowOtherLayout.value = false;
                              controller.selectShowKTimeList.clear();
                              controller.selectShowKTimeList
                                  .addAll(controller.showKlineTimeList);
                              controller.mMoreTimeAnimationController2
                                  .forward();
                            },
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (!controller.isShowOtherLayout.value) &&
                          controller.moreTimeDialogHeight.value >=
                              controller.mMoreTimeAnimation2EndDefaultValue,
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 5,
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 12.0),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.5 / 1,
                            children: _buildCustomizeMoreTimeList(
                                controller.klineMoreTimeData.length, context),
                          ),
                          Gaps.hLineHalf,
                          Container(
                            margin: const EdgeInsets.only(top: 12.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "kline_Intervals2".tr +
                                  " ${controller.selectShowKTimeList.length}/5",
                              textAlign: TextAlign.start,
                              style: ExThemes.textstyle_sm_color2_12(context),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: ExButton(
                                      minHeight: 40,
                                      text: "kline_reset".tr,
                                      backgroundColor: ExColors.fill_3(context),
                                      textColor: ExColors.text_1(context),
                                      onPressed: () =>
                                          resetSelectTimeToStorage(context),
                                    )),
                                Gaps.hGap10,
                                Expanded(
                                    flex: 1,
                                    child: ExButton(
                                      minHeight: 40,
                                      text: "kline_pop_dialog_confirm".tr,
                                      textColor: controller
                                                  .selectShowKTimeList.length ==
                                              5
                                          ? ExColors.text_4(context)
                                          : ExColors.text_2(context),
                                      backgroundColor: controller
                                                  .selectShowKTimeList.length ==
                                              5
                                          ? ExColors.btn_pressed_color(context)
                                          : ExColors.btn_enabled_color(context),
                                      onPressed: () =>
                                          setSelectTimeToStorage(context),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: GestureDetector(
                  onTap: () {
                    mKumiPopupWindow?.dismiss(context);
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                  )))
        ],
      ),
    );
  }

  void setSelectTimeToStorage(BuildContext context) {
    if (controller.selectShowKTimeList.length != 5) return;
    controller.showKlineTimeList.clear();
    controller.showKlineTimeList.addAll(controller.selectShowKTimeList);
    ExStorageUtils.putObject(ExStorageUtils.KLINE_TIME_SHOW_LIST,
        controller.selectShowKTimeList.join(","));
    Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex, param: {
      ExStorageUtils.KLINE_TIME_SHOW_LIST:
          controller.selectShowKTimeList.join(",")
    });
    controller.changeShowKlineTimeVisible();
    controller.changeMoreOtherKlineTime();
    mKumiPopupWindow?.dismiss(context);
  }

  void resetSelectTimeToStorage(BuildContext context) {
    controller.selectShowKTimeList.clear();
    controller.selectShowKTimeList.addAll(controller.showKlineTimeList);
  }

  bool isShowTime(String currentTime) {
    for (var iSelectTime in controller.selectShowKTimeList) {
      if (iSelectTime == currentTime) {
        return true;
      }
    }
    return false;
  }

  bool getCurKTimeIsClick() {
    var currentClickkTimeName = controller.klineTimeCurScale.value;
    for (var cTime in controller.showKlineMoreTimeOtherData) {
      if ((cTime.isLine ?? false) && controller.isLine.value) {
        return true;
      }
      if (cTime.subTime == currentClickkTimeName) {
        return true;
      }
    }
    return false;
  }

  List<Widget> _buildMoreTimeList(int count, BuildContext context) {
    return List<Widget>.generate(count, (int index) {
      var curTime =
          controller.isLine.value ? "line" : controller.klineTimeCurScale.value;
      var isClickTime =
          controller.showKlineMoreTimeOtherData[index].subTime == curTime;
      return GestureDetector(
        onTap: () {
          controller.switchKlineTimeScale(
              controller.showKlineMoreTimeOtherData[index]);
          mKumiPopupWindow?.dismiss(context);
        },
        child: Container(
          height: 24.0.h,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
              color: ExColors.card_bg_color_2(context),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: isClickTime
                          ? ExColorsLight.main_color
                          : ExColors.card_bg_color_2(context),
                      width: 0.5,
                      style: BorderStyle.solid),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(2.0),
                  ))),
          child: Text(
            controller.showKlineMoreTimeOtherData[index].showTime,
            style: ExThemes.textstyle_sm_color2_12(context).copyWith(
              color: isClickTime
                  ? ExColors.text_color_1(context)
                  : ExColors.text_color_2(context),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildCustomizeMoreTimeList(int count, BuildContext context) {
    return List<Widget>.generate(
      count,
      (int index) => GestureDetector(
        onTap: () {
          // controller.switchKlineTimeScale(controller.klineMoreTimeData[index]);
          // mKumiPopupWindow?.dismiss(context);
          var clickTime = controller.klineMoreTimeData[index].subTime;
          if (isShowTime(clickTime)) {
            controller.selectShowKTimeList.remove(clickTime);
            debugPrint(
                "当前选中的controller.selectShowKTimeList>>>${controller.selectShowKTimeList}");
          } else {
            if (controller.selectShowKTimeList.length >= 5) {
              showNativeToast("kline_Intervals3".tr);
              // Fluttertoast.showToast(msg: "kline_Intervals3".tr,gravity: ToastGravity.CENTER,backgroundColor:ExColors.toast_bg_color(context));
              return;
            }
            controller.selectShowKTimeList.add(clickTime);
          }
        },
        child: Obx(
          () => Container(
            height: 24.0,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
                color: ExColors.card_bg_color_2(context),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: isShowTime(
                                controller.klineMoreTimeData[index].subTime)
                            ? ExColorsLight.main_color
                            : ExColors.card_bg_color_2(context),
                        width: 0.5,
                        style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(2.0),
                    ))),
            child: Text(
              controller.klineMoreTimeData[index].showTime,
              style: ExThemes.textstyle_sm_color2_12(context).copyWith(
                color: isShowTime(controller.klineMoreTimeData[index].subTime)
                    ? ExColors.text_color_1(context)
                    : ExColors.text_color_2(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIndexList(
      int index, List<String> data, String type, BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () {
            if (type == "main") {
              if (controller.klineMainCurState.value ==
                  MainState.values[index]) {
                controller.klineMainCurState.value = MainState.NONE;
              } else {
                controller.klineMainCurState.value = MainState.values[index];
              }
            } else {
              if (controller.klineSubCurState.value ==
                  SecondaryState.values[index]) {
                controller.klineSubCurState.value = SecondaryState.NONE;
              } else {
                controller.klineSubCurState.value =
                    SecondaryState.values[index];
              }
            }
            LogUtil.e(MainState.NONE.name);
          },
          child: Container(
            height: 24,
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
                color: ExColors.card_bg_color_2(context),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: (type == "main"
                                ? controller.klineMainCurState.value ==
                                    MainState.values[index]
                                : controller.klineSubCurState.value ==
                                    SecondaryState.values[index])
                            ? ExColorsLight.main_color
                            : ExColors.card_bg_color_2(context),
                        width: 0.5,
                        style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(2.0),
                    ))),
            child: Text(
              data[index],
              style: (type == "main"
                      ? controller.klineMainCurState.value ==
                          MainState.values[index]
                      : controller.klineSubCurState.value ==
                          SecondaryState.values[index])
                  ? ExThemes.textstyle_sm_color1_12(context)
                  : ExThemes.textstyle_sm_color2_12(context),
            ),
          ),
        ));
  }

  Widget _buildMoreTimeItem(String value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        var value = controller.arrowController.value;
        if (value == 0.5) {
          controller.arrowController.animateTo(0);
        } else {
          controller.arrowController.animateTo(0.5);
        }
        showMoreKlineCtrl(context, 0);
      },
      child: ShowGuide(
        controller.moreTimeCtrlGuideKey,
        context,
        Container(
          height: 36,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Obx(
                () => Text(
                    getCurKTimeIsClick()
                        ? (controller.subTime2ShowTime(
                                controller.getKlineTimeScaleTX()) ??
                            "")
                        : "common_action_showMore".tr,
                    style: ExThemes.textstyle_sm_color2_12(context).copyWith(
                      color: getCurKTimeIsClick() ||
                              controller.isMoreTimeOpen.value
                          ? ExColors.text_color_1(context)
                          : ExColors.special_4(context),
                    )),
              ),
              Gaps.hGap2,
              Obx(
                () => controller.isMoreTimeOpen.value
                    ? ExIcon.icDropDownSelected()
                    : ExIcon.icDropDown(),
                // RotationTransition(
                //   turns: controller.arrowAnimation,
                //   child: SizedBox(
                //      height: 12,
                //      width: 12,
                //      child:
                //   )
                // ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeItem(KlineTimeEntity value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // controller.klineTimeCurScale.value = value.subTime;
        // controller.isLine.value = value.isLine ?? false;
        // controller.klineTimeCurId.value = value.id;
        // ExStorageUtils.setKlineTimeId(value.id);
        controller.switchKlineTimeScale(value);
      },
      child: Container(
        height: 36,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: Obx(
          () => Text(
            value.showTime,
            style: ExThemes.textstyle_sm_color2_12(context).copyWith(
              color: controller.getKlineTimeScaleColor(context, value),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepthItem(String value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.isShowDepth.value = !controller.isShowDepth.value;
        controller.klineTimeCurScale.value = "";
      },
      child: Container(
        height: 36,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 10, right: 4),
        alignment: Alignment.center,
        child: Obx(
          () => Text(
            value,
            style: ExThemes.textstyle_sm_color2_12(context).copyWith(
                color: controller.isShowDepth.value
                    ? ExColors.text_color_1(context)
                    : ExColors.special_4(context)),
          ),
        ),
      ),
    );
  }

  void showMoreKlineCtrl(BuildContext context, int type) {
    final targetRenderBox = (controller.moreTimeCtrlKey.currentContext
        ?.findRenderObject() as RenderBox);
    mKumiPopupWindow = showPopupWindow(
      context,
      gravity: KumiPopupGravity.centerTop,
      curve: Curves.easeInOutCubic,
      bgColor: Colors.grey.withOpacity(0),
      clickOutDismiss: true,
      clickBackDismiss: true,
      customAnimation: true,
      customPop: false,
      customPage: false,
      targetRenderBox: targetRenderBox,
      //needSafeDisplay: true,
      underStatusBar: false,
      underAppBar: true,
      offsetX: 0,
      offsetY: targetRenderBox.size.height + 0.5,
      duration: const Duration(milliseconds: 100),
      onShowStart: (pop) {
        print("showStart");
        controller.opacityAnimationController.forward();
        if (type == 1) {
          controller.mAnimationController.forward();
        } else {
          controller.mMoreTimeAnimationController.forward();
        }
      },
      onShowFinish: (pop) {
        print("showFinish");
        if (type == 0) {
          controller.isMoreTimeOpen.value = true;
        }
        if (type == 1) {
          controller.isMoreTargetOpen.value = true;
        }
      },
      onDismissStart: (pop) {
        print("dismissStart");
        controller.opacityAnimationController.reverse();
        if (type == 1) {
          controller.mAnimationController.reverse();
        } else {
          controller.mMoreTimeAnimationController.reverse();
        }
      },
      onDismissFinish: (pop) {
        print("dismissFinish");
        controller.arrowController.animateTo(0);
        controller.mMoreTimeAnimationController2.reverse();
        controller.isMoreTimeOpen.value = false;
        controller.isMoreTargetOpen.value = false;
        controller.isShowOtherLayout.value = true;
      },
      onClickOut: (pop) {
        print("onClickOut");
      },
      onClickBack: (pop) {
        print("onClickBack");
      },
      childFun: (pop) {
        return type == 0
            ? _buildMoreTimeCtrl()
            : _buildMoreIndexCtrlV2(context);
      },
    );
  }

  /// 主图指标 副图指标
  Widget _buildMoreIndexCtrl(BuildContext context) {
    return StatefulBuilder(
        key: GlobalKey(),
        builder: (popContext, popState) {
          return GestureDetector(
            onTap: () {
              mKumiPopupWindow?.dismiss(popContext);
            },
            child: Container(
              width: MediaQuery.of(popContext).size.width,
              color: ExColors.main_pop_bg_color(popContext).withOpacity(0.4),
              height: 1000,
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    Gaps.hLineHalf,
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        width: MediaQuery.of(popContext).size.width,
                        color: ExColors.card_bg_color_1(popContext),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "kline_algorithm_set".tr,
                              style: ExThemes.textstyle_sm_color2_12(context),
                            ),
                            Gaps.vGap12,
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "kline_algorithm_main".tr,
                                    style: ExThemes.textstyle_sm_color1_12(
                                        context),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    height: 24,
                                    child: ListView.builder(
                                      itemCount: 2,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _buildMoreIndexList(
                                            index,
                                            controller.klineMainIndexData,
                                            "main",
                                            context);
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Gaps.vGap16,
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "kline_algorithm_sub".tr,
                                    style: ExThemes.textstyle_sm_color1_12(
                                        context),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    height: 24,
                                    child: ListView.builder(
                                      itemCount: 4,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _buildMoreIndexList(
                                            index,
                                            controller.klineSubMainIndexData,
                                            "sub",
                                            context);
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Gaps.vGap16,
                            // Gaps.hLine,
                            // Gaps.vGap16,
                            // Text(
                            //   "Order Display",
                            //   style: ExThemes.textstyle_sm_color2_12(context),
                            // ),
                            // Gaps.vGap12,
                            // ExCheckbox(
                            //     str: "Order History",
                            //     value: true,
                            //     onChanged: (value){
                            //       // selCheckFun(value!);
                            //     }),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// 指标设置
  Widget _buildMoreIndexCtrlV2(BuildContext context) {
    return StatefulBuilder(
        key: GlobalKey(),
        builder: (popContext, popState) {
          return GestureDetector(
            onTap: () {
              mKumiPopupWindow?.dismiss(popContext);
            },
            child: Obx(
              () => Container(
                width: MediaQuery.of(popContext).size.width,
                color: ExColorsDark.fill_7
                    .withOpacity(controller.overOpacity.value),
                height: 1000,
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Obx(
                        () => Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            width: MediaQuery.of(popContext).size.width,
                            height: controller.indexDialogHeight.value,
                            color: ExColors.card_bg_color_1(popContext),
                            child: Visibility(
                              visible:
                                  controller.isContractKline.value?controller.indexDialogHeight.value >= 160.0:controller.indexDialogHeight.value >= 120.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      height: 40.0.h,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "kline_IndicatorsSetting".tr,
                                            style: ExThemes.textstyle_sm_color2_12(context),
                                          ),
                                          ExIcon.icArrowRight()
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      mKumiPopupWindow?.dismiss(popContext,
                                          onFinish: (KumiPopupWindow pop) {
                                        Routes.pushPage(
                                            routeName: Routes
                                                .KLINE_INDICATORS_SETTING_PAGE);
                                      });
                                    },
                                  ),
                                  Gaps.hLineHalf,
                                  SizedBox(height: 12.0.h),
                                  GestureDetector(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("cp_contract_order_display".tr,
                                          style: ExThemes.textstyle_sm_color2_12(context),
                                        ),
                                        Gaps.hGap2,
                                        ExIcon.icHint()
                                      ],
                                    ),
                                    onTap: () {
                                      Get.showDialogList();
                                      // Get.showCommonDialog(
                                      //     title: "cp_contract_order_history".tr,
                                      //     content: "kline_order_history".tr,
                                      //     posiText: "cp_extra_text28".tr,
                                      //     negaVisible: false);
                                    },
                                  ),
                                  SizedBox(height: 12.0.h),
                                  _buildOrderDisplayContent(context)
                                ],
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildOrderDisplayContent(BuildContext context){
    final canUseWidth = Get.width - 32.0 - 8.0;
    return Obx(
      ()=> Wrap(
        spacing:8.0,
        runSpacing: 8.0,
        children: controller.orderDisplayTextList.map((e) =>
            !controller.isContractKline.value && e!="cp_contract_order_history".tr? const SizedBox():
            ExBlockSelector(
              isSelected: controller.orderDisplayTextSelectors.contains(e),
              width: canUseWidth/2,
              height: 32.0.h,
              child: Align(alignment:Alignment.center,child: Text(e,style: ExThemes.textstyle_hm_color1_14(context),textAlign:TextAlign.center)),
              onTap: () {
                var visible = false;
                if(controller.orderDisplayTextSelectors.contains(e)){
                  visible = false;
                  controller.orderDisplayTextSelectors.remove(e);
                }else{
                  visible = true;
                  controller.orderDisplayTextSelectors.add(e);
                }
                controller.switchOrderDisplay(e,visible);
              },
            )
        ).toList(),
      ),
    );
  }

  Widget _buildBottomCtrl(BuildContext context) {
    if (safeBottomPaddingHeight == 0.0)
      safeBottomPaddingHeight = Get.mediaQuery.padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: ExColors.tabbar_bg_color(context),
        height: 60 + safeBottomPaddingHeight,
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: max(safeBottomPaddingHeight, 10)),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: ExButton(
                            minHeight: 40,
                            text: "contract_action_buy".tr,
                            backgroundColor: ExColors.rise_fall_color(1),
                            onPressed: () {
                              Routes.pushNvEvent(ev: NvEvent.kline_trading_buy);
                            },
                          )),
                      Gaps.hGap10,
                      Expanded(
                          flex: 1,
                          child: ExButton(
                            minHeight: 40,
                            text: "contract_action_sell".tr,
                            backgroundColor: ExColors.rise_fall_color(-1),
                            onPressed: () {
                              Routes.pushNvEvent(
                                  ev: NvEvent.kline_trading_sell);
                            },
                          ))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  ShowGuide(GlobalKey<State<StatefulWidget>> mGuideKey, BuildContext context,
      Widget tagChild) {
    if (controller.guideList.isEmpty) return const SizedBox();
    var guide = controller.guideList.first;
    if (mGuideKey == controller.timeCtrlSettingGuideKey) {
      guide = controller.guideList.last;
    }

    return Showcase(
        key: mGuideKey,
        disableMovingAnimation: true,
        overlayOpacity: 0,
        // titlePadding:EdgeInsets.only(top: 8.0,left: 16.0,right: 16.0),
        // descriptionPadding:EdgeInsets.only(top: 8,bottom: 5.0,right: 16.0),
        descriptionAlignment: TextAlign.end,
        // titleAlignment: TextAlign.end,
        tooltipBackgroundColor: ExColors.main_color(context),
        titleTextStyle: ExThemes.textstyle_sm_color1_14(context)
            .copyWith(color: ExColors.text_4(context)),
        descTextStyle: ExThemes.textstyle_sm_color2_12(context)
            .copyWith(color: ExColors.text_4(context)),
        textColor: ExColors.text_4(context),
        title: guide.title,
        message: guide.message,
        description: 'guide_3'.tr,
        disableDefaultTargetGestures: true,
        disposeOnTap: true,
        onToolTipClick: () {
          // debugPrint('点击本身销毁onToolTipClick>>>');
          saveGuide(mGuideKey);
          ShowCaseWidget.of(context)
              .startShowCase([controller.timeCtrlSettingGuideKey]);
        },
        onTargetClick: () {
          // debugPrint('点击本身销毁');
          saveGuide(mGuideKey);
          ShowCaseWidget.of(context)
              .startShowCase([controller.timeCtrlSettingGuideKey]);
        },
        onBarrierClick: () {
          // debugPrint('点击外部销毁');
          saveGuide(mGuideKey);
          ShowCaseWidget.of(context)
              .startShowCase([controller.timeCtrlSettingGuideKey]);
        },
        child: tagChild);
  }

  void saveGuide(GlobalKey key) {
    if (key == controller.timeCtrlSettingGuideKey) {
      print("guideFlag = saveGuide");
      ExStorageUtils.putObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS, "1");
      //兼容安卓
      Routes.pushNvEvent(ev: NvEvent.kline_guide_flag, param: {"flagStr": "1"});
    }
  }

  Widget _buildCountdown(BuildContext context) {
    return Obx(() => Container(
      height: 429,
      color: ExColors.fill_6(context),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.mCoinName.value,
            style: ExThemes.textstyle_hm_color1_20(context),
          ),
          Gaps.vGap8,
          Text(
            "${"trade_new_coin_open_kline_open_time".tr} ${long2date(controller.openTime.value)}",
            style: ExThemes.textstyle_hm_color2_14(context),
          ),
          Gaps.vGap32,
          Text(
            "trade_new_coin_open_kline_countdown".tr,
            style: ExThemes.textstyle_hm_color1_14(context),
          ),
          Gaps.vGap16,
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      ExIcon.icCountdownBj(),
                      Text(
                        (controller.timeDifference.value.inDays).toString().padLeft(2, '0'),
                        style: ExThemes.textstyle_hm_color1_12(context)
                            .copyWith(fontSize: 28),
                      ),
                      Container(
                        height: 2,
                        width: 60,
                        color: ExColors.fill_2(context),
                      )
                    ],
                  )),
              Text(":",style: ExThemes.textstyle_hm_color1_16(context),),
              Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      ExIcon.icCountdownBj(),
                      Text(
                        (controller.timeDifference.value.inHours%24).toString().padLeft(2, '0'),
                        style: ExThemes.textstyle_hm_color1_12(context)
                            .copyWith(fontSize: 28),
                      ),
                      Container(
                        height: 2,
                        width: 60,
                        color: ExColors.fill_2(context),
                      )
                    ],
                  )),
              Text(":",style: ExThemes.textstyle_hm_color1_16(context),),
              Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      ExIcon.icCountdownBj(),
                      Text(
                        (controller.timeDifference.value.inMinutes%60).toString().padLeft(2, '0'),
                        style: ExThemes.textstyle_hm_color1_12(context)
                            .copyWith(fontSize: 28),
                      ),
                      Container(
                        height: 2,
                        width: 60,
                        color: ExColors.fill_2(context),
                      )
                    ],
                  )),
              Text(":",style: ExThemes.textstyle_hm_color1_16(context),),
              Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      ExIcon.icCountdownBj(),
                      Text(
                        (controller.timeDifference.value.inSeconds%60).toString().padLeft(2, '0'),
                        style: ExThemes.textstyle_hm_color1_12(context)
                            .copyWith(fontSize: 28),
                      ),
                      Container(
                        height: 2,
                        width: 60,
                        color: ExColors.fill_2(context),
                      )
                    ],
                  )),
            ],
          ),
          Gaps.vGap4,
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(child:Text("trade_new_coin_open_kline_days".tr,style: ExThemes.textstyle_hm_color2_12(context),textAlign:TextAlign.center)),
              Expanded(child:Text("trade_new_coin_open_kline_hours".tr,style: ExThemes.textstyle_hm_color2_12(context),textAlign:TextAlign.center)),
              Expanded(child:Text("trade_new_coin_open_kline_mins".tr,style: ExThemes.textstyle_hm_color2_12(context),textAlign:TextAlign.center)),
              Expanded(child:Text("trade_new_coin_open_kline_secs".tr,style: ExThemes.textstyle_hm_color2_12(context),textAlign:TextAlign.center)),
            ],
          )
        ],
      ),
    ));
  }
}
