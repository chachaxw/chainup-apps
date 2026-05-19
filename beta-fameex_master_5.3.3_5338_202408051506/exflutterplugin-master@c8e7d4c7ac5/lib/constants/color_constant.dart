import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/ExColors_util.dart';

import '../utils/decimal.dart';
import 'package:library_kline/utils/storage_utils.dart';

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

class PieChartColors {
  static Color color1 = const Color(0xFF2B61FF);
  static Color color2 = const Color(0xFF2CC3FF);
  static Color color3 = const Color(0xFF6842FF);
  static Color color4 = const Color(0xFF00B595);
  static Color color5 = const Color(0xFFE9A92A);
  static Color color6 = const Color(0xFFFFD532);

  static List<Color> colors = [color1, color2, color3, color4, color5, color6];
}

class ExColors {
  //主色
  static Color main_color(BuildContext context) =>
      Theme.of(context).colorScheme.main_color;
  static Color main_color_3(BuildContext context) =>
      Theme.of(context).colorScheme.main_color_3;

  //按钮颜色
  static Color btn_pressed_color(BuildContext context) =>
      Theme.of(context).colorScheme.btn_pressed_color;
  static Color btn_enabled_color(BuildContext context) =>
      Theme.of(context).colorScheme.btn_enabled_color;
  static Color btn_text_color(BuildContext context) =>
      Theme.of(context).colorScheme.btn_text_color;
  static Color btn_normal_color(BuildContext context) =>
      Theme.of(context).colorScheme.btn_normal_color;
  static Color btn_normal_2_color(BuildContext context) =>
      Theme.of(context).colorScheme.btn_normal_2_color;

  //文字颜色
  static Color text_color_1(BuildContext context) =>
      Theme.of(context).colorScheme.text_color_1;
  static Color text_color_2(BuildContext context) =>
      Theme.of(context).colorScheme.text_color_2;
  static Color text_color_3(BuildContext context) =>
      Theme.of(context).colorScheme.text_color_3;
  static Color text_color_risk(BuildContext context) =>
      Theme.of(context).colorScheme.text_color_risk;

  //背景颜色
  static Color main_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.main_bg_color;
  static Color main_pop_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.main_pop_bg_color;
  static Color card_bg_color_1(BuildContext context) =>
      Theme.of(context).colorScheme.card_bg_color_1;
  static Color card_bg_color_2(BuildContext context) =>
      Theme.of(context).colorScheme.card_bg_color_2;
  static Color dialog_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.dialog_bg_color;
  static Color input_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.input_bg_color;

  //分割线颜色
  static Color line_color(BuildContext context) =>
      Theme.of(context).colorScheme.line_color;

  //TAB背景颜色
  static Color tabbar_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.tabbar_bg_color;

  //Toast提示背景色
  static Color toast_bg_color(BuildContext context) =>
      Theme.of(context).colorScheme.toast_bg_color;

  static Color kline_bg_top_gradient_color(BuildContext context) =>
      Theme.of(context).colorScheme.kline_bg_top_gradient_color;
  static Color kline_bg_bottom_gradient_color(BuildContext context) =>
      Theme.of(context).colorScheme.kline_bg_bottom_gradient_color;

  //涨跌色
  static Color main_red_color(BuildContext context) =>
      Theme.of(context).colorScheme.main_red_color;
  static Color main_green_color(BuildContext context) =>
      Theme.of(context).colorScheme.main_green_color;

  static Color main_red15_color(BuildContext context) => Color(0x26D1425E);
  static Color main_green15_color(BuildContext context) => Color(0x2600B595);

  //辅助色
  static Color main_yellow_color(BuildContext context) => Color(0xFFE9A92A);

  static Color main_yellow10_color(BuildContext context) => Color(0x1AE9A92A);

  //透明颜色
  static Color transparent_color(BuildContext context) => Color(0xFFFFFF);

  //半透明颜色
  static Color transparent_color_50(BuildContext context) => Color(0x80000000);

  static Color task_main_color(BuildContext context) => Color(0xFFF7CB1C);

