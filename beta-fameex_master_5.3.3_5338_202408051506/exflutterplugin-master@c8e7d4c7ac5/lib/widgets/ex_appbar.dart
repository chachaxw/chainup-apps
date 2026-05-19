import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';
import 'gaps.dart';

enum ExAppBarBackColor {
  light,
  dark,
}

class ExAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final String? rightTitle;
  final String? back;
  final Color? titleColor;
  final Color? appBarColor;
  final VoidCallback? onRightClick;
  final VoidCallback? onBack;
  final ExAppBarBackColor? backColor;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Color? rightTitleColor;
  final Widget? titleWidget;
  final double? height;
  final double? leftWidgetWidth;
  final bool? centerTitle;

  ExAppBar({
    Key? key,
    this.title,
    this.rightTitle,
    this.back,
    this.appBarColor,
    this.titleColor,
    this.onRightClick,
    this.onBack,
    this.backColor,
    this.leftWidget,
    this.rightWidget,
    this.rightTitleColor,
    this.titleWidget,
    this.height,
    this.leftWidgetWidth = 44,
    this.centerTitle = true,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  _ExAppBarState createState() => _ExAppBarState();

  @override
  final Size preferredSize;
}

class _ExAppBarState extends State<ExAppBar> {
  backAction() {
    if (widget.onBack != null) {
      Get.back();
      widget.onBack?.call();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarColor: widget.appBarColor,
      //     statusBarIconBrightness:Brightness.light),
      toolbarHeight: widget.height ?? kToolbarHeight,
      centerTitle: widget.centerTitle,
      title: Transform(
        transform: Matrix4.translationValues(
            widget.titleWidget != null ? 0 : 0, 0.0, 0.0),
        child: widget.titleWidget == null
            ? Text(
                widget.title ?? "",
                style: ExThemes.textstyle_sm_color1_18(context),
              )
            : (widget.titleWidget ?? Container()),
      ),
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          backAction();
        },
        child: Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(left: 16.0, right: 5.0),
          alignment: Alignment.center,
          child: widget.leftWidget ?? ExIcon.icBack(),
        ),
      ),
      leadingWidth: widget.leftWidgetWidth,
      actions: [
        widget.rightWidget != null
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 16),
                child: widget.rightWidget,
              )
            : Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 16),
                child: widget.rightTitle != null
                    ? GestureDetector(
                        child: Text(
                          widget.rightTitle.toString(),
                          style: ExThemes.textstyle_sm_color1_16(context)
                              .copyWith(
                                  color: widget.rightTitleColor ??
                                      ExColors.main_4(context)),
                        ),
                        onTap: () {
                          if (widget.onRightClick != null) {
                            widget.onRightClick!();
                          }
                        },
                      )
                    : Gaps.empty)
      ],
      backgroundColor: widget.appBarColor ?? Colors.transparent,
    );
  }
}

///////////////////////////////////////////////////////////////////
class ExCustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ExCustomAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.rightTitle,
    this.rightTitleColor,
    this.appBarColor,
    this.onRightClick,
    this.onBack,
    this.backColor,
    this.leftWidget,
    this.rightWidget,
    this.titleWidget,
    this.centerTitle = false,
  });

  final String? title;
  final Color? titleColor;
  final String? rightTitle;
  final Color? rightTitleColor;
  final Color? appBarColor;
  final VoidCallback? onRightClick;
  final VoidCallback? onBack;
  final ExAppBarBackColor? backColor;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Widget? titleWidget;
  final bool? centerTitle;

  @override
  State<ExCustomAppBar> createState() => _ExCustomAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(Platform.isIOS ? 44 : kToolbarHeight);
}

class _ExCustomAppBarState extends State<ExCustomAppBar> {
  void backAction() {
    if (widget.onBack != null) {
      widget.onBack?.call();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.appBarColor ?? Colors.transparent,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        color: Colors.transparent,
        child: _buildContentWidget(context),
      ),
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    if (widget.centerTitle == true) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackWidget(context),
          _buildTitleWidget(context),
          _buildRightWidget(context),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildBackWidget(context),
                _buildTitleWidget(context),
              ],
            ),
          ),
          _buildRightWidget(context),
        ],
      );
    }
  }

  Widget _buildBackWidget(BuildContext context) {
    return widget.leftWidget ??
        GestureDetector(
          onTap: () => backAction(),
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 5),
            alignment: Alignment.center,
            child: ExIcon.icBack(),
          ),
        );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Flexible(
        child: widget.titleWidget ??
            Text(
              widget.title ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ExThemes.textstyle_sm_color1_18(context),
            ));
  }

  Widget _buildRightWidget(BuildContext context) {
    return widget.rightWidget ??
        (widget.rightTitle != null
            ? GestureDetector(
                onTap: widget.onRightClick,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    widget.rightTitle.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ExThemes.textstyle_sm_color1_16(context),
                  ),
                ),
              )
            : Gaps.empty);
  }
}
