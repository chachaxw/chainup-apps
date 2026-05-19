import 'package:chainup_flutter_ex/ext/datetime_ext.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/date_utils.dart';

class BreakevenAnalysisUtil {
  ///从指定长度double类型数字里平均取出numberOfPoints个数字，包含起始和结束数字
  ///needCeilToDouble 取出的数字是否向上取整
  static List<double> getEquallySpacedDoubleNumbers(
      double start, double end, int numberOfPoints,
      {bool needCeilToDouble = false}) {
    List<double> numbers = [];

    if (numberOfPoints <= 0 || start > end) {
      if (kDebugMode) {
        throw ArgumentError("Invalid input parameters");
      } else {
        return [];
      }
    }

    if (numberOfPoints == 1) {
      numbers.add(start);
      return numbers;
    }

    double interval = (end - start) / (numberOfPoints - 1);

    for (int i = 0; i < numberOfPoints; i++) {
      double result = start + interval * i;
      result = needCeilToDouble ? result.ceilToDouble() : result;
      numbers.add(result);
    }

    return numbers;
  }

  ///从指定长度int类型数字里平均取出numberOfPoints个数字，包含起始数字
  static List<int> getEquallySpacedIntNumbers(
      int start, int end, int numberOfPoints) {
    List<int> numbers = [];

    if (numberOfPoints <= 0 || start > end) {
      return [];
    }

    if (numberOfPoints == 1) {
      numbers.add(start);
      return numbers;
    }

    double interval = (end - start) / (numberOfPoints - 1);

    for (int i = 0; i < numberOfPoints; i++) {
      numbers.add((start + interval * i).round());
    }

    return numbers;
  }

  static String getCurrentDate(DateTime dateTime) {
    String dateStr =
        EXDateUtils.formateDateTimeToString(dateTime, format: "yyyy-MM-dd");
    return dateStr;
  }
}