  static Color fill_1(BuildContext context) =>
      Theme.of(context).colorScheme.fill_1;
  static Color fill_2(BuildContext context) =>
      Theme.of(context).colorScheme.fill_2;
  static Color fill_3(BuildContext context) =>
      Theme.of(context).colorScheme.fill_3;
  static Color fill_4(BuildContext context) =>
      Theme.of(context).colorScheme.fill_4;
  static Color fill_5(BuildContext context) =>
      Theme.of(context).colorScheme.fill_5;
  static Color fill_6(BuildContext context) =>
      Theme.of(context).colorScheme.fill_6;
  static Color fill_7(BuildContext context) =>
      Theme.of(context).colorScheme.fill_7;
  static Color fill_8(BuildContext context) =>
      Theme.of(context).colorScheme.fill_8;
  static Color fill_9(BuildContext context) =>
      Theme.of(context).colorScheme.fill_9;

  static Color text_1(BuildContext context) =>
      Theme.of(context).colorScheme.text_1;
  static Color text_2(BuildContext context) =>
      Theme.of(context).colorScheme.text_2;
  static Color text_3(BuildContext context) =>
      Theme.of(context).colorScheme.text_3;
  static Color text_4(BuildContext context) =>
      Theme.of(context).colorScheme.text_4;

  static Color special_1(BuildContext context) =>
      Theme.of(context).colorScheme.special_1;
  static Color special_2(BuildContext context) =>
      Theme.of(context).colorScheme.special_2;
  static Color special_3(BuildContext context) =>
      Theme.of(context).colorScheme.special_3;
  static Color special_4(BuildContext context) =>
      Theme.of(context).colorScheme.special_4;

  static Color main_1(BuildContext context) =>
      Theme.of(context).colorScheme.main_1;
  static Color main_2(BuildContext context) =>
      Theme.of(context).colorScheme.main_2;
  static Color main_3(BuildContext context) =>
      Theme.of(context).colorScheme.main_3;
  static Color main_4(BuildContext context) =>
      Theme.of(context).colorScheme.main_4;

  static Color rise_1(BuildContext context) =>
      Theme.of(context).colorScheme.rise_1;
  static Color rise_2(BuildContext context) =>
      Theme.of(context).colorScheme.rise_2;
  static Color rise_3(BuildContext context) =>
      Theme.of(context).colorScheme.rise_3;
  static Color fall_1(BuildContext context) =>
      Theme.of(context).colorScheme.fall_1;
  static Color fall_2(BuildContext context) =>
      Theme.of(context).colorScheme.fall_2;
  static Color fall_3(BuildContext context) =>
      Theme.of(context).colorScheme.fall_3;

  static Color warning_1(BuildContext context) =>
      Theme.of(context).colorScheme.warning_1;
  static Color warning_2(BuildContext context) =>
      Theme.of(context).colorScheme.warning_2;
  static Color warning_3(BuildContext context) =>
      Theme.of(context).colorScheme.warning_3;

  static Color line_1(BuildContext context) =>
      Theme.of(context).colorScheme.line_1;
  static Color line_2(BuildContext context) =>
      Theme.of(context).colorScheme.line_2;
  static Color line_3(BuildContext context) =>
      Theme.of(context).colorScheme.line_3;
  static Color line_4(BuildContext context) =>
      Theme.of(context).colorScheme.line_4;
  static Color line_5(BuildContext context) =>
      Theme.of(context).colorScheme.line_5;
  static Color line_6(BuildContext context) =>
      Theme.of(context).colorScheme.line_6;

