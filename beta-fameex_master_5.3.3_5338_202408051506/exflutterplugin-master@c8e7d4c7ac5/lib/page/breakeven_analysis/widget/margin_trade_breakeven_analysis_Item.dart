import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/icon_constant.dart';
import '../../../models/user_asset_profit_loss_data_lever_entity.dart';

class MarginTradeBreakevenAnalysisItem extends StatelessWidget {
  final int currentIndex;
  final UserAssetProfitLossDataLeverEntity? entity;
  final bool showBTCAmount;
  final bool? showAmount;

  const MarginTradeBreakevenAnalysisItem(
      this.currentIndex, this.entity, this.showBTCAmount,
      {this.showAmount = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: (currentIndex == 0) ? 0.0 : 1.0),
      child: Column(
        children: children(context),
      ),
    );
  }

  List<Widget> children(BuildContext context) {
    return List.generate(5, (index) {
      if (index == 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 6),
          child: Row(
            children: [
              Text(
                entity?.curDateStr.toString() ?? "",
                style: ExThemes.textstyle_hm_color1_14(context),
              )
            ],
          ),
        );
      }
      return Container(
        margin: EdgeInsets.only(top: 5, bottom: index == 4 ? 32 : 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showTip(_getTitle(index - 1), context);
              },
              child: Row(
                children: [
                  Text(
                    _getTitle(index - 1),
                    style: ExThemes.textstyle_hr_color2_12(context),
                  ),
                  Gaps.hGap4,
                  (index == 1 || index == 2)
                      ? BreakevenAnalysisIcon.hintIcon()
                      : Container(),
                ],
              ),
            ),
            const Spacer(),
            Text(
              showAmount! ? _getAmount(index - 1) : "******",
              style: ExThemes.textstyle_hm_color1_12(context),
            ),
          ],
        ),
      );
    });
  }

  String _getTitle(int index) {
    String title = "";
    switch (index) {
      case 0:
        title = "breakeven_analysis_text21".tr;
        break;
      case 1:
        title = "breakeven_analysis_text22".tr;

        break;
      case 2:
        title = "breakeven_analysis_text23".tr;

        break;
      case 3:
        title = "breakeven_analysis_text24".tr;
        break;
      default:
    }
    return title;
  }

  String _getAmount(int index) {
    String amount = "0.00";

    switch (index) {
      case 0: //日收益额
        amount = showBTCAmount
            ? isNull(entity?.curProfitBTC)
            : isNull(entity?.curProfitUSDT);
        break;
      case 1: //累计盈亏
        amount = showBTCAmount
            ? isNull(entity?.cumulativeProfitBTC)
            : isNull(entity?.cumulativeProfitUSDT);
        break;
      case 2: //净划入
        amount = showBTCAmount
            ? isNull(entity?.pureComeBTC)
            : isNull(entity?.pureComeUSDT);
        break;
      case 3: //账户权益
        amount = showBTCAmount
            ? isNull(entity?.accountEquityBTC)
            : isNull(entity?.accountEquityUSDT);
        break;
      default:
    }

    return amount.toString();
  }

  String isNull(String? value) {
    if (value == null) {
      if (showBTCAmount) {
        return "0.00000000";
      } else {
        return "0.00";
      }
    } else {
      return value;
    }
  }

  void showTip(String? title, BuildContext context) {
    if (title == "breakeven_analysis_text21".tr) {
      Get.showCommonDialog(
        title: title ?? "",
        content: "breakeven_analysis_text36".tr,
        negaVisible: false,
        okBtnTextColor: ExColors.text_4(context),
      );
    } else if (title == "breakeven_analysis_text22".tr) {
      Get.showCommonDialog(
        title: title ?? "",
        content: "breakeven_analysis_text37".tr,
        negaVisible: false,
        okBtnTextColor: ExColors.text_4(context),
      );
    }
  }
}
