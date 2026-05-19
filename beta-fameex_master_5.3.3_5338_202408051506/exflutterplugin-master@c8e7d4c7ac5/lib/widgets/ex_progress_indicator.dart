import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExProgressIndicator extends StatefulWidget {
  ///进度条高度
  final double progressHeight;
  final double value;

  const ExProgressIndicator({
    Key? key,
    this.value = 0.0,
    this.progressHeight = 2.0,
  }) : super(key: key);

  @override
  _ExProgressIndicatorState createState() => _ExProgressIndicatorState();
}

class _ExProgressIndicatorState extends State<ExProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Animation? animation;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    forward(widget.value.ceil().toInt());
    super.initState();
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  forward(int value) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.linear);
    animation = IntTween(begin: 0, end: value).animate(curve);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    double height = widget.progressHeight;
    return AnimatedBuilder(
      builder: (context, widget) {
        int start = animation!.value;
        int end = 100 - start;
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Flexible(
                flex: start,
                child: Container(
                  decoration: BoxDecoration(
                    color: ExColors.main_1(context),
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                  height: height,
                ),
              ),
              Flexible(
                flex: end,
                child: Container(
                  height: height,
                  color: ExColors.fill_5(context),
                ),
              ),
            ],
          ),
        );
      },
      animation: controller,
    );
  }
}
