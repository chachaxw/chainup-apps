
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/base_stateless_widget.dart';
import '../../constants/color_constant.dart';
import '../../controllers/debug_controller.dart';
import '../../themes/Themes.dart';
import 'package:library_kline/utils/storage_utils.dart';
import '../../widgets/ExTextHighlight.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/gaps.dart';

class DebugPage extends BaseStatelessWidget<DebugController> {
  const DebugPage({Key? key}) : super(key: key);

  @override
  String titleString() {
    return "Debug";
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "代理设置：".tr,
            style: ExThemes.textstyle_sm_color2_16(context),
          ),
          Gaps.vGap8,
          ExTextField(
            hintText: "请输入主机名",
            controller: controller.accountController,
            focusNode: controller.accountFocusNode,
            onChanged: (value) {
              controller.isButtonEnable.value=(!controller.accountController.text.isEmpty &&
                  !controller.pwdController.text.isEmpty);
            },
          ),
          Gaps.vGap8,
          ExTextField(
            hintText: "请输入端口",
            controller: controller.pwdController,
            focusNode: controller.pwdFocusNode,
            onChanged: (value) {
              controller.isButtonEnable.value=(
                  !controller.accountController.text.isEmpty &&
                  !controller.pwdController.text.isEmpty
              );
            },
          ),
          Gaps.vGap8,
          Obx(() => ExButton(
                text: controller.mButtonStr.value,
                initialEnable: controller.isButtonEnable.value,
                onPressed: () {
                  if(ExStorageUtils.getString(ExStorageUtils.DEBUG_IP).isEmpty){
                    showToast("代理设置成功！");
                    controller.setProxy(controller.accountController.text,
                        controller.pwdController.text);
                  }else{
                    showToast("代理关闭成功！");
                    controller.accountController.text="";
                    controller.pwdController.text="";
                    controller.setProxy(controller.accountController.text,
                        controller.pwdController.text);
                  }

                },
              )),
          Container(
            margin: const EdgeInsets.only(left: 16,  right: 16,top: 8),
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
            decoration: ExThemes.getBoxWarning2Radius4(context),
            child: ExTextHighlight(
              "风险提示：ETH3S是追踪ETH当日跌幅3倍的杠杆代币，更适合单边行情下交易及短期持有。该产品波动较大有净值磨损风险。",
              controller.mHighlightStr,
              ExThemes.textstyle_sm_color1_12(context).copyWith(height: 1.3),
              ExThemes.textstyle_sm_color1_12(context).copyWith(color: ExColors.warning_1(context),height: 1.3),
            ),
          )
        ],
      ),
    );
  }
}
