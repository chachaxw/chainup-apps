import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ExColors_util.dart';

class ColorConstants {
  static Color gray50 = Color(0xFFe9e9e9);
  static Color gray100 = Color(0xFFbdbebe);
  static Color gray200 = Color(0xFF929293);
  static Color gray300 = Color(0xFF666667);
  static Color gray400 = Color(0xFF505151);
  static Color gray500 = Color(0xFF242526);
  static Color gray600 = Color(0xFF202122);
  static Color gray700 = Color(0xFF191a1b);
  static Color gray800 = Color(0xFF121313);
  static Color gray900 = Color(0xFF0e0f0f);
}


class ExKlineColors {

  //主色
  static Color main_color(BuildContext context) => Theme.of(context).colorScheme.main_color;

  //按钮颜色
  static Color btn_pressed_color(BuildContext context) => Theme.of(context).colorScheme.btn_pressed_color;
  static Color btn_enabled_color(BuildContext context) => Theme.of(context).colorScheme.btn_enabled_color;
  static Color btn_text_color(BuildContext context) => Theme.of(context).colorScheme.btn_text_color;
  static Color btn_normal_color(BuildContext context) => Theme.of(context).colorScheme.btn_normal_color;
  static Color btn_normal_2_color(BuildContext context) => Theme.of(context).colorScheme.btn_normal_2_color;

  //文字颜色
  static Color text_color_1(BuildContext context) =>  Theme.of(context).colorScheme.text_color_1;
  static Color text_color_2(BuildContext context) =>  Theme.of(context).colorScheme.text_color_2;
  static Color text_color_3(BuildContext context) =>  Theme.of(context).colorScheme.text_color_2;

  //背景颜色
  static Color main_bg_color (BuildContext context)=> Theme.of(context).colorScheme.main_bg_color;
  static Color card_bg_color_1(BuildContext context) => Theme.of(context).colorScheme.card_bg_color_1;
  static Color card_bg_color_2 (BuildContext context)=> Theme.of(context).colorScheme.card_bg_color_2;
  static Color dialog_bg_color(BuildContext context) => Theme.of(context).colorScheme.dialog_bg_color;
  static Color input_bg_color(BuildContext context) => Theme.of(context).colorScheme.input_bg_color;
  static Color fill_2(BuildContext context) => Theme.of(context).colorScheme.fill_2;

  //分割线颜色
  static Color line_color (BuildContext context)=> Theme.of(context).colorScheme.line_color;

  //TAB背景颜色
  static Color tabbar_bg_color (BuildContext context)=>  Theme.of(context).colorScheme.tabbar_bg_color;

  //Toast提示背景色
  static Color toast_bg_color(BuildContext context) => Theme.of(context).colorScheme.toast_bg_color;

  //涨跌色
  static Color main_red_color(BuildContext context) => Theme.of(context).colorScheme.main_red_color;
  static Color main_green_color(BuildContext context) =>  Theme.of(context).colorScheme.main_green_color;

  static Color main_red15_color(BuildContext context) =>  Color(0x26D1425E);
  static Color main_green15_color(BuildContext context) =>  Color(0x2600B595);

  //辅助色
  static Color main_yellow_color(BuildContext context) =>  Color(0xFFE9A92A);

  static Color main_yellow10_color(BuildContext context) =>  Color(0x1AE9A92A);

  //透明颜色
  static Color transparent_color(BuildContext context) => Color(0xFFFFFF);


}

extension CustomColorScheme on ColorScheme {
  Color get main_color =>  Get.isDarkMode ? ExColorsDark.main_color : ExColorsLight.main_color;
  Color get btn_pressed_color =>  Get.isDarkMode ? ExColorsDark.btn_pressed_color : ExColorsLight.btn_pressed_color;
  Color get btn_enabled_color =>  Get.isDarkMode ? ExColorsDark.btn_enabled_color : ExColorsLight.btn_enabled_color;
  Color get btn_text_color =>  Get.isDarkMode ? ExColorsDark.btn_text_color : ExColorsLight.btn_text_color;
  Color get btn_normal_color =>  Get.isDarkMode ? ExColorsDark.btn_normal_color : ExColorsLight.btn_normal_color;
  Color get btn_normal_2_color =>  Get.isDarkMode ? ExColorsDark.btn_normal_2_color : ExColorsLight.btn_normal_2_color;
  Color get text_color_1 =>  Get.isDarkMode ? ExColorsDark.text_color_1 : ExColorsLight.text_color_1;
  Color get text_color_2 =>  Get.isDarkMode ? ExColorsDark.text_color_2 : ExColorsLight.text_color_2;
  Color get text_color_3 =>  Get.isDarkMode ? ExColorsDark.text_color_3 : ExColorsLight.text_color_3;
  Color get main_bg_color =>  Get.isDarkMode ? ExColorsDark.main_bg_color : ExColorsLight.main_bg_color;
  Color get card_bg_color_1 =>  Get.isDarkMode ? ExColorsDark.card_bg_color_1 : ExColorsLight.card_bg_color_1;
  Color get card_bg_color_2 =>  Get.isDarkMode ? ExColorsDark.card_bg_color_2 : ExColorsLight.card_bg_color_2;
  Color get dialog_bg_color =>  Get.isDarkMode ? ExColorsDark.dialog_bg_color : ExColorsLight.dialog_bg_color;
  Color get line_color =>  Get.isDarkMode ? ExColorsDark.line_color : ExColorsLight.line_color;
  Color get toast_bg_color =>  Get.isDarkMode ? ExColorsDark.toast_bg_color : ExColorsLight.toast_bg_color;
  Color get tabbar_bg_color =>  Get.isDarkMode ? ExColorsDark.tabbar_bg_color : ExColorsLight.tabbar_bg_color;
  Color get input_bg_color =>  Get.isDarkMode ? ExColorsDark.input_bg_color : ExColorsLight.input_bg_color;
  Color get fill_2 =>  Get.isDarkMode ? ExColorsDark.fill_2 : ExColorsLight.fill_2;
  Color get main_red_color =>  ExColorsDark.main_red_color ;
  Color get main_green_color =>  ExColorsDark.main_green_color;
}



