
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../models/bottom_sheet_entity.dart';
import '../themes/Themes.dart';
import 'over_scroll_behavior.dart';


class ExBottomDialog extends StatelessWidget {
  ///当前选中
  int currentSelected;

  List<BottomSheetEntity> datas;

  ///关闭事件
  VoidCallback? closeTap;

  ///选择事件
  Function(int)? itemClickTap;

  ExBottomDialog({
    Key? key,
    required this.currentSelected,
    required this.datas,
    this.closeTap,
    this.itemClickTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child:  ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: ExColors.dialog_bg_color(context),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: datas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: (){
                          Get.back();
                          itemClickTap!(index);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: index==datas.length-1 ?0:0.5, color: ExColors.line_color(context))
                              )
                          ),
                          child:Text(datas[index].showName.toString(),style: ExThemes.textstyle_sm_color1_14(context).copyWith( color: currentSelected ==index ? ExColors.main_color(context) : ExColors.text_color_1(context)),),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 5,
                  color: ExColors.main_bg_color(context),
                ),
                GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    height: 50,
                    color: ExColors.dialog_bg_color(context),
                    alignment: Alignment.center,
                    child:Text('Cancel',style: ExThemes.textstyle_sm_color1_14(context),),
                  ),
                )

              ],
            )));
  }
}
