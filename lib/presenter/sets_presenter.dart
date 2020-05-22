import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';

class SetsPresenter with ChangeNotifier {
  AudioSet activeSet;
  List<SetCategory> setCategories;

  void init() {
    setCategories = SetCategory.fromAudioSetList(AudioSet.dummySets());
    activeSet = setCategories.first.sets.first;
    notifyListeners();
  }

  void setActiveSet(AudioSet audioSet) {
    activeSet = audioSet;
    notifyListeners();
  }
}
