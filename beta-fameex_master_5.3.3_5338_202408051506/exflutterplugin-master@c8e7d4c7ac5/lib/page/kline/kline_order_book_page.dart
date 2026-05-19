import 'package:chainup_flutter_ex/ext/String_ext.dart';
import 'package:chainup_flutter_ex/utils/date_format_util.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import 'package:library_kline/utils/number_util.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/kline/kline_order_book_controller.dart';
import '../../themes/Themes.dart';
import '../../utils/num_utils.dart';
import '../../widgets/gaps.dart';

class KLineOrderBookPage extends BaseStatelessWidget<KLineOrderBookController> {
  const KLineOrderBookPage({Key? key}) : super(key: key);

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
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: _buildOrderBookWidget(context),
    );
  }

  Widget _buildOrderBookWidget(BuildContext context) {
    return Obx(() => ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
          children: [
            Gaps.vGap12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${"cl_volume_str".tr}(${controller.mQuantityUnit})",
                  style: ExThemes.textstyle_sr_color3_10(context),
                ),
                Text(
                  "${"cl_price_str".tr}(${controller.mPriceUnit.value})",
                  style: ExThemes.textstyle_sr_color3_10(context),
                ),
                Text(
                  "${"cl_volume_str".tr}(${controller.mQuantityUnit})",
                  style: ExThemes.textstyle_sr_color3_10(context),
                )
              ],
            ),
            Gaps.vGap8,
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(child: _buildHandicapItemLeft(context)),
                Expanded(child: _buildHandicapItemRight(context)),
              ],
            )
          ],
        ));
  }

  Widget _buildHandicapItemLeft(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Obx(() => SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: double.infinity,
                    width: controller.getDepthWidthTx(
                        controller.buysDepthdatas, index, context),
                    color: ExColors.rise_fall_color(1).withOpacity(0.15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _obtainItemDepth(controller, index, true, isVol: true),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ExThemes.textstyle_sr_color1_12(context),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Get.width * 0.35
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            _obtainItemDepth(controller, index, true, isVol: false),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ExThemes.textstyle_sr_color_red_12(context)
                                .copyWith(
                                    color: ExColors.rise_fall_color(1)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

  Widget _buildHandicapItemRight(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Obx(() => SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: double.infinity,
                    width: controller.getDepthWidthTx(
                        controller.sellsDepthdatas, index, context),
                    color: ExColors.rise_fall_color(-1).withOpacity(0.15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Get.width * 0.35
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Text(
                            _obtainItemDepth(controller, index, false, isVol: false),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ExThemes.textstyle_sr_color_red_12(context)
                                .copyWith(
                                    color: ExColors.rise_fall_color(-1)),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _obtainItemDepth(controller, index, false, isVol: true),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ExThemes.textstyle_sr_color1_12(context),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

  String _obtainItemDepth(KLineOrderBookController controller, int index, bool isBuy, {bool isVol = true}) {
    final bool isContractKline = controller.isContractKline.value;
    final int multiplierPrecision = isContractKline ?
                                    NumberUtil.getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier) :
                                    controller.mSymbolAmountPrecision;
    final int pricePrecision = controller.mSymbolPricePrecision;
    final tick = isBuy ? controller.buysDepthdatas.value[index] : controller.sellsDepthdatas.value[index];
    if (tick.price.isNegative) {
      return "--";
    }
    if (tick.price==0) {
      return "--";
    }
    if (isVol) {
      if(tick.vol<=-1) return "--";
      double volBuffer = double.parse(controller.VolDisplayConversion(tick.vol));
      if (isContractKline) {
        if(KLineCoinInfo.isCoin){
          volBuffer = volBuffer * double.parse(KLineCoinInfo.mMultiplier);
        }
        final vol = DecimalUtils.showSNormal(volBuffer, digits: KLineCoinInfo.isCoin ? multiplierPrecision : 0, isShowThous: true);
        return vol;
      } else {
        // 非合约
        final vol = DecimalUtils.showSNormal(volBuffer, digits: multiplierPrecision , isShowThous: true);
        return vol;
      }
    } else {
      if(tick.price<=-1) return "--";
      final String price = DecimalUtils.showSNormal(tick?.price, digits: pricePrecision, isShowThous: true);
      return price.isNullOrEmpty() ? "--" : price;
    }
  }

}
