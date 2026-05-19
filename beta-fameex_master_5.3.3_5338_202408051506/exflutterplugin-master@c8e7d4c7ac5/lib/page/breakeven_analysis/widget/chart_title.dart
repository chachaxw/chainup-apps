import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/icon_constant.dart';
import '../../../themes/Themes.dart';
import '../../../widgets/gaps.dart';

class ChartTitle extends StatelessWidget {
  final String? title;
  const ChartTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showTip(context);
      },
      child: Row(
        children: [
          Text(
            title ?? "",
            style: ExThemes.textstyle_hm_color1_16((context)),
          ),
          Gaps.hGap4,
          BreakevenAnalysisIcon.hintIcon(),
        ],
      ),
    );
  }

  void showTip(BuildContext context) {
    debugPrint("$title == ${"breakeven_analysis_text8".tr}");
    String content = "";
    if (title == "breakeven_analysis_text8".tr) {
      content = "breakeven_analysis_text30".tr;
    } else if (title == "breakeven_analysis_text9".tr) {
      content = "breakeven_analysis_text32".tr;
    } else if (title == "breakeven_analysis_text19".tr) {
      content = "breakeven_analysis_text33".tr;
    } else if (title == "breakeven_analysis_text10".tr) {
      content = "breakeven_analysis_text34".tr;
    } else if (title == "breakeven_analysis_text29".tr) {
      content = "breakeven_analysis_text35".tr;
    }
    Get.showCommonDialog(
      title: title ?? "",
      content: content,
      negaVisible: false,
      okBtnTextColor: ExColors.text_4(context),
      posiText: "guide_3".tr,
    );
  }
}
