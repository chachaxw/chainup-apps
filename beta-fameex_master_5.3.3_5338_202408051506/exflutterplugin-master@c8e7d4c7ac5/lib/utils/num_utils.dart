import 'dart:ffi';
import 'dart:math';
import 'package:chainup_flutter_ex/utils/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import '../I10n/translation_service.dart';
import 'decimal.dart';

/// num工具类
class NumUtils {
  /// Checks if string is int or double.
  /// 检查字符串是int还是double
  static bool isNum(String s)  {
    try{
      var value = double.parse(s);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
    // var buff=false;
    // if (ObjectUtils.isNull(s)) {
    //   return buff;
    // }
    // buff=RegexUtils.isNum(s);
    // return buff;
  }

  /// 将数字字符串转num，数字保留x位小数
  static num? getNumByValueString(String valueStr, {int? fractionDigits}) {
    double? value = double.tryParse(valueStr);
    return fractionDigits == null
        ? value
        : getNumByValueDouble(value!, fractionDigits);
  }

  static String? getStringNumByValueString(
      dynamic? valueStr, int fractionDigits) {
    num? value = num.tryParse((valueStr ?? "0").toString());
    if (value == null) return "--";
    String valueBuffer = value.toStringAsFixed(fractionDigits);
    return fractionDigits == 0
        ? int.tryParse(valueBuffer).toString()
        : num.tryParse(valueBuffer).toString();
  }

  /// 浮点数字保留x位小数
  static num? getNumByValueDouble(double value, int fractionDigits) {
    if (value == null) return null;
    String valueStr = value.toStringAsFixed(fractionDigits);
    return fractionDigits == 0
        ? int.tryParse(valueStr)
        : double.tryParse(valueStr);
  }

  /// 浮点数字保留x位小数
  static String getStrByValueDouble(double? value, int fractionDigits) {
    if (value == null) return "--";
    String valueStr = value.toStringAsFixed(fractionDigits);
    return fractionDigits == 0
        ? int.tryParse(valueStr).toString()
        : double.tryParse(valueStr).toString();
  }

  /// 浮点数字保留x位小数
  static String getStrByValueInt(int value, int fractionDigits) {
    if (value == null) return "0";
    String valueStr = value.toStringAsFixed(fractionDigits);
    return fractionDigits == 0
        ? int.tryParse(valueStr).toString()
        : double.tryParse(valueStr).toString();
  }

  /// get int by value string
  /// 将数字字符串转int
  static int getIntByValueString(String valueStr, {int defValue = 0}) {
    return int.tryParse(valueStr) ?? defValue;
  }

  /// get double by value str.
  /// 数字字符串转double
  static double getDoubleByValueString(String valueStr, {double defValue = 0}) {
    return double.tryParse(valueStr) ?? defValue;
  }

  /// isZero
  /// 判断是否是否是0
  static bool isZero(num value) {
    return value == null || value == 0;
  }

  /// add (without loosing precision).
  /// 两个数相加（防止精度丢失）
  static double addNum(num a, num b) {
    return addDec(a, b).toDouble();
  }

  /// subtract (without loosing precision).
  /// 两个数相减（防止精度丢失）
  static double subtractNum(num a, num b) {
    return subtractDec(a, b).toDouble();
  }

  /// multiply (without loosing precision).
  /// 两个数相乘（防止精度丢失）
  static double multiplyNum(num a, num b) {
    return multiplyDec(a, b).toDouble();
  }

  /// divide (without loosing precision).
  /// 两个数相除（防止精度丢失）
  static double divideNum(num a, num b) {
    return divideDec(a, b).toDouble();
  }

  /// 加 (精确相加,防止精度丢失).
  /// add (without loosing precision).
  static Decimal addDec(num a, num b) {
    return addDecString(a.toString(), b.toString());
  }

  /// 减 (精确相减,防止精度丢失).
  /// subtract (without loosing precision).
  static Decimal subtractDec(num a, num b) {
    return subtractDecString(a.toString(), b.toString());
  }

  /// 乘 (精确相乘,防止精度丢失).
  /// multiply (without loosing precision).
  static Decimal multiplyDec(num a, num b) {
    return multiplyDecString(a.toString(), b.toString());
  }

  /// 除 (精确相除,防止精度丢失).
  /// divide (without loosing precision).
  static Decimal divideDec(num a, num b) {
    return divideDecString(a.toString(), b.toString());
  }

  /// 余数
  static Decimal remainder(num a, num b) {
    return remainderDecString(a.toString(), b.toString());
  }

  /// Relational less than operator.
  /// 关系小于运算符。判断a是否小于b
  static bool lessThan(num a, num b) {
    return lessThanDecString(a.toString(), b.toString());
  }

  /// Relational less than or equal operator.
  /// 关系小于或等于运算符。判断a是否小于或者等于b
  static bool thanOrEqual(num a, num b) {
    return thanOrEqualDecString(a.toString(), b.toString());
  }

  /// Relational greater than operator.
  /// 关系大于运算符。判断a是否大于b
  static bool greaterThan(num a, num b) {
    return greaterThanDecString(a.toString(), b.toString());
  }

  /// Relational greater than or equal operator.
  static bool greaterOrEqual(num a, num b) {
    return greaterOrEqualDecString(a.toString(), b.toString());
  }

  /// 两个数相加（防止精度丢失）
  static Decimal addDecString(String a, String b) {
    return Decimal.parse(a) + Decimal.parse(b);
  }

  static String addStr(String a, String b,int fractionDigits) {
    var buff = Decimal.parse(a) + Decimal.parse(b);
    return showSNormal(buff, fractionDigits);
  }

  /// 减
  static Decimal subtractDecString(String a, String b) {
    return Decimal.parse(a) - Decimal.parse(b);
  }
  static String subStr(String a, String b,int fractionDigits) {
    var buff = Decimal.parse(a) - Decimal.parse(b);
    return showSNormal(buff, fractionDigits);
  }

  /// 乘
  static Decimal multiplyDecString(String a, String b) {
    return Decimal.parse(a) * Decimal.parse(b);
  }

  /// 乘
  static String mulStr(String a, String b, int fractionDigits,{bool? isShowPrefix}) {
    var buff = Decimal.parse(a) * Decimal.parse(b);
    return showSNormal(buff, fractionDigits,isShowPrefix: isShowPrefix);
  }

  /// 除
  static Decimal divideDecString(String a, String b) {
    return Decimal.parse(a) / Decimal.parse(b);
  }

  /// 除
  static String divideStr(String? a, String? b,int fractionDigits) {
    var buff = Decimal.parse(a??"0") / Decimal.parse(b??"0");
    return showSNormal(buff, fractionDigits);
  }

  /// 余数
  static Decimal remainderDecString(String a, String b) {
    return Decimal.parse(a) % Decimal.parse(b);
  }

  /// Relational less than operator.
  /// 判断a是否小于b
  static bool lessThanDecString(String a, String b) {
    return Decimal.parse(a) < Decimal.parse(b);
  }

  /// Relational less than or equal operator.
  /// 判断a是否小于或者等于b
  static bool thanOrEqualDecString(String a, String b) {
    return Decimal.parse(a) <= Decimal.parse(b);
  }

  /// Relational greater than operator.
  /// 判断a是否大于b
  static bool greaterThanDecString(String a, String b) {
    return Decimal.parse(a) > Decimal.parse(b);
  }

  /// Relational greater than or equal operator.
  static bool greaterOrEqualDecString(String a, String b) {
    return Decimal.parse(a) >= Decimal.parse(b);
  }

  /// Checks if num a LOWER than num b.
  /// 检查num a是否小于num b。
  static bool isLowerThan(num a, num b) => a < b;

  /// Checks if num a GREATER than num b.
  /// 检查num a是否大于num b。
  static bool isGreaterThan(num a, num b) => a > b;

  /// Checks if num a EQUAL than num b.
  /// 检查num a是否等于num b。
  static bool isEqual(num a, num b) => a == b;

  static String format(double n,int fractionDigits) {

    var isChinese = TranslationService.isChinese();
    if (isChinese){
      if (n >= 100000000) {
        n /= 100000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}亿";
      } else if (n >= 10000) {
        n /= 10000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}万";
      } else {
        return showSNormal(n.toString(), fractionDigits,isShowThous: true);
      }
    }else {
      if (n >= 1000000000) {
        n /= 1000000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}B";
      } else if (n >= 1000000) {
        n /= 1000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}M";
      } else if (n >= 1000) {
        n /= 1000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}K";
      } else {
        return showSNormal(n.toString(), fractionDigits,isShowThous: true);
      }
    }
  }
  static int getDecimalLength(double b) {
    String s = b.toString();
    int dotIndex = s.indexOf(".");
    if (dotIndex < 0) {
      return 0;
    } else {
      return s.length - dotIndex - 1;
    }
  }

  static int getMaxDecimalLength(double a, double b, double c, double d) {
    int result = max(getDecimalLength(a), getDecimalLength(b));
    result = max(result, getDecimalLength(c));
    result = max(result, getDecimalLength(d));
    return result;
  }

  static bool checkNotNullOrZero(double? a) {
    if (a == null || a == 0) {
      return false;
    } else if (a.abs().toStringAsFixed(4) == "0.0000") {
      return false;
    } else {
      return true;
    }
  }

  static String numToScalePer(String? a) {
    return (a ?? "--") + "%";
  }

  static String strToPer(String? a) {
    return mulStr(a??"0", "100", 2) + "%";
  }

  static String showSNormal(dynamic? valueStr, int fractionDigits,
      {String? unit,bool? isShowPrefix,bool? isShowThous}) {
    String valuestr = double.tryParse(valueStr.toString()).toString();
    num? value = num.tryParse((valueStr ?? "0").toString());
    String valueBuffer = "0";
    if (value == null) return valueBuffer;
    if (fractionDigits == 0) {
      if (valuestr.lastIndexOf(".") != -1) {
        valueBuffer = valuestr.split(".")[0];
      } else {
        valueBuffer = valuestr;
      }
    } else {
      if (valuestr.lastIndexOf(".") == -1) {
        valueBuffer = value.toStringAsFixed(fractionDigits);
      } else {
        if ((valuestr.length - valuestr.lastIndexOf(".") - 1) <
            fractionDigits) {
          valueBuffer = value
              .toStringAsFixed(fractionDigits)
              .substring(0, valuestr.lastIndexOf(".") + fractionDigits + 1)
              .toString();
        } else {
          valueBuffer = valuestr
              .substring(0, valuestr.lastIndexOf(".") + fractionDigits + 1)
              .toString();
        }
      }
    }
    if(isShowThous==true){
      // var formatter = NumberFormat('#,##,000');
      // valueBuffer=formatter.format(num.tryParse(valueBuffer)??0);
      valueBuffer = thousThandToNumber(valueBuffer);
    }
    if(isShowPrefix==true){
      valueBuffer=addNumPrefix(valueBuffer);
    }
    return unit == null ? valueBuffer : "${valueBuffer + " " + unit}";
  }

  static String addNumPrefix(String input) {
    var isPositive= greaterThanDecString(input, "0");
    return "${isPositive?"+":""}$input";
  }

  /**
   * isAmount  成交额 以及 成交量需要该字段
   * isAmount  true  成交额 -需要乘以面值
   *           false 成交量 -需进行是张和币的换算
   *
   * */
  static String numberFormat(dynamic? valueStr,int digits, {bool? isAmount, bool isContract = true}){
    var valueBuffer = valueStr is String ? valueStr : valueStr.toString();
    var result = valueBuffer;
    int newDigits = digits;
    if (isContract) {
      // 合约
      final faceValue = KLineCoinInfo.mMultiplier;
      if (isAmount != null){
        if (isAmount == true){ //成交额  乘以面值
          result = mulStr(result, faceValue, newDigits);
        }else{
          if (KLineCoinInfo.isCoin) { //如果是币
            result = mulStr(result, faceValue, newDigits);
          }else{
            newDigits = 0;
          }
        }
      }
      // print("valueStr => ${valueStr} faceValue => ${faceValue} digits = ${newDigits} reslut =>${result}");
      final dounleVale =  double.parse(result);
      return format(dounleVale, newDigits);
    } else {
      // 现货
      final dounleVale =  double.parse(result);
      return format(dounleVale, newDigits);
    }
  }


  static String thousThandToNumber(String number) {
    String formattedNumber = number;
    String? smallPoint; //小数部分
    if (formattedNumber.contains(".")){
      final arr = formattedNumber.split(".");
      formattedNumber = arr[0];
      smallPoint = arr[1];
    }
    List<String> parts = [];
    while (formattedNumber.length > 3) {
      parts.add(formattedNumber.substring(formattedNumber.length - 3));
      formattedNumber = formattedNumber.substring(0, formattedNumber.length - 3);
    }
    if (formattedNumber.isNotEmpty) {
      parts.add(formattedNumber);
    }
    parts = parts.reversed.toList();
    var result = parts.join(',');
    if (smallPoint != null){
      result = "$result.$smallPoint";
    }
    return result;
  }


}
