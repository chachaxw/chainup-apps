import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../routes/routes.dart';

mixin ToastMixin {
  void showToast(String? msg,
      {Toast toastLength = Toast.LENGTH_SHORT,
      ToastGravity gravity = ToastGravity.CENTER,
      int timeInSecForIos = 1}) {
    Fluttertoast.showToast(
      msg: msg ?? "",
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: ExColorsLight.toast_bg_color,
      timeInSecForIosWeb: timeInSecForIos,
    );
  }

  void showShortToast(String? msg) {
    showToast(msg, toastLength: Toast.LENGTH_SHORT);
  }

  void showLongToast(String? msg) {
    showToast(msg, toastLength: Toast.LENGTH_LONG);
  }
  void showNativeToast(String msg){
    Routes.pushNvEvent(ev: NvEvent.show_native_toast,param: {
      "message":msg
    });
  }
}
