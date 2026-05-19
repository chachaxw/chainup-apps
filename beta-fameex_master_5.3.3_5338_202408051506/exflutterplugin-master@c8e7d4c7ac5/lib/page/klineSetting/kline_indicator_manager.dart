import 'dart:convert';

import 'package:get/get.dart';
import 'package:library_kline/models/indicators_entity.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../constants/color_constant.dart';

//
// "kline_indicator_ma": "MA",
// "kline_indicator_ema": "EMA",
// "kline_indicator_boll": "BOLL",
// "kline_indicator_macd": "MACD",
// "kline_indicator_rsi": "RSI",
// "kline_indicator_kdj": "KDJ",
// "kline_indicator_wr": "WR",
// "kline_indicator_mid": "MID",
// "kline_indicator_std": "STD",
// "kline_indicator_Period1": "计算周期",
// "kline_indicator_Period2": "移动平均周期 1",
// "kline_indicator_Period3": "移动平均周期 2",
// "kline_indicator_Period4": "计算周期",
// "kline_indicator_Period5": "短周期",
// "kline_indicator_Period6": "长周期",
// "kline_indicator_Period7": "移动平均周期",
enum KlineIndicatorType {
  ma("MA", 1, 1000,"kline_MA"), //
  ema("EMA", 1, 1000,"kline_EMA"),
  boll("BOLL", 1, 1000,"kline_BOLL"),
  macd("MACD", 2, 100,"kline_MACD"),
  rsi("RSI", 2, 1000,"kline_RSI"),
  kdj("KDJ", 1, 1000,"kline_KDJ"),
  wr("WR", 1, 1000,"kline_WR"),
  //其他辅助用的
  mid("MID", 2, 1000,""),
  std("STD", 2, 4,""),
  kdjPeriod1("kline_kdj1", 2, 90,"kline_kdj1"),
  kdjPeriod2("kline_kdj2", 2, 30,"kline_kdj2"),
  kdjPeriod3("kline_kdj3", 2, 30,"kline_kdj3"),
  unknow('error', 0, 0,"");

  const KlineIndicatorType(this.name, this.minNumber, this.maxNumber,this.lanKey);
  final String name;
  final int minNumber;
  final int maxNumber;
  final String lanKey;

  static KlineIndicatorType getTypeByTitle(String title) =>
      KlineIndicatorType.values.firstWhere((type) => type.name == title,
          orElse: () => KlineIndicatorType.unknow);

  String getStoreKey() {
    //用于存储
    return "KLineIndicator_$name";
  }

  bool showCheckBox() {
    if (this == KlineIndicatorType.boll ||
        this == KlineIndicatorType.macd ||
        this == KlineIndicatorType.kdj) {
      return false;
    }
    return true;
  }

  List<IndicatorsEntity> setDefaultData() {
    var list = <IndicatorsEntity>[];
    switch (this) {
      case KlineIndicatorType.ma:
        list = setMADefaultData();
        break;
      case KlineIndicatorType.ema:
        list = setEMADefaultData();
        break;
      case KlineIndicatorType.boll:
        list = setBOLLDefaultData();
        break;
      case KlineIndicatorType.macd:
        list = setMACDDefaultData();
        break;
      case KlineIndicatorType.kdj:
        list = setKDJDefaultData();
        break;
      case KlineIndicatorType.rsi:
        list = setRSIDefaultData();
        break;
      case KlineIndicatorType.wr:
        list = setWRDefaultData();
        break;
      default:
        break;
    }
    var map = list.map((s) => s.toJson()).toList();
    ExStorageUtils.putObject(getStoreKey(), jsonEncode(map));
    return list;
  }

  //获取指标数据
  List<IndicatorsEntity> getIndicatorData() {
    var storeData = ExStorageUtils.getString(getStoreKey());
    if (storeData.isEmpty) {
      setDefaultData();
      storeData = ExStorageUtils.getString(getStoreKey());
    }
    dynamic jsonData = jsonDecode(storeData);
    List<dynamic> list =
        jsonData.map((s) => IndicatorsEntity.fromJson(s)).toList();
    List<IndicatorsEntity> list1 = [];
    list.forEach((element) {
      var item = element as IndicatorsEntity;

      if (this == KlineIndicatorType.macd ||  this == KlineIndicatorType.kdj){ //macd / kdj 需要多语言
        item.name = item.name?.tr;
      }
      if (this == KlineIndicatorType.kdj){ //kdj 类型 来处理最大值和最小值
        if (item.name == "kline_kdj1".tr){
          item.type = KlineIndicatorType.kdjPeriod1;
        }else if(item.name == "kline_kdj2".tr){
         item.type = KlineIndicatorType.kdjPeriod2;
        }else {
          item.type = KlineIndicatorType.kdjPeriod3;
        }
      }else if (this == KlineIndicatorType.boll){

        if (item.name == "MID".tr){
          item.type = KlineIndicatorType.mid;
        }else if(item.name == "STD".tr){
          item.type = KlineIndicatorType.std;
        }
      } else{
        item.type = this;
      }
      print("this =${this} ${item.name?.tr}  ${item.type} ");
      list1.add(item);
    });
    return list1;
  }

