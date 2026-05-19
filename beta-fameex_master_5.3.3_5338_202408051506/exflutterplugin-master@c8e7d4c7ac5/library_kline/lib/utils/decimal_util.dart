import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

class DecimalUtil {
  //4.24e-8 科学计数法
  static String showSNormal(String? valueStr,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    if(valueStr==null) valueStr = "0";
    var str = (double.tryParse(valueStr) ?? 0).toStringAsFixed(digits ?? 0);
    if (Decimal.parse(str).abs() < Decimal.parse("1000").abs()) {
      return str;
    }
    const String zeroStr = "0";
    if (valueStr == null) return isShowEmpty ? "" : zeroStr;
    final String valueBuffer =
        valueStr is String ? valueStr : valueStr.toString();
    Decimal? parseValueBuffer = Decimal.tryParse(valueBuffer);
    if (parseValueBuffer == null || parseValueBuffer is Decimal == false) {
      return isShowEmpty ? "" : zeroStr;
    }
    if ((isShowThous == null || isShowThous == false) &&
        parseValueBuffer != null) {
      return parseValueBuffer.toString();
    }
    return _formatWithThousSymbol(parseValueBuffer, digits: digits);
  }

  static String showSMultiply(dynamic? value1, dynamic? value2,
      {bool? isShowThous, int? digits, bool isShowEmpty = true}) {
    const String zeroStr = "0";
    final value1Buffer = value1 is String ? value1 : value1.toString();
    final value2Buffer = value2 is String ? value2 : value2.toString();
    Decimal? parseValue1Buffer = Decimal.tryParse(value1Buffer);
    if (parseValue1Buffer == null || parseValue1Buffer is Decimal == false) {
      return isShowEmpty ? "" : zeroStr;
    }
    Decimal? parseValue2Buffer = Decimal.tryParse(value2Buffer);
    if (parseValue2Buffer == null || parseValue2Buffer is Decimal == false) {
      return isShowEmpty ? "" : zeroStr;
    }
    final valueBuffer = parseValue1Buffer * parseValue2Buffer;
    return showSNormal(valueBuffer.toString(),
        isShowThous: isShowThous, digits: digits, isShowEmpty: isShowEmpty);
  }

  static String _formatWithThousSymbol(Decimal decimal, {int? digits}) {
    if (digits == null) {
      final formatter = NumberFormat.decimalPattern("en-US");
      return formatter.format(DecimalIntl(decimal));
    } else {
      final digits0 = digits.isNegative ? 2 : digits;
      final formatter = NumberFormat.decimalPatternDigits(
          locale: "en-US", decimalDigits: min(digits0, 16));
      return formatter.format(DecimalIntl(decimal));
    }
  }
}
