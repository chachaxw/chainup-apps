import 'dart:math';

import 'package:chainup_flutter_ex/page/klineSetting/kline_indicator_manager.dart';
import 'package:library_kline/models/indicators_entity.dart';

import '../entity/k_line_entity.dart';

class DataUtil {
  static calculate(List<KLineEntity> dataList) {
    _calcMACustom(dataList);
    _calcBOLL(dataList);
    _calcVolumeMA(dataList);
    _calcKDJCustom(dataList);
    _calcEMACustom(dataList);
    _calcMACDCustom(dataList);
    _calcRSI(dataList);
    _calcWR(dataList);
  }

  static _calcMACustom(List<KLineEntity> dataList, [bool isLast = false]) {
    var indicatorList = KlineIndicatorType.ma.getShowIndicatorData();
    if (indicatorList.isEmpty) {
      //如果一个Ma 都没选，默认给一个M5,用于绘图
      // indicatorList = [KlineIndicatorType.ma.setDefaultData().first];
    }
    Map<int, double> mMaBuff = {};
    for (int j = 0; j < indicatorList!.length; j++) {
      mMaBuff[indicatorList[j].num ?? 0] = 0;
    }
    int i = 0;
    if (isLast && dataList.length > 30) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      mMaBuff.forEach((key, value) {
        mMaBuff[key] = (data.MAPriceData?[key] ?? 0) * key;
      });
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      entity.MAPriceData.clear();
      final closePrice = entity.close;
      mMaBuff.forEach((key, value) {
        mMaBuff[key] = (value + closePrice);
        if (i == key - 1) {
          entity.MAPriceData?[key] = (mMaBuff[key] ?? 0) / key;
        } else if (i >= key) {
          mMaBuff[key] = ((mMaBuff[key] ?? 0) - dataList[i - key].close);
          entity.MAPriceData?[key] = (mMaBuff[key] ?? 0) / key;
        } else {
          entity.MAPriceData?[key] = 0;
        }
        // print("i =${i},entity => ${entity.MAPriceData}");
      });
    }
  }

  static _calcMA(List<KLineEntity> dataList, int key, [bool isLast = false]) {
    Map<int, double> mMaBuff = {};
    mMaBuff[key] = 0;
    int i = 0;
    if (isLast && dataList.length > 30) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      // mMaBuff.forEach((key, value) {
      //   mMaBuff[key] = (data.MAPriceData?[key] ?? 0) * key;
      // });
      mMaBuff[key] = (data.MAPriceData?[key] ?? 0) * key;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      // mMaBuff.forEach((key, value) {
      final value = mMaBuff[key] ?? 0;
      mMaBuff[key] = (value + closePrice);
      if (i == key - 1) {
        entity.MAPriceData?[key] = (mMaBuff[key] ?? 0) / key;
      } else if (i >= key) {
        mMaBuff[key] = ((mMaBuff[key] ?? 0) - dataList[i - key].close);
        entity.MAPriceData?[key] = (mMaBuff[key] ?? 0) / key;
      } else {
        entity.MAPriceData?[key] = 0;
      }
      // });
    }
  }

  static void _calcBOLL(List<KLineEntity> dataList, [bool isLast = false]) {
    var indicatorList = KlineIndicatorType.boll.getShowIndicatorData();

    final midKey = indicatorList.first.num; //移动平均线
    final stdKey = indicatorList[1].num;
    final maList = KlineIndicatorType.ma.getShowIndicatorData();
    var canculated = false;
    for (var i = 0; i < maList.length; i++) {
      final item = maList[i];
      if (item.num == midKey) {
        canculated = true; //已经计算过,直接取
        break;
      }
    }
    if (canculated == false) {
      //如果没有需要计算
      _calcMA(dataList, midKey!, isLast);
    }
    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      var maPrice = entity.MAPriceData[midKey];
      if (i < midKey!) {
        entity.mb = 0;
        entity.up = 0;
        entity.dn = 0;
      } else {
        int n = midKey!;
        List<double> biaozhuncha = [];
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          // double m = maPrice!;
          // double value = c - m;
          // md += value * value;
          biaozhuncha.add(c);
        }

        md = DataUtil.calculateStandardDeviation(biaozhuncha);
        // md = md / (n - 1);
        // md = sqrt(md);
        entity.mb = maPrice;
        entity.up = entity.mb! + stdKey! * md;
        entity.dn = entity.mb! - stdKey! * md;
      }
    }
  }

  static void _calcMACD(List<KLineEntity> dataList, [bool isLast = false]) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      dif = data.dif!;
      dea = data.dea!;
      macd = data.macd!;
      ema12 = data.ema12!;
      ema26 = data.ema26!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * (12 - 1) / (12 + 1) + closePrice * 2 / (12 + 1);
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * (26 - 1) / (26 + 1) + closePrice * 2 / (26 + 1);
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * (9 - 1) / (9 + 1) + dif * 2 / (9 + 1);
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
      entity.ema12 = ema12;
      entity.ema26 = ema26;
    }
  }

  static void _calcMACDCustom(List<KLineEntity> dataList,
      [bool isLast = false]) {
    final list = KlineIndicatorType.macd.getShowIndicatorData();
    // final List<dynamic> strJson = jsonDecode(str);
    if (list.isEmpty) {
      return;
    }
    var shortParam = list[0].num!; //12
    var longParam = list[1].num!; //26
    var cycle = list[2].num!; //9
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      dif = data.dif!;
      dea = data.dea!;
      macd = data.macd!;
      ema12 = data.ema12!;
      ema26 = data.ema26!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * (shortParam - 1) / (shortParam + 1) +
            closePrice * 2 / (shortParam + 1);
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * (longParam - 1) / (longParam + 1) +
            closePrice * 2 / (longParam + 1);
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * (cycle - 1) / (cycle + 1) + dif * 2 / (cycle + 1);
      macd = (dif - dea);
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
      entity.ema12 = ema12;
      entity.ema26 = ema26;
    }
  }

  static void _calcVolumeMA(List<KLineEntity> dataList, [bool isLast = false]) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    int i = 0;
    if (isLast && dataList.length > 10) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      volumeMa5 = data.MA5Volume! * 5;
      volumeMa10 = data.MA10Volume! * 10;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }
  static void _calcRSI(List<KLineEntity> dataList, [bool isLast = false]) {
    List<IndicatorsEntity> list =
    KlineIndicatorType.rsi.getShowIndicatorData();
    if (list.isEmpty) return;
    var newLast = isLast;
    for (int j = 0; j < list.length; j++){
      final key = list[j].num;
      _calcNewRSI(dataList,key!,newLast);
    }
  }
  static void _calcNewRSI(List<KLineEntity> dataList, int numberKey,[bool isLast = false]) {
    double rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    int numKey = numberKey;
    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
        rsi = data.rsiMapData[numKey] ?? 0;
        rsiABSEma = data.rsiABSEmaMapData[numKey] ?? 0;
        rsiMaxEma = data.rsiMaxEmaData[numKey] ?? 0;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      entity.rsiMapData[numKey] = 0;
        final double closePrice = entity.close;
        if (i == 0) {
          rsi = 0;
          rsiABSEma = 0;
          rsiMaxEma = 0;
        } else {
          double Rmax = max(0, closePrice - dataList[i - 1].close);
          double RAbs = (closePrice - dataList[i - 1].close).abs();
          rsiMaxEma = (Rmax + (numKey - 1) * rsiMaxEma) / numKey;
          rsiABSEma = (RAbs + (numKey - 1) * rsiABSEma) / numKey;
          rsi = (rsiMaxEma / rsiABSEma) * 100;
        }
        if (i < numKey) rsi = 0;
        if (rsi.isNaN) rsi = 0;
        entity.rsiMapData[numKey] = rsi;
        entity.rsiABSEmaMapData[numKey] = rsi;
        entity.rsiMaxEmaData[numKey] = rsi;
    }
  }

  static void _calcEMACustom(List<KLineEntity> dataList,
      [bool isLast = false]) {
    Iterable<IndicatorsEntity> list =
        KlineIndicatorType.ema.getShowIndicatorData();
    list = list.where((element) => element.isOpen!);
    if (list.isEmpty) return;
    // EMA = α*（当期收盘价-上期 EMA）+上期 EMA；
    // 其中α为平滑指数，α=2/(N+1)，N为时间周期。
    int i = 0;
    Map<int, double> mEMABuff = {};
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        list.forEach((element) {
          mEMABuff[element.num!] = closePrice;
          entity.EMAPriceData[element.num!] = closePrice;
        });
      } else {
        for (var element in list) {
          var a = 2 / (element.num! + 1);
          var ema = a * (closePrice - mEMABuff[element.num]!) +
              mEMABuff[element.num]!;
          mEMABuff[element.num!] = ema;
          entity.EMAPriceData[element.num!] = ema;
        }
      }
    }
  }

  static void _calcKDJCustom(List<KLineEntity> dataList,
      [bool isLast = false]) {
    var list = KlineIndicatorType.kdj.getShowIndicatorData();
    if (list.isEmpty) {
      return;
    }
    var moveCycle1 = list[1].num!; //3
    var moveCycle2 = list[2].num!; //3
    var cycle = list[0].num!; //9
    double k = 0;
    double d = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      k = data.k!;
      d = data.d!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      int startIndex = cycle;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = -double.maxFinite;
      double min14 = double.maxFinite;
      if(i <= cycle){
        max14 = dataList[i].high;
        min14 = dataList[i].low;
      }else{
        var maxCyclePosition = (i - cycle);
        for (int index = i; index >= maxCyclePosition; index--) {
          max14 = max(max14, dataList[index].high);
          min14 = min(min14, dataList[index].low);
        }
      }

      double rsv = (closePrice - min14) / (max14 - min14) * 100;
      if (rsv.isNaN) {
        rsv = 0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        //K值=(p-1)/p × 前一日K值+ 1/p × 当日RSV
        k = (moveCycle1 - 1) / moveCycle1 * k + 1 / moveCycle1 * rsv;
        //D值=(p-1)/p ×前一日D值+ 1/p × 当日K值
        d = (moveCycle2 - 1) / moveCycle2 * d + 1 / moveCycle2 * k;

        // k = (rsv + 2 * k) / 3;
        // d = (k + 2 * d) / 3;
      }
      if (i < 13) {
        entity.k = 0;
        entity.d = 0;
        entity.j = 0;
      } else if (i == 13 || i == 14) {
        entity.k = k;
        entity.d = 0;
        entity.j = 0;
      } else {
        entity.k = k;
        entity.d = d;
        entity.j = 3 * k - 2 * d;
      }
    }
  }

  //WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
  static void _calcWR(List<KLineEntity> dataList, [bool isLast = false]) {
    var wrList = KlineIndicatorType.wr.getShowIndicatorData();
    if (wrList.isEmpty) {
      return;
    }

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      entity.WRMapData.clear();
      // print("当前此项i = ${i}====entity.high= ${entity.high} =entity.low= ${entity.low}");
      double maxValue = -double.maxFinite;
      double minValue = double.maxFinite;
      for (var element in wrList) {
        final numKey = element.num!;
        int startIndex = i - numKey + 1;
        if (startIndex < 0) {
          startIndex = 0;
        }
        // print("numKey ====== ${numKey}");
        for (int index = startIndex; index <= i; index++) {
          final item = dataList[index];
          // print("前面 =index= ${index} entity.high= ${item.high} =entity.low= ${item.low}");
          maxValue = max(maxValue, item.high);
          minValue = min(minValue, item.low);
        }
        // print("前面  ${numKey} 项的最大值= ${maxValue} 最小值=${minValue}");
        if (maxValue - minValue != 0){ //保证除数不等于0
          entity.r =
              (maxValue - dataList[i].close) / (maxValue - minValue) * -100;
        }else{
          entity.r = 0;
        }
        // print("公式 = 100 * (${maxValue} - ${dataList[i].close})/(${maxValue} - ${minValue})");
        // print("最后的计算结果 = ${entity.r}");
        entity.WRMapData[numKey] = entity.r!;
        // print("最后记录  entity = >${entity.WRMapData}");
      }
    }
  }

  //增量更新时计算最后一个数据
  static addLastData(List<KLineEntity> dataList, KLineEntity data) {
    dataList.add(data);
    _calcMACustom(dataList, true);
    _calcEMACustom(dataList, true);
    _calcBOLL(dataList, true);
    _calcVolumeMA(dataList, true);
    _calcKDJCustom(dataList, true);
    _calcMACDCustom(dataList, true);
    _calcRSI(dataList, true);
    _calcWR(dataList, true);
  }

  //更新最后一条数据
  static updateLastData(List<KLineEntity> dataList) {
    _calcMACustom(dataList, true);
    _calcEMACustom(dataList, true);
    _calcBOLL(dataList, true);
    _calcVolumeMA(dataList, true);
    _calcKDJCustom(dataList, true);
    _calcMACDCustom(dataList, true);
    _calcRSI(dataList, true);
    _calcWR(dataList, true);
  }


  static double calculateStandardDeviation(List<double> data) {
    // 计算平均值
    double sum = 0;
    for (double value in data) {
      sum += value;
    }
    double mean = sum / data.length;

    // 计算差的平方并求和
    double squaredDifferencesSum = 0;
    for (double value in data) {
      double difference = value - mean;
      squaredDifferencesSum += difference * difference;
    }

    // 计算方差
    double variance = squaredDifferencesSum / data.length;

    // 计算标准差
    double standardDeviation = sqrt(variance);

    return standardDeviation;
  }
}

class MaBuffEntity {
  double ma;
  int num;

  MaBuffEntity({
    required this.ma,
    required this.num,
  });
}
