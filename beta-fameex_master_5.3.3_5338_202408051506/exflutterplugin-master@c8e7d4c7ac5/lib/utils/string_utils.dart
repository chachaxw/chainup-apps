import 'regex_utils.dart';

class StringUtils {
  static String hideAccount(String original) {
    var isEmail = RegexUtils.isEmail(original);
    if (isEmail) {
      if (original.indexOf('@') > 0) {
        var str = original.split('@');
        var _s = '';
        if (str[0].length > 2) {
          for (int i = 2; i < str[0].length; i++) {
            _s += '*';
          }
          return str[0].substring(0, 2) + _s + '@' + str[1];
        } else {
          for (int i = 1; i < str[0].length; i++) {
            _s += '*';
          }
          return str[0].substring(0, 1) + _s + '@' + str[1];
        }
      }
      return original;
    } else {
      if (original.length == 11) {
        return original
            .replaceFirst(new RegExp(r'\d{6}'), '******', 3)
            .toString();
      }
      if (original.length == 10) {
        return original
            .replaceFirst(new RegExp(r'\d{4}'), '****', 3)
            .toString();
      }
      if (original.length == 9) {
        return original.replaceFirst(new RegExp(r'\d{3}'), '***', 3).toString();
      }
      if (original.length == 8) {
        return original.replaceFirst(new RegExp(r'\d{3}'), '***', 3).toString();
      }
      if (original.length == 7) {
        return original.replaceFirst(new RegExp(r'\d{3}'), '***', 3).toString();
      }
      if (original.length <= 6) {
        return original.replaceFirst(new RegExp(r'\d{2}'), '**', 3).toString();
      } else {
        return original;
      }
    }
  }

  /// 字符串为空时返回"--"
  static String parseString(String? string) {
    return string != null && string.isNotEmpty ? string : "--";
  }

  static String formateTime(Duration? time) {
    if (time == null) {
      return "";
    }
    String days = time.inDays.toString().padLeft(2, "0");
    String hours = (time.inHours % 24).toString().padLeft(2, "0");
    String minutes = (time.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    return "${days}d $hours:$minutes:$seconds";
  }
}
