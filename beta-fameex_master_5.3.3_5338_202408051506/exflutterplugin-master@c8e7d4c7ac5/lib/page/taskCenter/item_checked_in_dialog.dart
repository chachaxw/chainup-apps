import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/pageWidget/common_stateless_widget.dart';
import '../../models/task_center_index_entity.dart';
import '../../widgets/gaps.dart';

class ItemCheckedInDialog extends CommonStatelessWidget {
  VoidCallback? posiTap;
  TaskCenterIndexSignInInfo? signInInfo;
  ItemCheckedInDialog({
    Key? key,
    this.signInInfo,
    this.posiTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int seriateSignInNum = signInInfo?.seriateSignInNum ?? 0;
    return Material(
      type: MaterialType.transparency,
      color: ExColors.dialog_bg_color(context),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ExColors.dialog_bg_color(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "text7".tr,
                        style: ExThemes.textstyle_hm_color1_16(context),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          "text88".tr,
                          style: ExThemes.textstyle_hm_color2_14(context),
                        ),
                      ),
                    ],
                  ),
                  Gaps.vGap12,
                  _richText(
                      "text3"
                          .tr
                          .trParams({"number": seriateSignInNum.toString()}),
                      context),
                  Gaps.vGap12,
                  ListView.builder(
                    itemCount: signInInfo?.rewards?.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemView(context,
                          signInInfo!.rewards![index].toString(), index);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _richText(String text, BuildContext context) {
    debugPrint(text);
    return RichText(
      text: _getColoredTextSpan(text, context),
    );
  }

  TextSpan _getColoredTextSpan(String text, BuildContext context) {
    final RegExp regex = RegExp(r'\d+');
    final List<TextSpan> children = [];

    for (RegExpMatch match in regex.allMatches(text)) {
      children.add(
        TextSpan(
          text: match.group(0),
          style: ExThemes.textstyle_sm_color1_12(context),
        ),
      );
    }

    if (children.isEmpty) {
      return TextSpan(
        text: text,
        style: ExThemes.textstyle_sm_color2_12(context),
      );
    } else {
      List<TextSpan> spans = [];
      int start = 0;
      for (TextSpan child in children) {
        if (child.text != null) {
          final index = text.indexOf(child.text!, start);
          if (index > start) {
            spans.add(TextSpan(
              text: text.substring(start, index),
              style: ExThemes.textstyle_sm_color2_12(context),
            ));
          }
          spans.add(child);
          start = index + child.text!.length;
        }
      }
      if (start < text.length) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: ExThemes.textstyle_sm_color2_12(context),
        ));
      }
      return TextSpan(children: spans);
    }
  }

  _buildItemView(BuildContext context, String rewardsNum, int index) {
    var isSign = ((index + 1) <= signInInfo!.seriateSignInNum!);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSign
                ? [
                    const Color(0xFFFFF4C9),
                    const Color(0x00fff4c9),
                  ]
                : [
                    ExColors.fill_1(context),
                    ExColors.fill_1(context),
                  ],
          )),
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                ExIcon.icCheckinCoin(),
                Gaps.hGap10,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "task_centerk_07"
                          .tr
                          .trParams({"num": (index + 1).toString()}),
                      style: ExThemes.textstyle_hr_color2_12(context),
                    ),
                    Gaps.vGap4,
                    Text(
                      "${rewardsNum} ${signInInfo!.rewardCoin}",
                      style: ExThemes.textstyle_hm_color1_14(context),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            child: isSign
                ? ExIcon.icCheckinOver()
                : Text(
                    "task_centerk_06".tr,
                    style: ExThemes.textstyle_hm_color2_12(context),
                  ),
          ),
        ],
      ),
    );
  }
}
