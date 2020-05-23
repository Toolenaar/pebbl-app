import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/plugin/audio_plugin.dart';

class SetsPresenter with ChangeNotifier {
  static AudioPlugin _plugin = AudioPlugin();
  AudioSet activeSet;
  List<SetCategory> setCategories;

  bool isPlaying = false;

  void init() {
    setCategories = SetCategory.fromAudioSetList(AudioSet.dummySets());
    activeSet = setCategories.first.sets.first;
    
  }

  void setActiveSet(AudioSet audioSet) {
    activeSet = audioSet;
    notifyListeners();
  }

  void changeStemVolume(String fileName, double volume) {
    _plugin.changeStemVolume(fileName, volume);
  }

  void playActiveSet() async {
    var result = await _plugin.initSet(activeSet.fileName);
    if (result) {
      isPlaying = await _plugin.playSet(activeSet.fileName);
    } else {
      print('Error initializing set');
    }
    notifyListeners();
  }

  void stopActiveSet() async {
    isPlaying = !await _plugin.pauseSet(activeSet.fileName);
    notifyListeners();
  }
}
