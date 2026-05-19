import 'dart:math';

import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/controllers/klineSetting/kline_indicators_modify_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../themes/Themes.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/custom_text_field_style_5.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/ex_text.dart';
import '../../widgets/gaps.dart';

class KlineIndicatorsModifyPage
    extends BaseStatelessWidget<KlineIndicatorsModifyController> {
  const KlineIndicatorsModifyPage({Key? key}) : super(key: key);


  @override
  Color backgroundColor(BuildContext context) => ExColors.fill_2(context);

  @override
  bool showTitleBar() => true;

  @override
  String titleString() => controller.indicatorType.name.tr;

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Obx(() => ListView.builder(
                itemCount: controller.listData.length,
                itemBuilder: (BuildContext context, int index) {
                  return _createItemWidget(context, index);
                },
              )),
        ),

        // Expanded(
        //   child: Obx(() => ListView.builder(
        //         itemCount: controller.listData.length,
        //         itemBuilder: (BuildContext context, int index) {
        //           return _createItemWidget(context, index);
        //         },
        //       )),
        // ),
        _buildBottomCtrl(context)
      ],
    );
  }

  Widget _createItemWidget(BuildContext context, int index) {
    return Container(
      height: 56,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.listData[index].isOpen =
          !(controller.listData[index].isOpen == true);
          controller.listData.refresh();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                controller.indicatorType.showCheckBox()
                    ? ExCheckbox(
                    value: controller.listData[index].isOpen,
                    onChanged: (v) {
                      controller.listData[index].isOpen =
                      !(controller.listData[index].isOpen == true);
                      controller.listData.refresh();
                    })
                    : Gaps.hGap0,
                Gaps.hGap8,
                ExTextEf(
                  controller.listData[index].name ?? "",
                  style: ExThemes.textstyle_sm_color1_16(context),
                ),
                Gaps.hGap8,
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.listData[index].lineColor,
                    borderRadius: const BorderRadius.all(Radius.circular(28)),
                    border: Border.all(width: 0, style: BorderStyle.none),
                  ),
                )
              ],
            ),
            Container(
              width: 125,
              child: ExTextFieldStyle5(
                hintText: "",
                controller: controller.mTextEditingControllers[index],
                focusNode: controller.mFocusNodes[index],
                keyboardType: TextInputType.number,
                inputFormatters: [     FilteringTextInputFormatter.allow(RegExp("[0-9]")),],
                onChanged: (v) {
                  // print("输入 = ${v}");
                  controller.digitalLegalVerification(index);
                },
                onReduce: () {
                  controller.numbersOperations(
                      NumericOperations.subtracting, index);
                },
                onAdd: () {
                  controller.numbersOperations(NumericOperations.adding, index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCtrl(BuildContext context) {
    final double safeBottomPaddingHeight = Get.mediaQuery.padding.bottom;
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          height: 60 + safeBottomPaddingHeight,
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: max(safeBottomPaddingHeight, 10)),
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: ExButton(
                              minHeight: 40,
                              text: "kline_reset".tr,
                              backgroundColor: ExColors.fill_3(context),
                              textColor: ExColors.text_1(context),
                              onPressed: () {
                                controller.reset();
                              },
                            )),
                        Gaps.hGap10,
                        Expanded(
                            flex: 2,
                            child: ExButton(
                              minHeight: 40,
                              text: "kline_complete".tr,
                              textColor: ExColors.text_4(context),
                              backgroundColor: ExColors.main_1(context),
                              onPressed: () {
                                controller.saveIndicators();
                                Get.back();
                              },
                            ))
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
