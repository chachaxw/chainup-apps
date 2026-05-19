///累积收益率
class CumulativeProfitRatioChartDataEntity {
  ///BTC累积涨幅率  这里是原始数据乘以100后的数据
  double? btcCumulativeRate;

  ///累积盈亏率  这里是原始数据乘以100后的数据
  double? cumulativeRageReturn;

  ///数据序号
  int? index;

  ///日期
  String? date;

  CumulativeProfitRatioChartDataEntity({
    this.btcCumulativeRate,
    this.cumulativeRageReturn,
    this.index,
    this.date,
  });
}
/**
 * Map cumulativeRageReturn = {
            "cumulativeRageReturn": entity.cumulativeRageReturn ?? 0,
            "cumulativeRageReturnStr": entity.cumulativeRageReturn.toString(),
            "date": date,
            "index": i,
          }; //累积收
 */
