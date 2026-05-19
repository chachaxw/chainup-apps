import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/k_chart_widget.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/kline/h_kline_controller.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../routes/routes.dart';
import '../../themes/Themes.dart';
import '../../widgets/ex_kline_loading.dart';

class KLineHorizontalPage extends BaseStatelessWidget<HKlineController> {
  const KLineHorizontalPage({super.key});

  @override
  bool showTitleBar() {
    return false;
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(44, 0, 28, controller.klineBottomPadding),
      color: ExColors.fill_2(context),
      child: Column(
        children: [
          buildTopCoinInfoContent(context),
          buildKlineTimelineContent(context),
          buildBottomContainer(context)
        ],
      ),
    );
  }

  //币对信息涨跌
  Widget buildTopCoinInfoContent(BuildContext context) {
    return Container(
      height: controller.titleBarHeight,
      child: Row(
        children: [
          buildCoinInfo(context),
          GestureDetector(
            child: SizedBox(
              width: 35,
              child: Center(
                child: ExIcon.icKlineZoomout(),
              ),
            ),
            onTap: () {
              // controller.setPortrait();
              Routes.pushNvEvent(ev: NvEvent.close_kline_hpage);
              Get.back();
            },
          )
        ],
      ),
    );
  }

  Widget buildCoinInfo(BuildContext context) {
    return Obx(
      () => Expanded(
        child: Row(
          children: [
            Text(
              controller.mCoinName.value,
              style: ExThemes.textstyle_sb_color1_16(context),
            ),
            Gaps.hGap12,
            Text(
              controller.latestPrice.value,
              style: ExThemes.textstyle_sb_color1_14(context).copyWith(
                  color: ExColors.rise_fall_text_color(
                      controller.latestRoseDou.value)),
            ),
            Gaps.hGap12,
            Text(
              controller.latestLegalPrice.value,
              style: ExThemes.textstyle_sb_color1_14(context),
            ),
            Gaps.hGap12,
            Text(
              controller.latestRose.value,
              style: ExThemes.textstyle_sb_color1_14(context).copyWith(
                  color: ExColors.rise_fall_text_color(
                      controller.latestRoseDou.value)),
            ),
          ],
        ),
      ),
    );
  }

  //k线时间轴
  Widget buildKlineTimelineContent(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double totalWidth = constraints.maxWidth;
      return Container(
        height: controller.klineTimeBarHeight,
        child: Obx(() => buildTimelineList(
            totalWidth, controller.klineTimeCurScale.value, context)),
      );
    });
  }

  Widget buildTimelineList(
      double width, String selectedTime, BuildContext context) {
    final dataList = controller.klineMoreTimeData;

    /// 注意: 判断dataList数组的长度,防止越界溢出
    //第一个少一个左边的间隙
    var itemWidth = width / (dataList.length);
    List<Widget> list = [];
    for (var i = 0; i < dataList.length; i++) {
      final item = dataList[i];
      list.add(_buildTimeItem(item, context, itemWidth, i, dataList.length));
    }
    return ListView(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        // physics: const NeverScrollableScrollPhysics(), // 禁止滚动
        children: list);
  }

  Widget _buildTimeItem(KlineTimeEntity value, BuildContext context,
      double width, int index, int count) {
    return GestureDetector(
      onTap: () {
        controller.switchKlineTimeScale(value);
        print("timeKey = ${value.subTime}");
      },
      child: Container(
        height: double.infinity,
        padding: (index == 0
            ? const EdgeInsets.only(right: 26.0)
            : (index == count - 1
                ? const EdgeInsets.only(left: 26.0)
                : const EdgeInsets.symmetric(horizontal: 26.0))),
        child: Text(
          // textAlign: (index == 0) ? TextAlign.left : (index == count-1?TextAlign.right:TextAlign.center),
          value.showTime,
          style: ExThemes.textstyle_sm_color2_12(context).copyWith(
            color: controller.getKlineTimeScaleColor(context, value),
          ),
        ),
      ),
    );
  }

  //主图容器-左k线和指标
  Widget buildBottomContainer(BuildContext context) {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: ExColors.fill_4(context),
            width: 0.5), //Theme.of(context).colorScheme.fill_x4
      ),
      child: Row(
        children: [
          klinePage(),
          line(context),
          buildKlineIndicatorOperationContent(context)
        ],
      ),
    ));
  }

  //k线指标操作区
  Widget buildKlineIndicatorOperationContent(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double constraintsH = constraints.maxHeight - 0.5;
      double itemHeight =
          constraintsH / (controller.main.length + controller.sub.length);
      return Container(
        width: 46.3,
        child: Column(
          children: [
            Obx(
              () => SizedBox(
                height: itemHeight * controller.main.length,
                child: indicatorList(
                    context, controller.main, controller.mainUIList, "Main"),
              ),
            ),
            Container(
              height: 0.5,
              color: ExColors.fill_4(context),
            ),
            Obx(
              () => SizedBox(
                height: itemHeight * controller.sub.length,
                child: indicatorList(
                    context, controller.sub, controller.secondaryUIList, "Sub"),
              ),
            ),
          ],
        ),
      );
    });
  }

  //主图指标
  Widget line(BuildContext context) {
    return Container(
      color: ExColors.fill_4(context),
      width: 0.5,
    );
  }

  Widget indicatorList(BuildContext context, List<String> originArr,
      List<String> selected, String key) {
    List<Widget> widgetList = [];
    for (var item in originArr) {
      // return
      final w = GestureDetector(
        onTap: () {
          print("click = > item $item");
          if (item == "Main" || item == "Sub") {
            return;
          }
          if (key == "Main") {
            controller.clickMainIndex(item);
          } else {
            controller.clickSecondaryIndex(item);
          }
        },
        child: Text(
          item,
          style: getTextStyle(context, item, key),
        ),
      );
      widgetList.add(w);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widgetList,
    );
  }

  TextStyle getTextStyle(BuildContext context, String item, String key) {
    var textStyle = ExThemes.textstyle_sr_color3_12(context);
    if (item == "Main" || item == "Sub") return textStyle;
    var list = controller.mainUIList.value;
    if (key == "Sub") {
      list = controller.secondaryUIList.value;
    }
    if (item == "VOL") {
      if (controller.isVolUIVisible.value) {
        textStyle = ExThemes.textstyle_sr_color1_12(context);
      } else {
        textStyle = ExThemes.textstyle_sr_color2_12(context).copyWith(
          color: ExColors.special_4(context)
        );
      }
    } else {
      if (list.contains(item)) {
        textStyle = ExThemes.textstyle_sr_color1_12(context);
      } else {
        textStyle = ExThemes.textstyle_sr_color2_12(context).copyWith(
            color: ExColors.special_4(context)
        );
      }
    }

    return textStyle;
  }

  //k线指标操作区
  Widget klinePage() {
    return Obx(
      () => Expanded(
        child: SingleChildScrollView(
          child: Container(
              // color: Colors.red,
              height: controller.klineHeight.value,
              width: double.infinity,
              child: Stack(
                children: [
                  KChartWidget(
                    key: controller.mKChartKey,
                    controller.klineDatas.value,
                    controller.infoNames,
                    isLine: controller.isLine.value,
                    isShowOrder: controller.isShowOrder.value,
                    mainState: controller.klineMainCurState.value,
                    secondaryState: controller.klineSubCurState.value,
                    fractionDigits: controller.mSymbolPricePrecision.value,
                    isShowBottomIndex: false,
                    waterLogoPath: controller.waterLogoPath.value,
                    orientation: Orientation.landscape,
                    positionList: controller.positionList,
                    entrustList: controller.entrustList,
                    onMore: () {
                      controller.getMoreHistoryKlineData();
                    },
                    onScroll: (b) {
                      Routes.pushNvEvent(
                          ev: NvEvent.kline_scroll, param: {"isScroll": b});
                    },
                    isDay: controller.isSkinDay.value,
                  ),
                  KlineLoadingDialog(
                    isSmallKline: false,
                    key: controller.mKLoadingKey,
                    height: controller.mainChartHeight,
                    mState: controller.KlinePageState.value,
                    onReload: () {
                      controller.reloadKlineData();
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
