
import 'package:flutter/material.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';

/// @description :公共加载弹窗
class LoadingDialog extends StatefulWidget {
  LoadingDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        //创建透明层
        type: MaterialType.transparency, //透明类型
        child: Center(
          //保证控件居中效果
          child: SizedBox(
            width: 100,
            height: 100,
            child: Container(
              decoration: const ShapeDecoration(
                color: ExColorsDark.dialog_bg_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: RotationTransition(
                      child: ExIcon.icLoading(),
                      turns: _animController
                        ..addStatusListener((status) {
                          if (status == AnimationStatus.completed) {
                            _animController.reset();
                            _animController.forward();
                          }
                        }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _animController.dispose(); //解决内存泄漏
    super.dispose();
  }
}