  static Color rise_fall_text_color(dynamic value_) {
    var value = value_.toString();
    if (value == "--") {
      value = "0";
    }
    //0 绿涨红跌
    //1 红涨绿跌
    var riseFallColor =
        ExStorageUtils.getInt(key: ExStorageUtils.RISE_FALL_COLOR, def: 0);
    if (riseFallColor == 0) {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_green_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_red_color;
      }
    } else {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_red_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_green_color;
      }
    }
  }

  static Color rise_fall_color(dynamic value_) {
    var value = value_.toString();
    if (value == "--") {
      value = "0";
    }
    //0 绿涨红跌
    //1 红涨绿跌
    var riseFallColor =
        ExStorageUtils.getInt(key: ExStorageUtils.RISE_FALL_COLOR, def: 0);
    if (riseFallColor == 0) {
      //绿涨红跌
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_green_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_red_color;
      }
    } else {
      //红涨绿跌
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_red_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_green_color;
      }
    }
  }

  static Color setRiseFallTextColor(
      dynamic value_, Color defaultColor, BuildContext context) {
    var value = value_.toString();
    if (value == "--") {
      value = "0";
    }
    //0 绿涨红跌
    //1 红涨绿跌
    var riseFallColor =
        ExStorageUtils.getInt(key: ExStorageUtils.RISE_FALL_COLOR, def: 0);
    if (riseFallColor == 0) {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColors.rise_1(context);
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return defaultColor;
      } else {
        return ExColors.fall_1(context);
      }
    } else {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColors.fall_1(context);
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return defaultColor;
      } else {
        return ExColors.rise_1(context);
      }
    }
  }

  static Color rise_fall_bg_color(dynamic value_) {
    var value = value_.toString();
    if (value == "--") {
      value = "0";
    }
    //0 绿涨红跌
    //1 红涨绿跌
    var riseFallColor =
        ExStorageUtils.getInt(key: ExStorageUtils.RISE_FALL_COLOR, def: 0);
    if (riseFallColor == 0) {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_green15_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsDark.text_color15_3;
      } else {
        return ExColorsDark.main_red15_color;
      }
    } else {
      if (Decimal.parse(value.toString()) >= Decimal.parse("0")) {
        return ExColorsDark.main_red15_color;
      } else {
        return ExColorsDark.main_green15_color;
      }
    }
  }
}

extension CustomColorScheme on ColorScheme {
  Color get main_color =>
      Get.isDarkMode ? ExColorsDark.main_color : ExColorsLight.main_color;
  Color get main_color_3 =>
      Get.isDarkMode ? ExColorsDark.main_color_3 : ExColorsLight.main_color_3;
  Color get btn_pressed_color => Get.isDarkMode
      ? ExColorsDark.btn_pressed_color
      : ExColorsLight.btn_pressed_color;
  Color get btn_enabled_color => Get.isDarkMode
      ? ExColorsDark.btn_enabled_color
      : ExColorsLight.btn_enabled_color;
  Color get btn_text_color => Get.isDarkMode
      ? ExColorsDark.btn_text_color
      : ExColorsLight.btn_text_color;
  Color get btn_normal_color => Get.isDarkMode
      ? ExColorsDark.btn_normal_color
      : ExColorsLight.btn_normal_color;
  Color get btn_normal_2_color => Get.isDarkMode
      ? ExColorsDark.btn_normal_2_color
      : ExColorsLight.btn_normal_2_color;
  Color get text_color_1 =>
      Get.isDarkMode ? ExColorsDark.text_color_1 : ExColorsLight.text_color_1;
  Color get text_color_2 =>
      Get.isDarkMode ? ExColorsDark.text_color_2 : ExColorsLight.text_color_2;
  Color get text_color_3 =>
      Get.isDarkMode ? ExColorsDark.text_color_3 : ExColorsLight.text_color_3;
  Color get text_color_risk => Get.isDarkMode
      ? ExColorsDark.text_color_risk
      : ExColorsLight.text_color_risk;
  Color get main_bg_color =>
      Get.isDarkMode ? ExColorsDark.main_bg_color : ExColorsLight.main_bg_color;
  Color get main_pop_bg_color => Get.isDarkMode
      ? ExColorsDark.main_pop_bg_color
      : ExColorsLight.main_pop_bg_color;
  Color get card_bg_color_1 => Get.isDarkMode
      ? ExColorsDark.card_bg_color_1
      : ExColorsLight.card_bg_color_1;
  Color get card_bg_color_2 => Get.isDarkMode
      ? ExColorsDark.card_bg_color_2
      : ExColorsLight.card_bg_color_2;
  Color get dialog_bg_color => Get.isDarkMode
      ? ExColorsDark.dialog_bg_color
      : ExColorsLight.dialog_bg_color;
  Color get line_color =>
      Get.isDarkMode ? ExColorsDark.line_color : ExColorsLight.line_color;
  Color get toast_bg_color => Get.isDarkMode
      ? ExColorsDark.toast_bg_color
      : ExColorsLight.toast_bg_color;
  Color get tabbar_bg_color => Get.isDarkMode
      ? ExColorsDark.tabbar_bg_color
      : ExColorsLight.tabbar_bg_color;
  Color get input_bg_color => Get.isDarkMode
      ? ExColorsDark.input_bg_color
      : ExColorsLight.input_bg_color;
  Color get main_red_color => ExColorsDark.main_red_color;
  Color get main_green_color => ExColorsDark.main_green_color;
  Color get kline_bg_top_gradient_color => Get.isDarkMode
      ? ExColorsDark.kline_bg_top_gradient_color
      : ExColorsLight.kline_bg_top_gradient_color;
  Color get kline_bg_bottom_gradient_color => Get.isDarkMode
      ? ExColorsDark.kline_bg_bottom_gradient_color
      : ExColorsLight.kline_bg_bottom_gradient_color;

