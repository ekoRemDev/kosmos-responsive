import 'package:core_kosmos/core_package.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  List<Tuple2<int, String>> activeNodes = [];

  SettingsProvider();

  void updateNode(int level, String tag) {
    for (final e in activeNodes) {
      if (e.value1 >= level + 1) {
        activeNodes.remove(e);
      }
    }
    activeNodes.add(Tuple2(level, tag));
    printInDebug("[Settings] level: $level");
    printInDebug("[Settings] activeNodes: $activeNodes");
    notifyListeners();
  }

  void clear() {
    activeNodes.clear();
    notifyListeners();
  }

  bool isActive(String tag) {
    printInDebug("[Settings] isActive: ${activeNodes.any((e) => e.value2 == tag)}");
    return activeNodes.any((e) => e.value2 == tag);
  }
}
