import 'package:flutter/services.dart';

class ClipboardUtil {

  static void setClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text ?? "";
  }
}
