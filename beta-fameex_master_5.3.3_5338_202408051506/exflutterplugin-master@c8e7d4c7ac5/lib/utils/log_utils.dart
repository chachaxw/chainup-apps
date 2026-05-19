
import 'package:get/get_core/get_core.dart';

class LogUtil {

  static const String tag = 'EX-LOG';

  static void d(String msg, {String tag = tag}) {
    Get.log('"$tag":"$msg"');
  }

  // static void e(String msg, {String tag = tag}) {
  //   Get.log('"$tag":"$msg"',isError: true);
  // }

  static void e(dynamic msg, {String tag = tag}) {
    Get.log('"$tag":"${msg.toString()}"',isError: true);
  }
}