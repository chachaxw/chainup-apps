mixin RSIEntity {
  /// RSI值
  double? rsi;
  double? rsiABSEma;
  double? rsiMaxEma;
  Map<int, double> rsiMapData = {};
  Map<int, double> rsiABSEmaMapData = {};
  Map<int, double> rsiMaxEmaData = {};
}