  //获取存储的指标数据刷选出需要显示的key
  List<IndicatorsEntity> getShowIndicatorData() {
    var storeData = ExStorageUtils.getString(getStoreKey());
    if (storeData.isEmpty) {
      setDefaultData();
      storeData = ExStorageUtils.getString(getStoreKey());
    }
    dynamic jsonData = jsonDecode(storeData);
    List<dynamic> list =
        jsonData.map((s) => IndicatorsEntity.fromJson(s)).toList();
    List<IndicatorsEntity> list1 = [];
    list.forEach((element) {
      var item = element as IndicatorsEntity;
      item.type = this;
      if (item.isOpen ?? false) {
        list1.add(item);
      }
    });
    return list1;
  }

  List<IndicatorsEntity> setMADefaultData() {
    var buff = <IndicatorsEntity>[];
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 5,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.ma));
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 10,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.ma));
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 30,
        isOpen: true,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.ma));
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_4,
        type: KlineIndicatorType.ma));
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_5,
        type: KlineIndicatorType.ma));
    buff.add(IndicatorsEntity(
        name: KlineIndicatorType.ma.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_6,
        type: KlineIndicatorType.ma));
    return buff;
  }

  List<IndicatorsEntity> setEMADefaultData() {
    var mEMas = <IndicatorsEntity>[];
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 5,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.ema));
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 10,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.ema));
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 20,
        isOpen: true,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.ema));
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_4,
        type: KlineIndicatorType.ema));
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_5,
        type: KlineIndicatorType.ema));
    mEMas.add(IndicatorsEntity(
        name: KlineIndicatorType.ema.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_6,
        type: KlineIndicatorType.ema));
    return mEMas;
  }

  List<IndicatorsEntity> setBOLLDefaultData() {
    var list = <IndicatorsEntity>[];
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.mid.name,
        num: 20,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.mid));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.std.name,
        num: 2,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.std));

    return list;
  }

  List<IndicatorsEntity> setMACDDefaultData() {
    var list = <IndicatorsEntity>[];
    list.add(IndicatorsEntity(
        name: 'kline_macdShort',
        num: 12,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.macd));
    list.add(IndicatorsEntity(
        name: 'kline_macdLong',
        num: 26,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.macd));
    list.add(IndicatorsEntity(
        name: 'kline_macdMa',
        num: 9,
        isOpen: true,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.macd));

    return list;
  }

  List<IndicatorsEntity> setRSIDefaultData() {
    var list = <IndicatorsEntity>[];
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.rsi.name,
        num: 6,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.rsi));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.rsi.name,
        num: 12,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.rsi));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.rsi.name,
        num: 24,
        isOpen: true,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.rsi));

    return list;
  }

  List<IndicatorsEntity> setKDJDefaultData() {
    var list = <IndicatorsEntity>[];
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.kdjPeriod1.lanKey,
        num: 9,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.kdjPeriod1));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.kdjPeriod2.lanKey,
        num: 3,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.kdjPeriod2));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.kdjPeriod3.lanKey,
        num: 3,
        isOpen: true,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.kdjPeriod3));

    return list;
  }

  List<IndicatorsEntity> setWRDefaultData() {
    var list = <IndicatorsEntity>[];
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 4,
        isOpen: true,
        lineColor: ExColorsLight.line_1,
        type: KlineIndicatorType.wr));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 20,
        isOpen: true,
        lineColor: ExColorsLight.line_2,
        type: KlineIndicatorType.wr));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_3,
        type: KlineIndicatorType.wr));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_4,
        type: KlineIndicatorType.wr));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_5,
        type: KlineIndicatorType.wr));
    list.add(IndicatorsEntity(
        name: KlineIndicatorType.wr.name,
        num: 1,
        isOpen: false,
        lineColor: ExColorsLight.line_6,
        type: KlineIndicatorType.wr));
    return list;
  }
}
