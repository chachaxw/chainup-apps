import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/chart_style.dart';
import 'package:library_kline/k_chart_widget.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/kline/contract_kline_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/ex_kline_loading.dart';

class KLinePage extends BaseStatelessWidget<KlineController> {
  KLinePage({Key? key}) : super(key: key);

  @override
  Color backgroundColor(BuildContext context) {
    return ExColors.fill_1(context);
  }

  @override
  String titleString() => "";

  @override
  bool useLoadSir() => false;

  @override
  bool showTitleBar() => false;

  @override
  Widget buildContent(BuildContext context) {
    ChartStyle.gridRows = 3;
    return Obx(() => Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          KChartWidget(
            key:controller.mKChartKey,
            controller.klineDatas.value,
            controller.infoNames,
            isLine: controller.isLine.value,
            isSmallKline: true,
            isShowOrder: controller.isShowOrder.value,
            mainState: controller.klineMainCurState.value,
            secondaryState: controller.klineSubCurState.value,
            fractionDigits: controller.mSymbolPricePrecision.value,
            waterLogoPath: controller.waterLogoPath.value,
            positionList: controller.positionList,
            entrustList: controller.entrustList,
            isOnlyMainChart: true,
            isShowBottomIndex: false,
            onMore: (){
              controller.getMoreHistoryKlineData();
            },
            onScroll: (b){
              Routes.pushNvEvent(ev: NvEvent.kline_scroll,param: {"isScroll" : b});
            },
            isDay: controller.isSkinDay.value,
          ),
          KlineLoadingDialog(
            isSmallKline: true,
            key: controller.mKLoadingKey,
            mState: controller.KlinePageState.value,
            onReload: (){
              controller.reloadKlineData();
            }
          )
        ],
      ),
    ));
  }
}
