import 'dart:ui';
import 'package:library_kline/utils/kline_color_constant.dart';

class ExColorsUtil {
  ExColorsUtil._internal();
  factory ExColorsUtil() => _instance;
  static final ExColorsUtil _instance = ExColorsUtil._internal();
  Color? main_1 = const Color(0xFF2B61FF);
  Color? main_2 = const Color(0xFF5581FF);
  Color? main_3 = const Color(0xFFDFE7FF);
  Color? main_4 = const Color(0xFF2B61FF);
  Color? text_4 = const Color(0xFFFFFFFF);

 static update({String? main1, String? main2, String? main3, String? main4, String? text4}) {
    if (main1 != null && main1.length >= 6) _instance.main_1 = hexToColor(main1.substring(0,1) == "#" ? main1 : "#$main1");
    if (main2 != null && main2.length >= 6) _instance.main_2 = hexToColor(main2.substring(0,1) == "#" ? main2 : "#$main2");
    if (main3 != null && main3.length >= 6) _instance.main_3 = hexToColor(main3.substring(0,1) == "#" ? main3 : "#$main3");
    if (main4 != null && main4.length >= 6) _instance.main_4 = hexToColor(main4.substring(0,1) == "#" ? main4 : "#$main4");
    if (text4 != null && text4.length >= 6) _instance.text_4 = hexToColor(text4.substring(0,1) == "#" ? text4 : "#$text4");
  }
}
