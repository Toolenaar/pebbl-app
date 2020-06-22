import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebbl/logic/app_initializer.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/dashboard_screen.dart';

import 'package:provider/provider.dart';

import 'view/registration/login_start_screen.dart';

void main() {
  runApp(PebblApp());
}

class PebblApp extends StatefulWidget {
  PebblApp({Key key}) : super(key: key);

  @override
  _PebblAppState createState() => _PebblAppState();
}

class _PebblAppState extends State<PebblApp> {
  static UserPresenter _userPresenter = UserPresenter();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

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
          home: AppInitializer(
            homePage: DashboardScreen(),
            loginPage: LoginStartScreen(),
          )),
    );
  }
}

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   FirebaseAnalytics analytics = FirebaseAnalytics();
//   AudioPlugin _plugin = AudioPlugin();
//   //"test_1_0Core.mp3","test_1_1low.mp3","test_1_3blink.mp3","test_1_4birds.mp3","test_1_paars.mp3"
//   AudioSet _testSet = AudioSet(stems: [
//     Stem(filePath: 'test_1_0Core.mp3', name: 'Core'),
//     Stem(filePath: 'test_1_1low.mp3', name: 'Low'),
//     Stem(filePath: 'test_1_3blink.mp3', name: 'Blink'),
//     Stem(filePath: 'test_1_4birds.mp3', name: 'Birds'),
//     Stem(filePath: 'test_1_paars.mp3', name: 'Paars')
//   ]);
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _play() async {
//     var result = await _plugin.initSet('test');
//     if (result) {
//       _isPlaying = await _plugin.playSet('test');
//     } else {
//       print('Error initializing set');
//     }
//     setState(() {});
//   }

//   void _pause() async {
//     _isPlaying = !await _plugin.pauseSet('pause');
//     setState(() {});
//   }

//   List<Widget> _createVolumeSliders() {
//     if (!_isPlaying) return [SizedBox()];
//     var volumes = List<Widget>.from(
//       _testSet.stems.map(
//         (stem) => VolumeSlider(
//           stem: stem,
//           volumeChanged: (value) => _changeVolume(stem, value),
//         ),
//       ),
//     );
//     return volumes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorObservers: [
//         FirebaseAnalyticsObserver(analytics: analytics),
//       ],
//       home: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           backgroundColor: AppColors.background,
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: ListView(
//               children: <Widget>[
//                 RaisedButton(
//                   child: Text(_isPlaying ? 'Pause Audio' : 'Play Audio'),
//                   onPressed: _isPlaying ? _pause : _play,
//                 ),
//                 const SizedBox(height: 24),
//                 // VolumeSlider(stem: Stem(fileName: 'Test',name: 'Test'),),
//                 ..._createVolumeSliders()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _changeVolume(Stem stem, double volume) async {
//     _plugin.changeStemVolume(stem.filePath, volume);
//     stem.volume = volume;
//     setState(() {});
//   }
// }
