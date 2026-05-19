///累积收益
class CumulativeIncomeChartDataEntity {
  ///累积收益
  double? cumulativeIncome;

  ///累积收益保留两位精度的字符串
  String? cumulativeIncomeStr;

  ///数据序号
  int? index;

  ///日期
  String? date;

  CumulativeIncomeChartDataEntity({
    this.cumulativeIncome,
    this.cumulativeIncomeStr,
    this.index,
    this.date,
  });
}