class ExColorsLight {

  static final ExColorsUtil _colorUtil = ExColorsUtil();

  //主色
  static final Color main_color = _colorUtil.main_1 ?? const Color(0xFF2B61FF);

  //按钮颜色
  static const Color btn_pressed_color = Color(0xFF5581FF);
  static const Color btn_enabled_color = Color(0xFFD5D7DA);
  static const Color btn_text_color = Color(0xFFFFFFFF);
  static const Color btn_normal_color = Color(0xFFECF0F9);
  static const Color btn_normal_2_color = Color(0xFFD5D7DA);

  //文字颜色
  static const Color text_color_1 = Color(0xFF101111);
  static const Color text_color_2 = Color(0xFF606266);
  static const Color text_color_3 = Color(0xFFA0A2AA);

  //背景颜色
  static const Color main_bg_color = Color(0xFFF5F7FB);
  static const Color card_bg_color_1 = Color(0xFFFFFFFF);
  static const Color card_bg_color_2 = Color(0xFFEDEFF2);
  static const Color dialog_bg_color = Color(0xFFFFFFFF);
  static const Color search_bg_color = Color(0xFFFFFFFF);
  static const Color input_bg_color = Color(0xFFF5F7FB);
  static const Color real_time_Bg_Color = Color(0xFFDFE7FF);

  //分割线颜色
  static const Color line_color = Color(0xFFECF0F9);

  //TAB背景颜色
  static const Color tabbar_bg_color = Color(0xFFF2F5F7FB);

  //Toast提示背景色
  static const Color toast_bg_color = Color(0xFF303133);

  //K线网格线颜色
  static const Color kline_grid_color = Color(0xffECF0F9);
  static const Color fill_4 = Color(0xffECF0F9);


  //K线Marker背景填充颜色
  static const Color kline_marker_fill_color = Color(0xffF5F7FB);
  static const Color fill_6 = Color(0xffFFFFFF);

  //K线Marker背景边框颜色
  static const Color kline_marker_border_color = Color(0xffF5F7FB);
  static const Color kline_priceline_bg_color = Color(0xFFD5D7DA);

  static const Color special_2 = Color(0xffF5F7FB);
  static const Color special_4 = Color(0xffA0A2AA);
  static const Color fill_3 = Color(0xffEDEFF2);
  static const Color fill_2 = Color(0xFFFFFFFF);
  static const Color fill_5 = Color(0xffD5D7DA);
}


class ExColorsDark {

  static final ExColorsUtil _colorUtil = ExColorsUtil();

  //主色
  static final Color main_color = _colorUtil.main_1 ?? const Color(0xFF2B61FF);

  //按钮颜色
  static const Color btn_pressed_color = Color(0xFF5581FF);
  static const Color btn_enabled_color = Color(0xFFD5D7DA);
  static const Color btn_text_color = Color(0xFFFFFFFF);
  static const Color btn_normal_color = Color(0xFFECF0F9);
  static const Color btn_normal_2_color = Color(0xFF39393C);

  //文字颜色
  static const Color text_color_1 = Color(0xFFFFFFFF);
  static const Color text_color_2 = Color(0xFF909399);
  static const Color text_color_3 = Color(0xFF505255);

  //背景颜色
  static const Color main_bg_color = Color(0xFF010101);
  static const Color card_bg_color_1 = Color(0xFF111111);
  static const Color card_bg_color_2 = Color(0xFF232326);
  static const Color dialog_bg_color = Color(0xFF171717);
  static const Color search_bg_color = Color(0xFF232326);
  static const Color input_bg_color = Color(0xFF232326);
  static const Color real_time_Bg_Color = Color(0xFF151D35);

  //分割线颜色
  static const Color line_color = Color(0xFF282828);

  //TAB背景颜色
  static const Color tabbar_bg_color = Color(0xFFF2F5F7FB);

  //Toast提示背景色
  static const Color toast_bg_color = Color(0xFF303133);

  //涨跌色/红色
  static const Color main_red_color = Color(0xFFD1425E);

  //涨跌色/绿色
  static const Color main_green_color = Color(0xFF00B595);

  //K线网格线颜色
  static const Color kline_grid_color = Color(0xff282828);

  //K线Marker背景填充颜色
  static const Color kline_marker_fill_color = Color(0xff171717);
  static const Color fill_6 = Color(0xff171717);
  static const Color fill_3 = Color(0xff232326);
  static const Color fill_4 = Color(0xff282828);
  static const Color fill_5 = Color(0xff39393C);

  //K线Marker背景边框颜色
  static const Color kline_marker_border_color = Color(0xff39393C);

  static const Color kline_priceline_bg_color = Color(0xFF39393C);

  static const Color special_2 = Color(0xff232326);
  static const Color special_4 = Color(0xffA0A2AA);
  static const Color fill_2 = Color(0xFF111111);
}


 Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

  return Color(int.parse(hex.substring(1), radix: 16) +
      (hex.length == 7 ? 0xFF000000 : 0x00000000));
}
