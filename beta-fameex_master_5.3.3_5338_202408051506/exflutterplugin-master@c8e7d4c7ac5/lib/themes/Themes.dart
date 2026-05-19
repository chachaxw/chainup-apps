import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constant.dart';
import '../constants/color_constant.dart';
import '../utils/device_utils.dart';

class ExThemes {
  static TextStyle textstyle_sb_color1_28(BuildContext context) => TextStyle(
      fontSize: 28,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_24(BuildContext context) => TextStyle(
      fontSize: 24,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_hb_color1_24(BuildContext context) => TextStyle(
      fontSize: 24,
      color: ExColors.text_color_1(context),
      fontFamily: _fontHb());

  static TextStyle textstyle_sb_color1_20(BuildContext context) => TextStyle(
      fontSize: 20,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_13(BuildContext context) => TextStyle(
      fontSize: 13,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sb_color1_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_1(context),
      fontFamily: "HarmonyOS_Sans_SC_Bold");

  static TextStyle textstyle_sm_color1_32(BuildContext context) => TextStyle(
      fontSize: 32,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_28(BuildContext context) => TextStyle(
      fontSize: 28,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_hb_color1_28(BuildContext context) => TextStyle(
      fontSize: 28,
      color: ExColors.text_color_1(context),
      fontFamily: _fontHb(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_24(BuildContext context) => TextStyle(
      fontSize: 24,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_20(BuildContext context) => TextStyle(
      fontSize: 20,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_13(BuildContext context) => TextStyle(
      fontSize: 13,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color1_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color2_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_13(BuildContext context) => TextStyle(
      fontSize: 13,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color3_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sr_color1_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color1_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color1_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color1_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr(),
      fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle textstyle_sr_color1_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color1_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_1(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color2_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_2(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_hr_color3_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.text_color_3(context),
      fontFamily: _fontHr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_10(BuildContext context) => TextStyle(
      fontSize: 10,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color3_8(BuildContext context) => TextStyle(
      fontSize: 8,
      color: ExColors.text_color_3(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color_red_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr(),
      fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle textstyle_sr_color_red_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSr(),
      fontWeight: _fontWeightSr());

  static TextStyle textstyle_sr_color_green_14(BuildContext context) =>
      TextStyle(
          fontSize: 14,
          color: ExColors.main_green_color(context),
          fontFamily: _fontSr(),
          fontWeight: _fontWeightSr());

  static TextStyle textstyle_sm_color_red_12(BuildContext context) => TextStyle(
      fontSize: 12,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_red_14(BuildContext context) => TextStyle(
      fontSize: 14,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_red_16(BuildContext context) => TextStyle(
      fontSize: 16,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_red_18(BuildContext context) => TextStyle(
      fontSize: 18,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_red_28(BuildContext context) => TextStyle(
      fontSize: 28,
      color: ExColors.main_red_color(context),
      fontFamily: _fontSm(),
      fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_green_12(BuildContext context) =>
      TextStyle(
          fontSize: 12,
          color: ExColors.main_green_color(context),
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_green_14(BuildContext context) =>
      TextStyle(
          fontSize: 14,
          color: ExColors.main_green_color(context),
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_white_14(BuildContext context) =>
      TextStyle(
          fontSize: 14,
          color: ExColorsDark.text_color_1,
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_white_12(BuildContext context) =>
      TextStyle(
          fontSize: 12,
          color: ExColorsDark.text_color_1,
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_sm_color_white_18(BuildContext context) =>
      TextStyle(
          fontSize: 18,
          color: ExColorsDark.text_color_1,
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_sr_color_risk_12(BuildContext context) =>
      TextStyle(
          fontSize: 12,
          color: ExColors.text_color_risk(context),
          fontFamily: _fontSr(),
          fontWeight: _fontWeightSr());

  static TextStyle textstyle_sm_color_risk_12(BuildContext context) =>
      TextStyle(
          fontSize: 12,
          color: ExColors.text_color_risk(context),
          fontFamily: _fontSm(),
          fontWeight: _fontWeightSm());

  static TextStyle textstyle_hm_color1_12(BuildContext context) => TextStyle(
      fontSize: 12, color: ExColors.text_1(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color1_20(BuildContext context) => TextStyle(
      fontSize: 20, color: ExColors.text_1(context), fontFamily: _fontHm());

  static TextStyle textstyle_hr_color2_12(BuildContext context) => TextStyle(
      fontSize: 12, color: ExColors.text_2(context), fontFamily: _fontHr());

  static TextStyle textstyle_hr_color2_14(BuildContext context) => TextStyle(
      fontSize: 14, color: ExColors.text_2(context), fontFamily: _fontHr());

  static TextStyle textstyle_hr_color1_12(BuildContext context) => TextStyle(
      fontSize: 12, color: ExColors.text_1(context), fontFamily: _fontHr());

  static TextStyle textstyle_hm_color1_14(BuildContext context) => TextStyle(
      fontSize: 14, color: ExColors.text_1(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color1_16(BuildContext context) => TextStyle(
      fontSize: 16, color: ExColors.text_1(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color2_12(BuildContext context) => TextStyle(
      fontSize: 12, color: ExColors.text_2(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color2_14(BuildContext context) => TextStyle(
      fontSize: 14, color: ExColors.text_2(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color3_12(BuildContext context) => TextStyle(
      fontSize: 12, color: ExColors.text_3(context), fontFamily: _fontHm());

  static TextStyle textstyle_hm_color1_28(BuildContext context) => TextStyle(
      fontSize: 28, color: ExColors.text_1(context), fontFamily: _fontHm());

  static TextStyle textstyle_hr_color2_10(BuildContext context) => TextStyle(
      fontSize: 10, color: ExColors.text_2(context), fontFamily: _fontHr());

  static TextStyle textstyle_hr_color1_10(BuildContext context) => TextStyle(
      fontSize: 10, color: ExColors.text_1(context), fontFamily: _fontHr());

  static String _fontSm() => "HarmonyOS_Sans_SC_Medium";

  static String _fontSr() => "HarmonyOS_Sans_SC_Regular";

  static String _fontSb() => "HarmonyOS_Sans_SC_Bold";

  static FontWeight _fontWeightSm() =>
      Device.isAndroid ? FontWeight.w500 : FontWeight.w600;

  static FontWeight _fontWeightSr() =>
      Device.isAndroid ? FontWeight.w400 : FontWeight.w500;

  static FontWeight _fontWeightSb() =>
      Device.isAndroid ? FontWeight.w700 : FontWeight.w800;

  static String _fontHb() => "HarmonyOS_Sans_SC_Bold";

  static String _fontHm() => "HarmonyOS_Sans_SC_Medium";

  static String _fontHr() => "HarmonyOS_Sans_SC_Regular";

  static ButtonStyle getButtonStyle() {
    return ButtonStyle(
      overlayColor: MaterialStateProperty.all(ExColorsDark.btn_pressed_color),
      animationDuration: const Duration(milliseconds: 200),
      padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
      shape: MaterialStateProperty.all(const StadiumBorder()),
    );
  }

  static BoxDecoration getBoxCardBg2Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.card_bg_color_2(context),
      borderRadius: BorderRadius.circular(4),
    );
  }

  static BoxDecoration getBoxFill1Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.fill_1(context),
      borderRadius: BorderRadius.circular(4),
    );
  }

  static BoxDecoration getBoxWhiteRadius12(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration getBoxFill1Radius100(BuildContext context) {
    return BoxDecoration(
      color: ExColors.fill_1(context),
      borderRadius: BorderRadius.circular(100),
    );
  }

  static BoxDecoration getBoxCardTipsRadius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.main_yellow10_color(context),
      borderRadius: BorderRadius.circular(4),
    );
  }

  static BoxDecoration getBoxMainBgRadius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.main_bg_color(context),
      borderRadius: BorderRadius.circular(4),
    );
  }

  static BoxDecoration getBoxCardBg2Radius38(BuildContext context) {
    return BoxDecoration(
      color: ExColors.card_bg_color_2(context),
      borderRadius: BorderRadius.circular(38),
    );
  }

  static BoxDecoration getBoxlineCardBg2Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.card_bg_color_2(context),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: ExColors.main_color(context),
        width: 1,
      ),
    );
  }
  static BoxDecoration getBoxWarning2Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.warning_2(context),
      borderRadius: BorderRadius.circular(4),
    );
  }
  static BoxDecoration getBoxSpecial2Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.special_2(context),
      borderRadius: BorderRadius.circular(4),
    );
  }
  static BoxDecoration getBoxMain3Radius4(BuildContext context) {
    return BoxDecoration(
      color: ExColors.main_3(context),
      borderRadius: BorderRadius.circular(4),
    );
  }
  static BoxDecoration getBoxCardBg1RadiusTop12(BuildContext context) {
    return BoxDecoration(
      color: ExColors.card_bg_color_1(context),
      borderRadius: const BorderRadius.only(   
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    );
  }

  static BoxDecoration getBoxDialogRadius12(BuildContext context) {
    return BoxDecoration(
      color: ExColors.dialog_bg_color(context),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration getTagCardMainColorRadius2() {
    return BoxDecoration(
      color: ExColorsDark.tag_color,
      borderRadius: BorderRadius.circular(2),
    );
  }

  static Widget getC2cTypeTag(String? colorStr) {
    return Container(
      height: 14,
      width: 4,
      decoration: BoxDecoration(
        color: hexToColor(colorStr ?? "#FF5100"),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Button公共样式，无点击效果
  /// [ButtonStyle]
  static ButtonStyle getTransparentStyle() {
    return ButtonStyle(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  /// Button公共样式，无圆角
  /// [ButtonStyle]
  static ButtonStyle getNoShapeStyle() {
    return ButtonStyle(
      shadowColor: MaterialStateProperty.all(ExColorsDark.main_color),
      animationDuration: const Duration(milliseconds: 200),
      padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
    );
  }

  static TextStyle getUnLineStyle(BuildContext context, double _fontSize) {
    return ExThemes.textstyle_sm_color2_12(context).copyWith(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dashed,
      shadows: [
        Shadow(
            color: ExColors.text_color_2(context), offset: const Offset(0, -2))
      ],
      color: Colors.transparent,
      decorationColor: ExColors.text_color_2(context),
      fontSize: _fontSize,
    );
  }

  static ThemeData lightTheme = ThemeData(
      primaryColor: ExColorsLight.main_bg_color,
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ExColorsLight.main_bg_color,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
          titleTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: ExColorsLight.main_bg_color,
          elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          hintStyle: const TextStyle(
            fontSize: 14,
          )),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Colors.red),
      textTheme: TextTheme(
          headline1: const TextStyle(
              letterSpacing: -1.5,
              fontSize: 48,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          headline2: const TextStyle(
              letterSpacing: -1.0,
              fontSize: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          headline3: const TextStyle(
              letterSpacing: -1.0,
              fontSize: 32,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          headline4: const TextStyle(
              letterSpacing: -1.0,
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w600),
          headline5: const TextStyle(
              letterSpacing: -1.0,
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600),
          headline6: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          subtitle1: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          subtitle2: const TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          bodyText1: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          bodyText2: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w400),
          button: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          caption: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w400),
          overline: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5)),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(splashFactory: NoSplash.splashFactory)));

  static ThemeData darkTheme = ThemeData(
      primaryColor: ExColorsDark.main_bg_color,
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ExColorsDark.main_bg_color,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: ExColorsDark.main_bg_color,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomAppBarColor: ColorConstants.gray800,
      inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          hintStyle: const TextStyle(
            fontSize: 14,
          )),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Colors.white),
      textTheme: TextTheme(
          headline1: TextStyle(
              letterSpacing: -1.5,
              fontSize: 48,
              color: Colors.grey.shade50,
              fontWeight: FontWeight.bold),
          headline2: TextStyle(
              letterSpacing: -1.0,
              fontSize: 40,
              color: Colors.grey.shade50,
              fontWeight: FontWeight.bold),
          headline3: TextStyle(
              letterSpacing: -1.0,
              fontSize: 32,
              color: Colors.grey.shade50,
              fontWeight: FontWeight.bold),
          headline4: TextStyle(
              letterSpacing: -1.0,
              color: Colors.grey.shade50,
              fontSize: 28,
              fontWeight: FontWeight.w600),
          headline5: TextStyle(
              letterSpacing: -1.0,
              color: Colors.grey.shade50,
              fontSize: 24,
              fontWeight: FontWeight.w600),
          headline6: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          subtitle1: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 16,
              fontWeight: FontWeight.w600),
          subtitle2: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          bodyText1: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          bodyText2: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 14,
              fontWeight: FontWeight.w400),
          button: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          caption: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 12,
              fontWeight: FontWeight.w600),
          overline: TextStyle(
              color: Colors.grey.shade50,
              fontSize: 10,
              fontWeight: FontWeight.w400)),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(splashFactory: NoSplash.splashFactory)));

  static StrutStyle textStrutStyle() =>
      const StrutStyle(forceStrutHeight: true, leading: 0, height: 1);

  static StrutStyle textStrutStyle11() =>
      const StrutStyle(forceStrutHeight: true, leading: 0, height: 1.0);

  static StrutStyle textStrutStyle13() =>
      const StrutStyle(forceStrutHeight: true, leading: 0, height: 1.3);

  static StrutStyle textStrutStyleEf() =>
      const StrutStyle(forceStrutHeight: true, leading: 0, height: 1.5);
}
