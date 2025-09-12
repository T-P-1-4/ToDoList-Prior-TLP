import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todo_appdev/Controller/colors.dart';
import 'package:todo_appdev/Controller/controller.dart';
import 'package:todo_appdev/Controller/principle_controller.dart';
import 'package:todo_appdev/Model/app_data.dart';
import 'package:todo_appdev/Model/lifetime_stats.dart';
import 'package:todo_appdev/Model/priority_enum.dart';
import 'Controller/list_item_controller.dart';
import 'Controller/navigation_controller.dart';
import 'Controller/stats_controller.dart';
import 'Model/item_list.dart';
import 'View/view.dart';
import 'package:flutter/services.dart';
import 'Model/background_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nur Hochkant-Ansicht erlauben
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();
  await Controller.initHive();
  await Controller.loadLanguageFile(); // Sprachdaten laden

  // Hive Werte initial holen
  final colorFromHive = await Controller.readHiveColor();
  final customColor = await Controller.readHiveCustomColor();
  final langFromHive = await Controller.readHiveLanguage();
  final prioFromHive = await Controller.readHivePriority();
  final itemsFromHive = await Controller.readHiveItems();
  final notificationFromHive = await Controller.readHiveNotification();
  final lifetimeStats = await Controller.readHiveLifetimeStats();

  await requestNotificationPermissionOnce();

  Controller.setLanguageAtAppStart(langFromHive);

  if (notificationFromHive) {
    await callbackDispatcher(itemsFromHive); // send notifications at app start
    Controller.setNotificationAtAppStart(notificationFromHive);
  }

  runApp(TodoApp(
    initialColor: colorFromHive,
    initialPriority: prioFromHive,
    initialItems: itemsFromHive,
    initialCustomColor: customColor,
    initialLifetimeStats: lifetimeStats,
  ));
}

Future<void> requestNotificationPermissionOnce() async {
  final prefs = await SharedPreferences.getInstance();
  final alreadyAsked = prefs.getBool('notification_permission_asked') ?? false;

  if (!alreadyAsked) {
    await Permission.notification.request(); // systemeigene Abfrage
    await prefs.setBool('notification_permission_asked', true);
  }
  if ( await Permission.notification.isGranted){
    Controller.setNotificationAtAppStart(true);
  }
}


class TodoApp extends StatelessWidget {
  final String initialColor;
  final PriorityEnum initialPriority;
  final AppData initialItems;
  final Color? initialCustomColor;
  final LifetimeStats initialLifetimeStats;


  TodoApp({
    super.key,
    required this.initialColor,
    required this.initialPriority,
    required this.initialItems,
    required this.initialCustomColor,
    required this.initialLifetimeStats,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final nav = NavigationController();
          return nav;
        }),
        ChangeNotifierProvider(create: (_) {
          final color = AppColorController();

          final custom = initialCustomColor;
          if (custom != null) {
            color.setCustomColorScheme(custom, markAsSelected: false);
          }

          if (initialColor == 'customColor') {
            color.setCustomColorScheme(initialCustomColor ?? Colors.lightBlue, markAsSelected: false);
          } else {
            color.setColorScheme(initialColor);
          }

          return color;
        }),
        ChangeNotifierProvider(create: (_) {
          final principle = PrincipleController();
          principle.setSelected(initialPriority);
          return principle;
        }),
        ChangeNotifierProvider<ItemList>.value(value: initialItems.unchecked),
        ChangeNotifierProvider(create: (_) {
          final listItemController = ListItemController(initialItems.unchecked);
          return listItemController;
        }),
        ChangeNotifierProvider(create: (_) {
          final appData = AppData();
          appData.setList(initialItems.checked, initialItems.unchecked);
          return appData;
        }),
        ChangeNotifierProvider(create: (_) {
          final statsController = StatsController();
          statsController.updateLifetimeStats(initialLifetimeStats);
          return statsController;
        }),
      ],
      child: const MyAppWrapper(),
    );
  }
}

class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorController = Provider.of<AppColorController>(context, listen: false);
      if (colorController.currentColorKey == 'customColor' && colorController.getCustomColor() != null) {
        Controller.setCustomColor(context, colorController.getCustomColor()!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorController = Provider.of<AppColorController>(context);

    return MaterialApp(
      title: Controller.getTextLabel('App_Name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorController.currentColorScheme,
      ),
      home: const MainPage(),
    );
  }
}