  //----------------------6.0新颜色规范----------------------
  Color get fill_1 =>
      Get.isDarkMode ? ExColorsDark.fill_1 : ExColorsLight.fill_1;
  Color get fill_2 =>
      Get.isDarkMode ? ExColorsDark.fill_2 : ExColorsLight.fill_2;
  Color get fill_3 =>
      Get.isDarkMode ? ExColorsDark.fill_3 : ExColorsLight.fill_3;
  Color get fill_4 =>
      Get.isDarkMode ? ExColorsDark.fill_4 : ExColorsLight.fill_4;
  Color get fill_5 =>
      Get.isDarkMode ? ExColorsDark.fill_5 : ExColorsLight.fill_5;
  Color get fill_6 =>
      Get.isDarkMode ? ExColorsDark.fill_6 : ExColorsLight.fill_6;
  Color get fill_7 =>
      Get.isDarkMode ? ExColorsDark.fill_7 : ExColorsLight.fill_7;
  Color get fill_8 =>
      Get.isDarkMode ? ExColorsDark.fill_8 : ExColorsLight.fill_8;
  Color get fill_9 =>
      Get.isDarkMode ? ExColorsDark.fill_9 : ExColorsLight.fill_9;

  Color get text_1 =>
      Get.isDarkMode ? ExColorsDark.text_1 : ExColorsLight.text_1;
  Color get text_2 =>
      Get.isDarkMode ? ExColorsDark.text_2 : ExColorsLight.text_2;
  Color get text_3 =>
      Get.isDarkMode ? ExColorsDark.text_3 : ExColorsLight.text_3;
  Color get text_4 =>
      Get.isDarkMode ? ExColorsDark.text_4 : ExColorsLight.text_4;

  Color get special_1 =>
      Get.isDarkMode ? ExColorsDark.special_1 : ExColorsLight.special_1;
  Color get special_2 =>
      Get.isDarkMode ? ExColorsDark.special_2 : ExColorsLight.special_2;
  Color get special_3 =>
      Get.isDarkMode ? ExColorsDark.special_3 : ExColorsLight.special_3;
  Color get special_4 =>
      Get.isDarkMode ? ExColorsDark.special_4 : ExColorsLight.special_4;

  Color get main_1 =>
      Get.isDarkMode ? ExColorsDark.main_1 : ExColorsLight.main_1;
  Color get main_2 =>
      Get.isDarkMode ? ExColorsDark.main_2 : ExColorsLight.main_2;
  Color get main_3 =>
      Get.isDarkMode ? ExColorsDark.main_3 : ExColorsLight.main_3;
  Color get main_4 =>
      Get.isDarkMode ? ExColorsDark.main_4 : ExColorsLight.main_4;

