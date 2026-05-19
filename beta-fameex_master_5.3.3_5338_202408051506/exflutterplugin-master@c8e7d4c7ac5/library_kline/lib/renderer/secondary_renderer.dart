import 'package:chainup_flutter_ex/page/klineSetting/kline_indicator_manager.dart';
import 'package:flutter/material.dart';

import '../entity/macd_entity.dart';
import '../k_chart_widget.dart';
import '../models/text_span_cancluate.dart';
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  double mMACDWidth = ChartStyle.macdWidth;
  SecondaryState state;

  SecondaryRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding, this.state, double scaleX)
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            scaleX: scaleX);

  @override
  void drawChart(MACDEntity lastPoint, MACDEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        if (lastPoint.k != 0) {
          drawLine(lastPoint.k!, curPoint.k!, canvas, lastX, curX,
              ChartColors.kColor);
        }
        if (lastPoint.d != 0) {
          drawLine(lastPoint.d!, curPoint.d!, canvas, lastX, curX,
              ChartColors.dColor);
        }
        if (lastPoint.j != 0) {
          drawLine(lastPoint.j!, curPoint.j!, canvas, lastX, curX,
              ChartColors.jColor);
        }
        break;
      case SecondaryState.RSI:
        final list = KlineIndicatorType.rsi.getShowIndicatorData();
        if (list.isEmpty) {
          return;
        }
        for (var element in list) {
          final timeKey = element.num;
          final timeColor = element.lineColor ?? ChartColors.ma5Color;
          final lastWrValue = lastPoint.rsiMapData[timeKey] ?? 0;
          final curWrValue = curPoint.rsiMapData[timeKey] ?? 0;
          if (lastWrValue != 0) {
            drawLine(lastWrValue, curWrValue, canvas, lastX, curX, timeColor);
          }
        }
        // if (lastPoint.rsi != 0) {
        //   drawLine(lastPoint.rsi!, curPoint.rsi!, canvas, lastX, curX,
        //       ChartColors.rsiColor);
        // }
        break;
      case SecondaryState.WR:
        final list = KlineIndicatorType.wr.getShowIndicatorData();
        if (list.isEmpty) {
          return;
        }
        for (var element in list) {
          final timeKey = element.num;
          final timeColor = element.lineColor ?? ChartColors.ma5Color;
          final lastWrValue = lastPoint.WRMapData[timeKey] ?? 0;
          final curWrValue = curPoint.WRMapData[timeKey] ?? 0;
          drawLine(lastWrValue, curWrValue, canvas, lastX, curX, timeColor);
        }
        break;
      default:
        break;
    }
  }

  void drawMACD(MACDEntity curPoint, Canvas canvas, double curX,
      MACDEntity lastPoint, double lastX) {
    double macdY = getY(curPoint.macd!);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd! > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = ChartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = ChartColors.dnColor);
    }
    // if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif!, curPoint.dif!, canvas, lastX, curX,
          ChartColors.difColor);
    // }
    // if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea!, curPoint.dea!, canvas, lastX, curX,
          ChartColors.deaColor);
    // }
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan> children = [];
    switch (state) {
      case SecondaryState.MACD:
        final list = KlineIndicatorType.macd.getShowIndicatorData();
        final macdColor = list[0].lineColor ?? ChartColors.macdColor;
        final difColor = list[1].lineColor ?? ChartColors.difColor;
        final deaColor = list[2].lineColor ?? ChartColors.deaColor;
        children = [
            TextSpan(
                text: "MACD(${list[0].num},${list[1].num},${list[2].num})    ",
                style: getTextStyle(ChartColors.yAxisTextColor)
            ),

            TextSpan(
                text: "MACD:${format(data.macd!)}    ",
                style: getTextStyle(macdColor)
            ),

            TextSpan(
                text: "DIF:${format(data.dif!)}    ",
                style: getTextStyle(difColor)
            ),
            TextSpan(
                text: "DEA:${format(data.dea!)}    ",
                style: getTextStyle(deaColor)
            ),
        ];
        break;
      case SecondaryState.KDJ:
        final list = KlineIndicatorType.kdj.getShowIndicatorData();
        final kColor = list[0].lineColor ?? ChartColors.kColor;
        final dColor = list[1].lineColor ?? ChartColors.dColor;
        final jColor = list[2].lineColor ?? ChartColors.jColor;
        children = [
            TextSpan(
                text: "KDJ(${list[0].num},${list[1].num},${list[2].num})    ",
                style: getTextStyle(ChartColors.yAxisTextColor)
            ),

            TextSpan(
                text: "K:${format(data.k!)}    ",
                style: getTextStyle(kColor)
            ),

            TextSpan(
                text: "D:${format(data.d!)}    ",
                style: getTextStyle(dColor)
            ),

            TextSpan(
                text: "J:${format(data.j!)}    ",
                style: getTextStyle(jColor)
            ),
        ];
        break;
      case SecondaryState.RSI:
        final list = KlineIndicatorType.rsi.getShowIndicatorData();
        if (list.isEmpty) {
          return;
        }
        for (var element in list) {
          final color = element.lineColor ?? ChartColors.rsiColor;
          final timeKey = element.num!;
          final value = data.rsiMapData[timeKey] ?? 0;
          final span = TextSpan(
              text:
                  "${KlineIndicatorType.rsi.name}$timeKey:${format(value)}    ",
              style: getTextStyle(color));
          children.add(span);
        }
        break;
      case SecondaryState.WR:
        final list = KlineIndicatorType.wr.getShowIndicatorData();
        if (list.isEmpty) {
          return;
        }
        TextSpanTool.buildSpan(list, data.WRMapData, canvas, x,
            chartRect.top - topPadding + 4.0, chartRect.width);
        return;
      default:
        children = <TextSpan>[];
        break;
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding + 4.0));
  }

  void WR() {}
  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(maxValue)}  ", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(minValue)}  ", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding + ChartStyle.childPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
