import 'package:todo_appdev/Model/item_list.dart';
import 'dart:math';
import '../Controller/controller.dart';

class StatsModel {
  final ItemList checked;
  final ItemList unchecked;

  StatsModel({required this.checked, required this.unchecked});

  int getTotalTasks() => checked.items.length + unchecked.items.length;

  int getCompletedTasks() => checked.items.length;

  int getMissedDeadlines() {
    final now = DateTime.now();
    return unchecked.items.where((item) => item.expiration_date.isBefore(now)).length;
  }

  Map<int, int> getPriorityDistribution() {
    Map<int, int> dist = {1: 0, 2: 0, 3: 0};
    for (var item in [...checked.items, ...unchecked.items]) {
      dist[item.priority] = (dist[item.priority] ?? 0) + 1;
    }
    return dist;
  }

  double getAverageDuration() {
    var allItems = [...checked.items, ...unchecked.items];
    if (allItems.isEmpty) return 0.0;
    double sum = allItems.map((e) => e.duration_time_in_hours).reduce((a, b) => a + b);
    return sum / allItems.length;
  }

  double getCompletionRate() {
    int total = getTotalTasks();
    if (total == 0) return 0.0;
    return getCompletedTasks() / total;
  }

  Map<String, int> getCompletedByWeekday() {
    final localizedLabels = [
      Controller.getTextLabel('weekday_sunday_short'),
      Controller.getTextLabel('weekday_monday_short'),
      Controller.getTextLabel('weekday_tuesday_short'),
      Controller.getTextLabel('weekday_wednesday_short'),
      Controller.getTextLabel('weekday_thursday_short'),
      Controller.getTextLabel('weekday_friday_short'),
      Controller.getTextLabel('weekday_saturday_short'),
    ];

    final days = {
      for (var label in localizedLabels) label: 0,
    };

    for (var e in checked.items) {
      final weekdayIndex = e.checked_date.weekday % 7;
      final label = localizedLabels[weekdayIndex];
      days[label] = (days[label] ?? 0) + 1;
    }
    return days;
  }

  Map<int, Map<String, int>> getDetailedPriorityStats() {
    final result = <int, Map<String, int>>{};

    for (var prio in [1, 2, 3]) {
      final prioItemsChecked = checked.items.where((e) => e.priority == prio && e.checked_date != null);
      final prioItemsUnchecked = unchecked.items.where((e) => e.priority == prio);

      final onTime = prioItemsChecked
          .where((e) => e.checked_date!.isBefore(e.expiration_date) || e.checked_date!.isAtSameMomentAs(e.expiration_date))
          .length;
      final late = prioItemsChecked
          .where((e) => e.checked_date!.isAfter(e.expiration_date))
          .length;

      result[prio] = {
        'onTime': onTime,
        'late': late,
        'total': prioItemsChecked.length + prioItemsUnchecked.length,
      };
    }

    return result;
  }

  int getUncheckedTasks() => unchecked.items.length;
}
