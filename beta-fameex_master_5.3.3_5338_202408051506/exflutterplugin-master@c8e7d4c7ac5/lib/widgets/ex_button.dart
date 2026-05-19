import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../themes/Themes.dart';

class ExButton extends StatelessWidget {
  const ExButton({
    Key? key,
    this.text = '',
    this.fontSize = 14.0,
    this.textColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.minHeight = 44.0,
    this.minWidth = double.infinity,
    this.initialEnable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
    this.radius = 4.0,
    this.side = BorderSide.none,
    this.onPressed,
  });

  final String text;
  final double fontSize;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double? minHeight;
  final double? minWidth;
  final bool initialEnable;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return SizedBox(
      width: minWidth,
      height: minHeight,
      child: TextButton(
        onPressed: initialEnable ? onPressed : null,
        style: ButtonStyle(
          // 文字颜色
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return disabledTextColor ??
                    (isDark
                        ? ExColorsDark.btn_text_color
                        : ExColorsLight.btn_text_color);
              }
              return textColor ??
                  (isDark
                      ? ExColorsDark.btn_text_color
                      : ExColorsLight.btn_text_color);
            },
          ),
          // 背景颜色
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledBackgroundColor ??
                  (isDark
                      ? ExColorsDark.btn_enabled_color
                      : ExColorsDark.btn_enabled_color);
            }
            return backgroundColor ??
                (isDark ? ExColorsDark.main_color : ExColorsLight.main_color);
          }),
          //水波纹
          overlayColor: MaterialStateProperty.resolveWith((states) {
            return (textColor ??
                    (isDark
                        ? ExColorsDark.main_color
                        : ExColorsDark.main_color))
                .withOpacity(0.12);
          }),
          // 按钮最小大小
          minimumSize: (minWidth == null || minHeight == null)
              ? null
              : MaterialStateProperty.all<Size>(Size(minWidth!, minHeight!)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          side: MaterialStateProperty.all<BorderSide>(side),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ExThemes.textstyle_sm_color1_14(context).copyWith(
            fontSize: fontSize,
            color: textColor ?? ExColors.btn_text_color(context),
          ),
        ),
      ),
    );
  }
}
