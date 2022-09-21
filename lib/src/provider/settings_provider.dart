import 'package:core_kosmos/core_package.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  List<Tuple2<int, String>> activeNodes = [];

  SettingsProvider();

  void updateNode(int level, String tag) {
    List<Tuple2<int, String>> tmp = [];
    for (final e in activeNodes) {
      printInDebug("[Settings] level: $level vs ${e.value1}");
      if (e.value1 < level) {
        tmp.add(e);
      }
    }
    activeNodes = tmp;
    activeNodes.add(Tuple2(level, tag));
    printInDebug("[Settings] activeNodes: $activeNodes");
    notifyListeners();
  }

  void clear() {
    activeNodes.clear();
    notifyListeners();
  }

  bool isActive(String tag) {
    return activeNodes.any((e) => e.value2 == tag);
  }
}
