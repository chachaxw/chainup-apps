///每日收益
class DailyIncomeChartDataEntity {
  ///每日收益
  double? profit;

  ///每日收益保留两位精度的字符串
  String? profitStr;

  ///数据序号
  int? index;

  ///日期
  String? date;

  DailyIncomeChartDataEntity({
    this.profit,
    this.profitStr,
    this.index,
    this.date,
  });
}
