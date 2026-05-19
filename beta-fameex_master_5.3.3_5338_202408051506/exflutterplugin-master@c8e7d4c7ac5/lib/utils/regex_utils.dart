


import 'package:chainup_flutter_ex/utils/regex_constants.dart';

/// 常见正则表达式工具类
class RegexUtils {

  static final Map<String, String> cityMap = Map();

  /// Return whether input matches regex of simple mobile.
  /// 判断输入字符串是否符合手机号
  static bool isMobileSimple(String input) {
    return matches(RegexConstants.REGEX_MOBILE_SIMPLE, input);
  }

  /// Return whether input matches regex of exact mobile.
  /// 精确验证是否是手机号
  static bool isMobileExact(String input) {
    return matches(RegexConstants.REGEX_MOBILE_EXACT, input);
  }

  /// Return whether input matches regex of telephone number.
  /// 判断返回输入是否匹配电话号码的正则表达式
  static bool isTel(String input) {
    return matches(RegexConstants.REGEX_TEL, input);
  }

  /// Return whether input matches regex of id card number which length is 15.
  /// 返回输入是否匹配长度为15的身份证号码的正则表达式。
  static bool isIDCard15(String input) {
    return matches(RegexConstants.REGEX_ID_CARD15, input);
  }

  /// Return whether input matches regex of id card number which length is 18.
  /// 返回输入是否匹配长度为18的身份证号码的正则表达式。
  static bool isIDCard18(String input) {
    return matches(RegexConstants.REGEX_ID_CARD18, input);
  }


  /// Return whether input matches regex of email.
  /// 返回输入是否匹配电子邮件的正则表达式。
  static bool isEmail(String input) {
    return matches(RegexConstants.REGEX_EMAIL, input);
  }

  /// Return whether input matches regex of url.
  /// 返回输入是否匹配url的正则表达式。
  static bool isURL(String input) {
    return matches(RegexConstants.REGEX_URL, input);
  }

  /// Return whether input matches regex of Chinese character.
  /// 返回输入是否匹配汉字的正则表达式。
  static bool isZh(String input) {
    return '〇' == input || matches(RegexConstants.REGEX_ZH, input);
  }

  /// Return whether input matches regex of date which pattern is 'yyyy-MM-dd'.
  /// 返回输入是否匹配样式为'yyyy-MM-dd'的日期的正则表达式。
  static bool isDate(String input) {
    return matches(RegexConstants.REGEX_DATE, input);
  }

  /// Return whether input matches regex of ip address.
  /// 返回输入是否匹配ip地址的正则表达式。
  static bool isIP(String input) {
    return matches(RegexConstants.REGEX_IP, input);
  }

  /// Return whether input matches regex of username.
  /// 返回输入是否匹配用户名的正则表达式。
  static bool isUserName(String input, {String regex = RegexConstants.REGEX_USERNAME}) {
    return matches(regex, input);
  }

  static bool isNum(String input, {String regex = RegexConstants.REGEX_NUM}) {
    return matches(regex, input);
  }

  /// Return whether input matches the regex.
  /// 返回输入是否匹配正则表达式。
  static bool matches(String regex, String input) {
    if (input.isEmpty) {
      return false;
    }
    return RegExp(regex).hasMatch(input);
  }

}