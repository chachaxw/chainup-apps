import 'dart:math';

import 'package:chainup_flutter_ex/page/kline/main_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../chart_style.dart' show ChartStyle;
import '../entity/k_line_entity.dart';
import '../k_chart_widget.dart';
import '../models/entrust_order_entity.dart';
import '../models/position_entity.dart';
import '../utils/date_format_util.dart';
import '../utils/number_util.dart';
import '../utils/storage_utils.dart';

export 'package:flutter/material.dart'
    show Color, required, TextStyle, Rect, Canvas, Size, CustomPainter;

abstract class BaseChartPainter extends CustomPainter {
  static double maxScrollX = 0.0;
  List<KLineEntity> datas;
  MainState mainState;
  VolState volState;
  SecondaryState secondaryState;
  List<String> secondaryUIList = ["WR", "KDJ"];
  String? waterLogoPath;
  bool? isSmallKline;
  final Size waterLogoSize = const Size(18.0, 18.0);
  double scaleX = 1.0, scrollX = 0.0, selectX, selectY;
  bool isLongPress = false;
  bool isLine;
  bool isShowOrder;
  int? repaintNum = -1;
  List<PositionOrder> positionList;
  List<EntrustOrder> entrustList;

  //3块区域大小与位置
  late Rect mMainRect;
  Rect? mVolRect,
      mSecondaryRect,
      mSecondaryMACDRect,
      mSecondaryRSIRect,
      mSecondaryKDJRect,
      mSecondaryWRRect;
  late double mDisplayHeight, mWidth;

  int mStartIndex = 0, mStopIndex = 0;
  double mMainMaxValue = -double.maxFinite, mMainMinValue = double.maxFinite;
  double mVolMaxValue = -double.maxFinite, mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = -double.maxFinite,
      mSecondaryMinValue = double.maxFinite;
  double mSecondaryKDJMaxValue = -double.maxFinite,
      mSecondaryKDJMinValue = double.maxFinite;
  double mSecondaryWRMaxValue = -double.maxFinite,
      mSecondaryWRMinValue = double.maxFinite;
  double mSecondaryRSIMaxValue = -double.maxFinite,
      mSecondaryRSIMinValue = double.maxFinite;
  double mSecondaryMACDMaxValue = -double.maxFinite,
      mSecondaryMACDMinValue = double.maxFinite;

  double mTranslateX = -double.maxFinite;
  int mMainMaxIndex = 0, mMainMinIndex = 0;
  double mMainHighMaxValue = -double.maxFinite,
      mMainLowMinValue = double.maxFinite;
  int mItemCount = 0;
  double mDataLen = 0.0; //数据占屏幕总长度
  double mPointWidth = ChartStyle.pointWidth;
  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间
  double mMarginRight = 0.0; //k线右边空出来的距离

  List<KLineEntity> sellKLine = [];
  List<KLineEntity> buyKLine = [];
  List<int> sellIndexs = [];
  List<int> buyIndexs = [];
  Orientation? orientation;
  BaseChartPainter(
      {required this.datas,
      required this.scaleX,
      required this.scrollX,
      required this.isLongPress,
      required this.selectX,
      required this.selectY,
      required this.secondaryUIList,
      this.mainState = MainState.MA,
      this.volState = VolState.VOL,
      this.secondaryState = SecondaryState.MACD,
      this.isLine = false,
      this.isShowOrder = true,
      this.waterLogoPath,
      this.isSmallKline,
      this.orientation,
      this.repaintNum = -1,
      required this.positionList,
      required this.entrustList
    }) {
    mItemCount = datas.length;
    mDataLen = mItemCount * mPointWidth;
    initFormats();
  }

  void initFormats() {
//    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]
    if (mItemCount < 2) return;
    int firstTime = datas.first.id ?? 0;
    int secondTime = datas[1].id ?? 0;
    int time = secondTime - firstTime;
    //月线
    if (time >= 24 * 60 * 60 * 28)
      mFormats = [yyyy, '-', mm, '-', dd];
    //日线等
    else if (time >= 24 * 60 * 60)
      mFormats = [yyyy, '-', mm, '-', dd];
    //小时线等
    else
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
  }

