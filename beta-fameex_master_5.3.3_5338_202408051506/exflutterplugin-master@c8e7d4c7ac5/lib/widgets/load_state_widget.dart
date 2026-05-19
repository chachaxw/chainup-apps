
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../base/controller/base_controller.dart';
import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import 'gaps.dart';

///空布局
Widget createEmptyWidget(BaseController controller) {
  return Material(
    child: Center(
        widthFactor: double.infinity,
        child: GestureDetector(
          onTap: () {
            controller.showLoading();
            controller.loadNet();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExIcon.icNoData(),
              Gaps.vGap12,
              Text(
                "no results",
                style:
                    TextStyle(fontSize: 18.sp, color: ExColorsDark.text_color_2),
              )
            ],
          ),
        )),
  );
}



///回退按钮
Widget leadingButton() {
  return IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () async {
      // onBackPressed();
      var canPop = navigator?.canPop();
      if (canPop != null && canPop) {
        Get.back();
      } else {
        SystemNavigator.pop();
      }
    },
  );
}

Future<void> pop() async {
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

///异常布局
Widget createErroWidget(BaseController controller, String? error) {
  return Material(
      child: Center(
          widthFactor: double.infinity,
          child: GestureDetector(
            onTap: () {
              controller.showLoading();
              controller.loadNet();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExIcon.icNoData(),
                Gaps.vGap12,
                Text(
                  "error page",
                  style:
                  TextStyle(fontSize: 18.sp, color: ExColorsDark.text_color_2),
                )
              ],
            ),
          )));
}
