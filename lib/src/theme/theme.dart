import 'package:flutter/material.dart';

class SettingsThemeData {
  final TextStyle? nameStyle;
  final TextStyle? emailStyle;

  final TextStyle? sectionStyle;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final double? iconSize;
  final Color? iconColor;
  final Color? actionIconColor;
  final Color? activeIconColor;


  ///Only for Web
  final Color? iconActiveColor;
  final Color? buttonBackgroundActiveColor;

  const SettingsThemeData({
    this.emailStyle,
    this.nameStyle,
    this.sectionStyle,
    this.subTitleStyle,
    this.titleStyle,
    this.iconSize,
    this.iconColor,
    this.activeIconColor,
    this.actionIconColor,

    ///Web
    this.buttonBackgroundActiveColor,
    this.iconActiveColor,
  });
}
