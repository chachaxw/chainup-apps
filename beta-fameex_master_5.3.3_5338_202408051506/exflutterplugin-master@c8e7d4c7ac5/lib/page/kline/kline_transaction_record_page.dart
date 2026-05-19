import 'package:chainup_flutter_ex/ext/String_ext.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import 'package:library_kline/utils/number_util.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/kline/kline_transaction_record_controller.dart';
import '../../themes/Themes.dart';
import '../../utils/date_format_util.dart';
import '../../utils/num_utils.dart';
import '../../widgets/gaps.dart';

class KLineTransactionRecordPage
    extends BaseStatelessWidget<KLineTransactionRecordController> {
  const KLineTransactionRecordPage({Key? key}) : super(key: key);

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
    return Obx(() => Column(
          children: [
            Gaps.vGap12,
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      "cl_newtrade_text4".tr,
                      textAlign: TextAlign.left,
                      style: ExThemes.textstyle_sr_color3_10(context),
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      "${"cl_price_str".tr}(${controller.mPriceUnit.value})",
                      textAlign: TextAlign.center,
                      style: ExThemes.textstyle_sr_color3_10(context),
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      "${"cl_volume_str".tr}(${controller.mQuantityUnit.value})",
                      textAlign: TextAlign.right,
                      style: ExThemes.textstyle_sr_color3_10(context),
                    ))
              ],
            ),
            Gaps.vGap8,
            Obx(() => Expanded(child: _buildOrderRecordsItem(context))),
          ],
        ));
  }

  Widget _buildOrderRecordsItem(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
      itemCount: controller.dealRecorddatas.value.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var itemData = controller.dealRecorddatas.value[index];
        return SizedBox(
          height: 28,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    long2datehns(itemData.ts),
                    textAlign: TextAlign.left,
                    style: ExThemes.textstyle_sr_color1_12(context),
                  )),
              Expanded(
                  flex: 1,
                  child: Text(
                      _obtainRecordData(controller, index, false),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ExThemes.textstyle_sr_color_red_12(context).copyWith(
                        color: itemData.side == "SELL"
                            ? ExColors.rise_fall_color(1)
                            : ExColors.rise_fall_color(-1)),
                  )),
              Expanded(
                  flex: 1,
                  child: Text(
                    _obtainRecordData(controller, index, true),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ExThemes.textstyle_sr_color1_12(context),
                  )),
            ],
          ),
        );
      },
    );
  }

  String _obtainRecordData(KLineTransactionRecordController controller, int index, bool isVol) {
    final bool isContractKline = controller.isContractKline.value;
    final int multiplierPrecision = isContractKline ?
                                    NumberUtil.getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier) :
                                    controller.mSymbolAmountPrecision.value;
    final int pricePrecision = controller.mSymbolPricePrecision.value;
    final itemValue = controller.dealRecorddatas.value[index];
    if (isVol) {
      if(itemValue.vol==null) return "--";
      double itemVol = double.tryParse(controller.VolDisplayConversion(itemValue.vol))??0;
      if (isContractKline) {
        if(KLineCoinInfo.isCoin){
          itemVol = itemVol * double.parse(KLineCoinInfo.mMultiplier);
        }
        final String vol = DecimalUtils.showSNormal(itemVol, digits: KLineCoinInfo.isCoin ? multiplierPrecision : 0, isShowThous: true);
        return vol.isNullOrEmpty() ? "--" : vol;
      } else {
        // 非合约
        final String vol = DecimalUtils.showSNormal(itemVol, digits: multiplierPrecision, isShowThous: true);
        return vol.isNullOrEmpty() ? "--" : vol;
      }
    } else {
      final String price = DecimalUtils.showSNormal(itemValue.price, digits: pricePrecision, isShowThous: true);
      return price.isNullOrEmpty() ? "--" : price;
    }
  }
}
