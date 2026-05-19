import 'dart:async' show StreamSink;
import 'dart:convert';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/flutter_k_chart.dart';
import 'package:library_kline/models/position_entity.dart';
import 'package:library_kline/utils/kline_color_constant.dart';
import '../entity/k_line_entity.dart';
import '../models/entrust_order_entity.dart';
import '../utils/date_format_util.dart';
import '../entity/info_window_entity.dart';

import '../utils/decimal_util.dart';
import '../utils/klineCoinInfo.dart';
import '../utils/number_util.dart';
import '../utils/storage_utils.dart';
import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

class ChartPainter extends BaseChartPainter {
  static get maxScrollX => BaseChartPainter.maxScrollX;
  // static get  rectRealTimePrice =>rectRealTimeBg1;
  late BaseChartRenderer mMainRenderer;
  BaseChartRenderer? mVolRenderer,
      mSecondaryRenderer,
      mSecondaryMACDRenderer,
      mSecondaryRSIRenderer,
      mSecondaryKDJRenderer,
      mSecondaryWRRenderer;

  StreamSink<InfoWindowEntity?>? sink;
  AnimationController? controller;
  double opacity;
  BuildContext mBuildContext;
  late Paint mBgPaint;
  static late RRect rectRealTimePrice;
  List<String> mainUIList = [];
  ChartPainter(
      {required datas,
      required scaleX,
      required scrollX,
      required isLongPass,
      required selectX,
      required selectY,
      required secondaryUIList,
      required mainUIList,
      mainState,
      volState,
      secondaryState,
      this.sink,
      bool isSmallKline = false,
      bool isLine = false,
      bool isShowOrder = false,
      this.controller,
      required this.mBuildContext,
      this.opacity = 0.0,
      String? waterLogoPath,
      Orientation? orientation,
      int? repaintNum,
      required List<PositionOrder> positionList,
      required List<EntrustOrder> entrustList
      })
      : super(
            datas: datas,
            scaleX: scaleX,
            scrollX: scrollX,
            isLongPress: isLongPass,
            selectX: selectX,
            selectY: selectY,
            mainState: mainState,
            volState: volState,
            secondaryState: secondaryState,
            isLine: isLine,
            isShowOrder: isShowOrder,
            secondaryUIList: secondaryUIList,
            waterLogoPath: waterLogoPath,
            isSmallKline: isSmallKline,
            orientation: orientation,
            repaintNum:repaintNum,
            positionList: positionList,
            entrustList: entrustList,
  ) {
    this.mainUIList = mainUIList;
  }

  @override
  void initChartRenderer() {
    mMainRenderer = MainRenderer(mMainRect, mMainMaxValue, mMainMinValue,
        ChartStyle.topPadding, mainState, isLine, scaleX, mainUIList, this);

    for (var i = 0; i < secondaryUIList.length; i++) {
      var currentItemSecondaryName = secondaryUIList[i];
      switch (currentItemSecondaryName) {
        case "VOL":
          mVolRenderer ??= VolRenderer(mVolRect!, mVolMaxValue, mVolMinValue,
              ChartStyle.childPadding, scaleX);
          break;
        case "KDJ":
          mSecondaryKDJRenderer ??= SecondaryRenderer(
              mSecondaryKDJRect!,
              mSecondaryKDJMaxValue,
              mSecondaryKDJMinValue,
              ChartStyle.childPadding,
              SecondaryState.KDJ,
              scaleX);
          break;
        case "WR":
          mSecondaryWRRenderer ??= SecondaryRenderer(
              mSecondaryWRRect!,
              mSecondaryWRMaxValue,
              mSecondaryWRMinValue,
              ChartStyle.childPadding,
              SecondaryState.WR,
              scaleX);
          break;
        case "MACD":
          mSecondaryMACDRenderer ??= SecondaryRenderer(
              mSecondaryMACDRect!,
              mSecondaryMACDMaxValue,
              mSecondaryMACDMinValue,
              ChartStyle.childPadding,
              SecondaryState.MACD,
              scaleX);
          break;
        case "RSI":
          mSecondaryRSIRenderer ??= SecondaryRenderer(
              mSecondaryRSIRect!,
              mSecondaryRSIMaxValue,
              mSecondaryRSIMinValue,
              ChartStyle.childPadding,
              SecondaryState.RSI,
              scaleX);
          break;
      }
    }

    // if (mSecondaryRect != null) {
    //   mSecondaryRenderer ??= SecondaryRenderer(
    //       mSecondaryRect!,
    //       mSecondaryMaxValue,
    //       mSecondaryMinValue,
    //       ChartStyle.childPadding,
    //       secondaryState,
    //       scaleX);
    // }
  }

