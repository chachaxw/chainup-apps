import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';
import 'ex_button.dart';
import 'gaps.dart';
import 'over_scroll_behavior.dart';

/// @description :公共通用弹窗
// ignore: must_be_immutable
class CommonDialog extends StatelessWidget {
  ///标题
  String title = '';

  ///内容
  String content = '';

  ///左侧文字
  String negaText = '';

  ///右侧文字
  String posiText = '';

  ///左侧事件
  VoidCallback? negaTap;

  ///右侧事件
  VoidCallback? posiTap;

  ///左侧是否隐藏
  bool negaVisible = true;

  ///右侧是否隐藏
  bool posiVisible = true;

  ///顶部icon是否隐藏
  bool iconVisible = false;

  ///按钮字体颜色
  Color? okBtnTextColor;

  ///是否自动消除弹框
  bool isNeedAutoDismiss = true;

  CommonDialog({
    Key? key,
    this.title = '',
    this.content = '',
    this.negaText = '',
    this.posiText = '',
    this.negaVisible = true,
    this.posiVisible = true,
    this.iconVisible = false,
    this.negaTap,
    this.posiTap,
    this.okBtnTextColor,
    this.isNeedAutoDismiss = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(

        ///透明样式
        type: MaterialType.transparency,

        ///dialog居中
        child: Center(

            ///取消ListView滑动阴影
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),

                ///ListView 的shrinkWrap属性可适应高度（有多少占多少）
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ///背景及内容、边距、圆角等，必须包裹在ListView中
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 31.w),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          top: 24,
                        ),
                        decoration: ShapeDecoration(
                          color: ExColors.dialog_bg_color(context),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ///标题、内容
                            iconVisible
                                ? Container(
                                    margin: EdgeInsets.only(bottom: 18),
                                    child: ExIcon.icDialogTips(),
                                  )
                                : Container(),
                            Text(
                              title,
                              style: ExThemes.textstyle_sm_color1_16(context),
                            ),
                            Gaps.vGap16,
                            content.isNotEmpty
                                ? Container(
                                    constraints: BoxConstraints(maxHeight: 400),
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: SingleChildScrollView(
                                        child: Text(
                                      content,
                                      style: ExThemes.textstyle_sr_color2_14(
                                              context)
                                          .copyWith(height: 1.6),
                                    )),
                                  )
                                : Container(),

                            ///确定、取消按钮
                            Flex(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              direction: Axis.horizontal,
                              children: [
                                negaVisible
                                    ? Expanded(
                                        flex: 1,
                                        child: ExButton(
                                          backgroundColor:
                                              ExColors.card_bg_color_2(context),
                                          textColor: ExColors.text_1(context),
                                          onPressed: () {
                                            if (isNeedAutoDismiss) {
                                              Get.dismiss();
                                            }
                                            if (negaTap != null) {
                                              negaTap!();
                                            }
                                          },
                                          text: negaText,
                                        ),
                                      )
                                    : Gaps.empty,
                                negaVisible ? Gaps.hGap16 : Gaps.empty,
                                Expanded(
                                  flex: 1,
                                  child: ExButton(
                                    onPressed: () {
                                      if (isNeedAutoDismiss) {
                                        Get.dismiss();
                                      }
                                      if (posiTap != null) {
                                        posiTap!();
                                      }
                                    },
                                    textColor: okBtnTextColor ??
                                        ExColors.text_4(context),
                                    text: posiText,
                                  ),
                                )

                                // _buildTextButton(posiTap, posiText, posiVisible,context)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}

/// @description :公共列表通用弹窗

class ListDialogItem{
  String title = "";
  String content = "";
  ListDialogItem(this.title,this.content);

  static List<ListDialogItem> getDialogList(){
    ListDialogItem item = ListDialogItem("kline_cost_position".tr,"kline_cost_position_text".tr);
    ListDialogItem item1 = ListDialogItem("kline_open_orders".tr,"kline_open_orders_text".tr);
    ListDialogItem item2 = ListDialogItem( "cp_contract_order_history".tr,"kline_order_history".tr);
    return [item,item1,item2];
  }
 }


// ignore: must_be_immutable
class CommonListDialog extends StatelessWidget {

  ///列表内容
  List <ListDialogItem> dialogList = [];
  CommonListDialog({
    Key? key,
    required this.dialogList
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      ///透明样式
        type: MaterialType.transparency,
        ///dialog居中
        child: Center(
          ///取消ListView滑动阴影
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),
                ///ListView 的shrinkWrap属性可适应高度（有多少占多少）
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ///背景及内容、边距、圆角等，必须包裹在ListView中
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 31.w),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          top: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: ExColors.dialog_bg_color(context),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: getDialogList(context),
                        ),
                      ),
                    ),
                  ],
                )
            )
        )
    );
                ///ListView 的shrinkWrap属性可适应高度（有多少占多少）

  }

  List<Widget> getDialogList(BuildContext context){
    List<Widget> list = [];
    for (var item in dialogList)  {
      final w = _dialogItemBuilder(context, item);
      list.add(w);
    }
    ///确定、取消按钮
   final btn = Flex(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: ExButton(
            onPressed: () {
              Get.dismiss();
            },
            text:  "cp_extra_text28".tr,
          ),
        )
      ],
    );
    list.add(Gaps.vGap16);
    list.add(btn);

    return list;

  }
  Widget _dialogItemBuilder(BuildContext context, ListDialogItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(item.title,
            style: ExThemes.textstyle_sm_color1_14(context),
        ),
        const SizedBox(height: 8),
        Text(item.content,style: ExThemes.textstyle_sm_color2_12(context)),
        const SizedBox(height: 13),
        Container(color: ExColors.fill_4(context),height: 1)
      ],
    );
  }

}