  void setWaterLogoPath(String path) {
    waterLogoPath = path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print("repaint>>>${repaintNum}");
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    mDisplayHeight = size.height -
        ChartStyle.topPadding -
        ChartStyle.bottomDateHigh -
        ChartStyle.bottomPadding;
    mWidth = size.width;
    if(orientation==Orientation.landscape){
      mMarginRight = (mWidth / ChartStyle.gridColumns - mPointWidth - 80) / scaleX;
    }else{
      mMarginRight = (mWidth / ChartStyle.gridColumns - mPointWidth) / scaleX;
    }

    initRect(size);
    calculateValue();
    initChartRenderer();

    canvas.save();
    canvas.scale(1, 1);
    drawWaterLogo(canvas);
    drawBg(canvas, size);
    //网格线
    drawGrid(canvas);
    if (datas.isNotEmpty) {
      //柱子+指标线
      drawChart(canvas, size);
      //历史委托小角标
      // print("isShowOrder:$isShowOrder");
      if (isShowOrder == true) drawSellAndBuy(canvas);
      //最高价/最低价
      drawMaxAndMin(canvas);
      //右侧价格
      drawRightText(canvas);
      drawDate(canvas, size);
      //左上角指标文字
      drawText(canvas, datas.last, 5);

      drawPositionOrder(canvas, size);
      drawEntrustOrder(canvas, size);

      //最新价灰色标签（带箭头）+横虚线
      drawRealTimePrice(canvas, size);
      //十字线、右侧灰色标签价格、气泡
      if (isLongPress == true) drawCrossLineText(canvas, size);

    }
    canvas.restore();
  }

  void initChartRenderer();

  //画背景
  void drawBg(Canvas canvas, Size size);

  //画网格
  void drawGrid(Canvas canvas);

  //画图表
  void drawChart(Canvas canvas, Size size);

  //画右边值
  void drawRightText(canvas);

  //画时间
  void drawDate(Canvas canvas, Size size);

  //画值
  void drawText(Canvas canvas, KLineEntity data, double x);

  //画最大最小值
  void drawMaxAndMin(Canvas canvas);

  //画卖买点icon
  void drawSellAndBuy(Canvas canvas);

  //交叉线值
  void drawCrossLineText(Canvas canvas, Size size);

  void initRect(Size size) {
    double mainHeight = mDisplayHeight * 0.8;
    double secondaryHeight = mDisplayHeight * 0.2;
    // 0.84  1
    // 0.72  2
    // 0.63  3
    // 0.56  4
    double mainFactor = 1.00;
    double childFactor = 0.00;
    switch(secondaryUIList.length){
      case 0:
        mainFactor = 1.00;
        break;
      case 1:
        mainFactor = 0.80;
        break;
      case 2:
        mainFactor = 0.68;
        break;
      case 3:
        mainFactor = 0.60;
        break;
      case 4:
        mainFactor = 0.54;
        break;
    }
    childFactor = 1.0 - mainFactor;

    mainHeight = mDisplayHeight * mainFactor;
    var subConsumableHeight = mDisplayHeight * childFactor;
    var itemSubHeight = subConsumableHeight / secondaryUIList.length;
    secondaryHeight = itemSubHeight;

    mMainRect = Rect.fromLTRB(
        0, ChartStyle.topPadding, mWidth, ChartStyle.topPadding + mainHeight);
    for (var i = 0; i < secondaryUIList.length; i++) {
      var currentItemSecondaryName = secondaryUIList[i];
      var prevItemSecondaryName = i == 0 ? "" : secondaryUIList[i - 1];
      double bottomCalc = 0;
      if (prevItemSecondaryName == "") {
        bottomCalc = mMainRect.bottom + ChartStyle.bottomPadding;
      } else {
        var cRect = getRectByStr(prevItemSecondaryName);
        bottomCalc = cRect?.bottom ?? (mVolRect?.bottom ?? mMainRect.bottom);
      }

      switch (currentItemSecondaryName) {
        case "VOL":
          mVolRect = Rect.fromLTRB(
              0,
              bottomCalc + ChartStyle.childPadding,
              mWidth,
              bottomCalc + secondaryHeight
          );
          break;
        case "KDJ":
          mSecondaryKDJRect = Rect.fromLTRB(
              0,
              bottomCalc + ChartStyle.childPadding,
              mWidth,
              bottomCalc + secondaryHeight);
          break;
        case "WR":
          mSecondaryWRRect = Rect.fromLTRB(
              0,
              bottomCalc + ChartStyle.childPadding,
              mWidth,
              bottomCalc + secondaryHeight);
          break;
        case "MACD":
          mSecondaryMACDRect = Rect.fromLTRB(
              0,
              bottomCalc + ChartStyle.childPadding,
              mWidth,
              bottomCalc + secondaryHeight);
          break;
        case "RSI":
          mSecondaryRSIRect = Rect.fromLTRB(
              0,
              bottomCalc + ChartStyle.childPadding,
              mWidth,
              bottomCalc + secondaryHeight);
          break;
      }
    }
  }

  Rect? getRectByStr(String name) {
    switch (name) {
      case "VOL":
        return mVolRect;
      case "KDJ":
        return mSecondaryKDJRect;
      case "WR":
        return mSecondaryWRRect;
      case "MACD":
        return mSecondaryMACDRect;
      case "RSI":
        return mSecondaryRSIRect;
      default:
        return mMainRect;
    }
  }

