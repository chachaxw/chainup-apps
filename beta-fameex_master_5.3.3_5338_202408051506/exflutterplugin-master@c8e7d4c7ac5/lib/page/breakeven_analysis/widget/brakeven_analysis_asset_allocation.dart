import 'package:chainup_flutter_ex/models/coin_assets_location_entity.dart';
import 'package:chainup_flutter_ex/models/market_coin_entity.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/utils/date_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../themes/Themes.dart';
import '../../../widgets/gaps.dart';
import 'chart_title.dart';

class BreakevenAnalysisAssetAllocation extends StatelessWidget {
  final List<SingleCoinAssetsLocationEntity>? list;
  final ExLoadingStatus? loadStatus;
  final VoidCallback? tryCallback;
  final MarketCoinInfo? marketCoinInfo;

  BreakevenAnalysisAssetAllocation({
    required this.list,
    this.loadStatus,
    this.tryCallback,
    this.marketCoinInfo,
    super.key,
  });
  int touchedIndex = -1;

  bool isEmpty() {
    return list == null || list!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.vGap28,
          ChartTitle(
            title: "breakeven_analysis_text29".tr,
          ),
          Gaps.vGap4,
          Text(
            EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
                format: "yyyy-MM-dd"),
            style: ExThemes.textstyle_hr_color2_12((context)),
          ),
          Gaps.vGap34,
          loadStatus == ExLoadingStatus.loading ||
                  loadStatus == ExLoadingStatus.failed
              ? Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                  child: LoadingView(
                    loadingStatus: loadStatus,
                    tryCallback: () {
                      tryCallback?.call();
                    },
                  ),
                )
              : _chartView(context),
          Gaps.vGap40,
        ],
      ),
    );
  }

  Widget _chartView(BuildContext context) {
    return Row(
      children: [
        Gaps.hGap8,
        Container(
          width: 120,
          alignment: Alignment.centerLeft,
          height: 120,
          child: _pieChartWidget(context),
        ),
        const Spacer(),
        Flexible(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.only(right: 5),
            child: SizedBox(
              height: 120,
              child: _coinList(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coinList(BuildContext context) {
    if (isEmpty()) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: ExColors.special_4(context),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(1),
                  ),
                ),
              ),
              Gaps.hGap8,
              Text(
                "breakeven_analysis_text11".tr,
                style: ExThemes.textstyle_hm_color1_12(context),
              ),
            ],
          ),
          Gaps.vGap8,
          Text(
            "breakeven_analysis_text13".tr,
            style: ExThemes.textstyle_hr_color2_12(context),
          ),
          // Spacer(),
          // Container(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _coinCategoryList(context),
      );
    }
  }

  String getShowName(String sourceCoinName) {
    String showName = "";
    Map? coinData = marketCoinInfo?.coinList;
    if (coinData != null && coinData[sourceCoinName] != null) {
      Map coin = coinData[sourceCoinName];
      showName = coin["showName"];
    } else {
      showName = sourceCoinName;
    }
    return showName;
  }

  List<Widget> _coinCategoryList(BuildContext context) {
    List<Widget> coinList = [];
    for (var i = 0; i < list!.length; i++) {
      SingleCoinAssetsLocationEntity entity = list![i];
      String num = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
          entity.proportion, 2,
          needAddZero: true);
      Color color = entity.coinSymbol == "other" ? getColor(6) : getColor(i);
      Widget widget = Row(
        children: [
          Container(
            height: 4,
            width: 4,
            color: color,
          ),
          Gaps.hGap4,
          Text(
            getShowName(entity.coinSymbol ?? ""),
            style: ExThemes.textstyle_hr_color2_10(context),
          ),
          const Spacer(),
          GetBuilder<CoinTransactionBreakevenAnalysisController>(
            builder: (controller) {
              return Obx(
                () => Text(
                  controller.showAmount.value ? "$num%" : "******",
                  style: ExThemes.textstyle_hr_color1_10(context),
                ),
              );
            },
          ),
        ],
      );
      coinList.add(widget);
      coinList.add(Gaps.vGap8);
    }
    return coinList;
  }

  Widget _pieChartWidget(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // setState(() {
            //   if (!event.isInterestedForInteractions ||
            //       pieTouchResponse == null ||
            //       pieTouchResponse.touchedSection == null) {
            //     touchedIndex = -1;
            //     return;
            //   }
            //   touchedIndex =
            //       pieTouchResponse.touchedSection!.touchedSectionIndex;
            // });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections:
            isEmpty() ? showingNoneSections(context) : showingSections(context),
      ),
    );
  }

  List<PieChartSectionData> showingNoneSections(BuildContext context) {
    return List.generate(1, (i) {
      return PieChartSectionData(
        color: ExColors.fill_3(context),
        value: 100,
        title: '40%',
        radius: 20,
        showTitle: false,
      );
    });
  }

  List<PieChartSectionData> showingSections(BuildContext context) {
    bool showTitle = false;
    List<PieChartSectionData> tempList = [];
    for (var i = 0; i < list!.length; i++) {
      SingleCoinAssetsLocationEntity entity = list![i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 12.0 : 10.0;
      final radius = isTouched ? 40.0 : 20.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      TextStyle textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: ExColors.text_4(context),
        shadows: shadows,
      );
      Color color = entity.coinSymbol == "other" ? getColor(6) : getColor(i);

      String title = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
          entity.proportion, 2);
      PieChartSectionData pieSection = PieChartSectionData(
        color: color,
        value: entity.proportion,
        showTitle: showTitle,
        title: "$title%",
        radius: radius,
        titleStyle: textStyle,
      );

      tempList.add(pieSection);
    }
    return tempList;
  }

  Color getColor(int index) {
    Color color = PieChartColors.color6;
    switch (index) {
      case 0:
        color = PieChartColors.color1;
        break;
      case 1:
        color = PieChartColors.color2;
        break;
      case 2:
        color = PieChartColors.color3;
        break;
      case 3:
        color = PieChartColors.color4;
        break;
      case 4:
        color = PieChartColors.color5;
        break;
      case 5:
        color = PieChartColors.color6;
        break;
      default:
        color = PieChartColors.color6;
    }
    return color;
  }
}
