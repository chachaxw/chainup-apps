import 'package:chainup_flutter_ex/base/pageWidget/base_stateless_widget.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/brakeven_analysis_asset_allocation.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_cumulative_return.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_daily_income.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_header.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_profits.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_special_note.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_tab_bar.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/breakeven_analysis_total_assets.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:chainup_flutter_ex/utils/sticky_tabbar_delegate.dart';
import 'package:chainup_flutter_ex/widgets/empty_list_page.dart';
import 'package:chainup_flutter_ex/widgets/ex_smart_refresher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoinTransactionBreakevenAnalysisPage
    extends BaseStatelessWidget<CoinTransactionBreakevenAnalysisController> {
  const CoinTransactionBreakevenAnalysisPage({Key? key}) : super(key: key);

  @override
  useLoadSir() => false;

  @override
  String titleString() => "breakeven_analysis_text1".tr;

  @override
  VoidCallback? onBack() {
    Routes.pushNvEvent(ev: NvEvent.closePage);
  }

  @override
  Widget buildContent(BuildContext context) {
    return ExSmartRefresher(
      controller: controller.refreshController,
      onRefresh: () {
        controller.refreshData();
      },
      enablePullUp: false,
      child: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          _headerWidget(context),
          _buildTabBar(context),
          Obx(
            () => _buildPageView(context),
          ),
        ],
      ),
    );
  }

  Widget _headerWidget(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => CoinBreakevenAnalysisHeader(
            currentDayProfitEntity: controller.currentDayProfitEntity.value,
            sevenDayProfitEntity: controller.sevenDayProfitEntity.value,
            thirtyDayProfitEntity: controller.thirtyDayProfitEntity.value,
            accountBalanceEntity: controller.accountBalanceEntity.value,
            defaultCoin: controller.showCoinName.value,
            legalCoinAmount: controller.legalCoinAmount.value,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: StickyTabBarDelegate(
        minHeight: 44,
        maxHeight: 44,
        child: Obx(() => BreakevenAnalysisTabBar(
              currentSelectTab: controller.currentDateIndex.value,
              itemWidth: !controller.isShowCustomDateBtn.value ? 170 : 113,
              isShowCustomDateBtn: controller.isShowCustomDateBtn.value,
              tabData: controller.tabData,
              tabClickCallback: (value) {
                controller.updateCurrentTabIndex(value);
              },
              selectDateCallback: (startTime, endTime) {
                debugPrint("dateStr :$startTime --- $endTime");

                controller.accordCustomDateGetData(startTime, endTime);
              },
              cancelSelectTimeCallback: () {
                controller.cancelSelectTIme();
              },
            )),
      ),
    );
  }

  Widget _buildPageView(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: controller.isLoad.value
            ? 7
            : controller.isEmpty.value
                ? 1
                : 6,
        (context, index) {
          if (controller.isEmpty.value) {
            return const EmptyListWidget(
              iconTopPadding: 200,
            );
          }
          switch (index) {
            case 0:
              return Obx(
                //资产总值
                () => BreakevenAnalysisTotalAssets(
                  totalAssets: controller.totalAssets.value,
                  dataList: controller.totalAssetsList.value,
                  bottomDateList: controller.bottomDateList.value,
                  bottomTagIndexList: controller.bottomTagIndexList.value,
                  chartBottomTitles: controller.chartBottomTitles.value,
                  loadStatus: controller.loadStatus.value,
                  tryCallback: () {
                    controller.refreshData();
                  },
                  maxY: controller.maxAssetY.value,
                  minY: controller.minAssetY.value,
                  minAssetBalance: controller.minAssetBalance.value,
                ),
              );
            case 1:
              return Obx(
                  //累积收益率
                  () => BreakevenAnalysisCumulativeReturn(
                        cumulativeProfitAndLossRatio:
                            controller.cumulativeProfitAndLossRatio.value,
                        btcCumulativeRate: controller.btcCumulativeRate.value,
                        dataList: controller.cumulativeReturnRateList.value,
                        bottomDateList: controller.bottomDateList.value,
                        bottomTagIndexList: controller.bottomTagIndexList.value,
                        chartBottomTitles: controller.chartBottomTitles.value,
                        loadStatus: controller.loadStatus.value,
                        tryCallback: () {
                          controller.refreshData();
                        },
                      ));
            case 2:
              //每日收益
              return Obx(() => BreakevenAnalysisDailyIncome(
                    dailyIncome: controller.dailyIncome.value,
                    dataList: controller.dailyProfitList.value,
                    bottomDateList: controller.bottomDateList.value,
                    bottomTagIndexList: controller.bottomTagIndexList.value,
                    chartBottomTitles: controller.chartBottomTitles.value,
                    loadStatus: controller.loadStatus.value,
                    tryCallback: () {
                      controller.refreshData();
                    },
                  ));
            case 3:

              ///累积收益
              return Obx(() => BreakevenAnalysisProfits(
                    cumulativeIncome: controller.cumulativeIncome.value,
                    dataList: controller.cumulativeReturnList.value,
                    bottomDateList: controller.bottomDateList.value,
                    bottomTagIndexList: controller.bottomTagIndexList.value,
                    chartBottomTitles: controller.chartBottomTitles.value,
                    loadStatus: controller.loadStatus.value,
                    tryCallback: () {
                      controller.refreshData();
                    },
                  ));
            case 4:

              ///资产分布
              return Obx(
                () => BreakevenAnalysisAssetAllocation(
                  list: controller.coinAssetsLocationEntity.value.list,
                  loadStatus: controller.loadStatus.value,
                  marketCoinInfo: controller.marketCoinInfo.value,
                  tryCallback: () {
                    controller.refreshData();
                  },
                ),
              );

            case 5:
              return const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: BreakevenAnalysisSpecialNote(),
              );
            default:
          }
          return Container(
            height: 100,
          );
        },
      ),
    );
  }
}