  Color get rise_1 =>
      Get.isDarkMode ? ExColorsDark.rise_1 : ExColorsLight.rise_1;
  Color get rise_2 =>
      Get.isDarkMode ? ExColorsDark.rise_2 : ExColorsLight.rise_2;
  Color get rise_3 =>
      Get.isDarkMode ? ExColorsDark.rise_3 : ExColorsLight.rise_3;
  Color get fall_1 =>
      Get.isDarkMode ? ExColorsDark.fall_1 : ExColorsLight.fall_1;
  Color get fall_2 =>
      Get.isDarkMode ? ExColorsDark.fall_2 : ExColorsLight.fall_2;
  Color get fall_3 =>
      Get.isDarkMode ? ExColorsDark.fall_3 : ExColorsLight.fall_3;

  Color get warning_1 =>
      Get.isDarkMode ? ExColorsDark.warning_1 : ExColorsLight.warning_1;
  Color get warning_2 =>
      Get.isDarkMode ? ExColorsDark.warning_2 : ExColorsLight.warning_2;
  Color get warning_3 =>
      Get.isDarkMode ? ExColorsDark.warning_3 : ExColorsLight.warning_3;

  Color get line_1 =>
      Get.isDarkMode ? ExColorsDark.line_1 : ExColorsLight.line_1;
  Color get line_2 =>
      Get.isDarkMode ? ExColorsDark.line_2 : ExColorsLight.line_2;
  Color get line_3 =>
      Get.isDarkMode ? ExColorsDark.line_3 : ExColorsLight.line_3;
  Color get line_4 =>
      Get.isDarkMode ? ExColorsDark.line_4 : ExColorsLight.line_4;
  Color get line_5 =>
      Get.isDarkMode ? ExColorsDark.line_5 : ExColorsLight.line_5;
  Color get line_6 =>
      Get.isDarkMode ? ExColorsDark.line_6 : ExColorsLight.line_6;
}

class ExColorsLight {
  static final ExColorsUtil _colorUtil = ExColorsUtil();
  //主色
  static final Color main_color = _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static final Color main_color_3 =
      _colorUtil.main_3 ?? const Color(0xFFDFE7FF);

  static const Color tag_color = Color(0x262B61FF);

  //按钮颜色
  static final Color btn_pressed_color =
      _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static const Color btn_enabled_color = Color(0xFFD5D7DA);
  static const Color btn_text_color = Color(0xFFFFFFFF);
  static const Color btn_normal_color = Color(0xFFECF0F9);
  static const Color btn_normal_2_color = Color(0xFFD5D7DA);

  //文字颜色
  static const Color text_color_1 = Color(0xFF101111);
  static const Color text_color_2 = Color(0xFF606266);
  static const Color text_color_3 = Color(0xFFA0A2AA);
  static final Color text_color_risk =
      _colorUtil.main_4 ?? const Color(0xFF2B61FF);

  //背景颜色
  static const Color main_bg_color = Color(0xFFFFFFFF);
  static const Color main_pop_bg_color = Color(0xFF111111);
  static const Color card_bg_color_1 = Color(0xFFFFFFFF);
  static const Color card_bg_color_2 = Color(0xFFEDEFF2);
  static const Color dialog_bg_color = Color(0xFFFFFFFF);
  static const Color search_bg_color = Color(0xFFFFFFFF);
  static const Color input_bg_color = Color(0xFFF5F7FB);

  //分割线颜色
  static const Color line_color = Color(0xFFECF0F9);

  //TAB背景颜色
  static const Color tabbar_bg_color = Color(0xFFF5F7FB);

  //Toast提示背景色
  static const Color toast_bg_color = Color(0xFF303133);

  static const Color kline_bg_top_gradient_color = Color(0xFFFFFFFF);
  static const Color kline_bg_bottom_gradient_color = Color(0xFFFFFFFF);

