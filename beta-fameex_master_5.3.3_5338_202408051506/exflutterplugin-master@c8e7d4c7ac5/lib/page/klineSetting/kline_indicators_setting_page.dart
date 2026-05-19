import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/klineSetting/kline_indicators_setting_controller.dart';
import '../../routes/routes.dart';
import '../../themes/Themes.dart';
import '../../widgets/gaps.dart';
import 'kline_indicator_manager.dart';

class KlineIndicatorsSettingPage
    extends BaseStatelessWidget<klineIndicatorsSettingController> {
  const KlineIndicatorsSettingPage({Key? key}) : super(key: key);

  @override
  Color backgroundColor(BuildContext context) => ExColors.fill_2(context);

  @override
  bool showTitleBar() => true;

  @override //IndicatorsSetting
  String titleString() => "kline_IndicatorsSetting".tr;

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "kline_algorithm_main".tr,
                style: ExThemes.textstyle_sm_color2_14(context),
              ),
            ),
            Gaps.vGap4,
            _createItemWidget(context, KlineIndicatorType.ma.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.ma});
            }),
            _createItemWidget(context, KlineIndicatorType.ema.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.ema});
            }),
            _createItemWidget(context, KlineIndicatorType.boll.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.boll});
            }),
            Gaps.vGap16,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "kline_algorithm_sub".tr,
                style: ExThemes.textstyle_sm_color2_14(context),
              ),
            ),
            Gaps.vGap4,
            _createItemWidget(context, KlineIndicatorType.macd.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.macd});
            }),
            _createItemWidget(context, KlineIndicatorType.kdj.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.kdj});
            }),
            _createItemWidget(context, KlineIndicatorType.rsi.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.rsi});
            }),
            _createItemWidget(context, KlineIndicatorType.wr.lanKey.tr, () {
              Routes.pushPage(
                  routeName: Routes.KLINE_INDICATORS_MODIFY_PAGE,
                  params: {"type": KlineIndicatorType.wr});
            }),
          ],
        ),
      ),
    );
  }

  Widget _createItemWidget(BuildContext context, String k, onTab) {
    return InkWell(
      onTap: onTab,
      highlightColor: ExColors.fill_3(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              k,
              style: ExThemes.textstyle_sm_color1_16(context),
            ),
            ExIcon.icArrowRight()
          ],
        ),
      ),
    );
  }
}
