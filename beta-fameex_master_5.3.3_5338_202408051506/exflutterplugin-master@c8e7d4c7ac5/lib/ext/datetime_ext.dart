extension DateExt on DateTime {
  ///将date转成utc+8的时间
  DateTime transformToUtc8() {
    DateTime tempDate = toUtc();
    DateTime utcPlus8Time = tempDate.add(const Duration(hours: 8));
    return utcPlus8Time;
  }
}
