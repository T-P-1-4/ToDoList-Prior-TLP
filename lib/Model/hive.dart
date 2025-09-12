import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time/time.dart';
import 'package:todo_appdev/Model/app_data.dart';
import 'package:todo_appdev/Model/priority_enum.dart';
import 'item_list.dart';
import 'list_item.dart';
import 'lifetime_stats.dart';

Future<void> init() async {
  //Hive initialisieren
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
}

Future<AppData> readLists() async {
  var box = await Hive.openBox('items');
  AppData loaded = AppData();

  for (var value in box.values) {
    if (value is String) {
      print(value);
      var item = ListItem.fromJsonString(value);
      if (item.isChecked) {
        DateTime date = item.getCheckedDate;
        DateTime now = DateTime.now();
        Duration difference = date.difference(now.date);
        if (difference.inDays <= -6){ // delete Item on checked list on 7th day untouched
          deleteItem(item);
        }else {
          loaded.checked.l.add(item);
        }
      } else {
        loaded.unchecked.l.add(item);
      }
    }
  }
  return loaded;
}

Future<void> writeLists(ItemList checked, ItemList unchecked) async {
  var box = await Hive.openBox('items');

  for(int i =0; i<checked.l.length;i++){
    box.put(checked.l[i].getCreatedTimestamp.toString(), checked.l[i].toJsonString());
  }
  for(int i =0; i<unchecked.l.length;i++){
    box.put(unchecked.l[i].getCreatedTimestamp.toString(), unchecked.l[i].toJsonString());
  }
}

Future<void> writeItem(ListItem i) async {
  var box = await Hive.openBox('items');
  box.put(i.getCreatedTimestamp.toString(),i.toJsonString());
}

Future<void> deleteItem(ListItem i) async{
  var box = await Hive.openBox('items');
  box.delete(i.getCreatedTimestamp.toString());
}

Future<void> writeColor(String color) async {
  var box = await Hive.openBox('color');
  box.put("color",color);
}

Future<void> writeLanguage(String language) async {
  var box = await Hive.openBox('language');
  box.put("language",language);
}

Future<void> writePriority(PriorityEnum e) async {
  var box = await Hive.openBox('priority');
  // Den Wert direkt als int zurückgeben, nicht als .toString()
  box.put("priority",e.value);
}

Future<void> writeWSM(int a, int b, int c) async {
  var box = await Hive.openBox('priorityWSM');
  box.put("a",a);
  box.put("b",b);
  box.put("c",c);
}

Future<void> writeNotification(bool send_notifications) async{
  var box = await Hive.openBox('notification');
  // Den Wert direkt als int zurückgeben, nicht als .toString()
  box.put("notification",send_notifications);
}

// Custom Color Picker save to hive
Future<void> writeCustomColorToHive(Color color) async {
  var box = await Hive.openBox('customColor');
  box.put("value", color.value);
}

// Save / Read Lifetime stats in hive
Future<void> writeLifetimeStats(LifetimeStats stats) async {
  var box = await Hive.openBox('lifetimeStats');
  box.put('createdCount', stats.createdCount);
  box.put('checkedCount', stats.checkedCount);
}

//read
Future<String> readColor() async {
  var box = await Hive.openBox('color');
  if (!box.containsKey('color')) {
    await box.put('color', 'lightBlue');
  }
  return box.get("color").toString().replaceFirst("(", "").replaceFirst(")", "");
}

Future<String> readLanguage() async {
  var box = await Hive.openBox('language');
  if (!box.containsKey('language')) {
    await box.put('language', 'en');
  }
  return box.get("language").toString().replaceFirst("(", "").replaceFirst(")", "");
}

Future<PriorityEnum> readPriority() async {
  var box = await Hive.openBox('priority');
  if (!box.containsKey('priority')) {
    await box.put('priority', 0); // Default: OwnPriority
  }

  final value = box.get("priority");
  if (value is int) {
    switch (value) {
      case 0: return PriorityEnum.OwnPriority;
      case 1: return PriorityEnum.EDD;
      case 2: return PriorityEnum.EisenhowerMatrix;
      case 3: return PriorityEnum.ValueEffort;
      case 4: return PriorityEnum.DurationDeadline;
      case 5: return PriorityEnum.WeightedScoringModel;
    }
  }
  throw Exception("Number of priority is not known");
}

Future<List<int>> readWSM() async{
  var box = await Hive.openBox('priorityWSM');
  if (!box.containsKey('a')) {
    await box.put('a', 33);
    await box.put('b', 33);
    await box.put('c', 34);
  }
  List<int> l = [];
  l.add(box.get("a") as int);
  l.add(box.get("b") as int );
  l.add(box.get("c") as int);
  //print(l);
  return l;
}

Future<bool> readNotification() async{
  var box = await Hive.openBox('notification');
  if (!box.containsKey('notification')) {
    await box.put('notification', false);
  }
  return box.get("notification");
}

Future<Color?> readCustomColorFromHive() async {
  var box = await Hive.openBox('customColor');
  if (!box.containsKey('value')) return null;

  final value = box.get("value");
  if (value is int) {
    return Color(value);
  }
  return null;
}

Future<LifetimeStats> readLifetimeStats() async {
  var box = await Hive.openBox('lifetimeStats');
  return LifetimeStats(
    createdCount: box.get('createdCount', defaultValue: 0),
    checkedCount: box.get('checkedCount', defaultValue: 0),
  );
}
