import 'package:chainup_flutter_ex/page/klineSetting/kline_indicator_manager.dart';
import 'package:flutter/material.dart';

import '../chart_style.dart';
import '../utils/number_util.dart';
import 'indicators_entity.dart';

class TextSpanTool {
  static void buildSpan(
      List<IndicatorsEntity> indicators,
      Map<int, double> indicatorMap,
      Canvas canvas,
      double x,
      double y,
      double maxWidth) {
    if (indicators.isEmpty) {
      return;
    }
    double buffConsumerLineHeight = y;
    Map<String, List<InlineSpan>> buff = {};
    var line = 0;
    double lineHeight = 0;
    double consumerLineWidth = 0;
    KlineIndicatorType? type = indicators[0].type;
    indicatorMap.forEach((key, value) {
      var elements = indicators!.where((element) => (element.num == key));
      if (elements.isNotEmpty) {
        var text = "${type?.name}${key}:${format(value!)}    ";
        var tStyle = getTextStyle(indicators!
                .where((element) => (element.num == key))
                .first
                .lineColor ??
            Colors.white);
        var size = calculateTextSize(text, tStyle);
        lineHeight = size.height;
        var canConsumerW = maxWidth - consumerLineWidth;
        if (canConsumerW < size.width) {
          line++;
          consumerLineWidth = 0.0;
        }
        if (buff[line.toString()] == null) {
          buff[line.toString()] = [];
        }
        consumerLineWidth += size.width;
        buff[line.toString()]!.add(TextSpan(text: text, style: tStyle));
      }
    });
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

  static Size calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 2,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static Size calculateTextSpanSize(TextSpan span) {
    final TextPainter textPainter =
        TextPainter(text: span, maxLines: 2, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static void drawTextSpan(Canvas canvas, TextSpan span, double x, double y) {
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }

  static String format(double n) {
    return NumberUtil.format(n,rounding: true);
  }

  static TextStyle getTextStyle(Color color) {
    return TextStyle(
        fontSize: ChartStyle.defaultTextSize,
        color: color,
        fontFamily: "HarmonyOS_Sans_SC_Regular");
  }
}