  // final Paint mBgPaint = Paint()..color = ChartColors.bgColor;

  @override
  void drawBg(Canvas canvas, Size size) {
    mBgPaint = Paint()..color = ExKlineColors.transparent_color(mBuildContext);
    Rect mainRect = Rect.fromLTRB(
        0, 0, mMainRect.width, mMainRect.height + ChartStyle.topPadding);
    canvas.drawRect(mainRect, mBgPaint);

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(0, mVolRect!.top - ChartStyle.childPadding,
          mVolRect!.width, mVolRect!.bottom);
      canvas.drawRect(volRect, mBgPaint);
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(
          0,
          mSecondaryRect!.top - ChartStyle.childPadding,
          mSecondaryRect!.width,
          mSecondaryRect!.bottom);
      canvas.drawRect(secondaryRect, mBgPaint);
    }
    Rect dateRect = Rect.fromLTRB(
        0, size.height - ChartStyle.bottomDateHigh, size.width, size.height);
    canvas.drawRect(dateRect, mBgPaint);
  }

  @override
  void drawGrid(Canvas canvas) {
    final Paint gridPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = ChartColors.gridColor;
    mMainRenderer.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    var isNeedDrawLine = true;
    if ((secondaryUIList.isNotEmpty || volState == VolState.VOL)) {
      isNeedDrawLine = true;
    } else {
      isNeedDrawLine = false;
    }
    if (isNeedDrawLine)
      canvas.drawLine(Offset(0, mMainRect.height + 24.0 + ChartStyle.topPadding),
          Offset(mMainRect.width, mMainRect.height + 24.0 + ChartStyle.topPadding), gridPaint);

    mVolRenderer?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    mSecondaryRenderer?.drawGrid(
        canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    mSecondaryWRRenderer?.drawGrid(
        canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    mSecondaryKDJRenderer?.drawGrid(
        canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    mSecondaryMACDRenderer?.drawGrid(
        canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    mSecondaryRSIRenderer?.drawGrid(
        canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      KLineEntity curPoint = datas[i];
      KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryWRRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryRSIRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryKDJRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryMACDRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
    }

    canvas.restore();
    // if (isLongPress == true) drawCrossLine(canvas, size);
  }

  @override
  void drawRightText(canvas) {
    var textStyle = getTextStyle(ChartColors.yAxisTextColor);
    mMainRenderer.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mVolRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mSecondaryRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mSecondaryWRRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mSecondaryKDJRenderer?.drawRightText(
        canvas, textStyle, ChartStyle.gridRows);
    mSecondaryRSIRenderer?.drawRightText(
        canvas, textStyle, ChartStyle.gridRows);
    mSecondaryMACDRenderer?.drawRightText(
        canvas, textStyle, ChartStyle.gridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / ChartStyle.gridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double y = 0.0;
    for (var i = 0; i <= ChartStyle.gridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        String dateStr = getDate(datas[index].id!);
        TextPainter tp = getTextPainter(dateStr,
            color: ChartColors.xAxisTextColor);
        y = mMainRect.height +
            ChartStyle.topPadding +
            (ChartStyle.bottomPadding - tp.height) / 2;
        // print("mMainRect height>>>" + y.toString());
        var xPosition = columnSpace * i - tp.width / 2;
        if (i == 0) {
          xPosition = 0;
          if(dateStr.contains(" ")){
            var time = dateStr.split(" ")[1];
            tp = getTextPainter(time,
                color: ChartColors.xAxisTextColor);
          }else if(dateStr.contains("-")){
            var date = dateStr.substring(dateStr.indexOf("-")+1,dateStr.length);
            tp = getTextPainter(date,
                color: ChartColors.xAxisTextColor);
          }
        } else if (i == ChartStyle.gridColumns) {

          if(dateStr.contains(" ")){
            var time = dateStr.split(" ")[1];
            tp = getTextPainter(time,
                color: ChartColors.xAxisTextColor);
          }else if(dateStr.contains("-")){
            var date = dateStr.substring(dateStr.indexOf("-")+1,dateStr.length);
            tp = getTextPainter(date,
                color: ChartColors.xAxisTextColor);
          }
          xPosition = columnSpace * i - tp.width;
        }
        tp.paint(canvas, Offset(xPosition, y));
      }
    }
  }

  Paint selectPointPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..color = ChartColors.longPressPathBgColor;
  Paint selectorBorderPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke
    ..color = ChartColors.longPressDateBorderLineColor;

  double getYPriceByLongPressY() {
    var changePositionY = selectY;
    if(mMainRect.contains(Offset(selectX, selectY))){
      print("getYPriceByLongPressY>>>进入主图");
      changePositionY = selectY - mMainRect.top;
      double positionYScale = min(changePositionY / (mMainRect.height), 1);
      double value = (mMainRenderer.maxValue - mMainRenderer.minValue) *
          (1 - positionYScale);
      double cprice = mMainRenderer.minValue + value;
      // double y = getMainY(cprice) - mMainRenderer.topPadding;
      return cprice;
    }else if(mVolRect?.contains(Offset(selectX, selectY))??false){
      return getSecondaryYPriceByLongPressY(mVolRect!,mVolRenderer as BaseChartRenderer);
    }else if(mSecondaryMACDRect?.contains(Offset(selectX, selectY))??false){
      return getSecondaryYPriceByLongPressY(mSecondaryMACDRect!,mSecondaryMACDRenderer! as SecondaryRenderer);
    }else if(mSecondaryRSIRect?.contains(Offset(selectX, selectY))??false){
      return getSecondaryYPriceByLongPressY(mSecondaryRSIRect!,mSecondaryRSIRenderer! as SecondaryRenderer);
    }else if(mSecondaryKDJRect?.contains(Offset(selectX, selectY))??false){
      return getSecondaryYPriceByLongPressY(mSecondaryKDJRect!,mSecondaryKDJRenderer! as SecondaryRenderer);

    }else if(mSecondaryWRRect?.contains(Offset(selectX, selectY))??false){
      return getSecondaryYPriceByLongPressY(mSecondaryWRRect!,mSecondaryWRRenderer! as SecondaryRenderer);

    }else{
      return 0.0;
    }
  }

  double getSecondaryYPriceByLongPressY(Rect secondaryRect,BaseChartRenderer? secondaryRenderer){
    if(secondaryRenderer == null){
      return 0.0;
    }
    var changePositionY = selectY;
    print("getYPriceByLongPressY>>>进入${secondaryRenderer}图");
    changePositionY = selectY - secondaryRect.top;
    double positionYScale = min(changePositionY / (secondaryRect.height), 1);
    double value = (secondaryRenderer.maxValue - secondaryRenderer.minValue) * (1 - positionYScale);
    double cprice = secondaryRenderer.minValue + value;
    if(cprice>secondaryRenderer.maxValue){
      return secondaryRenderer.maxValue;
    }else if(cprice<secondaryRenderer.minValue){
      return secondaryRenderer.minValue;
    }
    return cprice;
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    drawCrossLine(canvas, size);
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);
    double price = getYPriceByLongPressY();
    if(price==0.0) return;
    TextPainter tp = getTextPainter(format(price),
        color: ChartColors.longPressPathTextColor);
    if(mVolRect?.contains(Offset(selectX, selectY))??false){
      tp = getTextPainter(NumberUtil.volFormat(price),
          color: ChartColors.longPressPathTextColor);
    }
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 9;
    double r = textHeight / 2 + 3;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
    } else {
      isLeft = true;
    }
    x = mWidth - textWidth - 1 - 2 * w1 - w2;
    Path path = new Path();
    path.moveTo(x, selectY);
    path.lineTo(x + w2, selectY + r);
    path.lineTo(mWidth, selectY + r);
    path.lineTo(mWidth, selectY - r);
    path.lineTo(x + w2, selectY - r);
    path.close();
    canvas.drawPath(path, selectPointPaint);
    // canvas.drawPath(path, selectorBorderPaint);
    tp.paint(canvas, Offset(x + w1 + w2, selectY - textHeight / 2));

    TextPainter dateTp = getTextPainter(getDate(point.id!),
        color: ChartColors.longPressPathTextColor);
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - ChartStyle.bottomDateHigh;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    double dateHorPadding = 4.0;
    var phei = mMainRect.height +
        ChartStyle.topPadding + 4.0;
    canvas.drawRRect(
        RRect.fromLTRBR(
            x - textWidth / 2 - dateHorPadding, phei,
            x + textWidth / 2 + dateHorPadding, phei + baseLine + r + 4,const Radius.circular(4.0)
        ),
        selectPointPaint
    );
    canvas.drawRRect(
        RRect.fromLTRBR(x - textWidth / 2 - dateHorPadding, phei,
            x + textWidth / 2 + dateHorPadding, phei + baseLine + r + 4,const Radius.circular(4.0)
        ),
        selectorBorderPaint
    );

    dateTp.paint(canvas, Offset(x - textWidth / 2, phei + 3));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
    mSecondaryKDJRenderer?.drawText(canvas, data, x);
    mSecondaryRSIRenderer?.drawText(canvas, data, x);
    mSecondaryMACDRenderer?.drawText(canvas, data, x);
    mSecondaryWRRenderer?.drawText(canvas, data, x);
  }

  void drawSellAndBuy(Canvas canvas) {
    if (isLine == true) return;
    double x = 0;
    double y = 0;
    for (var index = 0; index < buyKLine.length; index++) {
      double x = translateXtoX(getX(buyIndexs[index]));
      double y = getMainY(buyKLine[index].low);

      Size size = Size(14, 14);
      final squarePaint = Paint()..color = ChartColors.depthBuyColor;
      final arrowPaint = Paint()..color = ChartColors.depthBuyColor;

      final squareRect = RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(x - ChartStyle.pointWidth, y + 6),
          Offset(x + ChartStyle.pointWidth, y+size.height + 6),
        ),
        Radius.circular(4.0),
      );
      canvas.drawRRect(squareRect, squarePaint);
      TextSpan span = TextSpan(text: "B", style: getTextStyle(Colors.white));
      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(x - ChartStyle.pointWidth + (size.width - tp.width)/2 +1.0, y + 6.0 + (size.height - tp.height)/2 + 1.0));

      // 绘制箭头朝下
      final arrowPath = Path();
      arrowPath.moveTo(x, y+2); // 箭头的顶点
      arrowPath.lineTo(x - (size.width - 8)/2, y + 6); // 左边的点
      arrowPath.lineTo(x + (size.width - 8)/2, y + 6); // 右边的点
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);

    }


    for (var index = 0; index < sellKLine.length; index++) {
      x = translateXtoX(getX(sellIndexs[index]));
      y = getMainY(sellKLine[index].high);

      Size size = Size(14, 14);
      final squarePaint = Paint()..color = ChartColors.depthSellColor;
      final arrowPaint = Paint()..color = ChartColors.depthSellColor;

      final squareRect = RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(x - ChartStyle.pointWidth, y-6),
          Offset(x + ChartStyle.pointWidth, y - size.height - 6),
        ),
        Radius.circular(4.0),
      );
      canvas.drawRRect(squareRect, squarePaint);

      TextSpan span = TextSpan(text: "S", style: getTextStyle(Colors.white));
      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(x - ChartStyle.pointWidth + (size.width - tp.width)/2 +1.0, y - 18.0 + (size.height - tp.height) / 2 - 1.0));
      // 绘制箭头朝下
      final arrowPath = Path();
      arrowPath.moveTo(x, y-2); // 箭头的顶点
      arrowPath.lineTo(x + (size.width-8.0)/2, y - 6); // 左边的点
      arrowPath.lineTo(x - (size.width-8.0)/2, y - 6); // 右边的点
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);

    }
  }

  void drawSellAndBuyV2(Canvas canvas, KLineEntity curPoint, double curX) {
    if (isLine == true) return;
    // 获取要绘制的图像
    ImageProvider icBuyProvider = AssetImage('images/light/kline_buy.png');
    ImageProvider icSellProvider = AssetImage('images/light/kline_sell.png');
    double x = translateXtoX(curX);
    double y = getMainY(curPoint.high);
    icBuyProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        double targetWidth = 15;
        double targetHeight = 18.22;
        Rect srcRect = Rect.fromLTWH(
            0, 0, info.image.width.toDouble(), info.image.height.toDouble());
        Rect dstRect =
            Rect.fromLTWH(x - targetWidth / 2, y, targetWidth, targetHeight);
        canvas.drawImageRect(info.image, srcRect, dstRect, Paint());
      }),
    );

    x = translateXtoX(curX);
    y = getMainY(curPoint.low);
    icSellProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        double targetWidth = 15;
        double targetHeight = 18.22;
        Rect srcRect = Rect.fromLTWH(
            0, 0, info.image.width.toDouble(), info.image.height.toDouble());
        Rect dstRect = Rect.fromLTWH(
            x - targetWidth / 2, y - targetHeight, targetWidth, targetHeight);
        canvas.drawImageRect(info.image, srcRect, dstRect, Paint());
      }),
    );

    // double x = translateXtoX(getX(mMainMinIndex));
    // double y = getMainY(mMainLowMinValue);
    //
    // icBuyProvider.resolve(ImageConfiguration()).addListener(
    //   ImageStreamListener((ImageInfo info, bool _) {
    //     double targetWidth = 15;
    //     double targetHeight = 18.22;
    //     Rect srcRect = Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble());
    //     Rect dstRect = Rect.fromLTWH(x-targetWidth/2, y, targetWidth, targetHeight);
    //     canvas.drawImageRect(info.image, srcRect, dstRect, Paint());
    //
    //   }),
    // );
    //
    // x = translateXtoX(getX(mMainMaxIndex));
    // y = getMainY(mMainHighMaxValue);
    // icSellProvider.resolve(ImageConfiguration()).addListener(
    //   ImageStreamListener((ImageInfo info, bool _) {
    //     double targetWidth = 15;
    //     double targetHeight = 18.22;
    //     Rect srcRect = Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble());
    //     Rect dstRect = Rect.fromLTWH(x-targetWidth/2, y-targetHeight, targetWidth, targetHeight);
    //     canvas.drawImageRect(info.image, srcRect, dstRect, Paint());
    //   }),
    // );
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    mMainRenderer.drawMaxAndMin(canvas);
  }

  ///画十字交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    // var tempSelectX = selectX;
    // if (orientation == Orientation.landscape) {
    //   tempSelectX -= 44.0;
    // }
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);
    Paint paintY = Paint()
      ..color = ChartColors.crossLineColor
      ..strokeWidth = ChartStyle.vCrossWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Paint paintX = Paint()
      ..color = ChartColors.crossLineColor
      ..strokeWidth = ChartStyle.hCrossWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Paint paintCircle = Paint()
      ..color = ChartColors.longPressCircleBg
      ..strokeWidth = ChartStyle.hCrossWidth
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    double x = getX(index);
    double y = getMainY(point.close);
    double px = translateXtoX(x);
    var maxY = size.height - ChartStyle.bottomDateHigh;
    var maxX = mWidth;
    var dashWidth = 3;
    var dashSpace = 2;
    double startY = 0;
    double startX = 0;
    final space = (dashSpace + dashWidth);
    // k线图竖线
    while (startY < maxY) {
      canvas.drawLine(Offset(px, startY), Offset(px, startY + dashWidth), paintY);
      startY += space;
    }

    // k线图横线
    while (startX < maxX) {
      canvas.drawLine(
          Offset(startX, selectY), Offset(startX + dashWidth, selectY), paintX);
      startX += space;
    }

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(px, selectY), height: 4.0, width: 4.0),
        paintCircle);
  }
  final Paint lastPricePaint = Paint()
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke
    ..color = ChartColors.kLineColor
    ..isAntiAlias = true;
  final Paint realTimePaint = Paint()
        ..strokeWidth = 0.5
        ..isAntiAlias = true,
      pointPaint = Paint();
  final Paint orderPaint = Paint()
    ..strokeWidth = 0.5
    ..isAntiAlias = true;

  @override
  void drawEntrustOrder(Canvas canvas, Size size) {
    if (isLine == true) return;
    final isVisible = ExStorageUtils.getInt(key: ExStorageUtils.KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS)==1;
    if(!isVisible) return;
    if(entrustList.isEmpty) return;
    var dashWidth = 5;
    var dashSpace = 2.5;
    final space = (dashSpace + dashWidth);
    for(var item in entrustList){
      final isStopLossOrder = item.isTriggerOrder!=null && item.isTriggerOrder! && (item.triggerType==1||item.triggerType==2);
      var isBuy = item.side=="BUY";
      var isMarket = item.type=="2";
      String newVolume = item.volume??"0";
      String newDealVolume = item.dealVolume??"0";
      double price = double.parse(item.price??"0.0");
      if(KLineCoinInfo.isCoin) {
        var newVolumeDecimal = Decimal.parse(newVolume) * Decimal.parse(KLineCoinInfo.mMultiplier);
        newVolume = newVolumeDecimal.toString();
        if(!isStopLossOrder){
          var newDealVolumeDecimal = Decimal.parse(newDealVolume) * Decimal.parse(KLineCoinInfo.mMultiplier);
          newDealVolume = newDealVolumeDecimal.toString();
        }
      }
      Decimal unDealDecimal = isStopLossOrder ? Decimal.parse(newVolume) : (Decimal.parse(newVolume) - Decimal.parse(newDealVolume));
      final multiplierPrecision = NumberUtil.getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier);
      final unDealVolumeText = DecimalUtil.showSNormal(unDealDecimal.toString(),digits: KLineCoinInfo.isCoin ? multiplierPrecision : 0,isShowThous: true);
      var orderText = isMarket?"contract_market".tr:"contract_limit".tr;
      if(item.isTriggerOrder!=null && item.isTriggerOrder!){
        if(item.triggerType==1){//Stop Loss Order
          if(isMarket){
            price = double.parse(item.triggerPrice??"0.0");
            orderText = "contract_market_sp".tr;
          }else{
            price = double.parse(item.price??"0.0");
            orderText = "contract_limit_sp".tr;
          }
        }else if(item.triggerType==2){//Stop Profit Doc
          if(isMarket){
            price = double.parse(item.triggerPrice??"0.0");
            orderText = "contract_market_tp".tr;
          }else{
            price = double.parse(item.price??"0.0");
            orderText = "contract_limit_tp".tr;
          }
        }
      }
      Color drawColor = isBuy?ChartColors.upColor:ChartColors.dnColor;
      TextPainter tp = getTextPainter(format(price), color: drawColor);
      TextPainter orderTextTp = getTextPainter("$orderText $unDealVolumeText", color: drawColor);
      double y = getMainY(price);
      if(y>mMainRect.bottom || y<mMainRect.top || y<=0) {
        continue;
      }
      double startX = size.width/2 + orderTextTp.width + 4.0;
      double max = size.width - tp.width - 4.0 - 4.0 - 6.0;
      while (startX < max) {
        canvas.drawLine(
            Offset(startX, y),
            Offset(startX + dashWidth, y),
            orderPaint..color = drawColor);
        startX += space;
      }

      orderPaint.style = PaintingStyle.fill;
      orderPaint.color = ChartColors.fill_2;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width - tp.width - 4.0 - 4.0 - 6.0, y - tp.height/2 - 2.0, size.width - 6.0,y + tp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);
      tp.paint(canvas, Offset(size.width - tp.width - 4.0 - 6.0, y - tp.height/2+1));
      orderPaint.style = PaintingStyle.stroke;
      orderPaint.color = drawColor;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width - tp.width - 4.0 - 4.0 - 6.0, y - tp.height/2 - 2.0, size.width - 6.0,y + tp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);
      //绘订单信息 orderTextTp
      orderPaint.style = PaintingStyle.fill;
      orderPaint.color = ChartColors.fill_2;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width/2, y - orderTextTp.height/2 - 2.0, size.width/2+orderTextTp.width+4.0,y + orderTextTp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);
      orderTextTp.paint(canvas, Offset(size.width/2+2.0, y - tp.height/2+1));
      orderPaint.style = PaintingStyle.stroke;
      orderPaint.color = drawColor;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width/2, y - orderTextTp.height/2 - 2.0, size.width/2+orderTextTp.width+4.0,y + orderTextTp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);

    }
  }

  @override
  void drawPositionOrder(Canvas canvas, Size size) {
    if (isLine == true) return;
    final isVisible = ExStorageUtils.getInt(key: ExStorageUtils.KLINE_HOLD_COST_VISIBLE_STATUS)==1;
    if(!isVisible) return;
    if(positionList.isEmpty) return;
    var dashWidth = 5;
    var dashSpace = 2.5;
    final double x = 27.0;
    final space = (dashSpace + dashWidth);

    for(var item in positionList) {
      var isBuy = item.orderSide=="BUY";
      double price = double.parse(item.openAvgPrice??"0");
      Color drawColor = isBuy?ChartColors.upColor:ChartColors.dnColor;
      var isRise = Decimal.parse(item.unRealizedAmount??"0")>(Decimal.zero);
      var isZero = Decimal.parse(item.unRealizedAmount??"0")==(Decimal.zero);
      var prefix="";
      if(isRise) prefix = "+";
      if(isZero) prefix = "";
      String showUnRealizedAmount = DecimalUtil.showSNormal(item.unRealizedAmount,digits: KLineCoinInfo.marginCoinPrecision,isShowThous: true);
      String showPositionVolume;
      if(KLineCoinInfo.isCoin) {
        final multiplierPrecision = NumberUtil.getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier);
        showPositionVolume = DecimalUtil.showSNormal(
            (Decimal.parse(item.positionVolume??"0") * Decimal.parse(KLineCoinInfo.mMultiplier)).toString(),
            digits: multiplierPrecision,
            isShowThous: true
        );
      }else{
        showPositionVolume = DecimalUtil.showSNormal(item.positionVolume,digits: 0,isShowThous: true);
      }
      Color pnlColor = isZero?ChartColors.text_color_2:(isRise?ChartColors.upColor:ChartColors.dnColor);
      TextPainter tp = getTextPainter(format(price), color: drawColor);
      TextPainter orderTextTp = getTextPainter("PNL $prefix$showUnRealizedAmount $showPositionVolume", color: pnlColor);
      double y = getMainY(price);
      if(y>mMainRect.bottom){
        break;
      }
      if(y<mMainRect.top || y<=0){
        break;
      }
      double startX = x + orderTextTp.width + 4.0;
      double max = size.width - tp.width - 4.0 - 4.0 - 6.0;
      while (startX < max) {
        canvas.drawLine(
            Offset(startX, y),
            Offset(startX + dashWidth, y),
            orderPaint..color = drawColor);
        startX += space;
      }
      orderPaint.style = PaintingStyle.fill;
      orderPaint.color = ChartColors.fill_2;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width - tp.width - 4.0 - 4.0 - 6.0, y - tp.height/2 - 2.0, size.width - 6.0,y + tp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);
      tp.paint(canvas, Offset(size.width - tp.width - 4.0 - 6.0, y - tp.height/2+1));

      orderPaint.style = PaintingStyle.stroke;
      orderPaint.color = drawColor;
      canvas.drawRRect(
          RRect.fromLTRBR(size.width - tp.width - 4.0 - 4.0 - 6.0, y - tp.height/2 - 2.0, size.width - 6.0,y + tp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);


      //绘订单信息 orderTextTp
      orderPaint.style = PaintingStyle.fill;
      orderPaint.color = ChartColors.fill_2;
      canvas.drawRRect(
          RRect.fromLTRBR(x, y - orderTextTp.height/2 - 2.0, x+orderTextTp.width+4.0,y + orderTextTp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);
      orderPaint.style = PaintingStyle.stroke;
      orderPaint.color = ChartColors.fill_5;
      canvas.drawRRect(
          RRect.fromLTRBR(x, y - orderTextTp.height/2 - 2.0, x+orderTextTp.width+4.0,y + orderTextTp.height/2 + 2.0, const Radius.circular(2.0)), orderPaint);

      orderTextTp.paint(canvas, Offset(x+2.0, y - tp.height/2+1));
    }
  }

  ///画实时价格线
  @override
  void drawRealTimePrice(Canvas canvas, Size size) {
    if (mMarginRight == 0 || datas.isEmpty == true) return;
    KLineEntity point = datas.last;
    TextPainter tp = getTextPainter(format(point.close),
        color: ChartColors.kLineColor);
    double y = getMainY(point.close);
    //max越往右边滑值越小
    var max = (mTranslateX.abs() +
            mMarginRight -
            getMinTranslateX().abs() +
            mPointWidth) *
        scaleX;
    double x = mWidth - max;
    if (!isLine) x += mPointWidth / 2;
    var dashWidth = 5;
    var dashSpace = 2.5;
    double startX = 0;
    final space = (dashSpace + dashWidth);
    if (tp.width < max) {
      while (startX < max) {
        if ((x + startX) < mWidth - tp.width - 4) {
          canvas.drawLine(
              Offset(x + startX, y),
              Offset(x + startX + dashWidth, y),
              realTimePaint..color = ChartColors.realTimeLineColor);
        }
        startX += space;
      }
      //画一闪一闪
      if (isLine) {
        startAnimation();
        Gradient pointGradient = RadialGradient(
            colors: [Colors.white.withOpacity(opacity), Colors.transparent]);
        pointPaint.shader = pointGradient
            .createShader(Rect.fromCircle(center: Offset(x, y), radius: 14.0));
        canvas.drawCircle(Offset(x, y), 14.0, pointPaint);
        canvas.drawCircle(
            Offset(x, y), 2.0, realTimePaint..color = Colors.white);
      } else {
        stopAnimation(); //停止一闪闪
      }
      double left = mWidth - tp.width - 4 - 6.0;
      double top = y - tp.height / 2;
      lastPricePaint.style = PaintingStyle.fill;
      lastPricePaint.color = ChartColors.fill_2;
      canvas.drawRRect(
          RRect.fromLTRBR(left - 2, top - 2, size.width - 6.0,
              top + tp.height + 2, const Radius.circular(2.0)),
          lastPricePaint);
      lastPricePaint.style = PaintingStyle.stroke;
      lastPricePaint.color = ChartColors.kLineColor;
      canvas.drawRRect(
          RRect.fromLTRBR(left - 2, top - 2, size.width - 6.0,
              top + tp.height + 2, const Radius.circular(2.0)),
          lastPricePaint);
      tp.paint(canvas, Offset(left + 2, top + 1));
    } else {
      stopAnimation(); //停止一闪闪
      startX = 0;
      if (point.close > mMainMaxValue) {
        y = getMainY(mMainMaxValue);
      } else if (point.close < mMainMinValue) {
        y = getMainY(mMainMinValue);
      }
      while (startX < mWidth) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y),
            realTimePaint..color = ChartColors.realTimeLine2Color);
        startX += space;
      }

      const padding = 3.0;
      const triangleHeight = 8.0; //三角高度
      const triangleWidth = 5.0; //三角宽度

      double left =
          mWidth - mWidth / ChartStyle.gridColumns - tp.width / 2 - padding * 2;
      double top = y - tp.height / 2 - padding;
      //加上三角形的宽以及padding
      double right = left + tp.width + padding * 2 + triangleWidth + padding;
      double bottom = top + tp.height + padding * 2;
      double radius = 4.0;

      //画椭圆背景
      RRect rectBg1 =
          RRect.fromLTRBR(left, top, right, bottom, Radius.circular(radius));
      rectRealTimePrice = rectBg1;
      // RRect rectBg2 = RRect.fromLTRBR(left - 1, top - 1, right + 1, bottom + 1,
      //     Radius.circular(radius + 2));
      // canvas.drawRRect(
      //     rectBg2, realTimePaint..color = ChartColors.realTimeTextBorderColor);
      canvas.drawRRect(
          rectBg1, realTimePaint..color = ChartColors.realTimeTextBgColor);
      tp = getTextPainter(format(point.close),
          color: ChartColors.realTimeText2Color);
      Offset textOffset = Offset(left + padding, y - tp.height / 2 + 1);
      tp.paint(canvas, textOffset);
      //画三角
      // Path path = Path();
      // double dx = tp.width + textOffset.dx + padding;
      // double dy = top + (bottom - top - triangleHeight) / 2;
      // path.moveTo(dx, dy);
      // path.lineTo(dx + triangleWidth, dy + triangleHeight / 2);
      // path.lineTo(dx, dy + triangleHeight);
      // path.close();

      // 绘制图片
      final myImage = AssetImage(Get.isDarkMode
          ? "images/dark/trade_retun.png"
          : "images/light/trade_retun.png");
      final myImageProvider = myImage.resolve(ImageConfiguration.empty);

      myImageProvider.addListener(
        ImageStreamListener((info, synchronousCall) {
          final image = info.image;
          final paint = Paint();
          paint.color = Colors.black; // 可以设置绘制的颜色
          // 将图片绘制到画布上
          final Rect srcRect = Rect.fromPoints(
            Offset(0, 0), // 图片源矩形的左上角
            Offset(
                image.width.toDouble(), image.height.toDouble()), // 图片源矩形的右下角
          );
          final Rect dstRect = Rect.fromPoints(
            Offset(rectBg1.right, rectBg1.top + 4), // 目标矩形的左上角
            Offset(rectBg1.right - 11, rectBg1.top + 14), // 目标矩形的右下角
          );

          // 缩放绘制图片
          canvas.drawImageRect(
            image,
            // 图片
            srcRect,
            dstRect, // 源矩形
            // 目标矩形
            paint, // 画笔
          );
        }),
      );

      // canvas.drawPath(
      //     path,
      //     realTimePaint
      //       ..color = ChartColors.realTimeText2Color
      //       ..shader = null);
    }
  }

  TextPainter getTextPainter(text, {color = Colors.white}) {
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int date) =>
      dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000), mFormats);

  double getMainY(double y) => mMainRenderer.getY(y);

  startAnimation() {
    if (controller?.isAnimating != true) controller?.repeat(reverse: true);
  }

  stopAnimation() {
    if (controller?.isAnimating == true) controller?.stop();
  }
}
