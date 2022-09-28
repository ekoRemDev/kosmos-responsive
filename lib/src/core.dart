// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_package.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:settings_kosmos/src/widget/alert.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:url_launcher/url_launcher.dart';
import '../src/services/firebase/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../settings_kosmos.dart';

final settingsProvider = ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider();
});

class ResponsiveSettings extends HookConsumerWidget {
  final List<dz.Tuple2<String, List<SettingsNode>>> nodes;
  final Function? deleteAccountFunction;

  File? profilPicture;

  final SettingsThemeData? theme;
  final String? themeName;

  final bool showUserProfil;
  final bool showUserImage;
  final bool showEditedBy;

  final String? userName;
  final String? userEmail;
  final String? userImage;

  ResponsiveSettings({
    Key? key,
    required this.nodes,
    this.profilPicture,
    this.theme,
    this.themeName,
    this.deleteAccountFunction,
    this.showUserImage = true,
    this.showUserProfil = true,
    this.showEditedBy = true,
    this.userEmail,
    this.userImage,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsThemeData? themeData = loadThemeData(theme, themeName ?? "settings", () => const SettingsThemeData());

    if (getResponsiveValue(context, defaultValue: false, tablet: true, phone: true)) {
      execAfterBuild(() => ref.read(settingsProvider).clear());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: double.infinity, height: .1),
        if (showUserProfil) ...[
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: AutoRouter.of(context).canNavigateBack &&
                              getResponsiveValue(context, defaultValue: false, tablet: false, phone: true)
                          ? 1
                          : 0,
                      child: InkWell(
                        onTap: () {
                          if (AutoRouter.of(context).canNavigateBack) AutoRouter.of(context).navigateBack();
                        },
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black,
                          size: formatWidth(20),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final showBoxAlertToDeleteAccount = await showCupertinoModalPopup(
                          context: context,
                          builder: (_) {
                            return CupertinoActionSheet(
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.of(_).pop(false);
                                },
                                child: Text(
                                  "utils.cancel".tr(),
                                  style: TextStyle(
                                    color: const Color(0xFF007AFF),
                                    fontSize: sp(20),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                "settings.what-you-want-do".tr(),
                                style: TextStyle(
                                  fontSize: sp(13),
                                  color: const Color(0xFF8F8F8F),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                CupertinoActionSheetAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    AutoRouter.of(context).replaceNamed("/logout");
                                  },
                                  child: Text(
                                    "settings.logout".tr(),
                                    style: TextStyle(
                                      color: const Color(0xFFFF3B30),
                                      fontSize: sp(20),
                                    ),
                                  ),
                                ),
                                CupertinoActionSheetAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.of(_).pop(true);
                                  },
                                  child: Text(
                                    "settings.delete-profil".tr(),
                                    style: TextStyle(
                                      color: const Color(0xFFFF3B30),
                                      fontSize: sp(20),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (showBoxAlertToDeleteAccount == true) {
                          final rep = await AlertBox.show<bool>(
                            context: context,
                            title: "settings.delete-account".tr(),
                            message: "settings.delete-account-confirm".tr(),
                            actions: [
                              (_) => CTA.primary(
                                    textButton: "utils.yes".tr(),
                                    width: formatWidth(207),
                                    textButtonStyle: TextStyle(color: Colors.white, fontSize: sp(14)),
                                    onTap: () => Navigator.of(_).pop(true),
                                  ),
                              (_) => CTA.secondary(
                                    textButton: "utils.non".tr(),
                                    width: formatWidth(207),
                                    textButtonStyle: TextStyle(color: Colors.black, fontSize: sp(14)),
                                    onTap: () => Navigator.of(_).pop(false),
                                  ),
                            ],
                          );
                          if (rep == true) {
                            if (deleteAccountFunction != null) await deleteAccountFunction!();
                            AutoRouter.of(context).replaceNamed("/logout");
                          }
                        }
                      },
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                        size: formatWidth(20),
                      ),
                    )
                  ],
                ),
                sh(25),
                if (showUserImage) ...[
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      userImage != null
                      ? Container(
                         width: formatWidth(92),
                    height: formatWidth(92),
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: userImage!,
                          placeholder: (_, __) => Image.asset(
                            "assets/images/img_default_user.png",
                            package: "settings_kosmos",
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            "assets/images/img_default_user.png",
                            package: "settings_kosmos",
                            fit: BoxFit.cover,
                          ),
                          fit: BoxFit.cover,
                        ),
                      )
                      : CircleAvatar(
                        child: Image.asset(
                          "assets/images/img_default_user.png",
                          package: "settings_kosmos",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: -10,
                        child: InkWell(
                          onTap: () async {
                            await showCupertinoModalPopup(
                              context: context,
                              builder: (_) {
                                return CupertinoActionSheet(
                                  cancelButton: CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(_).pop(false);
                                    },
                                    child: Text(
                                      "utils.cancel".tr(),
                                      style: TextStyle(
                                        color: const Color(0xFF007AFF),
                                        fontSize: sp(20),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "settings.what-you-want-do".tr(),
                                    style: TextStyle(
                                      fontSize: sp(13),
                                      color: const Color(0xFF8F8F8F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        //AutoRouter.of(context).replaceNamed("/logout");
                                      },
                                      //Prendre une photo/video
                                      child: Text(
                                        "settings.take-picture".tr(),
                                        style: TextStyle(
                                          color: const Color(0xFF007AFF),
                                          fontSize: sp(20),
                                        ),
                                      ),
                                    ),
                                    //Bibliothèque
                                    CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: () async {
                                        File? image = await FirebaseStorageController()
                                            .selectFile(FirebaseAuth.instance.currentUser!.uid);
                                        if (image != null) {
                                          profilPicture = image;
                                        }
                                        Navigator.of(_).pop(true);
                                      },
                                      child: Text(
                                        "settings.modify-picture".tr(),
                                        style: TextStyle(
                                          color: const Color(0xFF007AFF),
                                          fontSize: sp(20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            // if (showBoxAlertToModifyProfilPicture == true) {
                            //   final rep = await AlertBox.show<bool>(
                            //     context: context,
                            //     title: "settings.modify-picture".tr(),
                            //     message: "settings.modify-picture-confirm".tr(),
                            //     actions: [
                            //       (_) => CTA.primary(
                            //             textButton: "utils.yes".tr(),
                            //             width: formatWidth(207),
                            //             textButtonStyle: TextStyle(color: Colors.white, fontSize: sp(14)),
                            //             onTap: () => Navigator.of(_).pop(true),
                            //           ),
                            //       (_) => CTA.secondary(
                            //             textButton: "utils.non".tr(),
                            //             width: formatWidth(207),
                            //             textButtonStyle: TextStyle(color: Colors.black, fontSize: sp(14)),
                            //             onTap: () => Navigator.of(_).pop(false),
                            //           ),
                            //     ],
                            //   );
                            //   if (rep == true) {
                            //     if (deleteAccountFunction != null) await deleteAccountFunction!();
                            //     AutoRouter.of(context).replaceNamed("/logout");
                            //   }
                            // }
                          },
                          //storageservice
                          //getdowlondurl
                          //updatefirebaseuser

                          child: SvgPicture.asset(
                            'assets/svg/pen.svg',
                            package: "settings_kosmos",
                            height: 30,
                          ),
                        ),
                      )
                    ],
                  ),
                  sh(5.4),
                ],
                if (userName != null) ...[
                  Text(
                    userName!,
                    style: themeData?.nameStyle ??
                        TextStyle(
                          fontSize: sp(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (userEmail != null) ...[
                  Text(
                    userEmail!,
                    style: themeData?.emailStyle ??
                        TextStyle(
                          fontSize: sp(13),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA7ADB5),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (showUserProfil) ...[
          sh(13),
          const Divider(height: .5),
          sh(23),
        ],
        ...nodes.map((e) => _buildSettingsSection(context, e, themeData, ref)).toList(),
        if (showEditedBy) ...[
          sh(21),
          Center(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "settings.edited_by".tr(),
                  style: themeData?.titleStyle ??
                      TextStyle(fontSize: sp(14), color: Colors.black, fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: "kosmos-digital.com",
                  style: (themeData?.titleStyle ??
                          TextStyle(fontSize: sp(14), color: Colors.black, fontWeight: FontWeight.w500))
                      .copyWith(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse("https://kosmos-digital.com")),
                ),
              ]),
            ),
          )
        ]
      ],
    );
  }

  _buildSettingsSection(
      BuildContext context, dz.Tuple2<String, List<SettingsNode>> node, SettingsThemeData? themeData, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          node.value1.tr(),
          style:
              themeData?.sectionStyle ?? TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600, color: Colors.black),
        ),
        sh(10),
        ...node.value2
            .map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSettingsItem(context, e, themeData, ref),
                    sh(7),
                  ],
                ))
            .toList(),
      ],
    );
  }
}

/// Node builder
buildSettingsItem(BuildContext context, SettingsNode e, SettingsThemeData? themeData, WidgetRef ref, [int level = 0]) {
  switch (e.type) {
    case SettingsType.personnalData:
      if (e.data!.builder != null) {
        return e.data!.builder!(context, ref);
      } else {
        return SettingsCellule(
          isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
              ? ref.watch(settingsProvider).isActive(e.tag)
              : false,
          onClick: () async {
            if (e.data?.onTap != null) {
              await e.data!.onTap!(context, ref);
            } else if (e.children != null) {
              if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
                ref.read(settingsProvider).updateNode(level, e.tag);
              } else {
                AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
              }
            } else if (e.data?.childBuilder != null) {
              if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
                ref.read(settingsProvider).updateNode(level, e.tag);
              } else {
                AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
              }
            }
          },
          title: e.data!.title,
          titleStyle: themeData?.titleStyle,
          subtitle: e.data!.subTitle,
          subtitleStyle: themeData?.subTitleStyle,
          icon: e.data!.prefix,
          activeIcon: e.data?.activePrefix,
        );
      }
    case SettingsType.security:
      return SettingsCellule(
        isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
            ? ref.watch(settingsProvider).isActive(e.tag)
            : false,
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          } else if (e.children != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          } else if (e.data?.childBuilder != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          }
        },
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/lock.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        activeIcon: Center(
          child: SvgPicture.asset(
            "assets/svg/lock.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.activeIconColor ?? Colors.white,
          ),
        ),
        title: "settings.security.title".tr(),
        titleStyle: themeData?.titleStyle,
        subtitle: "settings.security.subTitle".tr(),
        subtitleStyle: themeData?.subTitleStyle,
      );
    case SettingsType.payment:
      return SettingsCellule(
        isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
            ? ref.watch(settingsProvider).isActive(e.tag)
            : false,
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          } else if (e.children != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          } else if (e.data?.childBuilder != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          }
        },
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/credit-card.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        activeIcon: Center(
          child: SvgPicture.asset(
            "assets/svg/credit-card.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.activeIconColor ?? Colors.white,
          ),
        ),
        title: "settings.payment.title".tr(),
        titleStyle: themeData?.titleStyle,
        subtitle: "settings.payment.subTitle".tr(),
        subtitleStyle: themeData?.subTitleStyle,
      );
    case SettingsType.share:
      return SettingsCellule(
        isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
            ? ref.watch(settingsProvider).isActive(e.tag)
            : false,
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          } else if (e.children != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          } else if (e.data?.childBuilder != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          }
        },
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/share.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        activeIcon: Center(
          child: SvgPicture.asset(
            "assets/svg/share.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.activeIconColor ?? Colors.white,
          ),
        ),
        title: "settings.share.title".tr(),
        titleStyle: themeData?.titleStyle,
        subtitle: "settings.share.subTitle".tr(),
        subtitleStyle: themeData?.subTitleStyle,
      );
    case SettingsType.help:
      return SettingsCellule(
        isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
            ? ref.watch(settingsProvider).isActive(e.tag)
            : false,
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          } else if (e.children != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          } else if (e.data?.childBuilder != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          }
        },
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/help.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        activeIcon: Center(
          child: SvgPicture.asset(
            "assets/svg/help.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.activeIconColor ?? Colors.white,
          ),
        ),
        title: "settings.help.title".tr(),
        titleStyle: themeData?.titleStyle,
        subtitle: "settings.help.subTitle".tr(),
        subtitleStyle: themeData?.subTitleStyle,
      );
    case SettingsType.link:
      return SettingsCellule(
        isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
            ? ref.watch(settingsProvider).isActive(e.tag)
            : false,
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          } else if (e.children != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          } else if (e.data?.childBuilder != null) {
            if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
              ref.read(settingsProvider).updateNode(level, e.tag);
            } else {
              AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
            }
          }
        },
        icon: e.data?.prefix,
        activeIcon: e.data?.prefix,
        title: e.data?.title,
        titleStyle: themeData?.titleStyle,
      );
    case SettingsType.custom:
      if (e.data?.builder != null) {
        return e.data!.builder!(context, ref);
      } else {
        return SettingsCellule(
          isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
              ? ref.watch(settingsProvider).isActive(e.tag)
              : false,
          onClick: () async {
            if (e.data?.onTap != null) {
              await e.data!.onTap!(context, ref);
            } else if (e.children != null) {
              if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
                ref.read(settingsProvider).updateNode(level, e.tag);
              } else {
                AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
              }
            } else if (e.data?.childBuilder != null) {
              if (getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)) {
                ref.read(settingsProvider).updateNode(level, e.tag);
              } else {
                AutoRouter.of(context).navigateNamed("/dashboard/profile/settings/${e.tag}");
              }
            }
          },
          title: e.data!.title,
          titleStyle: themeData?.titleStyle,
          subtitle: e.data!.subTitle,
          subtitleStyle: themeData?.subTitleStyle,
          icon: e.data!.prefix,
          activeIcon: e.data!.prefix,
        );
      }
    case SettingsType.facebook:
      return SettingsCellule(
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          }
        },
        iconBackgroundColor: const Color(0xFF0074F6),
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/facebook.svg",
            package: "settings_kosmos",
            height: themeData?.iconSize ?? formatWidth(19),
          ),
        ),
        title: "settings.facebook.title".tr(),
        titleStyle: themeData?.titleStyle,
      );
    case SettingsType.instagram:
      return SettingsCellule(
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          }
        },
        icon: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SvgPicture.asset(
              "assets/svg/instaLink.svg",
              package: "settings_kosmos",
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: "settings.instagram.title".tr(),
        titleStyle: themeData?.titleStyle,
      );
    case SettingsType.twitter:
      return SettingsCellule(
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          }
        },
        iconBackgroundColor: const Color(0xFF00acee),
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/twitter.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        title: "settings.twitter.title".tr(),
        titleStyle: themeData?.titleStyle,
      );
    case SettingsType.linkedin:
      return SettingsCellule(
        onClick: () async {
          if (e.data?.onTap != null) {
            await e.data!.onTap!(context, ref);
          }
        },
        iconBackgroundColor: const Color(0xFF007AB9),
        icon: Center(
          child: SvgPicture.asset(
            "assets/svg/linkedin.svg",
            package: "settings_kosmos",
            width: themeData?.iconSize ?? formatWidth(16),
            color: themeData?.iconColor ?? Colors.white,
          ),
        ),
        title: "settings.linkedin.title".tr(),
        titleStyle: themeData?.titleStyle,
      );
    case SettingsType.switcher:
      if (e.data?.builder != null) {
        return e.data!.builder!(context, ref);
      } else {
        return SettingsCellule(
          switchNotif: CupertinoSwitch(
            activeColor: e.data!.activeSwitchColor,
            value: e.data!.switchValue!(ref),
            onChanged: (val) async {
              if (e.data?.onSwicth != null) {
                await e.data!.onSwicth!(context, ref, val);
              }
            },
          ),
          isActive: getResponsiveValue(context, defaultValue: true, phone: false, tablet: true)
              ? ref.watch(settingsProvider).isActive(e.tag)
              : false,
          onClick: () async {
            if (e.data?.onSwicth != null) {
              await e.data!.onSwicth!(context, ref, !e.data!.switchValue!(ref));
            }
          },
          title: e.data!.title,
          titleStyle: themeData?.titleStyle,
          subtitle: e.data!.subTitle,
          subtitleStyle: themeData?.subTitleStyle,
          icon: e.data!.prefix,
          activeIcon: e.data?.prefix,
        );
      }
  }
}

