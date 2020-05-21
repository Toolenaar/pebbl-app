import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/colors.dart';

import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/stem.dart';
import 'package:pebbl/plugin/audio_plugin.dart';
import 'package:pebbl/view/volume_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  AudioPlugin _plugin = AudioPlugin();
  //"test_1_0Core.mp3","test_1_1low.mp3","test_1_3blink.mp3","test_1_4birds.mp3","test_1_paars.mp3"
  AudioSet _testSet = AudioSet(stems: [
    Stem(fileName: 'test_1_0Core.mp3', name: 'Core'),
    Stem(fileName: 'test_1_1low.mp3', name: 'Low'),
    Stem(fileName: 'test_1_3blink.mp3', name: 'Blink'),
    Stem(fileName: 'test_1_4birds.mp3', name: 'Birds'),
    Stem(fileName: 'test_1_paars.mp3', name: 'Paars')
  ]);
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  void _play() async {
    var result = await _plugin.initSet('test');
    if (result) {
      _isPlaying = await _plugin.playSet('test');
    } else {
      print('Error initializing set');
    }
    setState(() {});
  }

  void _pause() async {
    _isPlaying = !await _plugin.pauseSet('pause');
    setState(() {});
  }

  List<Widget> _createVolumeSliders() {
    if (!_isPlaying) return [SizedBox()];
    var volumes = List<Widget>.from(
      _testSet.stems.map(
        (stem) => VolumeSlider(
          stem: stem,
          volumeChanged: (value) => _changeVolume(stem, value),
        ),
      ),
    );
    return volumes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                RaisedButton(
                  child: Text(_isPlaying ? 'Pause Audio' : 'Play Audio'),
                  onPressed: _isPlaying ? _pause : _play,
                ),
                const SizedBox(height:24),
               // VolumeSlider(stem: Stem(fileName: 'Test',name: 'Test'),),
                ..._createVolumeSliders()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeVolume(Stem stem, double volume) async {
    _plugin.changeStemVolume(stem.fileName, volume);
    stem.volume = volume;
    setState(() {});
  }
}
