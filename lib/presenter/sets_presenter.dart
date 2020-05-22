import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
class SetsPresenter with ChangeNotifier{
  List<SetCategory> get setCategories {
    return SetCategory.fromAudioSetList(AudioSet.dummySets());
  }
}
