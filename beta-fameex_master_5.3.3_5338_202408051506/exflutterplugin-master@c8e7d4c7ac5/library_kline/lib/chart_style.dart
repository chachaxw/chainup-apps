import 'package:flutter/material.dart' show BuildContext, Color;
import 'package:get/get.dart';
import 'package:library_kline/utils/kline_color_constant.dart';

import 'kline_constant.dart';

class ChartColors {
  ChartColors._();

  //背景颜色
  static const Color bgColor = Color(0xFFF5F7FB) ;
  static final Color kLineColor = ExColorsDark.main_color;
  static Color gridColor = Get.isDarkMode? ExColorsDark.fill_4 :ExColorsLight.fill_4;
  static const List<Color> kLineShadowColor = [Color(0x552B61FF), Color(0x00FFFFFF)]; //k线阴影渐变
  static const Color ma5Color = Color(0xffFBCD2D);
  static const Color ma10Color = Color(0xff5FCFBF);
  static const Color ma30Color = Color(0xffDD89F5);
  static  Color upColor = KlineConstant.COLOR_TYPE == 0 ? Color(0xff00B595) : Color(0xffC15466);
  static  Color dnColor = KlineConstant.COLOR_TYPE == 0 ? Color(0xffC15466) : Color(0xff00B595);
  static const Color volColor = Color(0xffE9A991);

  static const Color macdColor = Color(0xff4729AE);
  static const Color difColor = Color(0xffC9B885);
  static const Color deaColor = Color(0xff6CB0A6);

  static const Color kColor = Color(0xffC9B885);
  static const Color dColor = Color(0xff6CB0A6);
  static const Color jColor = Color(0xff9979C6);
  static const Color rsiColor = Color(0xffC9B885);
  static Color volTextColor = Color(0xFFFFA989); //marker 文字颜色

  static Color markerTextColor = Get.isDarkMode? ExColorsDark.text_color_1 :ExColorsLight.text_color_1; //marker 文字颜色
  static Color markerLabelColor = Get.isDarkMode? ExColorsDark.text_color_2 :ExColorsLight.text_color_2; //marker 文字颜色

  static  Color yAxisTextColor = Get.isDarkMode? ExColorsDark.special_4 :ExColorsLight.special_4; //右边y轴刻度
  // static const Color xAxisTextColor = Color(0xff60738E); //下方时间刻度
  static  Color xAxisTextColor = Get.isDarkMode? ExColorsDark.special_4 :ExColorsLight.special_4; //下方时间刻度

  static  Color maxMinTextColor = Get.isDarkMode? ExColorsDark.text_color_1 :ExColorsLight.text_color_1; //最大最小值的颜色

  // static const Color maxMinTextColor = Color(0xffffffff); //最大最小值的颜色
  // static Color maxMinTextColor(BuildContext context)  => ExKlineColors.text_color_3(context); //最大最小值的颜色

  //深度颜色
  static Color depthBuyColor  = KlineConstant.COLOR_TYPE == 0 ? Color(0xff00B595) : Color(0xffC15866);
  static  Color depthSellColor = KlineConstant.COLOR_TYPE == 0 ? Color(0xffC15866) : Color(0xff00B595);

  //选中后显示值边框颜色
  static Color markerBorderColor = Get.isDarkMode? ExColorsDark.kline_marker_border_color :ExColorsLight.kline_marker_border_color;

  //选中后显示值背景的填充颜色
  static Color markerBgColor = Get.isDarkMode? ExColorsDark.kline_marker_fill_color :ExColorsLight.kline_marker_fill_color;

  static Color klineMarkerBgColor = Get.isDarkMode? ExColorsDark.fill_6 :ExColorsLight.fill_6;
  static Color smallKlineMarkerBgColor = Get.isDarkMode? ExColorsDark.dialog_bg_color : const Color(0xffffffff);

  //十字交叉线颜色
  static Color crossLineColor = Get.isDarkMode? ExColorsDark.text_color_2 :ExColorsLight.text_color_3;

  //实时线颜色等
  static Color realTimeBgColor = Get.isDarkMode? ExColorsDark.real_time_Bg_Color :ExColorsLight.real_time_Bg_Color;
  static Color rightRealTimeTextColor = Get.isDarkMode? ExColorsDark.main_color :ExColorsLight.main_color;
  static Color realTimeTextBorderColor =Get.isDarkMode? ExColorsDark.card_bg_color_2 :ExColorsLight.card_bg_color_2;
  static Color realTimeTextBgColor = Get.isDarkMode? ExColorsDark.fill_3 :ExColorsLight.fill_3;
  static const Color realTimeTextColor = Color(0xffffffff);
  static Color realTimeText2Color = Get.isDarkMode? ExColorsDark.text_color_1 :ExColorsLight.text_color_1;
  static Color realTimeLine2Color = Get.isDarkMode? ExColorsDark.text_color_3 :ExColorsLight.text_color_3;

  //实时线
  static final Color realTimeLineColor = ExColorsDark.main_color;
  static const Color realTimeLongLineColor = Color(0xff4C86CD);

  static Color simpleLineUpColor = KlineConstant.COLOR_TYPE == 0 ? Color(0xff00B595) : Color(0xffC15466);
  static Color simpleLineDnColor = KlineConstant.COLOR_TYPE == 0 ? Color(0xffC15466) : Color(0xff00B595);

  // 深度图 买卖
  static Color buySellText2Color = Get.isDarkMode? ExColorsDark.text_color_2 :ExColorsLight.text_color_2;
  static Color text_color_2 = Get.isDarkMode? ExColorsDark.text_color_2 :ExColorsLight.text_color_2;
  static Color longPressCircleBg = Get.isDarkMode? ExColorsDark.text_color_1 :ExColorsLight.text_color_2;
  static Color longPressPathTextColor = Get.isDarkMode? ExColorsDark.text_color_1 :ExColorsLight.text_color_1; //marker 文字颜色
  static Color longPressPathBgColor = Get.isDarkMode? const Color(0xFF39393C) :const Color(0xFFEDEFF2); //marker 文字颜色
  static Color longPressDateBorderLineColor = Get.isDarkMode? ExColorsDark.text_color_3 : ExColorsLight.text_color_3;
  static Color fill_2 = Get.isDarkMode? ExColorsDark.fill_2 : ExColorsLight.fill_2;
  static Color fill_5 = Get.isDarkMode? ExColorsDark.fill_5 : ExColorsLight.fill_5;


}

class ChartStyle {
  ChartStyle._();

  //点与点的距离
  static const double pointWidth = 7.7;

  //蜡烛宽度
  static const double candleWidth = 6.9;

  //蜡烛中间线的宽度
  static const double candleLineWidth = 1.0;

  //vol柱子宽度
  static const double volWidth = 6.9;

  //macd柱子宽度
  static const double macdWidth = 6.9;

  //垂直交叉线宽度
  static const double vCrossWidth = 0.5;

  //水平交叉线宽度
  static const double hCrossWidth = 0.5;

  //网格
  static int gridRows = 4, gridColumns = 4;

  static double topPadding = 4.0;
  static const double maxMainTopPadding = 46.0;
  static const bottomDateHigh = 2.0, childPadding = 20.0,bottomPadding=25.0;

  static const double defaultTextSize = 10.0;

  static const String fontFamily = "HarmonyOS_Sans_SC_Regular";
}
