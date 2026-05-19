import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../base/pageWidget/common_stateless_widget.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/gaps.dart';
import '../../widgets/over_scroll_behavior.dart';

class ItemKycCheckDialog extends CommonStatelessWidget {
  bool? isIDAuth = false;
  bool? isOpenGA = false;
  bool? isOpenMobile = false;
  VoidCallback? posiTap;
  ItemKycCheckDialog({
    Key? key,
    this.posiTap,
    this.isIDAuth,
    this.isOpenMobile,
    this.isOpenGA,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(

        ///透明样式
        type: MaterialType.transparency,

        ///dialog居中
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: ExColors.dialog_bg_color(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "text83".tr,
                        style: ExThemes.textstyle_sm_color1_16(context),
                      ),
                      Gaps.vGap12,
                      Text(
                        "text84".tr,
                        style: ExThemes.textstyle_sm_color2_14(context),
                      ),
                      Gaps.vGap12,
                      _buildItemView(context, "text85".tr, isIDAuth),
                      _buildItemView(
                          context,
                          isOpenMobile == true ? "text91".tr : "text90".tr,
                          isOpenGA),
                      Gaps.vGap20,
                      Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ExButton(
                              backgroundColor:
                                  ExColors.card_bg_color_2(context),
                              textColor: Get.isDarkMode
                                  ? ExColorsDark.text_color_1
                                  : ExColorsLight.text_color_1,
                              onPressed: () {
                                Get.dismiss();
                              },
                              text: "text88".tr,
                            ),
                          ),
                          Gaps.hGap16,
                          Expanded(
                            flex: 1,
                            child: ExButton(
                              onPressed: () {
                                posiTap!();
                                Get.dismiss();
                              },
                              text: "text89".tr,
                            ),
                          )

                          // _buildTextButton(posiTap, posiText, posiVisible,context)
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _buildItemView(BuildContext context, String value, bool? isSel) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          isSel == true ? ExIcon.icSelected(16.0) : ExIcon.icUnSelected(16.0),
          Gaps.hGap8,
          Text(
            value,
            style: ExThemes.textstyle_sm_color1_14(context).copyWith(
                color: isSel == true
                    ? ExColors.main_1(context)
                    : ExColors.text_color_1(context)),
          ),
        ],
      ),
    );
  }
}
