import 'package:chainup_flutter_ex/base/pageWidget/base_stateless_widget.dart';
import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/home_page/home_controller.dart';
import 'package:chainup_flutter_ex/page/taskCenter/task_center_index_page.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:flutter/material.dart';

import '../constants/icon_constant.dart';
import '../utils/app_utils.dart';
import '../widgets/gaps.dart';

class HomePage extends BaseStatelessWidget<HomeController> {
  const HomePage({super.key});
  @override
  String titleString() => "Home";

  @override
  bool useLoadSir() => false;

  @override
  bool showTitleBar() => true;

  @override
  bool showBackButton() => true;

  @override
  VoidCallback? onBack() {
    Routes.pushNvEvent(ev: NvEvent.closePage);
  }

  @override
  Widget? rightWidget(BuildContext context) {
    return !AppUtil.isDebug()
        ? Gaps.empty
        : GestureDetector(
            onTap: () {
              Routes.pushPage(routeName: Routes.DEBUG);
            },
            child: Container(
              width: 20,
              height: 20,
              child: ExIcon.icDialogTips(),
            ),
          );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _itemWidget(
            pageName: "任务中心",
            onPressed: () {
              Routes.pushPage(routeName: Routes.TASK_CENTER_INDEX_PAGE);
            },
            context: context,
          ),
          _itemWidget(
            pageName: "币币盈亏分析",
            onPressed: () {
              Routes.pushPage(
                  routeName: Routes.COIN_TRANSACTION_BREAKEVEN_ANALYSIS_PAGE);
            },
            context: context,
          ),
          _itemWidget(
            pageName: "杠杆盈亏分析",
            onPressed: () {
              Routes.pushPage(
                  routeName: Routes.MARGIN_TRADE_BREAKEVEN_ANALYSIS_PAGE);
            },
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _itemWidget({
    required String pageName,
    required Function onPressed,
    required BuildContext context,
  }) {
    return TextButton(
      onPressed: () {
        onPressed.call();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(ExColors.main_1(context))),
      child: Text(
        pageName,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
