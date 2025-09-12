import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'list_item.dart';
import 'magenta_cloud_connection.dart';
import 'qr_code_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'hive.dart';
import 'app_data.dart';
import 'priority_enum.dart';
import 'lifetime_stats.dart';


class Model {

  Model();

  static Future<QrImageView> getQrCode() async{
    while (! (await pushMagenta())){/*await response from magenta cloud*/}
    return buildQrCode();
  }

  static Future<bool> pushMagenta() async{
    AppData a = await readHiveItems();

    List<Map<String, dynamic>> allItems = [];
    for (var item in a.checked.l)  {
      allItems.add(jsonDecode(item.toJsonString()));
    }
    for (var item in a.unchecked.l)  {
      allItems.add(jsonDecode(item.toJsonString()));
    }
    final lifetimeStats = await readHiveLifetimeStats();

    Map<String, dynamic> dataMap = {
      'Items': allItems,
      'Stats': lifetimeStats,
      'Language': await readLanguage(),
      'Prio': (await readPriority()).value.toString(),
      'Color': await readColor(),
      'Send_Notifications': (await readHiveNotification() == true) ? 1: 0,
      'Custom_Color': (await readCustomColorFromHive())?.value ?? Colors.lightBlue.value
    };

    String data = jsonEncode(dataMap);

    return await updateCloud(data);
  }

  static Future<Map<String, dynamic>> popMagenta(String encoded_id, String key, String checksum) async{
    String value = await getCloudEntry(encoded_id, key, checksum);

    //deserialize
    Map<String, dynamic> dataMap = jsonDecode(value);
    List<dynamic> itemsJson = dataMap['Items'];
    List<ListItem> allItems = itemsJson.map((itemJson) => ListItem.fromJsonString(jsonEncode(itemJson))).toList();

    String lang = dataMap['Language'];
    int prio = int.parse(dataMap['Prio']);
    String color = dataMap['Color'];
    var stats = dataMap['Stats'];
    int colorValue = dataMap['Custom_Color'] as int;
    Color customColor = Color(colorValue);

    if (stats != null) {
      final currentLifetimeStats = await readHiveLifetimeStats();
      final incomingLifetimeStats = LifetimeStats.fromJson(stats);

      final mergedLifetimeStats = LifetimeStats(
        createdCount: currentLifetimeStats.createdCount + incomingLifetimeStats.createdCount,
        checkedCount: currentLifetimeStats.checkedCount + incomingLifetimeStats.checkedCount,
      );

      await writeHiveLifetimeStats(mergedLifetimeStats);
    }
    bool send_notifications = false;
    if (dataMap['Send_Notifications'] == 1){
      send_notifications = true;
    }

    //safe to hive
    for (int i = 0; i <allItems.length;i++){
      await writeHiveItem(allItems[i]);
    }
    await writeHiveLanguage(lang);
    switch (prio) {
      case 0:  await writeHivePriority(PriorityEnum.OwnPriority); break;
      case 1:  await writeHivePriority(PriorityEnum.EDD); break;
      case 2:  await writeHivePriority(PriorityEnum.EisenhowerMatrix); break;
      case 3:  await writeHivePriority(PriorityEnum.ValueEffort); break;
      case 4:  await writeHivePriority(PriorityEnum.DurationDeadline); break;
      case 5:  await writeHivePriority(PriorityEnum.WeightedScoringModel); break;
    }
    await writeHiveColor(color);

    await writeHiveNotification(send_notifications);

    await writeCustomColor(customColor);

    bool deleted = await deleteCloudEntry(encoded_id);
    return {
      'deleted': deleted,
      'appData': await readHiveItems(),
      'language': lang,
      'priority': prio,
      'color': color,
      'stats': stats,
      'Send_Notifications': send_notifications,
      'Custom_Color': customColor,
    };
  }

  //wrapper
  static Future<void> initHive() async{init();}
  static Future<AppData> readHiveItems() async => await readLists();
  static Future<void> writeHiveItems(AppData a) async => await writeLists(a.checked, a.unchecked);
  static Future<void> writeHiveItem(ListItem i)async => await writeItem(i);
  static Future<void> deleteHiveItem(ListItem i) async => await deleteItem(i);
  static Future<void> writeHiveColor(String color) async => await writeColor(color);
  static Future<void> writeHiveLanguage(String language) async => await writeLanguage(language);
  static Future<void> writeHivePriority(PriorityEnum e) async => await writePriority(e);
  static Future<void> writeHiveWSM(int a, int b, int c) async => await writeWSM(a, b, c);
  static Future<String> readHiveColor() async => await readColor();
  static Future<String> readHiveLanguage() async => await readLanguage();
  static Future<PriorityEnum> readHivePriority() async => await readPriority();
  static Future<List<int>> readHiveWSM() async => await readWSM();
  static Future<void> writeCustomColor(Color color) async => await writeCustomColorToHive(color);
  static Future<Color?> readCustomColor() async => await readCustomColorFromHive();
  static Future<bool> readHiveNotification() async => await readNotification();
  static Future<void> writeHiveNotification(bool a) async => await writeNotification(a);
  static Future<void> writeHiveLifetimeStats(LifetimeStats stats) async => await writeLifetimeStats(stats);
  static Future<LifetimeStats> readHiveLifetimeStats() async => await readLifetimeStats();

}