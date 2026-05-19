import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/ex_refresh_loading.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

enum ExLoadingStatus {
  idle,
  loading,
  success,
  failed,
}

class LoadingView extends StatelessWidget {
  final ExLoadingStatus? loadingStatus;
  final VoidCallback? tryCallback;
  final double? height;
  const LoadingView({
    this.loadingStatus = ExLoadingStatus.idle,
    this.tryCallback,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 147,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: loadingStatus == ExLoadingStatus.loading
              ? loadingWidget()
              : loadingStatus == ExLoadingStatus.failed
                  ? loadFailedWidget()
                  : [],
        ),
      ),
    );
  }

  List<Widget> loadingWidget() {
    return [
      _iconWidget(),
      Gaps.vGap8,
      _loadingText(),
    ];
  }

  List<Widget> loadFailedWidget() {
    return [
      _iconWidget(),
      Gaps.vGap8,
      _loadingText(),
      Gaps.vGap8,
      loadingStatus == ExLoadingStatus.failed ? _tryText() : Container(),
    ];
  }

  Widget _iconWidget() {
    if (loadingStatus == ExLoadingStatus.loading) {
      return const RefreshLoadingWidget();
    }
    if (loadingStatus == ExLoadingStatus.failed) {
      return ExIcon.icChartRetry();
    }
    return Container();
  }

  Widget _loadingText() {
    return Builder(
      builder: (context) {
        return Text(
          loadingStatus == ExLoadingStatus.loading
              ? "common_text_loading".tr
              : "kline_fail_msg".tr,
          style: ExThemes.textstyle_hr_color1_12(context),
        );
      },
    );
  }

  Widget _tryText() {
    return GestureDetector(
      onTap: () {
        tryCallback?.call();
      },
      child: Builder(
        builder: (context) {
          return Text(
            "kline_fail_msg2".tr,
            style: ExThemes.textstyle_hr_color1_12(context)
                .copyWith(color: ExColors.main_4(context)),
          );
        },
      ),
    );
  }
}
