import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

extension DecimalExt on Decimal {
  String formatWith(NumberFormat formatter) =>
      formatter.format(DecimalIntl(this));

  /// 显示千位分隔符号 以及digits小数保留位数
  String formatWithThousSymbol({int? digits}) {
    if (digits == null) {
      final formatter = NumberFormat.decimalPattern("en-US");
      return formatWith(formatter);
    } else {
      final digits0 = digits.isNegative ? 2 : digits;
      final formatter = NumberFormat.decimalPatternDigits(
          locale: "en-US", decimalDigits: min(digits0, 16));
      return formatWith(formatter);
    }
  }
}
