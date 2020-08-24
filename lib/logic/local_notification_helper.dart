import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pebbl/view/dashboard_screen.dart';

class LocalNotificationHelper {
  BuildContext _context;
  LocalNotificationHelper();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future sendNotification(String title, String body, {Duration scheduleFromNow}) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pebbl', 'Pebbl timer', 'Notifications for the pebbl pomodoro timer!',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    if (scheduleFromNow != null) {
      final scheduledNotificationDateTime = DateTime.now().add(scheduleFromNow);
      await flutterLocalNotificationsPlugin.schedule(
          0, title, body, scheduledNotificationDateTime, platformChannelSpecifics);
    } else {
      await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
    }
  }

  void cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  initLocalNotifications(BuildContext context) {
    _context = context;
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    final initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => DashboardScreen()),
    // );
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
