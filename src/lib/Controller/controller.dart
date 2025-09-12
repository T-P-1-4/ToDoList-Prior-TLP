import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:todo_appdev/Controller/list_item_controller.dart';
import 'package:todo_appdev/Controller/stats_controller.dart';
import 'package:todo_appdev/Model/item_list.dart';
import '../Model/app_data.dart';
import '../Model/list_item.dart';
import 'principle_controller.dart';
import 'package:todo_appdev/Model/priority_enum.dart';
import 'navigation_controller.dart';
import '../Model/navigation_item.dart';
import 'language.dart';
import 'colors.dart';
import 'notification.dart';
import '../Model/model.dart';
import '../Model/lifetime_stats.dart';

class Controller {
  Controller();

  static void sortList(BuildContext context, int prio){
    final appData = Provider.of<AppData>(context, listen: false);
    appData.unchecked.orderList(prio);
  }

  static void addListItem(BuildContext context, ListItem i) async {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.addNewItem(i);
    int prio = getPriorityController(context).value;
    appData.unchecked.orderList(prio);

    final stats = await readHiveLifetimeStats();
    stats.createdCount++;
    await writeHiveLifetimeStats(stats);
    getStatsController(context).updateLifetimeStats(stats);
  }

  static void updateListItem(context, i) async {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.addNewItem(i);
    int prio = getPriorityController(context).value;
    appData.unchecked.orderList(prio);
  }

  static void setItemChecked(BuildContext context, ListItem i) async {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.setItemChecked(i);
    int prio = getPriorityController(context).value;
    appData.unchecked.orderList(prio);

    final stats = await readHiveLifetimeStats();
    stats.checkedCount++;
    await writeHiveLifetimeStats(stats);
    getStatsController(context).updateLifetimeStats(stats);
  }

  static void setItemUnchecked(BuildContext context, ListItem i) async {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.setItemUnchecked(i);
    int prio = getPriorityController(context).value;
    appData.unchecked.orderList(prio);

    final stats = await readHiveLifetimeStats();
    stats.checkedCount = (stats.checkedCount > 0) ? stats.checkedCount - 1 : 0;
    await writeHiveLifetimeStats(stats);
    getStatsController(context).updateLifetimeStats(stats);
  }

  static void deleteItem(BuildContext context, ListItem i) async{
    final appData = Provider.of<AppData>(context, listen: false);
    appData.deleteItem(i);
    int prio = getPriorityController(context).value;
    appData.unchecked.orderList(prio);

    final stats = await readHiveLifetimeStats();
    stats.createdCount = (stats.createdCount > 0) ? stats.createdCount - 1 : 0;
    if (i.checked) {
      stats.checkedCount = (stats.checkedCount > 0) ? stats.checkedCount - 1 : 0;
    }

    await writeHiveLifetimeStats(stats);
    getStatsController(context).updateLifetimeStats(stats);
  }

  static ItemList getCheckedList(BuildContext context, ){
    final appData = Provider.of<AppData>(context, listen: false);
    return appData.getCheckedList;
  }

  static ItemList getUncheckedList(BuildContext context, ){
    final appData = Provider.of<AppData>(context, listen: false);
    return appData.getUncheckedList;
  }

  static void setAppData(BuildContext context, AppData a){
    final appData = Provider.of<AppData>(context, listen: false);
    appData.unchecked = a.unchecked;
    appData.checked = a.checked;
  }

  static String getTextLabel(String key){
    return Language.getText(key);
  }

  /// Methods of the Navigation Controller
  static void selectNavigationItem(BuildContext context, NavigationItem item) {
    final navController = Provider.of<NavigationController>(context, listen: false);  // listen = false verhindert unnötigen rebuild des Controllers
    navController.selectItem(item);
  }

  static NavigationItem getCurrentNavigationItem(BuildContext context) {
    return Provider.of<NavigationController>(context).selectedItem;
  }

  /// Methods of the List Controller
  static ListItemController itemList(BuildContext context) {
    return Provider.of<ListItemController>(context, listen: false);
  }

  /// Methods of the Principle Controller
  static void setSelectedPrinciple(BuildContext context, PriorityEnum p) {
    final princpleController = Provider.of<PrincipleController>(context, listen: false);
    princpleController.setSelected(p);
  }

  static PriorityEnum getCurrentPrincipleEnum(BuildContext context) {
    return Provider.of<PrincipleController>(context).selected;
  }

  static PriorityEnum getPriorityController(BuildContext context) {
    return Provider.of<PrincipleController>(context, listen: false).selected;
  }

  /// Methods of the Language Controller
  static String getCurrentLanguage() {
    return Language.getCurrentLanguage();
  }

  static List<String> getAvailableLanguages() {
    return Language.getAvailableLanguages();
  }

  static void setLanguageAtAppStart(String lang){
    Language.setLanguage(lang);
  }

  static Future<void> loadLanguageFile() async {
    await Language.loadLanguageFile();
  }

