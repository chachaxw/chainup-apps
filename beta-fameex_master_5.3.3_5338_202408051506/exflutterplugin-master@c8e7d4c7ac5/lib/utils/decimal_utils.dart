import 'package:chainup_flutter_ex/ext/decimal_ext.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:decimal/decimal.dart';

class DecimalUtils {
  /// 显示格式化数值字符串
  /// isShowThous: 千位分隔符
  /// digits:小数精度
  /// isShowEmpty: 格式化失败时返回""或者"0"
  static String showSNormal(dynamic valueStr,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    if (valueStr == null) return isShowEmpty ? "" : zeroStr;
    String valueBuffer = valueStr is String ? valueStr : valueStr.toString();
    if (digits != null) {
      ///先保留指定长度的小数
      valueBuffer = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
          valueStr, digits,
          needAddZero: true);
    }


    Decimal? parseValueBuffer = Decimal.tryParse(valueBuffer);
    if (parseValueBuffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    if (isShowThous == null || isShowThous == false) {
      return parseValueBuffer.toString();
    }
    String first = "";
    String last = "";
    if (valueBuffer.toString().contains(".")) {
      first = valueBuffer.toString().split(".").first;
      last = valueBuffer.toString().split(".").last;
      parseValueBuffer = Decimal.tryParse(first);
      String result = parseValueBuffer!.formatWithThousSymbol();
      double firstNum = double.tryParse(first) ?? 0;
      if (first.contains("-") && firstNum > -1) {
        result = "-$result.$last";
      } else {
        result = "$result.$last";
      }
      return result;
    } else {
      valueBuffer = parseValueBuffer.formatWithThousSymbol(digits: digits);
      return valueBuffer;
    }
  }

  ///格式化指定长度的数字，小数部分不4舍5入
  static String formateNum(dynamic valueStr,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    if (valueStr == null) return isShowEmpty ? "" : zeroStr;
    String valueBuffer = valueStr is String ? valueStr : valueStr.toString();
    if (digits != null) {
      ///先保留指定长度的小数
      valueBuffer = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
          valueStr, digits,
          needAddZero: true);
    }

    Decimal? parseValueBuffer = Decimal.tryParse(valueBuffer);
    if (parseValueBuffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    if (isShowThous == null || isShowThous == false) {
      return parseValueBuffer.toString();
    }
    String first = "";
    String last = "";
    if (valueBuffer.toString().contains(".")) {
      first = valueBuffer.toString().split(".").first;
      last = valueBuffer.toString().split(".").last;
      parseValueBuffer = Decimal.tryParse(first);
      String result = parseValueBuffer!.formatWithThousSymbol();
      double firstNum = double.tryParse(first) ?? 0;
      if (first.contains("-") && firstNum > -1) {
        result = "-$result.$last";
      } else {
        result = "$result.$last";
      }
      return result;
    } else {
      return parseValueBuffer.formatWithThousSymbol(digits: digits);
    }
  }

  /// 显示格式化数值相乘后的字符串
  /// isShowThous: 千位分隔符
  /// digits:小数精度
  /// isShowEmpty: 格式化失败时返回""或者"0"
  static String showSMultiply(dynamic value1, dynamic value2,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    final value1Buffer = value1 is String ? value1 : value1.toString();
    final value2Buffer = value2 is String ? value2 : value2.toString();
    Decimal? parseValue1Buffer = Decimal.tryParse(value1Buffer);
    if (parseValue1Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    Decimal? parseValue2Buffer = Decimal.tryParse(value2Buffer);
    if (parseValue2Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    final valueBuffer = parseValue1Buffer * parseValue2Buffer;
    return showSNormal(valueBuffer.toString(),
        isShowThous: isShowThous, digits: digits, isShowEmpty: isShowEmpty);
  }

  /// 显示格式化数值相除后的字符串
  /// isShowThous: 千位分隔符
  /// digits:小数精度
  /// isShowEmpty: 格式化失败时返回""或者"0"
  static String showDivide(dynamic value1, dynamic value2,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    final value1Buffer = value1 is String ? value1 : value1.toString();
    final value2Buffer = value2 is String ? value2 : value2.toString();
    Decimal? parseValue1Buffer = Decimal.tryParse(value1Buffer);
    if (parseValue1Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    Decimal? parseValue2Buffer = Decimal.tryParse(value2Buffer);
    if (parseValue2Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    final valueBuffer = parseValue1Buffer / parseValue2Buffer;
    return showSNormal(valueBuffer.toDouble().toString(),
        isShowThous: isShowThous, digits: digits, isShowEmpty: isShowEmpty);
  }

  /// value1 + value2
  /// isShowThous: 千位分隔符
  /// digits:小数精度
  /// isShowEmpty: 格式化失败时返回""或者"0"
  static String showAdd(dynamic value1, dynamic value2,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    final value1Buffer = value1 is String ? value1 : value1.toString();
    final value2Buffer = value2 is String ? value2 : value2.toString();
    Decimal? parseValue1Buffer = Decimal.tryParse(value1Buffer);
    if (parseValue1Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    Decimal? parseValue2Buffer = Decimal.tryParse(value2Buffer);
    if (parseValue2Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    final valueBuffer = parseValue1Buffer + parseValue2Buffer;
    return showSNormal(valueBuffer.toString(),
        isShowThous: isShowThous, digits: digits, isShowEmpty: isShowEmpty);
  }

  ///value1 - value2
  static String showSubtract(dynamic value1, dynamic value2,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    final value1Buffer = value1 is String ? value1 : value1.toString();
    final value2Buffer = value2 is String ? value2 : value2.toString();
    Decimal? parseValue1Buffer = Decimal.tryParse(value1Buffer);
    if (parseValue1Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    Decimal? parseValue2Buffer = Decimal.tryParse(value2Buffer);
    if (parseValue2Buffer == null) {
      return isShowEmpty ? "" : zeroStr;
    }
    final valueBuffer = parseValue1Buffer - parseValue2Buffer;
    return showSNormal(valueBuffer.toString(),
        isShowThous: isShowThous, digits: digits, isShowEmpty: isShowEmpty);
  }

  ///分割指定两个数字
  ///divisions 被等分后得到的数字的个数
  ///例： a=0,b=10, divisions=6, 进行5等分，得到 [0,2,4,6,8,10]，共6个数
  static List<Decimal> calculateMidpoints(
    Decimal a,
    Decimal b,
    int divisions,
  ) {
    // 确保 a <= b
    if (b < a) {
      Decimal temp = b;
      b = a;
      a = temp;
    }

    Decimal result = b - a;
    // 计算步长
    Decimal tempDivisions = Decimal.parse(divisions.toString());
    final step = result / tempDivisions;
    String aa = step.toDouble().toString();

    // 生成中间数数组
    List<Decimal> midpoints = [a];
    for (int i = 1; i <= divisions; i++) {
      Decimal midpoint = a + Decimal.fromInt(i) * Decimal.parse(aa);
      midpoints.add(midpoint);
    }

    return midpoints;
  }

  static List<double> newCalculateMidpoints(
    double a,
    double b,
    int divisions,
  ) {
    // 确保 a <= b
    if (b < a) {
      double temp = b;
      b = a;
      a = temp;
    }

    double result = b - a;
    // 计算步长
    double step = result / double.parse(divisions.toString());

    // 生成中间数数组
    List<double> midpoints = [a];
    for (int i = 1; i <= divisions; i++) {
      double midpoint = a + i * step;
      midpoints.add(midpoint);
    }

    return midpoints;
  }
}
