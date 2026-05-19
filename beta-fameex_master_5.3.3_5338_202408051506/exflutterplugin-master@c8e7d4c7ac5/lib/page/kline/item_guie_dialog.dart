
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
import '../../models/guide_item_entity.dart';
import '../../widgets/ex_button.dart';
import '../../widgets/gaps.dart';
import '../../widgets/over_scroll_behavior.dart';

class ItemGuideDialog extends CommonStatelessWidget {

  ItemGuideModel? itemGuideModel;
  ItemGuideDialog({
    Key? key,
    required this.itemGuideModel,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final RenderBox renderBox = itemGuideModel?.renderObject as RenderBox;
    // print("ItemGuideDialog renderBox == ${renderBox}");
    final size = renderBox.size; // 尺寸
    final position = renderBox.localToGlobal(Offset.zero); // 位置
    // final position = Offset(200, 200);
    // print("ItemGuideDialog renderBox == size-${size} position =${position}");
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left:position.dx + size.width/2),
          child: ExIcon.icGuidePopTop(),
        ),
        Container(
          constraints: const BoxConstraints(
            // 最小宽度
            maxWidth: 200, // 最大宽度
          ),
          margin: EdgeInsets.only(top: 6.0,left:position.dx - (itemGuideModel!.title == "kline_IndicatorsGuide2".tr ? 100:100)),
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 13.0),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              color:ExColors.main_color(context)
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (itemGuideModel?.title ?? "") + " :",
                    style: ExThemes.textstyle_sm_color1_14(context).copyWith(
                        color: const Color(0xffffffff)
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    (itemGuideModel?.message ?? ""),
                    style: ExThemes.textstyle_sr_color1_12(context).copyWith(
                        color: const Color(0xffffffff)
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
              Positioned(
                bottom: 0,right: 0,
                  child:
              Text(
                "guide_3".tr,
                textAlign: TextAlign.right,
                style: ExThemes.textstyle_sm_color1_12(context).copyWith(
                    color: const Color(0xffffffff)
                ),
              ))
            ],
          ),
        )
      ],
    );
  }
}


