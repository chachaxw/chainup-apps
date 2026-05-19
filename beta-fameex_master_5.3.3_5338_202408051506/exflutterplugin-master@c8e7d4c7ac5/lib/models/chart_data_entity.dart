class TotalAssetsChartDataEntity {
  ///原始数据
  double? value;

  ///资产总值  原始精度数据换成法币，保留两位精度后的值
  double? totalBalance;

  ///资产总值 原始精度数据换成法币，保留两位精度后的字符串
  String? totalBalanceStr;

  ///数据序号
  int? index;

  ///日期
  String? date;

  TotalAssetsChartDataEntity({
    this.value,
    this.totalBalance,
    this.totalBalanceStr,
    this.index,
    this.date,
  });
}
