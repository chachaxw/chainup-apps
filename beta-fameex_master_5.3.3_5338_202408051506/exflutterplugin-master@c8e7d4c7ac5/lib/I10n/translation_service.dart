import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';

import 'package:library_kline/utils/storage_utils.dart';
import 'en_US.dart';
import 'zh_CN.dart';

class TranslationService extends Translations {
  static Locale? get locale => currentLocal();
  static final fallbackLocale = Locale('en', 'US');
  // static final fallbackLocale = Locale('zh', 'CH');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'zh_CN': zh_CN,
      };

  static Locale currentLocal() {
    String currentLanguage = ExStorageUtils.getString(ExStorageUtils.LAN);
    List<String> result = currentLanguage.split("_");
    if (currentLanguage.isEmpty) {
      return fallbackLocale;
    }
    if (result.first == "zh" && result.last == 'CN') {
      return const Locale("zh", "CN");
    } else {
      return const Locale("en", "US");
    }
  }

  static bool isChinese() {
    final lan = currentLocal();
    if (lan.languageCode == "zh") {
      return true;
    }
    return false;
  }
}
