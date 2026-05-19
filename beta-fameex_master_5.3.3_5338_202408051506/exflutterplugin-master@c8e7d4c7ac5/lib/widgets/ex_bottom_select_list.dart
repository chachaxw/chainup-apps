
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../models/bottom_sheet_entity.dart';
import '../themes/Themes.dart';
import 'gaps.dart';
import 'over_scroll_behavior.dart';

class SheetSelectList extends StatelessWidget {
  ///当前选中
  int currentSelected;

  //数据源
  List<BottomSheetEntity> datas;

  //title
  String title;

  ///关闭事件
  VoidCallback? closeTap;

  ///选择事件
  Function(int)? itemClickTap;

  SheetSelectList({
    Key? key,
    required this.currentSelected,
    required this.datas,
    required this.title,
    this.closeTap,
    this.itemClickTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 30),
              decoration: ShapeDecoration(
                color: ExColors.dialog_bg_color(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: ExThemes.textstyle_sm_color1_18(context),
                      ),
                      GestureDetector(
                        onTap: (){
                          Get.back();
                        },
                        child: Text(
                          "cancel",
                          style: ExThemes.textstyle_sm_color2_14(context),
                        ),
                      )
                    ],
                  ),
                  Gaps.vGap18,
                  // Text(
                  //   "Please select the mainnet that is consistent with the withdrawal platform for deposit, otherwise your funds may be lost",
                  //   style: ExThemes.textstyle_sr_color2_12(context)
                  //       .copyWith(color: ExColors.main_yellow_color(context)),
                  // ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: datas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Get.back();
                          itemClickTap!(index);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Stack(
                            children: [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color:ExColors.card_bg_color_2(context),
                                    border:Border.all(
                                      color: currentSelected == index
                                          ? ExColors.main_color(context)
                                          : ExColors.card_bg_color_2(context),
                                      width: 2.0,
                                    )),
                                child:  Text(
                                  datas[index].showName.toString(),
                                  style: ExThemes.textstyle_sm_color1_14(context)
                                      .copyWith(
                                      color: currentSelected == index
                                          ? ExColors.main_color(context)
                                          : ExColors.text_color_1(context)),
                                ),
                              ),
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: currentSelected == index?ExIcon.icCornerMarkerSelect():Gaps.empty
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
