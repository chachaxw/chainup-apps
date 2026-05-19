import 'package:flutter/material.dart';

class VerticalDashedLine extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;

  const VerticalDashedLine({
    super.key,
    this.height = 100.0,
    this.color,
    this.width = 1.0,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // 定义线的宽度
      height: height, // 定义线的高度
      child: CustomPaint(
        painter: DashedLinePainter(width: width, color: color),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double? width;
  final Color? color;

  const DashedLinePainter({
    this.color,
    this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color ?? Colors.black // 定义线的颜色
      ..strokeWidth = width ?? 1.0 // 定义线的宽度
      ..strokeCap = StrokeCap.round; // 定义线的端点形状为圆形

    double dashWidth = 5.0; // 定义虚线的宽度
    double dashSpace = 3.0; // 定义虚线之间的间隔

    double startY = 0.0;
    double endY = size.height;

    double currentY = startY;

    while (currentY < endY) {
      canvas.drawLine(
        Offset(size.width / 2, currentY),
        Offset(size.width / 2, currentY + dashWidth),
        paint,
      );

      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
