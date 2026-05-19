import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyListWidget extends StatelessWidget {
  final String? text;
  final Image? icon;
  final double? iconTopPadding;
  const EmptyListWidget({this.text, this.icon, this.iconTopPadding, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ExColors.fill_2(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: iconTopPadding ?? 150,
            ),
            child: icon ?? ExIcon.taskEmptyData(),
          ),
          Gaps.vGap20,
          Text(
            text ?? "timed_task_detail_text22".tr,
            style:
                ExThemes.textstyle_sr_color2_12(context).copyWith(height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
