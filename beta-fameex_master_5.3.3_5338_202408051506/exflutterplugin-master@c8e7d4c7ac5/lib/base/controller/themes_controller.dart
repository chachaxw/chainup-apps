import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:library_kline/utils/storage_utils.dart';

class ThemesController extends GetxController {
  // final storage = GetStorage();

  var theme = 'light';

  @override
  void onInit() {
    super.onInit();
    getThemeState();
  }

  getThemeState() {
    var theme=ExStorageUtils.getString(ExStorageUtils.THEME);
    if (theme.length!=0) {
      return setTheme(theme);
    }

  }

  void setTheme(String value) {
    theme = value;
    ExStorageUtils.putObject(ExStorageUtils.THEME, value);
    if (value == 'system') Get.changeThemeMode(ThemeMode.system);
    if (value == 'light') Get.changeThemeMode(ThemeMode.light);
    if (value == 'dark') Get.changeThemeMode(ThemeMode.dark);

    update();
  }
}
