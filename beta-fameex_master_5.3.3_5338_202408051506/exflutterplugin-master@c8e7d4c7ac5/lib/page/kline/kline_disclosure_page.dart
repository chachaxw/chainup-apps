
import 'package:chainup_flutter_ex/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/kline/kline_disclosure_controller.dart';
import '../../controllers/kline/kline_introduction_controller.dart';
import '../../controllers/kline/kline_order_book_controller.dart';
import '../../controllers/kline/kline_transaction_record_controller.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../utils/num_utils.dart';
import '../../widgets/gaps.dart';

class KLineDisclosurePage
    extends BaseStatelessWidget<KLineDisclosureController> {
  KLineDisclosurePage({Key? key}) : super(key: key);

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
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      child: _buildOrderBookWidget(context),
    );
  }

  Widget _buildOrderBookWidget(BuildContext context) {
    return Obx(() => MediaQuery.removePadding(    //由于直接使用listview会在顶部留下空白区域，所以使用MediaQuery.removePadding去除空白
        context: context,
        removeTop: true,
        child:  ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
          children: [
            Gaps.vGap20,
            Text(controller.mEtfName.value??"", style: ExThemes.textstyle_sm_color1_16(context),),
            Gaps.vGap12,
            Text(controller.mEtfDesc.value, style: ExThemes.textstyle_sr_color2_12(context).copyWith(  height: 1.3,),),
            Gaps.vGap20,
            _createDetailsItemWidget(context, "etf_info_lever".tr, "${StringUtils.parseString(controller.mEtfNetValueEntity.value.maxLeverValue)}/${StringUtils.parseString(controller.mEtfNetValueEntity.value.realLeverValue)}"),
            _createDetailsItemWidget(context, "etf_text_networth_current".tr,StringUtils.parseString(controller.mEtfNetValueEntity.value.price)),
            _createDetailsItemWidget(context, "etf_info_rules".tr, "etf_notes_auto_lever_time".tr),
            _createDetailsItemWidget(context, "etf_info_rules_no".tr, "etf_notes_manual_lever_time".trParams({"number":StringUtils.parseString(controller.mEtfNetValueEntity.value.maxLeverValue)})),
            _createDetailsItemWidget(context, "sl_str_funds_rate".tr, StringUtils.parseString(controller.mFundRate.value)),
          ],
        ),));
  }


  Widget _createDetailsItemWidget(BuildContext context, String k, String? v,
      {bool? isHighlight = false, bool? isShowCopy = false,onCopy,onHighlightClick}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              margin: EdgeInsets.only(right: 20),
              child: Text(
                k,
                style: ExThemes.textstyle_sr_color2_14(context),
              ),
            ),
          ),
          Expanded(
            flex: 5,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onHighlightClick,
                      child: Text(
                        v ?? "--",
                        style: ExThemes.textstyle_sm_color1_14(context).copyWith(
                            color: isHighlight==true?ExColorsDark.main_color:ExColors.text_color_1(context)
                        ),
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
