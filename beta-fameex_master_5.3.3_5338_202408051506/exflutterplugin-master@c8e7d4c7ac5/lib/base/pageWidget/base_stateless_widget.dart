import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/color_constant.dart';
import '../../widgets/ex_appbar.dart';
import '../../widgets/ex_loading.dart';
import '../../widgets/load_state_widget.dart';
import '../../widgets/toast_mixin.dart';
import '../controller/base_controller.dart';

///常用页面无状态page封装，基本依赖Controller+OBX实现原有State+StatefulWidget效果
abstract class BaseStatelessWidget<T extends BaseController> extends GetView<T>
    with ToastMixin {
  const BaseStatelessWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return isNeedScaffold()
        ? Scaffold(
            appBar: createAppBar(context),
            resizeToAvoidBottomInset: false,
            body: _buildBody(context),
            drawer: showDrawer() ? createDrawer(context) : null,
            backgroundColor: backgroundColor(context),
          )
        : Material(
            color: backgroundColor(context),
            child: _buildBody(context),
          );
  }

  ///AppBar生成逻辑
  PreferredSizeWidget? createAppBar(BuildContext context) {
    if (isCustomTitleBar()) {
      return ExCustomAppBar(
        leftWidget: showBackButton() ? backWidget(context) : Container(),
        title: titleString(),
        titleWidget: titleWidget(context),
        rightTitle: rightTitleString(),
        rightWidget: rightWidget(context),
        onBack: onBack,
      );
    }
    if (showTitleBar()) {
      return ExAppBar(
        leftWidget: showBackButton() ? backWidget(context) : Container(),
        title: titleString(),
        titleWidget: titleWidget(context),
        rightTitle: rightTitleString(),
        rightWidget: rightWidget(context),
        onBack: onBack,
      );
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
      return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0, boldText: false),
          child: buildContent(context));
      // return buildContent(context);
    }
  }

  ///是否展示titleBar标题栏
  bool showTitleBar() => true;

  //自定义titlebar
  bool isCustomTitleBar() => false;

  ///侧边栏
  bool showDrawer() => false;

  // Key? setKey() => controller.scaffoldKey;

  ///页面标题设置
  String titleString() => "";

  String rightTitleString() => "";

  Widget? rightWidget(BuildContext context) {}

  ///标题栏title的Widget
  Widget? titleWidget(BuildContext context) {}

  ///返回按钮的Widget
  Widget? backWidget(BuildContext context) {}

  VoidCallback? onBack() {}

  ///是否开启加载状态
  bool useLoadSir() => true;

  ///是否展示回退按钮
  bool showBackButton() => true;

  //背景色
  Color backgroundColor(BuildContext context) => ExColors.fill_2(context);

  Color appBarColor(BuildContext context) => backgroundColor(context);

  ///showSuccess展示成功的布局
  Widget buildContent(BuildContext context);

  bool isNeedScaffold() => true;
}
