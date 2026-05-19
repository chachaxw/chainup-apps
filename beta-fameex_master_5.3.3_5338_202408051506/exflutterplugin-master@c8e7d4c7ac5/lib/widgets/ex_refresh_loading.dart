import 'package:flutter/material.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';

/// @description :公共加载弹窗
class RefreshLoadingWidget extends StatefulWidget {
  const RefreshLoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RefreshLoadingWidgetState();
}

class RefreshLoadingWidgetState extends State<RefreshLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        //创建透明层
        type: MaterialType.transparency, //透明类型
        child: Center(
          //保证控件居中效果
          child: SizedBox(
            width: 20,
            height: 20,
            child: RotationTransition(
              turns: _animController
                ..addStatusListener(
                  (status) {
                    if (status == AnimationStatus.completed) {
                      _animController.reset();
                      _animController.forward();
                    }
                  },
                ),
              child: BreakevenAnalysisIcon.iconLoading(),
            ),
          ),
        ));
  }
}
