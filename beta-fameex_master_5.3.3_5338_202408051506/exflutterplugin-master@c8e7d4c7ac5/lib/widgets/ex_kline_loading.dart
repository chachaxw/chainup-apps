import 'package:chainup_flutter_ex/widgets/ex_button.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/k_chart_widget.dart';
import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';

class KlineLoadingDialog extends StatefulWidget {
  final String? text;
  final bool isSmallKline;
  KlineState mState = KlineState.LOADING;
  final VoidCallback? onReload;
  double? height = double.infinity;

  KlineLoadingDialog({
    Key? key,
    this.text,
    this.height,
    this.onReload,
    required this.isSmallKline,
    required this.mState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => KlineLoadingDialogState();
}

class KlineLoadingDialogState extends State<KlineLoadingDialog>
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
        child: Container(
          width: double.infinity,
          height: widget.height,
          color: widget.mState == KlineState.RELOAD
              ?  (widget.isSmallKline ? ExColors.fill_1(context) : ExColors.fill_2(context) )
              : null,
          child: Center(
            //保证控件居中效果
            child: Stack(
              children: [
                widget.mState == KlineState.LOADING
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: RotationTransition(
                              turns: _animController
                                ..addStatusListener((status) {
                                  if (status == AnimationStatus.completed) {
                                    _animController.reset();
                                    _animController.forward();
                                  }
                                }),
                              child: ExIcon.icKlineLoading(),
                            ),
                          ),
                          Gaps.vGap3,
                          Text("kline_loading".tr, style: ExThemes.textstyle_sr_color1_10(context))
                        ],
                      )
                    : const SizedBox(),
                widget.mState == KlineState.RELOAD
                    ? _buildRetryLayout(context)
                    : const SizedBox(),
              ],
            ),
          ),
        ));
  }

  Widget _buildRetryLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Visibility(
          visible: !widget.isSmallKline,
          child: Column(children: [
            Container(
              width: 80,
              height: 80,
              child: ExIcon.noNetWorkImg(),
            ),
            Gaps.vGap8,
          ]),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 38),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "network_loading_page".tr,
              textAlign: TextAlign.center,
              style: ExThemes.textstyle_hm_color2_14(context)
                  .copyWith(height: 1.5),
            ),
          ),
        ),
        Gaps.vGap16,
        ExButton(
          text: "network_loading_button".tr,
          textColor: ExColors.text_1(context),
          disabledBackgroundColor: ExColors.fill_5(context),
          backgroundColor: ExColors.fill_3(context),
          minWidth: 165,
          minHeight: 36,
          onPressed: () {
            widget.onReload!();
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    _animController.dispose(); //解决内存泄漏
    super.dispose();
  }
}
