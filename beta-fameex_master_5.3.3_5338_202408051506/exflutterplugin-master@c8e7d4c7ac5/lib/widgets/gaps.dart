import 'package:chainup_flutter_ex/widgets/hor_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import 'custom_skeleton_view.dart';

class Gaps {
  static const Widget hGap0 = SizedBox(width: 0);
  static const Widget hGap2 = SizedBox(width: 2);
  static const Widget hGap4 = SizedBox(width: 4);
  static const Widget hGap5 = SizedBox(width: 5);
  static const Widget hGap6 = SizedBox(width: 6);
  static const Widget hGap8 = SizedBox(width: 8);
  static const Widget hGap10 = SizedBox(width: 10);
  static const Widget hGap12 = SizedBox(width: 12);
  static const Widget hGap15 = SizedBox(width: 15);
  static const Widget hGap16 = SizedBox(width: 16);
  static const Widget hGap20 = SizedBox(width: 20);
  static const Widget hGap26 = SizedBox(width: 26);
  static const Widget hGap32 = SizedBox(width: 32);
  static const Widget hGap38 = SizedBox(width: 38);

  static const Widget vGap2 = SizedBox(height: 2);
  static const Widget vGap3 = SizedBox(height: 3);
  static const Widget vGap4 = SizedBox(height: 4);
  static const Widget vGap5 = SizedBox(height: 5);
  static const Widget vGap6 = SizedBox(height: 6);
  static const Widget vGap8 = SizedBox(height: 8);
  static const Widget vGap9 = SizedBox(height: 9);

  static const Widget vGap10 = SizedBox(height: 10);
  static const Widget vGap12 = SizedBox(height: 12);
  static const Widget vGap14 = SizedBox(height: 14);
  static const Widget vGap15 = SizedBox(height: 15);
  static const Widget vGap16 = SizedBox(height: 16);
  static const Widget vGap17 = SizedBox(height: 17);
  static const Widget vGap18 = SizedBox(height: 18);
  static const Widget vGap20 = SizedBox(height: 20);
  static const Widget vGap24 = SizedBox(height: 24);
  static const Widget vGap25 = SizedBox(height: 25);
  static const Widget vGap26 = SizedBox(height: 26);
  static const Widget vGap28 = SizedBox(height: 28);
  static const Widget vGap30 = SizedBox(height: 30);
  static const Widget vGap32 = SizedBox(height: 32);
  static const Widget vGap34 = SizedBox(height: 34);

  static const Widget vGap36 = SizedBox(height: 36);
  static const Widget vGap40 = SizedBox(height: 40);
  static const Widget vGap46 = SizedBox(height: 46);
  static const Widget vGap50 = SizedBox(height: 50);
  static const Widget vGap60 = SizedBox(height: 60);
  static const Widget vGap80 = SizedBox(height: 80);
  static const Widget vGap110 = SizedBox(height: 110);
  static const Widget vGap1200 = SizedBox(height: 1200);

  static const Widget line = Divider();

  static const Widget hLine = SizedBox(
    child: Divider(
      height: 1,
    ),
  );

  ///虚线
  static const Widget dottedLine = SizedBox(
    child: DashedLine(
      height: 1,
    ),
  );

  static Widget hLineHalf = Container(
      height: 0.5,
      color:
          Get.isDarkMode ? ExColorsDark.line_color : ExColorsLight.line_color);

  static Widget vLine = SizedBox(
    width: 1.0,
    height: 24.0,
    child: VerticalDivider(
      width: 8.0,
      thickness: 1.0,
      color: Get.isDarkMode ? ExColorsDark.fill_4 : ExColorsLight.fill_4,
    ),
  );
  static const Widget vLine90 = SizedBox(
    width: 0.6,
    height: 90.0,
    child: VerticalDivider(),
  );

  static const Widget vLine12 = SizedBox(
    width: 0.6,
    height: 12.0,
    child: VerticalDivider(),
  );

  static const Widget vLine18 = SizedBox(
    width: 0.6,
    height: 18.0,
    child: VerticalDivider(),
  );

  static const Widget empty = SizedBox.shrink();
  static const Widget empty50 = SizedBox(
    height: 50.0,
  );
  static const Widget empty60 = SizedBox(
      height: 60.0,
      width: 60.0,
      child: CircleAvatar(
        backgroundColor: ExColorsDark.card_bg_color_2,
      ));
}
