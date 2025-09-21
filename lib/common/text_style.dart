import 'package:brain_nest/common/app_colors.dart';
import 'package:brain_nest/common/size_config.dart';
import 'package:flutter/material.dart';


class AppTextStyles {
  static TextStyle textStyle(
      {Color? txtColor = AppColors.black,
      Color? decorationColor,
      double fontSize = 14,
      FontStyle? fontStyle,
      FontWeight fontWeight = FontWeight.w400,
      TextDecoration decoration = TextDecoration.none,
      double? letterSpacing,
      double? height}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: txtColor,
        decoration: decoration,
        decorationColor: decorationColor ?? txtColor,
        letterSpacing: letterSpacing,
        height: height ?? 1.1,
        fontStyle: fontStyle,
        fontSize: getWidth(fontSize));
  }
}
