import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  final Function(BuildContext)? onTap;
  final Widget Function(BuildContext)? builder;
  final Widget Function(BuildContext)? childBuilder;

  const SettingsData({
    this.title,
    this.subTitle,
    this.prefix,
    this.onTap,
    this.builder,
    this.childBuilder,
  });
}
