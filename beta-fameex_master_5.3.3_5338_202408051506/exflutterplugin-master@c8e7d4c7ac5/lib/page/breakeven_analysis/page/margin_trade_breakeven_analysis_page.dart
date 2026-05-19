import 'package:chainup_flutter_ex/base/pageWidget/base_stateless_widget.dart';
import 'package:chainup_flutter_ex/models/bottom_sheet_entity.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/ex_trade_analysis_tab_bar_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/margin_trade_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/margin_trade_breakeven_analysis_tab_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/ex_trade_analysis_tab_bar.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:chainup_flutter_ex/widgets/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'margin_trade_breakeven_analysis_tab_page.dart';

class MarginTradeBreakevenAnalysisPage
    extends BaseStatelessWidget<MaiginTradeBreakevenAnalysisController> {
  const MarginTradeBreakevenAnalysisPage({super.key});

  @override
  useLoadSir() => false;

  @override
  VoidCallback? onBack() {
    Routes.pushNvEvent(ev: NvEvent.closePage);
  }

  @override
  Widget titleWidget(BuildContext context) {
    return Obx(
      () => ExMaiginTradeAnalysisTabBar(
        titleList: controller.tabData,
        defaultSelectIndex: controller.selectedTabIndex.value,
        changedCallback: (value) {
          controller.updateCurrentTabIndex(value);
        },
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return _buildPageView(context);
  }

  Widget _buildPageView(BuildContext context) {
    return Obx(() {
      return KeepAliveWrapper(
        keepAlive: true,
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller.mPagerController,
          onPageChanged: (index) {
            controller.selectedTabIndex.value = index;
            ExTradeAnalysisTabBarController tabBarController = Get.find();
            tabBarController.updateCurrentTabIndex(index);

            BottomSheetEntity element = controller.tabData[index];

            MarginTradeBreakevenAnalysisTabController
                marginTradeBreakevenAnalysisTabController =
                Get.find(tag: element.extrasStr);
            marginTradeBreakevenAnalysisTabController.onRefreshData();
          },
          children: _buildPageItem(context),
        ),
      );
    });
  }

  List<Widget> _buildPageItem(BuildContext context) {
    List<Widget> listPage = [];
    for (var i = 0; i < controller.tabData.length; i++) {
      BottomSheetEntity element = controller.tabData[i];
      Get.lazyPut(
          () => MarginTradeBreakevenAnalysisTabController(element.extrasStr),
          tag: element.extrasStr);

      listPage.add(
          MarginTradeBreakevenAnalysisTabPage(element.extrasStr.toString(), i));
    }
    return listPage;
  }
}
