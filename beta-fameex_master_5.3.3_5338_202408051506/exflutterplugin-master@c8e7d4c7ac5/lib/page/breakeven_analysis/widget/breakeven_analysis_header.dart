import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/date_picker/src/date_format.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../models/account_balance_entity.dart';
import '../../../models/query_profit_and_loss_entity.dart';
import '../../../themes/Themes.dart';
import '../../../utils/decimal_utils.dart';
import '../breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';

class CoinBreakevenAnalysisHeader extends StatelessWidget {
  final SingleCoinAssetsChartEntity? currentDayProfitEntity;

  final SingleCoinAssetsChartEntity? sevenDayProfitEntity;
  final SingleCoinAssetsChartEntity? thirtyDayProfitEntity;
  final AccountBalanceEntity? accountBalanceEntity;
  final String? defaultCoin;
  final String? legalCoinAmount;
  const CoinBreakevenAnalysisHeader({
    required this.currentDayProfitEntity,
    required this.sevenDayProfitEntity,
    required this.thirtyDayProfitEntity,
    required this.accountBalanceEntity,
    required this.defaultCoin,
    this.legalCoinAmount = "0.00",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String coin = defaultCoin ?? "BTC";
    double account =
        double.tryParse(accountBalanceEntity?.totalBalance ?? "0") ?? 0.00;
    String total = DecimalUtils.formateNum(accountBalanceEntity?.totalBalance,
        isShowThous: true);

    return GetBuilder<CoinTransactionBreakevenAnalysisController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gaps.vGap17,
            GestureDetector(
              onTap: () {
                controller.showAmount.value = !controller.showAmount.value;
                Routes.pushNvEvent(
                    ev: NvEvent.showOrHideAssetsAmountEvent,
                    param: {
                      "showOrHideAssetsAmount":
                          controller.showAmount.value ? "1" : "0",
                      "pageType": "1"
                    });
              },
              child: Row(
                children: [
                  Text(
                    "${"breakeven_analysis_text5".tr}($coin)",
                    style: ExThemes.textstyle_hm_color2_12((context)),
                  ),
                  Gaps.hGap4,
                  Container(
                    color: ExColors.fill_2(context),
                    padding: const EdgeInsets.only(right: 4),
                    // height: 20,
                    // width: 30,
                    child: Obx(
                      () => controller.showAmount.value
                          ? BreakevenAnalysisIcon.eyeIcon()
                          : BreakevenAnalysisIcon.assetsEyeoff(),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.vGap6,
            Obx(() => Text(
                  controller.showAmount.value
                      ? account == 0
                          ? coin.contains("BTC")
                              ? "0.00000000"
                              : "0.00"
                          : total
                      : "******",
                  style: ExThemes.textstyle_hm_color1_28((context)),
                )),
            Gaps.vGap4,
            Obx(
              () => Text(
                controller.showAmount.value
                    ? "≈ ${controller.mCurrencyCoin.value}${DecimalUtils.formateNum(legalCoinAmount, digits: 2, isShowThous: true)}"
                    : "******",
                style: ExThemes.textstyle_hm_color2_12((context)),
              ),
            ),
            Gaps.vGap20,
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: _item(0, context, controller),
                ),
                Flexible(
                  flex: 1,
                  child: _item(1, context, controller),
                ),
                Flexible(
                  flex: 1,
                  child: _item(2, context, controller),
                ),
              ],
            ),
            Gaps.vGap40,
          ],
        );
      },
    );
  }

  Widget _item(int index, BuildContext context,
      CoinTransactionBreakevenAnalysisController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (index == 0) {
              Get.showCommonDialog(
                title: _itemTitle(0),
                content: "breakeven_analysis_text31".tr,
                negaVisible: false,
                okBtnTextColor: ExColors.text_4(context),
                posiText: "guide_3".tr,
              );
            }
          },
          child: Row(
            children: [
              Text(
                _itemTitle(index),
                style: ExThemes.textstyle_hr_color2_12((context)),
              ),
              Gaps.hGap4,
              index == 0 ? BreakevenAnalysisIcon.hintIcon() : Container(),
            ],
          ),
        ),
        Gaps.vGap4,
        Obx(
          () => Text(
            controller.showAmount.value ? getProfitRate(index) : "******",
            style: ExThemes.textstyle_hm_color2_14((context)).copyWith(
              color: controller.showAmount.value
                  ? getProfitColor(index, false, context)
                  : ExColors.text_1(context),
            ),
          ),
        ),
        Gaps.vGap4,
        Obx(
          () => Text(
            controller.showAmount.value
                ? getProfitNum(index, controller.mCurrencyCoin.value)
                : "******",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ExThemes.textstyle_hr_color2_12((context)).copyWith(
              color: controller.showAmount.value
                  ? getProfitColor(index, false, context)
                  : ExColors.text_2(context),
            ),
          ),
        )
      ],
    );
  }

  String _itemTitle(int index) {
    if (index == 0) {
      return "breakeven_analysis_text6".tr;
    } else if (index == 1) {
      return "breakeven_analysis_text18".tr;
    }
    return "breakeven_analysis_text7".tr;
  }

  String getProfitRate(int index) {
    String str = "0.00%";
    bool isBigThenZero = true;
    switch (index) {
      case 0:
        {
          str = handleShowData(currentDayProfitEntity, true);
          isBigThenZero =
              isBigThenZeroMethod(currentDayProfitEntity?.profitAndLossRatio);
        }
        break;
      case 1:
        {
          str = handleShowData(sevenDayProfitEntity, true);
          isBigThenZero =
              isBigThenZeroMethod(sevenDayProfitEntity?.profitAndLossRatio);
        }
        break;
      case 2:
        {
          str = handleShowData(thirtyDayProfitEntity, true);
          isBigThenZero =
              isBigThenZeroMethod(thirtyDayProfitEntity?.profitAndLossRatio);
        }
        break;
      default:
    }
    return isBigThenZero ? "+$str%" : "$str%";
  }

  bool isBigThenZeroMethod(double? value) {
    String aa = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(value, 2,
        needAddZero: true);
    double result = double.tryParse(aa) ?? 0;
    if (result <= 0) {
      return false;
    }
    return true;
  }

  String getProfitNum(int index, String coinSymbol) {
    String str = "0.00";
    bool isBigThenZero = true;

    switch (index) {
      case 0:
        str = handleShowData(currentDayProfitEntity, false);
        isBigThenZero =
            isBigThenZeroMethod(currentDayProfitEntity?.amountOfProfitOrLoss);
        break;
      case 1:
        str = handleShowData(sevenDayProfitEntity, false);
        isBigThenZero =
            isBigThenZeroMethod(sevenDayProfitEntity?.amountOfProfitOrLoss);
        break;
      case 2:
        str = handleShowData(thirtyDayProfitEntity, false);
        isBigThenZero =
            isBigThenZeroMethod(thirtyDayProfitEntity?.amountOfProfitOrLoss);
        break;
      default:
    }
    if (str.contains("-")) {
      str = str.replaceFirst(RegExp(r'-'), '');
      return "-$coinSymbol$str";
    }
    return isBigThenZero ? "+$coinSymbol$str" : "$coinSymbol$str";
  }

  String handleShowData(SingleCoinAssetsChartEntity? chartEntity, bool isRate) {
    String str = "0.00";
    if (isRate) {
      if (chartEntity != null && chartEntity.profitAndLossRatio != null) {
        if (chartEntity.profitAndLossRatio == 0) {
          return "0.00";
        }
        str = DecimalUtils.formateNum(chartEntity.profitAndLossRatio,
            digits: 2, isShowThous: true);
      } else {
        return "0.00";
      }
    } else {
      if (chartEntity != null && chartEntity.amountOfProfitOrLoss != null) {
        if (chartEntity.amountOfProfitOrLoss == 0) {
          return "0.00";
        }
        str = DecimalUtils.formateNum(chartEntity.amountOfProfitOrLoss,
            digits: 2, isShowThous: true);
      } else {
        return "0.00";
      }
    }

    return str;
  }

  Color getProfitColor(int index, bool isRate, BuildContext context) {
    Color color = ExColors.text_1(context);
    double temp = 0;
    switch (index) {
      case 0:
        {
          if (isRate) {
            temp = currentDayProfitEntity?.profitAndLossRatio ?? 0;
          } else {
            temp = currentDayProfitEntity?.amountOfProfitOrLoss ?? 0;
          }
        }
        break;
      case 1:
        {
          if (isRate) {
            temp = sevenDayProfitEntity?.profitAndLossRatio ?? 0;
          } else {
            temp = sevenDayProfitEntity?.amountOfProfitOrLoss ?? 0;
          }
        }
        break;
      case 2:
        {
          if (isRate) {
            temp = thirtyDayProfitEntity?.profitAndLossRatio ?? 0;
          } else {
            temp = thirtyDayProfitEntity?.amountOfProfitOrLoss ?? 0;
          }
        }
        break;

      default:
    }

    color = ExColors.setRiseFallTextColor(
        TaskCenterCommon.truncateToSpecifiedDecimalPlaces(temp, 2),
        isRate ? ExColors.text_1(context) : ExColors.text_2(context),
        context);
    return color;
  }
}