  static Future<void> setLanguage(BuildContext context, String lang) async {
    Language.setLanguage(lang);
    await Language.loadLanguageFile();
    Provider.of<NavigationController>(context, listen: false).notifyListeners();
  }

  /// Methods of the Notification Controller
  static bool getCurrentNotification() {
    return AppNotification.getCurrentNotification();
  }

  static void setNotificationAtAppStart( bool send_notification){
    AppNotification.setNotification(send_notification);
  }

  static Future<void> setNotification(BuildContext context, bool send_notification) async {
    AppNotification.setNotification(send_notification);
    Provider.of<NavigationController>(context, listen: false).notifyListeners();
  }

  /// Methods of the Stats Controller
  static StatsController getStatsController(BuildContext context) {
    return Provider.of<StatsController>(context, listen: false);
  }

  static Map<String, int> getWeekdayCompletion(BuildContext context) {
    return getStatsController(context).weekdayCompletion;
  }

  static void setLifetimeStats(BuildContext context) async {
    LifetimeStats stats = await readHiveLifetimeStats();
    getStatsController(context).updateLifetimeStats(stats);
  }

  /// Methods of the Color Controller
  static ColorScheme getCurrentColor(BuildContext context) {
    final colorController = Provider.of<AppColorController>(context, listen: false);
    return colorController.currentColorScheme;
  }

  static String getCurrentColorScheme(BuildContext context) {
    final colorController = Provider.of<AppColorController>(context, listen: false);
    return colorController.currentColorKey;
  }

  static List<String> getAvailableColorSchemes(BuildContext context) {
    final colorController = Provider.of<AppColorController>(context, listen: false);
    return colorController.availableSchemes;
  }

  static Future<void> setColorScheme(BuildContext context, String colorKey) async {
    final colorController = Provider.of<AppColorController>(context, listen: false);
    await Future.delayed(Duration.zero);
    colorController.setColorScheme(colorKey);
  }

  static ColorScheme getColorSchemeByKey(BuildContext context, String key) {
    final colorController = Provider.of<AppColorController>(context, listen: false);
    return colorController.colorSchemeByKey(key);
  }

  static Future<void> setCustomColor(BuildContext context, Color c) async {
      final colorController = Provider.of<AppColorController>(context, listen: false);
      await Future.delayed(Duration.zero);
      colorController.setCustomColorScheme(c);
      await writeHiveCustomColor(c);
    }

  // Model-Wrapper
  static Future<void> popMagenta(String encoded_id, String key, String checksum, BuildContext context) async{
    var result =  await Model.popMagenta(encoded_id, key, checksum);
    bool deleted = result['deleted'];
    AppData a = result['appData'];
    String language = result['language'];
    int prio = result['priority'];
    String color = result['color'];
    var stats = result['stats']; // eventuell null
    bool send_notification = result['Send_Notifications'];
    Color customColor = result['Custom_Color'];
    setAppData(context, a);
    setLanguage(context, language);
    await setColorScheme(context, color);
    setSelectedPrinciple(context, PriorityEnum.fromInt(prio));
    await setNotification(context, send_notification);
    if (color == 'customColor'){
      await setCustomColor(context, customColor);
    }
  }

  static Future<QrImageView> getQrCode() async => await Model.getQrCode();
  static Future<bool> pushMagenta() async => await Model.pushMagenta();
  static Future<void> initHive() async => await Model.initHive();
  static Future<AppData> readHiveItems() async => await Model.readHiveItems();
  static Future<void> writeHiveItems(AppData a) async => await Model.writeHiveItems(a);
  static Future<void> writeHiveItem(ListItem i) async => await Model.writeHiveItem(i);
  static Future<void> deleteHiveItem(ListItem i) async => await Model.deleteHiveItem(i);
  static Future<void> writeHiveColor(String color) async => await Model.writeHiveColor(color);
  static Future<void> writeHiveLanguage(String language) async => await Model.writeHiveLanguage(language);
  static Future<void> writeHivePriority(PriorityEnum e) async => await Model.writeHivePriority(e);
  static Future<void> writeHiveWSM(int a, int b, int c) async => await Model.writeHiveWSM(a, b, c);
  static Future<String> readHiveColor() async => await Model.readHiveColor();
  static Future<String> readHiveLanguage() async => await Model.readHiveLanguage();
  static Future<PriorityEnum> readHivePriority() async => await Model.readHivePriority();
  static Future<List<int>> readHiveWSM() async => await Model.readHiveWSM();
  static Future<void> writeHiveCustomColor(Color color) async => await Model.writeCustomColor(color);
  static Future<Color?> readHiveCustomColor() async => await Model.readCustomColor();
  static Future<bool> readHiveNotification() async => await Model.readHiveNotification();
  static Future<void> writeHiveNotification(bool a) async => await Model.writeHiveNotification(a);
  static Future<void> writeHiveLifetimeStats(LifetimeStats stats) async => await Model.writeHiveLifetimeStats(stats);
  static Future<LifetimeStats> readHiveLifetimeStats() async => await Model.readHiveLifetimeStats();

}