  //----------------------6.0新颜色规范Light----------------------
  //填充色Fill
  static const Color fill_1 = Color(0xFFF5F7FB);
  static const Color fill_2 = Color(0xFFFFFFFF);
  static const Color fill_3 = Color(0xFFEDEFF2);
  static const Color fill_4 = Color(0xFFECF0F9);
  static const Color fill_5 = Color(0xFFD5D7DA);
  static const Color fill_6 = Color(0xFFFFFFFF);
  static const Color fill_7 = Color(0xFF000000);
  static const Color fill_8 = Color(0xFF303133);
  static const Color fill_9 = Color(0xFFF5F7FB);
  //文字色Text
  static const Color text_1 = Color(0xFF101111);
  static const Color text_2 = Color(0xFF606266);
  static const Color text_3 = Color(0xFFA0A2AA);
  static final Color text_4 = _colorUtil.text_4 ?? const Color(0xFFFFFFFF);
  //特殊色Special
  static const Color special_1 = Color(0xFFF5F7FB);
  static const Color special_2 = Color(0xFFF5F7FB);
  static const Color special_3 = Color(0xFFFFFFFF);
  static const Color special_4 = Color(0xFFA0A2AA);
  //主色Main
  static final Color main_1 = _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static final Color main_2 = _colorUtil.main_2 ?? const Color(0xFF5581FF);
  static final Color main_3 = _colorUtil.main_3 ?? const Color(0xFFDFE7FF);
  static final Color main_4 = _colorUtil.main_4 ?? const Color(0xFF2B61FF);
  //辅助色.涨跌色
  static const Color rise_1 = Color(0xFF00B595);
  static const Color rise_2 = Color(0xFF26C0A4);
  static const Color rise_3 = Color(0xFFD9F4EF);
  static const Color fall_1 = Color(0xFFD1425E);
  static const Color fall_2 = Color(0xFFD75E75);
  static const Color fall_3 = Color(0xFFF8E3E7);
  //辅助色.功能色
  static const Color warning_1 = Color(0xFFE9A92A);
  static const Color warning_2 = Color(0xFFFDF6EA);
  static const Color warning_3 = Color(0xFFDA687E);
  //K线指标色
  static const Color line_1 = Color(0xFFFBCD2D);
  static const Color line_2 = Color(0xFF5FCFBF);
  static const Color line_3 = Color(0xFFDD89F5);
  static const Color line_4 = Color(0xFFFFA989);
  static const Color line_5 = Color(0xFFFFC793);
  static const Color line_6 = Color(0xFFB499D8);
}

class ExColorsDark {
  static final ExColorsUtil _colorUtil = ExColorsUtil();

  //主色
  static final Color main_color = _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static final Color main_color_3 =
      _colorUtil.main_3 ?? const Color(0xFF151D35);

  static const Color tag_color = Color(0x262B61FF);

  //按钮颜色
  static final Color btn_pressed_color =
      _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static const Color btn_enabled_color = Color(0xFF39393C);
  static const Color btn_text_color = Color(0xFFFFFFFF);
  static const Color btn_normal_color = Color(0xFFECF0F9);
  static const Color btn_normal_2_color = Color(0xFF39393C);

  //文字颜色
  static const Color text_color_1 = Color(0xFFFFFFFF);
  static const Color text_color_2 = Color(0xFF909399);
  static const Color text_color_3 = Color(0xFF505255);
  static final Color text_color_risk =
      _colorUtil.main_4 ?? const Color(0xFF2B61FF);

  //背景颜色
  static const Color main_bg_color = Color(0xFF010101);
  static const Color main_pop_bg_color = Color(0xFF111111);
  static const Color card_bg_color_1 = Color(0xFF111111);
  static const Color card_bg_color_2 = Color(0xFF232326);
  static const Color dialog_bg_color = Color(0xFF171717);
  static const Color search_bg_color = Color(0xFF232326);
  static const Color input_bg_color = Color(0xFF232326);

  //分割线颜色
  static const Color line_color = Color(0xFF282828);

  //TAB背景颜色
  static const Color tabbar_bg_color = Color(0xFF1A1A1A);

