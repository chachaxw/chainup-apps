import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
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

class ItemReceivedSuccessDialog extends CommonStatelessWidget {
  String rewardCoin;
  String rewardAmount;
  final String? rewardType;
  String? viewMoreText;
  final VoidCallback? viewMoreCallback;
  final VoidCallback? okCallback;

  ItemReceivedSuccessDialog({
    Key? key,
    required this.rewardCoin,
    required this.rewardAmount,
    this.rewardType,
    this.viewMoreText,
    this.viewMoreCallback,
    this.okCallback,
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
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFCCD4FF),
                  Color(0xFFEDF0FF),
                  Color(0xFFFFFFFF),
                ],
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 20),
                child: Column(
                  children: [
                    ExIcon.icSignReceivedSuccessfully(),
                    Gaps.vGap20,
                    Text(
                      "text19".tr,
                      style: ExThemes.textstyle_sm_color1_16(context),
                    ),
                    Gaps.vGap12,
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: rewardAmount,
                        style: ExThemes.textstyle_sm_color1_32(context)
                            .copyWith(color: ExColors.main_4(context)),
                      ),
                      TextSpan(
                        text: " $rewardCoin",
                        style: ExThemes.textstyle_sm_color1_20(context),
                      ),
                    ])),
                    rewardTypeWidget(context),
                    Gaps.vGap20,
                    ExButton(
                      text: "task_center_ok".tr,
                      textColor: ExColors.text_4(context),
                      minHeight: 44,
                      onPressed: () {
                        Get.back();
                        okCallback?.call();
                      },
                    ),
                    viewMoreWidget(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rewardTypeWidget(BuildContext context) {
    if (rewardType != null) {
      return Column(
        children: [
          Gaps.vGap16,
          Text(
            rewardType!,
            style: ExThemes.textstyle_sr_color2_14(context),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget viewMoreWidget(BuildContext context) {
    if (viewMoreText != null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            viewMoreCallback?.call();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewMoreText!,
                style: ExThemes.textstyle_sm_color1_14(context)
                    .copyWith(color: ExColors.main_4(context)),
              ),
              ExIcon.viewMore(color: ExColors.main_4(context)),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
