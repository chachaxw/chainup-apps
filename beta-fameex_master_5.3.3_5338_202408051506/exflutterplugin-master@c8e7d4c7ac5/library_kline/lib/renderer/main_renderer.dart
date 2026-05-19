import 'package:chainup_flutter_ex/page/kline/main_state.dart';
import 'package:chainup_flutter_ex/page/klineSetting/kline_indicator_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../entity/candle_entity.dart';
import '../models/indicators_entity.dart';
import 'base_chart_renderer.dart';
import 'chart_painter.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  MainState state;
  bool isLine;
  List<String> mainUIList = [];
  double _contentPadding = 12.0;
  double consumerLineHeight = 0.0;
  ChartPainter chartPainter;

  MainRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,
      this.isLine,
      double scaleX,
      List<String> mainUIList,
      this.chartPainter)
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            scaleX: scaleX) {
    this.mainUIList = mainUIList;
    var diff = maxValue - minValue; //计算差
    var newScaleY = (chartRect.height - _contentPadding) / diff; //内容区域高度/差=新的比例
    var newDiff = chartRect.height / newScaleY; //高/新比例=新的差
    var value = (newDiff - diff) / 2; //新差-差/2=y轴需要扩大的值
    if (newDiff > diff) {
      this.scaleY = newScaleY;
      this.maxValue += value;
      this.minValue -= value;
    }
  }

  final Paint tagValueLinePaint = Paint()
    ..strokeWidth = 1.0
    ..color = ChartColors.maxMinTextColor
    ..isAntiAlias = true;

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    consumerLineHeight = 4.0;
    double consumerLineWidth = 0;
    for (var itemIndex in mainUIList) {
      drawIndexText(canvas, itemIndex, data, x, consumerLineWidth);
    }
    if(mainUIList.length<=0){
      ChartStyle.topPadding = 0.0;
    }else{
      ChartStyle.topPadding = consumerLineHeight>ChartStyle.maxMainTopPadding ? ChartStyle.maxMainTopPadding : consumerLineHeight;
    }
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (isLine != true) drawCandle(curPoint, canvas, curX);
    if (isLine == true) {
      draLine(lastPoint.close, curPoint.close, canvas, lastX, curX);
      return;
    }

    for (var itemIndex in mainUIList) {
      MainState state = MainState.getTypeByValue(itemIndex);
      if (state == MainState.MA) {
        drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.BOLL) {
        drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.EMA) {
        drawEMALine(lastPoint, curPoint, canvas, lastX, curX);
      }
    }
  }

  void drawIndexText(Canvas canvas, String indexName, CandleEntity data,
      double x, double consumerLineWidth) {
    MainState mainState = MainState.getTypeByValue(indexName);
    switch (mainState) {
      case MainState.MA:
        var mIndicators = KlineIndicatorType.ma.getShowIndicatorData();
        buildMaSpan(
            mIndicators, data.MAPriceData, canvas, x, consumerLineWidth);
        break;
      case MainState.BOLL:
        buildBOLLspan(canvas, x, data, consumerLineWidth);
        break;
      case MainState.EMA:
        var mIndicators = KlineIndicatorType.ema.getShowIndicatorData();
        buildMaSpan(
            mIndicators, data.EMAPriceData, canvas, x, consumerLineWidth);
        break;
      default:
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  final double mLineStrokeWidth = 1.0;
  final Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..color = ChartColors.kLineColor;
  final Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  draLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
    mLinePath ??= Path();

    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: ChartColors.kLineShadowColor,
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath?.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath?.lineTo(lastX, getY(lastPrice));
    mLineFillPath?.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath?.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath?.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath?.reset();

    canvas.drawPath(mLinePath!,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.3, 1.0));
    mLinePath?.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    //获取需要显示的指标
    final list = KlineIndicatorType.ma.getShowIndicatorData();
    if (list.isEmpty) {
      return;
    }
    list.forEach((element) {
      final maTimeKey = element.num;
      final maTimeColor = element.lineColor ?? ChartColors.ma5Color;

      final lastMaTimeValue = lastPoint.MAPriceData[maTimeKey] ?? 0;
      final currnetMaTimeValue = curPoint.MAPriceData[maTimeKey] ?? 0;
      if (lastMaTimeValue != 0 && currnetMaTimeValue != 0) {
        drawLine(lastMaTimeValue, currnetMaTimeValue, canvas, lastX, curX,
            maTimeColor);
      }
    });
    // if (lastPoint.MA5Price != 0) {
    //   drawLine(lastPoint.MA5Price!, curPoint.MA5Price!, canvas, lastX, curX,
    //       ChartColors.ma5Color);
    // }
    // if (lastPoint.MA10Price != 0) {
    //   drawLine(lastPoint.MA10Price!, curPoint.MA10Price!, canvas, lastX, curX,
    //       ChartColors.ma10Color);
    // }
    // if (lastPoint.MA30Price != 0) {
    //   drawLine(lastPoint.MA30Price!, curPoint.MA30Price!, canvas, lastX, curX,
    //       ChartColors.ma30Color);
    // }
  }

  void drawEMALine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    //获取需要显示的指标
    final list = KlineIndicatorType.ema.getShowIndicatorData();
    if (list.isEmpty) {
      return;
    }
    list.forEach((element) {
      final emaTimeKey = element.num;
      final emaTimeColor = element.lineColor ?? ChartColors.ma5Color;
      final lastEMaTimeValue = lastPoint.EMAPriceData[emaTimeKey] ?? 0;
      final currentEMaTimeValue = curPoint.EMAPriceData[emaTimeKey] ?? 0;
      if (lastEMaTimeValue != 0 && currentEMaTimeValue != 0) {
        drawLine(lastEMaTimeValue, currentEMaTimeValue, canvas, lastX, curX,
            emaTimeColor);
      }
    });
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up!, curPoint.up!, canvas, lastX, curX,
          ChartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(lastPoint.mb!, curPoint.mb!, canvas, lastX, curX,
          ChartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn!, curPoint.dn!, canvas, lastX, curX,
          ChartColors.ma30Color);
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;

    //防止线太细，强制最细1px
    if ((open - close).abs() < 1) {
      if (open > close) {
        open += 0.5;
        close -= 0.5;
      } else {
        open -= 0.5;
        close += 0.5;
      }
    }
    if (open > close) {
      chartPaint.color = ChartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else {
      chartPaint.color = ChartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    }
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double position = 0;
      if (i == 0) {
        position = (gridRows - i) * rowSpace - _contentPadding / 2;
      } else if (i == gridRows) {
        position = (gridRows - i) * rowSpace + _contentPadding / 2;
      } else {
        position = (gridRows - i) * rowSpace;
      }
      var value = position / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      double y;
      if (i == 0 || i == gridRows) {
        y = getY(value) - tp.height / 2;
      } else {
        y = getY(value) - tp.height;
      }
      if(i==0) {
        y = (ChartStyle.topPadding - tp.height)<=0 ? 2.0 : (ChartStyle.topPadding - tp.height);
      }
      tp.paint(canvas, Offset(chartRect.width - tp.width - 4, y));
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      if (i == 0) {
        canvas.drawLine(Offset(0, rowSpace * i + topPadding),
            Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
      } else {
        canvas.drawLine(Offset(0, rowSpace * i + topPadding),
            Offset(chartRect.width, rowSpace * i+ topPadding), gridPaint);
      }
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, 0),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  void buildMaSpan(
      List<IndicatorsEntity> mIndicators,
      Map<int, double> mIndicatorMap,
      Canvas canvas,
      double x,
      double consumerLineWidth) {
    double buffConsumerLineHeight = consumerLineHeight;
    Map<String, List<InlineSpan>> buff = {};
    var line = 0;
    double lineHeight = 0;

    if (mIndicators.isEmpty) {
      return;
    }
    KlineIndicatorType? type = mIndicators[0].type;

    for(var item in mIndicators){
      var key = item.num;
      var value = mIndicatorMap[key];
      var elements = item;
      if (!elements.isNull) {
        var text = "${type?.name}${key}:${format(value!)}    ";
        var tStyle = getTextStyle(mIndicators!
            .where((element) => (element.num == key))
            .first
            .lineColor ??
            Colors.white);
        var size = calculateTextSize(text, tStyle);
        lineHeight = size.height;
        var canConsumerW = chartRect.width - consumerLineWidth;
        if (canConsumerW < size.width) {
          line++;
          consumerLineWidth = 0.0;
          consumerLineHeight += size.height;
        }
        if (buff[line.toString()] == null) {
          buff[line.toString()] = [];
        }
        consumerLineWidth += size.width;
        buff[line.toString()]!.add(TextSpan(text: text, style: tStyle));
      }
    }
    consumerLineHeight += lineHeight;
    Iterator iterator = buff.keys.iterator;
    while (iterator.moveNext()) {
      String key = iterator.current;
      int line = int.parse(iterator.current);
      List<InlineSpan> textSpanList = buff[key] ?? [];
      if (textSpanList.isNotEmpty) {
        TextSpan span = TextSpan(
          children: textSpanList,
        );
        drawTextSpan(
            canvas, span, x, buffConsumerLineHeight + line * lineHeight);
      }
    }
  }

  void buildBOLLspan(
      Canvas canvas, double x, CandleEntity data, double consumerLineWidth) {
    // var indicators = KlineIndicatorType.boll.getShowIndicatorData();
    // final macdColor = list[0].lineColor ?? ChartColors.macdColor;
    // final difColor = list[1].lineColor ?? ChartColors.difColor;
    // final deaColor = list[2].lineColor ?? ChartColors.deaColor;
    List<InlineSpan> textSpanList = [
      if (data.mb != 0)
        TextSpan(
            text: "BOLL:${format(data.mb!)}    ",
            style: getTextStyle(ChartColors.ma5Color)),
      if (data.up != 0)
        TextSpan(
            text: "UP:${format(data.up!)}    ",
            style: getTextStyle(ChartColors.ma10Color)),
      if (data.dn != 0)
        TextSpan(
            text: "LB:${format(data.dn!)}    ",
            style: getTextStyle(ChartColors.ma30Color)),
    ];
    TextSpan spanContent = TextSpan(children: textSpanList);
    Size size = calculateTextSpanSize(spanContent);
    drawTextSpan(canvas, spanContent, x, consumerLineHeight);
    consumerLineHeight += size.height;
    consumerLineWidth = 0.0;
  }

  Size calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 2,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Size calculateTextSpanSize(TextSpan span) {
    final TextPainter textPainter =
        TextPainter(text: span, maxLines: 2, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  void drawTextSpan(Canvas canvas, TextSpan span, double x, double y) {
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    super.drawMaxAndMin(canvas);
    if (isLine == true) return;
    final double lineWidth = 44.0;
    //绘制最大值和最小值
    double x = chartPainter.translateXtoX(chartPainter.getX(chartPainter.mMainMinIndex));
    double y = chartPainter.getMainY(chartPainter.mMainLowMinValue);
    if (x < chartPainter.mWidth / 2) {
      //画右边
      TextPainter tp = chartPainter.getTextPainter("${format(chartPainter.mMainLowMinValue)}",
          color: ChartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x+lineWidth, y - tp.height / 2));
      canvas.drawLine(Offset(x, y), Offset(x+lineWidth, y), tagValueLinePaint);
    } else {
      TextPainter tp = chartPainter.getTextPainter("${format(chartPainter.mMainLowMinValue)}",
          color: ChartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x-tp.width-lineWidth, y - tp.height / 2));
      canvas.drawLine(Offset(x, y), Offset(x-lineWidth, y), tagValueLinePaint);
    }
    x = chartPainter.translateXtoX(chartPainter.getX(chartPainter.mMainMaxIndex));
    y = chartPainter.getMainY(chartPainter.mMainHighMaxValue);
    if (x < chartPainter.mWidth / 2) {
      //画右边
      TextPainter tp = chartPainter.getTextPainter("${format(chartPainter.mMainHighMaxValue)}",
          color: ChartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x+lineWidth, y - tp.height / 2));
      canvas.drawLine(Offset(x, y), Offset(x+lineWidth, y), tagValueLinePaint);
    } else {
      TextPainter tp = chartPainter.getTextPainter("${format(chartPainter.mMainHighMaxValue)}",
          color: ChartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x - tp.width - lineWidth, y - tp.height / 2));
      canvas.drawLine(Offset(x, y), Offset(x-lineWidth, y), tagValueLinePaint);
    }
  }
}
