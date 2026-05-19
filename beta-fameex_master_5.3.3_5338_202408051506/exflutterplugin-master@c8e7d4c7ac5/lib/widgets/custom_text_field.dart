
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'dart:math' as math;

import '../constants/color_constant.dart';
import '../themes/Themes.dart';
import 'gaps.dart';

class ExTextField extends StatefulWidget {
  const ExTextField(
      {Key? key,
      required this.controller,
      this.onChanged,
      this.hintText,
      this.keyboardType,
      this.inputFormatters,
      this.enabled = true,
      this.isPwd = false,
      this.isObscure = false,
      this.maxLength,
      this.counterText,
      this.errorText,
      this.autofocus,
      this.style,
      this.hintStyle,
      this.focusNode,
      this.keyboardActionEnable = true,
      this.hasFocus = false})
      : super(key: key);

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? isPwd;
  final bool? isObscure;
  final int? maxLength;
  final String? counterText;
  final String? errorText;
  final bool? autofocus;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  final bool keyboardActionEnable;
  final bool hasFocus;

  @override
  _ExTextFieldState createState() => _ExTextFieldState();
}

class _ExTextFieldState extends State<ExTextField> {
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
    });
    _isObscure=widget.isObscure??false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KeyboardActions(
            // tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            tapOutsideBehavior: TapOutsideBehavior.none,
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
                            padding: EdgeInsets.only(right: 10),
                            child:
                                Image.asset("images/ic_keyboard_putaway.png")),
                        onTap: () {
                          (widget.focusNode ?? _defaultFocusNode).unfocus();
                        },
                      );
                    }
                  ],
                ),
              ],
            ),
            child: Listener(
              onPointerDown:  (e) => FocusScope.of(context).requestFocus(widget.focusNode ?? _defaultFocusNode),
              child: TextField(
                cursorColor: ExColorsLight.main_color,
                cursorRadius: Radius.circular(1.5),
                cursorWidth: 2,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                focusNode: widget.focusNode ?? _defaultFocusNode,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                style: widget.style ?? ExThemes.textstyle_sm_color1_13(context),
                keyboardType: widget.keyboardType,
                obscureText: _isObscure,
                onChanged: widget.onChanged ??
                        (value) {
                      print("正在输入内容：$value");
                    },
                autofocus: widget.autofocus ?? false,
                decoration: InputDecoration(
                  errorText: (widget.errorText??"").length==0?null:widget.errorText,
                  counterText: widget.counterText,
                  hintText: widget.hintText,
                  isCollapsed: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none),
                  fillColor:  Get.isDarkMode ? ExColorsDark.card_bg_color_2 : ExColorsLight.card_bg_color_2,
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(16, 13, 16, 13),
                  hintStyle: widget.hintStyle ??
                      ExThemes.textstyle_sm_color3_13(context),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: ExColorsLight.main_color,
                          width: 0.5,
                          style: BorderStyle.solid)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: ExColorsDark.main_red_color,
                          width: 0.5,
                          style: BorderStyle.solid)),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.controller.text.length>0?
                      IconButton(
                        onPressed: () {
                          widget.onChanged?.call('');
                          widget.controller.clear();
                        },
                        icon: Icon(Icons.clear),
                      ):Gaps.empty,
                      widget.isPwd == true
                          ? IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      )
                          : Gaps.empty,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