  //Toast提示背景色
  static const Color toast_bg_color = Color(0xFF303133);

  static const Color kline_bg_top_gradient_color = Color(0xFF010101);
  static const Color kline_bg_bottom_gradient_color = Color(0xFF111111);

  //涨跌色/红色
  static const Color main_red_color = Color(0xFFD1425E);

  //涨跌色/绿色
  static const Color main_green_color = Color(0xFF00B595);

  static const Color main_red15_color = Color(0x26D1425E);

  static const Color main_green15_color = Color(0x2600B595);

  static const Color text_color15_3 = Color(0x26505255);

  //----------------------6.0新颜色规范Dark----------------------
  //填充色Fill
  static const Color fill_1 = Color(0xFF010101);
  static const Color fill_2 = Color(0xFF111111);
  static const Color fill_3 = Color(0xFF232326);
  static const Color fill_4 = Color(0xFF282828);
  static const Color fill_5 = Color(0xFF39393C);
  static const Color fill_6 = Color(0xFF171717);
  static const Color fill_7 = Color(0xFF000000);
  static const Color fill_8 = Color(0xFF303133);
  static const Color fill_9 = Color(0xFF1A1A1A);
  //文字色Text
  static const Color text_1 = Color(0xFFFFFFFF);
  static const Color text_2 = Color(0xFF909399);
  static const Color text_3 = Color(0xFF505255);
  static final Color text_4 = _colorUtil.text_4 ?? const Color(0xFFFFFFFF);
  //特殊色Special
  static const Color special_1 = Color(0xFF111111);
  static const Color special_2 = Color(0xFF232326);
  static const Color special_3 = Color(0xFF232326);
  static const Color special_4 = Color(0xFF909399);
  //主色Main
  static final Color main_1 = _colorUtil.main_1 ?? const Color(0xFF2B61FF);
  static final Color main_2 = _colorUtil.main_2 ?? const Color(0xFF5581FF);
  static final Color main_3 = _colorUtil.main_3 ?? const Color(0xFF151D35);
  static final Color main_4 = _colorUtil.main_4 ?? const Color(0xFF4071FF);
  //辅助色.涨跌色
  static const Color rise_1 = Color(0xFF00B595);
  static const Color rise_2 = Color(0xFF26C0A4);
  static const Color rise_3 = Color(0xFF0E2A25);
  static const Color fall_1 = Color(0xFFD1425E);
  static const Color fall_2 = Color(0xFFD75E75);
  static const Color fall_3 = Color(0xFF2E181D);
  //辅助色.功能色
  static const Color warning_1 = Color(0xFFE9A92A);
  static const Color warning_2 = Color(0xFF272014);
  static const Color warning_3 = Color(0xFFAA384F);
  //K线指标色
  static const Color line_1 = Color(0xFFFFDC61);
  static const Color line_2 = Color(0xFF5FCFBF);
  static const Color line_3 = Color(0xFFDD89F5);
  static const Color line_4 = Color(0xFFFFA693);
  static const Color line_5 = Color(0xFFFFC793);
  static const Color line_6 = Color(0xFFB499D8);

  static Color rise_fall_text_color(dynamic value_) {
    var value = value_.toString();
    if (value == "--") {
      value = "0";
    }
    //0 绿涨红跌
    //1 红涨绿跌
    var riseFallColor =
        ExStorageUtils.getInt(key: ExStorageUtils.RISE_FALL_COLOR, def: 0);
    if (riseFallColor == 0) {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_green_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_red_color;
      }
    } else {
      if (Decimal.parse(value.toString()) > Decimal.parse("0")) {
        return ExColorsDark.main_red_color;
      } else if (Decimal.parse(value.toString()) == Decimal.parse("0")) {
        return ExColorsLight.text_color_3;
      } else {
        return ExColorsDark.main_green_color;
      }
    }
  }
}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

  return Color(int.parse(hex.substring(1), radix: 16) +
      (hex.length == 7 ? 0xFF000000 : 0x00000000));
}
