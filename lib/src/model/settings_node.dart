import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SettingsType {
  personnalData,
  security,
  payment,
  share,
  help,
  link,
  custom,
  facebook,
  instagram,
  twitter,
  linkedin,
  switcher,
}

class SettingsNode {
  final String tag;
  final SettingsType type;
  final int? level;
  final SettingsData? data;

  /// It's a fucking shit
  final List<Tuple2<String, List<SettingsNode>>>? children;

  const SettingsNode({
    required this.tag,
    required this.type,
    this.level,
    this.data,
    this.children,
  }) : assert(type == SettingsType.custom ? data != null : true);

  SettingsNode copyWith({
    String? tag,
    SettingsType? type,
    int? level,
    SettingsData? data,
    List<Tuple2<String, List<SettingsNode>>>? children,
  }) {
    return SettingsNode(
      tag: tag ?? this.tag,
      type: type ?? this.type,
      level: level ?? this.level,
      data: data ?? this.data,
      children: children ?? this.children,
    );
  }
}

class SettingsData {
  final String? title;
  final String? subTitle;
  final Widget? prefix;
  final Widget? activePrefix;
  final bool Function(WidgetRef)? switchValue;
  final Function(BuildContext, WidgetRef)? onTap;
  final Function(BuildContext, WidgetRef, bool)? onSwicth;
  final Widget Function(BuildContext, WidgetRef)? builder;
  final Widget Function(BuildContext, WidgetRef)? childBuilder;
  final Color? activeSwitchColor;

  const SettingsData({
    this.title,
    this.subTitle,
    this.prefix,
    this.activePrefix,
    this.onTap,
    this.onSwicth,
    this.builder,
    this.childBuilder,
    this.switchValue,
    this.activeSwitchColor,
  });
}
