import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/margin_trade_breakeven_analysis_tab_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_tab_bar.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/margin_breakeven_analysis_cumulative_return.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/margin_trade_breakeven_analysis_Item.dart';
import 'package:chainup_flutter_ex/utils/sticky_tabbar_delegate.dart';
import 'package:chainup_flutter_ex/widgets/empty_list_page.dart';
import 'package:chainup_flutter_ex/widgets/ex_smart_refresher.dart';
import 'package:chainup_flutter_ex/widgets/loading_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarginTradeBreakevenAnalysisTabPage extends StatefulWidget {
  final String? type;
  final int index;
  const MarginTradeBreakevenAnalysisTabPage(this.type, this.index, {super.key});

  @override
  State<MarginTradeBreakevenAnalysisTabPage> createState() =>
      _MarginTradeBreakevenAnalysisTabPageState();
}

class _MarginTradeBreakevenAnalysisTabPageState
    extends State<MarginTradeBreakevenAnalysisTabPage> {
  late MarginTradeBreakevenAnalysisTabController controller;

  @override
  void initState() {
    controller = Get.find(tag: widget.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExSmartRefresher(
      controller: controller.refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: () {
        controller.onRefreshData();
      },
      onLoading: () {
        controller.loadMore();
      },
      child: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          _headerWidget(context),
          _buildTabBar(context, controller),
          _buildPageView(context),
        ],
      ),
    );
  }

  Widget _headerWidget(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 16,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context,
      MarginTradeBreakevenAnalysisTabController controller) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: StickyTabBarDelegate(
          minHeight: 44,
          maxHeight: 44,
          child: Obx(
            () => BreakevenAnalysisTabBar(
              currentSelectTab: controller.currentDateIndex.value,
              isShowCustomDateBtn: controller.isShowCustomDateBtn.value,
              itemWidth: controller.isShowCustomDateBtn.value
                  ? (MediaQuery.of(context).size.width - 36) / 3.0
                  : (MediaQuery.of(context).size.width - 36) / 2.0,
              tabData: controller.tabData,
              tabClickCallback: (value) {
                controller.updateCurrentTabIndex(value);
              },
              selectDateCallback: (startTime, endTime) {
                controller.accordCustomDateGetData(startTime, endTime);
              },
              cancelSelectTimeCallback: () {
                controller.cancelSelectTIme();
              },
            ),
          )),
    );
  }

  Widget _buildPageView(BuildContext context) {
    return Obx(
      () => SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: controller.isLoad.value
              ? 1
              : controller.isEmpty.value
                  ? 1
                  : controller.listViewData.length + 1,
          (context, index) {
            // if (controller.isLoad.value) {
            //   return const ExLoadingPlaceholderView();
            // }
            if (controller.isEmpty.value) {
              return const EmptyListWidget(
                iconTopPadding: 200,
              );
            }

            if (index == 0) {
              return Obx(
                () => MarginBreakevenAnalysisCumulativeReturn(
                  showDropdownButton: true,
                  needTransformToBTC: controller.needTransformToBTC.value,
                  selectedValue: controller.currentCoin.value,
                  profitNum: controller.profitNum.value,
                  profitRatio: controller.profitRatio.value,
                  profitTime: controller.profitTime.value,
                  chartBottomTitles: controller.chartBottomTitles.value,
                  chartLeftTitles: controller.chartLeftTitles.value,
                  chartRightTitles: controller.chartRightTitles.value,
                  sourceDataList:
                      controller.userAssetProfitLossDataLeverList.value,
                  bottomDateList: controller.bottomDateList.value,
                  btcPrecision: controller.btcPrecision.value,
                  selectCoinCallback: (value) {
                    if (value.isNotEmpty) {
                      controller.selectedCoin(value);
                    }
                  },
                  loadStatus: controller.loadStatus.value,
                  tryCallback: () {
                    controller.onRefreshData();
                  },
                  showAmount: controller.showAmount.value,
                  showAmountChanged: () {
                    controller.changeShowAmountStatus();
                  },
                ),
              );
            }

            return Obx(() => MarginTradeBreakevenAnalysisItem(
                  index - 1,
                  controller.listViewData[index - 1],
                  controller.needTransformToBTC.value,
                  showAmount: controller.showAmount.value,
                ));
          },
        ),
      ),
    );
  }
}