class NodePage extends ConsumerWidget {
  final String nodeTag;
  final List<dz.Tuple2<String, List<SettingsNode>>> nodes;

  final SettingsThemeData? theme;
  final String? themeName;

  final int level;

  NodePage({
    Key? key,
    required this.nodeTag,
    required this.nodes,
    this.themeName,
    this.theme,
    this.level = 1,
  }) : super(key: key) {
    node = _catchNode(nodes);
  }

  late SettingsNode? node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsThemeData? themeData = loadThemeData(theme, themeName ?? "settings", () => const SettingsThemeData());

    if (node != null && node!.data?.childBuilder != null) {
      return node!.data!.childBuilder!(context, ref);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (node != null) ...[
          ...node!.children!.map((e) => _buildSettingsSection(context, e, themeData, ref)).toList(),
        ] else ...[
          Text(
            "settings.node.noNode".tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ],
    );
  }

  _buildSettingsSection(
      BuildContext context, dz.Tuple2<String, List<SettingsNode>> node, SettingsThemeData? themeData, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: formatHeight(35),
          child: Stack(
            children: [
              Center(
                child: Text(
                  node.value1.tr(),
                  style: themeData?.sectionStyle ??
                      TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
              if (getResponsiveValue(context, defaultValue: false, tablet: false, phone: true))
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: InkWell(
                    onTap: () => AutoRouter.of(context).navigateBack(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: formatWidth(18),
                    ),
                  ),
                ),
            ],
          ),
        ),
        sh(20),
        ...node.value2
            .map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSettingsItem(context, e, themeData, ref, level),
                    sh(7),
                  ],
                ))
            .toList(),
      ],
    );
  }

  SettingsNode? _catchNode(List<dz.Tuple2<String, List<SettingsNode>>> nodes) {
    for (var e in nodes) {
      for (final i in e.value2) {
        if (i.tag == nodeTag) {
          return i;
        } else if (i.children != null) {
          var j = _catchNode(i.children!);
          if (j != null) return j;
        }
      }
    }
    return null;
  }
}