  calculateValue() {
    if (datas.isEmpty) return;
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX);
    mStartIndex = indexOfTranslateX(xToTranslateX(0));
    mStopIndex = indexOfTranslateX(xToTranslateX(mWidth));
    sellIndexs.clear();
    buyIndexs.clear();
    buyKLine.clear();
    sellKLine.clear();
    for (int i = ((mStartIndex-1)>=0 ? (mStartIndex-1) : mStartIndex); i <= mStopIndex; i++) {
      var item = datas[i];
      getMainMaxMinValue(item, i);
      getVolMaxMinValue(item);
      getSecondaryMaxMinValue(item);

      getMainBuySellValue(item, i);
    }
  }

  void getMainBuySellValue(KLineEntity item, int i) {
    if (item.orderIsBuy == true) {
      buyKLine.add(item);
      buyIndexs.add(i);
    }
    if (item.orderIsSell == true) {
      sellKLine.add(item);
      sellIndexs.add(i);
    }
  }

  void getMainMaxMinValue(KLineEntity item, int i) {
    if (isLine == true) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    } else {
      //获取所有指标的最大值和最小值，防止画的线越界
      double maxPrice = item.high, minPrice = item.low;
      var mainUIStr = ExStorageUtils.getString(
          ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST);
      List<String> mainUIList = mainUIStr.split(",");
      List<double> numberValueList = [];
      for (var element in mainUIList) {
        MainState state = MainState.getTypeByValue(element);
        // print("state = $state");
        if (state == MainState.MA) {
          numberValueList = item.MAPriceData.values.toList();
        } else if (state == MainState.EMA) {
          numberValueList = item.EMAPriceData.values.toList();
        } else if (state == MainState.BOLL) {
          numberValueList = [item.up!, item.dn!];
        }
        // print("numberValueList = $numberValueList");
        for (var numValue in numberValueList) {
          maxPrice = max(maxPrice, numValue);
          minPrice = min(minPrice, numValue==0?item.low:numValue);
        }
        // print("maxPrice = $maxPrice");
        // print("minPrice = $minPrice");
      }

      mMainMaxValue = max(mMainMaxValue, maxPrice);
      mMainMinValue = min(mMainMinValue, minPrice);
      if (mMainMinValue < 0) {
        mMainMinValue = 0;
      }
      if (mMainHighMaxValue < item.high) {
        mMainHighMaxValue = item.high;
        mMainMaxIndex = i;
      }
      if (mMainLowMinValue > item.low) {
        mMainLowMinValue = item.low;
        mMainMinIndex = i;
      }
    }
  }

  void getVolMaxMinValue(KLineEntity item) {
    mVolMaxValue = max(
        mVolMaxValue, max(item.vol, max(item.MA5Volume!, item.MA10Volume!)));
    mVolMinValue = min(
        mVolMinValue, min(item.vol, min(item.MA5Volume!, item.MA10Volume!)));
  }

  void getSecondaryMaxMinValue(KLineEntity item) {
    mSecondaryMACDMaxValue =
        max(mSecondaryMACDMaxValue, max(item.macd!, max(item.dif!, item.dea!)));
    mSecondaryMACDMinValue =
        min(mSecondaryMACDMinValue, min(item.macd!, min(item.dif!, item.dea!)));
    mSecondaryKDJMaxValue =
        max(mSecondaryKDJMaxValue, max(item.k!, max(item.d!, item.j!)));
    mSecondaryKDJMinValue =
        min(mSecondaryKDJMinValue, min(item.k!, min(item.d!, item.j!)));

    item.rsiMapData.forEach((key, value) {
      // print("rsiMapData = key-${key} value-${value}");
      // if (value > 0) {
        mSecondaryRSIMaxValue = max(mSecondaryRSIMaxValue, value);
        mSecondaryRSIMinValue = min(mSecondaryRSIMinValue, value);
      // }
    });
    item.WRMapData.forEach((key, value) {
      // print("WRMapData = key-${key} value-${value}");
        mSecondaryWRMaxValue = max(mSecondaryWRMaxValue, value);
        mSecondaryWRMinValue = min(mSecondaryWRMinValue, value);
    });
    // mSecondaryRSIMaxValue = max(mSecondaryRSIMaxValue, item.rsi!);
    // mSecondaryRSIMinValue = min(mSecondaryRSIMinValue, item.rsi!);
    // mSecondaryWRMaxValue = max(mSecondaryWRMaxValue, item.r!);
    // mSecondaryWRMinValue = min(mSecondaryWRMinValue, item.r!);
  }

  double xToTranslateX(double x) => -mTranslateX + x / scaleX;

  int indexOfTranslateX(double translateX) =>
      _indexOfTranslateX(translateX, 0, mItemCount - 1);

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end);
    } else {
      return mid;
    }
  }

  ///根据索引索取x坐标
  ///+ mPointWidth / 2防止第一根和最后一根k线显示不全
  ///@param position 索引值
  double getX(int position) => position * mPointWidth + mPointWidth / 2;

  KLineEntity getItem(int position) {
    return datas[position];
  }

  ///scrollX 转换为 TranslateX
  void setTranslateXFromScrollX(double scrollX) =>
      mTranslateX = scrollX + getMinTranslateX();

  ///获取平移的最小值
  double getMinTranslateX() {
//    var x = -mDataLen + mWidth / scaleX - mPointWidth / 2;
    var x = -mDataLen + mWidth / scaleX - mPointWidth / 2;
    x = x >= 0 ? 0.0 : x;
    //数据不足一屏
    if (x >= 0) {
      if (mWidth / scaleX - getX(datas.length) < mMarginRight) {
        //数据填充后剩余空间比mMarginRight小，求出差。x-=差
        x -= mMarginRight - mWidth / scaleX + getX(datas.length);
      } else {
        //数据填充后剩余空间比Right大
        mMarginRight = mWidth / scaleX - getX(datas.length);
      }
    } else if (x < 0) {
      //数据超过一屏
      x -= mMarginRight;
    }
    return x >= 0 ? 0.0 : x;
  }

  ///计算长按后x的值，转换为index
  int calculateSelectedX(double selectX) {
    int mSelectedIndex = indexOfTranslateX(xToTranslateX(selectX));
    if (mSelectedIndex < mStartIndex) {
      mSelectedIndex = mStartIndex;
    }
    if (mSelectedIndex > mStopIndex) {
      mSelectedIndex = mStopIndex;
    }
    return mSelectedIndex;
  }

  ///translateX转化为view中的x
  double translateXtoX(double translateX) =>
      (translateX + mTranslateX) * scaleX;

  TextStyle getTextStyle(Color color) {
    return TextStyle(
        fontSize: ChartStyle.defaultTextSize,
        color: color,
        fontFamily: ChartStyle.fontFamily);
  }

  void drawRealTimePrice(Canvas canvas, Size size);

  void drawEntrustOrder(Canvas canvas, Size size);
  void drawPositionOrder(Canvas canvas, Size size);

  String format(double n) {
    return NumberUtil.format(n,rounding: true);
  }

  void drawWaterLogo(Canvas canvas) {
    // print("waterLogoPath_kline : $waterLogoPath");
    if (waterLogoPath == null || "" == waterLogoPath) return;
    final image = NetworkImage(waterLogoPath!);
    final stream = image.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((info, _) {
      final img = info.image;
      if (img != null) {
        final imageSize = Size(img.width.toDouble(), img.height.toDouble());
        final srcRect = Rect.fromPoints(
            Offset(0, 0), Offset(imageSize.width, imageSize.height));

        var logoW = 0.0;
        var logoH = 0.0;
        var factor = imageSize.width / imageSize.height;
        if (factor == 1) {
          logoW = waterLogoSize.width;
          logoH = waterLogoSize.width;
        } else {
          if (imageSize.width > imageSize.height) {
            logoW = waterLogoSize.width * factor;
            logoH = waterLogoSize.width;
          } else {
            logoH = waterLogoSize.width * factor;
            logoW = waterLogoSize.width;
          }
        }

        print("waterLogoSizeInfo>>>width=$logoW,height=$logoH");

        Rect destRect;
        if(isSmallKline==true){
          double centerX = (mMainRect.width - logoW) / 2;
          double centerY = (mMainRect.height - logoH) / 2;
          destRect = Rect.fromPoints(Offset(centerX, centerY),
              Offset(centerX + logoW, centerY + logoH));
        }else{
          destRect = Rect.fromPoints(Offset(5, mMainRect.height - logoH + ChartStyle.topPadding - 4.0),
              Offset(logoW + 5, mMainRect.height + ChartStyle.topPadding - 4.0));
        }

        canvas.drawImageRect(img, srcRect, destRect, Paint());
      }
    }));
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
//    return oldDelegate.datas != datas ||
//        oldDelegate.datas?.length != datas?.length ||
//        oldDelegate.scaleX != scaleX ||
//        oldDelegate.scrollX != scrollX ||
//        oldDelegate.isLongPress != isLongPress ||
//        oldDelegate.selectX != selectX ||
//        oldDelegate.isLine != isLine ||
//        oldDelegate.mainState != mainState ||
//        oldDelegate.secondaryState != secondaryState;
  }
}
