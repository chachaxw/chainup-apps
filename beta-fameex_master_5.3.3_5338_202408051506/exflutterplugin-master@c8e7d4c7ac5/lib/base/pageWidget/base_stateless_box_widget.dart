
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/color_constant.dart';
import '../../widgets/ex_appbar.dart';
import '../../widgets/ex_loading.dart';
import '../../widgets/load_state_widget.dart';
import '../../widgets/toast_mixin.dart';
import '../controller/base_controller.dart';

///常用页面无状态page封装，基本依赖Controller+OBX实现原有State+StatefulWidget效果
abstract class BaseStatelessBoxWidget<T extends BaseController> extends GetView<T>
    with ToastMixin {
  const BaseStatelessBoxWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  ///AppBar生成逻辑
  ExAppBar? createAppBar(BuildContext context) {
    if (showTitleBar()) {
      return ExAppBar(title:titleString());
    } else {
      return null;
    }
  }
  ///构建侧边栏内容
  Widget createDrawer(BuildContext context) {
    return Container();
  }

  ///创建AppBar ActionView
  List<Widget>? appBarActionWidget(BuildContext context) {}

  ///构建Scaffold-body主体内容
  Widget _buildBody(BuildContext context) {
    if (useLoadSir()) {
      return controller.obx((state) => buildContent(context),
          onLoading: Center(
            child: LoadingDialog(),
          ),
          onError: (error) => createErroWidget(controller, error),
          onEmpty: createEmptyWidget(controller));
    } else {
      return buildContent(context);
    }
  }

  ///是否展示titleBar标题栏
  bool showTitleBar() => true;

  //自定义titlebar
  bool isCustomTitleBar() => false;

  ///侧边栏
  bool showDrawer() => false;


  ///页面标题设置
  String titleString() => "Title";

  ///标题栏title的Widget
  Widget? titleWidget() {}

  ///是否开启加载状态
  bool useLoadSir() => true;

  ///是否展示回退按钮
  bool showBackButton() => true;

  //背景色
  Color backgroundColor(BuildContext context) => ExColors.main_bg_color(context);

  ///showSuccess展示成功的布局
  Widget buildContent(BuildContext context);
}
