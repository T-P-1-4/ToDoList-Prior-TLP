import 'package:flutter/material.dart';
import 'package:todo_appdev/Model/lifetime_stats.dart';
import 'package:todo_appdev/Model/stats_model.dart';
import '../Model/app_data.dart';
import 'controller.dart';

class StatsController extends ChangeNotifier {
  late StatsModel _model;
  late LifetimeStats _lifetimeStats;

  void load(AppData data) async {
    _model = StatsModel(checked: data.checked, unchecked: data.unchecked);
    _lifetimeStats = await Controller.readHiveLifetimeStats();
  }

  StatsModel get model => _model;
  LifetimeStats get lifetime => _lifetimeStats;

  void updateLifetimeStats(LifetimeStats stats) {
    _lifetimeStats = stats;
    notifyListeners();
  }

  Map<String, int> get weekdayCompletion => _model.getCompletedByWeekday();
}

