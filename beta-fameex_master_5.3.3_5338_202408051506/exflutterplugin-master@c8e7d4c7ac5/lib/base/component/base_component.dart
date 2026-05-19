
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/ex_loading.dart';
import '../../widgets/load_state_widget.dart';
import '../controller/base_controller.dart';

abstract class BaseComponent<T extends BaseController> extends GetView<T> {
  String? componentTag;

  BaseComponent({Key? key, this.componentTag}) : super(key: key);

  @override
  String? get tag => componentTag;

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) => buildContent(context),
        onLoading: Center(
          child: LoadingDialog(),
        ),
        onError: (error) => createErroWidget(controller, error),
        onEmpty: createEmptyWidget(controller));
  }
  Widget buildContent(BuildContext context);
}
