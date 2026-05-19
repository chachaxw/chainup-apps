import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:library_kline/utils/storage_utils.dart';



class AppUtil {
  static bool needSubWs = true;

  static bool isDebug() {
    return ExStorageUtils.getBoolean(key: ExStorageUtils.IS_DEBUG,def: false);
  }

  static void setDebug(String? isDebug) {
     ExStorageUtils.putObject(ExStorageUtils.IS_DEBUG,isDebug.toString()=="1");
  }

  static bool isDark() {
    return Get.isDarkMode;
  }

}

//
// class CoinInfo {
//   static bool isCoin = false; //是否为币
//   static String mMultiplier = "1";//面值
//   static int marginCoinPrecision = 1; //保证金币种精度
// }