import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/utils/string_utils.dart';
import 'package:container_tab_indicator/container_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/kline/kline_adjustment_controller.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../widgets/gaps.dart';
import '../../widgets/keep_alive_wrapper.dart';

class KLineAdjustmentPage
    extends BaseStatelessWidget<KLineAdjustmentController> {
  const KLineAdjustmentPage({Key? key}) : super(key: key);

  @override
  bool showTitleBar() => false;

  @override
  bool useLoadSir() => false;

  @override
  Color backgroundColor(BuildContext context) {
    return ExColors.card_bg_color_1(context);
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createTabBar(context),
          Expanded(child: KeepAliveWrapper(
            child: PageView(
              controller: controller.pagerController,
              children: [
                _buildRulesWidget(context),
                _buildRecordWidget(context),
              ],
              onPageChanged: (index) {
                controller.tabController.index = index;
              },
            ),
      ))],
    );
  }

  Widget _createTabBar(BuildContext context) {
    return Container(
      color: ExColors.transparent_color(context),
      height: 28,
      margin: const EdgeInsets.only(top: 16, left: 8, right: 8),
      child: TabBar(
        tabs: controller.mTabListData
            .map((element) => Tab(
                  text: element,
                ))
            .toList(),
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        labelColor: ExColors.text_color_1(context),
        unselectedLabelColor: ExColors.text_color_2(context),
        indicator: ContainerTabIndicator(
            radius: BorderRadius.circular(4.0),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 1),
            color: ExColors.card_bg_color_2(context)),
        controller: controller.tabController,
        onTap: (index) {
          controller.pagerController.jumpToPage(index);
        },
      ),
    );
  }

  Widget _buildRecordWidget(BuildContext context) {
    return Obx(() => controller
        .mEtfPositionRecordEntity.value.etfPositionRecordList?.length != null && controller
        .mEtfPositionRecordEntity.value.etfPositionRecordList!.isNotEmpty ? ListView.builder(
        padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller
            .mEtfPositionRecordEntity.value.etfPositionRecordList?.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItemView(context, index);
        }) : Container(
      padding: const EdgeInsets.only(top: 10),
      color:  ExColors.card_bg_color_1(context),
      child: Center(
        child: ExIcon.icEmptyData(),
      ),
    ));
  }

  Widget _buildItemView(BuildContext context, int index) {
    var mEtfPosition =
        controller.mEtfPositionRecordEntity.value.etfPositionRecordList![index];
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${long2date(mEtfPosition.adjustTime)} ${mEtfPosition.type == 0 ? "market_tab_etf_type_auto_no".tr : "market_tab_etf_type_auto".tr}",
            style: ExThemes.textstyle_sm_color1_16(context),
          ),
          Gaps.vGap12,
          _createDetailsItemWidget(context, "market_tab_etf_tran".tr,
              "${mEtfPosition.netValue} ${mEtfPosition.quote}"),
          _createDetailsItemWidget(
              context, "market_tab_etf_before".tr, mEtfPosition.beforeLever),
          _createDetailsItemWidget(
              context, "market_tab_etf_after".tr, mEtfPosition.afterLever),
        ],
      ),
    );
  }

  Widget _buildRulesWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Obx(() => ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding:
                EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
            children: [
              Wrap(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "etf_notes_lever_next_if".tr,
                      style: ExThemes.textstyle_sm_color1_16(context),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "${"etf_notes_lever_manual".tr}${StringUtils.parseString(controller.mEtfNetValueEntity.value.maxLeverValue)}",
                      style: ExThemes.textstyle_sr_color2_14(context),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: ExThemes.getBoxCardBg2Radius4(context),
                    child: Text(
                      "${"market_tab_etf_leverage_current".tr} ${StringUtils.parseString(controller.mEtfNetValueEntity.value.price)}",
                      style: ExThemes.textstyle_sm_color2_14(context),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "etf_notes_lever_auto".tr,
                      style: ExThemes.textstyle_sr_color2_14(context),
                    ),
                  ),
                  Text(
                    "etf_notes_manual_lever_tran".tr,
                    style: ExThemes.textstyle_sm_color1_16(context),
                  ),
                  Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16),
                      child: Text(
                        "etf_notes_manual_lever_tran_info".tr,
                        style:
                            ExThemes.textstyle_sr_color1_12(context).copyWith(
                          height: 2,
                        ),
                      )),
                ],
              ),
            ],
          )),
    );
  }

  Widget _createDetailsItemWidget(BuildContext context, String k, String? v,
      {bool? isHighlight = false, onHighlightClick}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Text(
              k,
              style: ExThemes.textstyle_sr_color2_14(context),
            ),
          ),
          Expanded(
              child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onHighlightClick,
                  child: Text(
                    v ?? "--",
                    style: ExThemes.textstyle_sm_color1_14(context).copyWith(
                        color: isHighlight == true
                            ? ExColorsDark.main_color
                            : ExColors.text_color_1(context)),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
