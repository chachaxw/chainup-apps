import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double? height;
  final double? width;

  final Color? color;
  final double? dashWidth;
  final double? dashSpace;
  final double? strokeWidth;

  const DashedLine({
    super.key,
    this.height = 1.0,
    this.width = double.infinity,
    this.color,
    this.dashSpace = 5,
    this.dashWidth = 5,
    this.strokeWidth = 1,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height, // 虚线的高度
      child: CustomPaint(
        painter: DashedLinePainter(
          height: height,
          dashSpace: dashSpace,
          dashWidth: dashWidth,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double? height;
  final double? dashWidth;
  final double? dashSpace;
  final double? strokeWidth;

  final Color? color;

  DashedLinePainter({
    this.color,
    this.height,
    this.dashSpace = 5,
    this.dashWidth = 5,
    this.strokeWidth = 1,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFFD5D7DA)
      ..strokeWidth = strokeWidth!;
    paint.strokeCap = StrokeCap.square;

    double dashWidth = this.dashWidth!;
    double dashSpace = this.dashSpace!;

    final double startY = size.height / 2;

    for (double i = 0; i < size.width; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(i, startY), Offset(i + dashWidth, startY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
