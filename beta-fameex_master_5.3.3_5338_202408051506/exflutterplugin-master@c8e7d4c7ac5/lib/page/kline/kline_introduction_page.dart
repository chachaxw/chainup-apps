
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../constants/icon_constant.dart';
import '../../controllers/kline/kline_adjustment_controller.dart';
import '../../controllers/kline/kline_introduction_controller.dart';
import '../../controllers/kline/kline_order_book_controller.dart';
import '../../controllers/kline/kline_transaction_record_controller.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../utils/num_utils.dart';
import '../../widgets/gaps.dart';

class KLineIntroductionPage
    extends BaseStatelessWidget<KLineIntroductionController> {
  KLineIntroductionPage({Key? key}) : super(key: key);

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
    return Obx(() => ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
      children: [
        Gaps.vGap20,
        Text(controller.mKlineCoinIntroduceEntity.value.shortName??"", style: ExThemes.textstyle_sm_color1_16(context),),
        Gaps.vGap10,
        _createDetailsItemWidget(context, "market_text_publishtime".tr, long2dateYmd(controller.mKlineCoinIntroduceEntity.value.publishTime)),
        _createDetailsItemWidget(context, "market_text_publishTotal".tr, controller.mKlineCoinIntroduceEntity.value.publishAmount??"0"),
        _createDetailsItemWidget(context, "market_text_currentTotal".tr, controller.mKlineCoinIntroduceEntity.value.currencyAmount??"0"),
        _createDetailsItemWidget(context, "market_text_coinHomepage".tr, controller.mKlineCoinIntroduceEntity.value.officialUrl,isHighlight:true,onHighlightClick: (){
        controller.GoWebUrl(controller.mKlineCoinIntroduceEntity.value.officialUrl, "market_text_coinHomepage".tr);
        }),
        _createDetailsItemWidget(context, "market_text_blockSearch".tr, controller.mKlineCoinIntroduceEntity.value.blockchainUrl,isHighlight:true,onHighlightClick: (){
          controller.GoWebUrl(controller.mKlineCoinIntroduceEntity.value.blockchainUrl,"market_text_blockSearch".tr);
        }),
        Gaps.vGap20,
        Text("market_text_coinInfo".tr, style: ExThemes.textstyle_sm_color1_16(context),),
        Gaps.vGap12,
        Text(controller.mKlineCoinIntroduceEntity.value.introduction??"", style: ExThemes.textstyle_sr_color1_12(context).copyWith(  height: 2,),),
      ],
    ));
  }


  Widget _createDetailsItemWidget(BuildContext context, String k, String? v,
      {bool? isHighlight = false, bool? isShowCopy = false,onCopy,onHighlightClick}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(right: 20),
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
