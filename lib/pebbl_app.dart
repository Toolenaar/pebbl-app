import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebbl/logic/app_initializer.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:pebbl/view/registration/login_start_screen.dart';
import 'package:provider/provider.dart';

import 'presenter/timer_presenter.dart';

class PebblApp extends StatefulWidget {
  PebblApp({Key key}) : super(key: key);

  @override
  _PebblAppState createState() => _PebblAppState();
}

class _PebblAppState extends State<PebblApp> {
  static UserPresenter _userPresenter = UserPresenter();
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  LocalNotificationHelper _notificationHelper;

  @override
  void initState() {
    _userPresenter.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SetsPresenter(),
        ),
        Provider(
          create: (context) => _userPresenter,
        ),
        Provider(
          create: (context) => AudioController(),
        ),
        Provider(
          create: (context) => TimerPresenter(),
        ),
        Provider(create: (context) => _notificationHelper = LocalNotificationHelper())
      ],
      child: MaterialApp(
        theme: ThemeData(
          accentColor: AppColors.text,
          textTheme: GoogleFonts.karlaTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: AudioServiceWidget(
          child: AppInitializer(
            homePage: DashboardScreen(),
            loginPage: LoginStartScreen(),
          ),
        ),
      ),
    );
  }
}
