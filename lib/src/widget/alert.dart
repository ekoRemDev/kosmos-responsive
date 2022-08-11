import 'dart:async';

import 'package:core_kosmos/core_package.dart';
import 'package:flutter/material.dart';

abstract class AlertBox {
  static FutureOr<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    List<Widget Function(BuildContext)>? actions,
    bool isClosable = true,
  }) async {
    return await showGeneralDialog<T>(
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  width: formatWidth(282),
                  padding: EdgeInsets.symmetric(vertical: formatHeight(28), horizontal: formatWidth(34)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(_),
                            child: Icon(Icons.close_rounded, color: const Color(0xFFCFD2D6), size: formatWidth(28)),
                          ),
                        ],
                      ),
                      sh(12),
                      SizedBox(
                        width: formatWidth(200),
                        child: Text(
                          title,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: sp(20)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      sh(6),
                      Text(
                        message,
                        style: TextStyle(color: const Color(0xFFA7ADB5), fontWeight: FontWeight.w600, fontSize: sp(14)),
                        textAlign: TextAlign.center,
                      ),
                      sh(32),
                      if (actions != null)
                        ...actions
                            .map(
                              (e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  e(_),
                                  sh(8),
                                ],
                              ),
                            )
                            .toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
