import 'package:flutter/cupertino.dart';
import 'package:todo_appdev/Model/list_item.dart';
import 'app_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_appdev/Controller/controller.dart';

Future<void> callbackDispatcher(AppData a) async{
  WidgetsFlutterBinding.ensureInitialized();

  List<ListItem> tasks = a.unchecked.l;
  DateTime now = DateTime.now();

  List<String> expired = [];
  List<String> expiring = [];
  List<String> tight = [];

  for (ListItem task in tasks) {
    if (!task.isChecked) {
      Duration difference = task.getExpirationDate.difference(now);
      DateTime taskDate = DateTime(
          task.getExpirationDate.year,
          task.getExpirationDate.month,
          task.getExpirationDate.day);
      DateTime today = DateTime(now.year, now.month, now.day);

      if (taskDate == today) {
        expiring.add(task.title);
      }
      else if (difference.inMinutes < 0) {
        expired.add(task.title);
      }
      else if (difference.inMinutes < (task.getDurationTimeInHours *60)) {
        tight.add(task.title);
      }
    }
  }

  //send push if some list is not empty
  if (!(expired.isEmpty && expiring.isEmpty && tight.isEmpty)) {
    StringBuffer buffer1 = StringBuffer();
    StringBuffer buffer2 = StringBuffer();
    StringBuffer buffer3 = StringBuffer();
    String titel1 = "";
    String titel2 = "";
    String titel3 = "";

    if (expired.isNotEmpty) {
      if (expired.length > 1) {
        titel1 = "❌ ${expired.length} " + Controller.getTextLabel('push_exp_m');
      }
      else {
        titel1 = "❌ ${expired.length} " + Controller.getTextLabel('push_exp_s');
      }
      for (String t in expired) {
        buffer1.writeln("• $t");
      }
    }

    if (expiring.isNotEmpty) {
      if (expiring.length > 1) {
        titel2 = "⚠ ${expiring.length} " + Controller.getTextLabel('push_exp_t_m');
      }
      else {
        titel2 = "⚠ ${expiring.length} " + Controller.getTextLabel('push_exp_t_s');
      }
      for (String t in expiring) {
        buffer2.writeln("• $t");
      }
    }

    if (tight.isNotEmpty) {
      if (tight.length > 1) {
        titel3 = "🕒 ${tight.length} " + Controller.getTextLabel('push_tight_m');
      }
      else {
        titel3 = "🕒 ${tight.length} " + Controller.getTextLabel('push_tight_s');
      }

      for (String t in tight) {
        buffer3.writeln("• $t");
      }
    }

    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(initSettings);

    // Expired tasks notification with BigTextStyle
    if (buffer1.isNotEmpty) {
      final AndroidNotificationDetails expiredDetails = AndroidNotificationDetails(
        'todo_channel_expired',
        'Todo Abgelaufene Aufgaben',
        icon: 'android_chrome_192x192',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          buffer1.toString().trim(),
          htmlFormatBigText: false,
          contentTitle: titel1,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        ),
      );

      final NotificationDetails expiredNotificationDetails = NotificationDetails(
          android: expiredDetails
      );

      await notificationsPlugin.show(
        0,
        titel1,
        buffer1.toString().trim(),
        expiredNotificationDetails,
      );
    }

    // Expiring today tasks notification with BigTextStyle
    if (buffer2.isNotEmpty) {
      final AndroidNotificationDetails expiringDetails = AndroidNotificationDetails(
        'todo_channel_expiring',
        'Todo Heute Ablaufende Aufgaben',
        icon: 'android_chrome_192x192',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          buffer2.toString().trim(),
          htmlFormatBigText: false,
          contentTitle: titel2,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        ),
      );

      final NotificationDetails expiringNotificationDetails = NotificationDetails(
          android: expiringDetails
      );

      await notificationsPlugin.show(
        1,
        titel2,
        buffer2.toString().trim(),
        expiringNotificationDetails,
      );
    }

    // Tight deadline tasks notification with BigTextStyle
    if (buffer3.isNotEmpty) {
      final AndroidNotificationDetails tightDetails = AndroidNotificationDetails(
        'todo_channel_tight',
        'Todo Knappe Deadlines',
        icon: 'android_chrome_192x192',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          buffer3.toString().trim(),
          htmlFormatBigText: false,
          contentTitle: titel3,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        ),
      );

      final NotificationDetails tightNotificationDetails = NotificationDetails(
          android: tightDetails
      );

      await notificationsPlugin.show(
        2,
        titel3,
        buffer3.toString().trim(),
        tightNotificationDetails,
      );
    }
    //print("notification was sent.");
  }

  return Future.value(true);
}