import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../constants/icon_constant.dart';
import '../themes/Themes.dart';
import 'gaps.dart';

Text ExText(String text,
    {TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow}) {
  return Text(text,
      style: style,
      strutStyle: ExThemes.textStrutStyle(),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow);
}

Text ExText11(String text,
    {TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow}) {
  return Text(text,
      style: style,
      strutStyle: ExThemes.textStrutStyle11(),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow);
}

Text ExText13(String text,
    {TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow}) {
  return Text(text,
      style: style,
      strutStyle: ExThemes.textStrutStyle13(),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow);
}

Text ExTextEf(String text,
    {TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow}) {
  return Text(text,
      style: style,
      strutStyle: ExThemes.textStrutStyleEf(),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow);
}
