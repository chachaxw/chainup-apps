import 'dart:math' as math;

import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../constants/color_constant.dart';
import '../themes/Themes.dart';

class ExTextFieldStyle5 extends StatefulWidget {
  const ExTextFieldStyle5({
    Key? key,
    required this.controller,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.isShowAll = false,
    this.maxLength,
    this.counterText,
    this.autofocus,
    this.style,
    this.hintStyle,
    this.focusNode,
    this.keyboardActionEnable = true,
    this.hasFocus = false,
    required this.onAdd,
    required this.onReduce,
  }) : super(key: key);

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? isShowAll;
  final int? maxLength;
  final String? counterText;
  final bool? autofocus;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  final bool keyboardActionEnable;
  final bool hasFocus;
  final VoidCallback onAdd;
  final VoidCallback onReduce;

  @override
  _ExTextFieldStyle5State createState() => _ExTextFieldStyle5State();
}

class _ExTextFieldStyle5State extends State<ExTextFieldStyle5> {
  bool showClean = false;
  final FocusNode _defaultFocusNode = FocusNode();
  bool _isObscure = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          showClean = widget.controller.text.isNotEmpty;
        });
      }
      // widget.onChanged!(widget.controller.text);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 32.h,
      child: Row(
        children: [
          Expanded(
            child: KeyboardActions(
              tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
              // tapOutsideBehavior: TapOutsideBehavior.none,
              autoScroll: true,
              isDialog: false,
              disableScroll: true,
              enable: widget.keyboardActionEnable,
              config: KeyboardActionsConfig(
                keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
                keyboardBarColor: ExColors.input_bg_color(context),
                nextFocus: false,
                actions: [
                  KeyboardActionsItem(
                    focusNode: widget.focusNode ?? _defaultFocusNode,
                    toolbarButtons: [
                      (FocusNode focusNode) {
                        return GestureDetector(
                          child: Padding(
                              padding: EdgeInsets.only(right: 10.w),
                              child: Image.asset(
                                  "images/light/ic_keyboard_putaway.png")),
                          onTap: () {
                            (widget.focusNode ?? _defaultFocusNode).unfocus();
                          },
                        );
                      }
                    ],
                  ),
                ],
              ),
              child: TextField(
                textAlign: TextAlign.center,
                textAlignVertical:TextAlignVertical.center,
                cursorColor: ExColorsLight.main_color,
                cursorRadius: Radius.circular(1.5),
                cursorWidth: 2,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                focusNode: widget.focusNode ?? _defaultFocusNode,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                style: widget.style ?? ExThemes.textstyle_sm_color1_14(context),
                keyboardType: widget.keyboardType,
                obscureText: _isObscure,
                onChanged: widget.onChanged ??
                    (value) {
                      print("正在输入内容：$value");
                    },
                autofocus: widget.autofocus ?? false,
                decoration: InputDecoration(
                  counterText: widget.counterText,
                  hintText: widget.hintText,
                  isCollapsed: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none),
                  fillColor: ExColors.input_bg_color(context),
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
                  hintStyle: widget.hintStyle ??
                      ExThemes.textstyle_sm_color3_13(context),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: ExColorsLight.main_color,
                          width: 0.5,
                          style: BorderStyle.solid)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                          color: ExColorsDark.main_red_color,
                          width: 0.5,
                          style: BorderStyle.solid)),
                  prefixIcon: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.onReduce();
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 8.w),
                      child: ExIcon.icTradeReduce(),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 24),
                  suffixIconConstraints: const BoxConstraints(minWidth: 24),
                  suffixIcon: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.onAdd();
                    },
                    child: Container(
                      // width: 30.w,
                      padding: EdgeInsets.only(right: 8.w),
                      child: ExIcon.icTradeAdd(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InputFormat extends TextInputFormatter {
  InputFormat({this.decimalRange = 2})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String nValue = newValue.text;
    TextSelection nSelection = newValue.selection;

    Pattern p = RegExp(r'(\d+\.?)|(\.?\d+)|(\.?)');
    nValue = p
        .allMatches(nValue)
        .map<String>((Match match) => match.group(0).toString())
        .join();

    if (nValue.startsWith('.')) {
      nValue = '0.';
    } else if (nValue.contains('.')) {
      //来验证小数点位置
      if (nValue.substring(nValue.indexOf('.') + 1).length > decimalRange) {
        nValue = oldValue.text;
      } else {
        if (nValue.split('.').length > 2) {
          List<String> split = nValue.split('.');
          nValue = split[0] + '.' + split[1];
        }
      }
    }

    nSelection = newValue.selection.copyWith(
      baseOffset: math.min(nValue.length, nValue.length + 1),
      extentOffset: math.min(nValue.length, nValue.length + 1),
    );

    return TextEditingValue(
        text: nValue, selection: nSelection, composing: TextRange.empty);
  }
}
