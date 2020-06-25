import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'dart:math';

import 'package:pebbl/presenter/sets_presenter.dart';

class SoundscapeManager {
  SoundscapeManager({@required this.audioSets, @required this.presenter}) {
    activeSet = addSetToQueue(audioSets.first);
  }
  final SetsPresenter presenter;
  final List<AudioSet> audioSets;
  List<AudioSet> playQueue = [];
  final Random random = Random();
  AudioSet activeSet;

  Function(String) _listener;

  void play() async {
    presenter.setActiveSet(activeSet);
    presenter.playActiveSet();
  }

  //handles state changes from the method channel
  void notifyPlayerStateChange(String state) {
    if (state == 'completed') {
      queueNextSet();
      play();
    }
    if (_listener != null) {
      _listener(state);
    }
    print(state);
  }

  void setStateListener(Function(String) listener) {
    _listener = listener;
  }

  void removeStateListener() {
    _listener = null;
  }

  AudioSet addSetToQueue(AudioSet audioSet) {
    final newSet = audioSet.copyWith();
    playQueue.add(newSet);
    return newSet;
  }

  void queueNextSet() {
    // only one set active so we cant randomize
    if (audioSets.length == 1) {
      addSetToQueue(audioSets.first);
      return;
    }
    //get random set except the previous one
    final potententials = audioSets.where((e) => e.id != activeSet.id).toList();
    int randomNumber = random.nextInt(potententials.length);
    addSetToQueue(potententials[randomNumber]);
  }
}
