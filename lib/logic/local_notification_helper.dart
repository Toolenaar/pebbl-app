import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationHelper {
  BuildContext _context;
  LocalNotificationHelper();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future sendNotification(String title, String body, {Duration scheduleFromNow}) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pomfi', 'Pomfi timer', 'Notifications for the pebbl pomodoro timer!',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker', playSound: true);
    final iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: true, presentAlert: true);
    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    if (scheduleFromNow != null) {
      // final scheduledNotificationDateTime = DateTime.now().toUtc().add(scheduleFromNow);
      final scheduledNotificationDateTime = tz.TZDateTime.now(tz.local).add(scheduleFromNow);
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0, title, body, scheduledNotificationDateTime, platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
    }
  }

  void cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  initLocalNotifications(BuildContext context) async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    _context = context;
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    final initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

    showDialog(
      context: _context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SecondScreen(payload),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }
}
