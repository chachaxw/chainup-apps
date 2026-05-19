// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants/icon_constant.dart';
import '../themes/Themes.dart';
import 'gaps.dart';



class ExCheckbox extends StatefulWidget {
  const ExCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.size,
    this.str,
    this.padding,
    this.margin,
    this.textStyle,
  }) :super(key: key);

  final String? str;
  final bool? value;
  final double? size;
  final TextStyle? textStyle;

  final ValueChanged<bool?>? onChanged;
  static const double width = 18.0;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  @override
  State<ExCheckbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<ExCheckbox> with TickerProviderStateMixin {
  bool? _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(ExCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  ValueChanged<bool?>? get onChanged => widget.onChanged;

  @override
  bool? get value => widget.value;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.onChanged!(!value!);
      },
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        color: Colors.transparent,
        child: Row(
          children: [
            value==false?ExIcon.icUnSelected(widget.size??16.0):ExIcon.icSelected(widget.size??16.0),
            Gaps.hGap4,
            widget.str != null?
            Expanded(child: Text(
              widget.str??"",
              style: widget.textStyle ?? ExThemes.textstyle_sm_color2_12(context),
            )):Gaps.empty,],
        ),
      ),
    );
  }
}
