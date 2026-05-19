
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/ex_appbar.dart';
import '../../widgets/ex_loading.dart';
import '../../widgets/load_state_widget.dart';
import '../../widgets/toast_mixin.dart';
import '../controller/base_controller.dart';

abstract class BaseStatefulWidget<T extends BaseController>
    extends StatefulWidget with ToastMixin {
  const BaseStatefulWidget({Key? key}) : super(key: key);

  final String? tag = null;

  T get controller {
    return GetInstance().find<T>(tag: tag);
  }

  ///Get 局部更新字段
  get updateId => null;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(context),
      body: buildBody(context),
      drawer: showDrawer() ? createDrawer() : null,
    );
  }

  ///AppBar生成逻辑
  ExAppBar? _createAppBar(BuildContext context) {
    if (showTitleBar()) {
      return ExAppBar(title:titleString());
    } else {
      return null;
    }
  }

  ///构建侧边栏内容
  Widget createDrawer() {
    return Container();
  }

  ///创建AppBar ActionView
  List<Widget>? appBarActionWidget(BuildContext context) {}

  ///构建Scaffold-body主体内容
  Widget buildBody(BuildContext context) {
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

  ///侧边栏
  bool showDrawer() => false;

  ///页面标题设置
  String titleString() => "标题";

  ///标题栏title的Widget
  Widget? titleWidget() {}

  ///是否开启加载状态
  bool useLoadSir() => true;

  ///是否展示回退按钮
  bool showBackButton() => true;

  ///showSuccess展示成功的布局
  Widget buildContent(BuildContext context);

  ///widget生命周期
  get lifecycle => null;

  @override
  State createState() => AutoDisposeState<T>();
}

class AutoDisposeState<T extends GetxController>
    extends State<BaseStatefulWidget>
    with
        AutomaticKeepAliveClientMixin<BaseStatefulWidget>,
        WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<T>(
        tag: widget.tag,
        id: widget.updateId,
        builder: (controller) {
          return widget.build(context);
        });
  }

  @override
  void initState() {
    super.initState();
    if (widget.lifecycle != null) {
      WidgetsBinding.instance?.addObserver(this);
    }
  }

  @override
  void dispose() {
    Get.delete<T>(tag: widget.tag);
    if (widget.lifecycle != null) {
      WidgetsBinding.instance?.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (widget.lifecycle != null) {
      widget.lifecycle(state);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
