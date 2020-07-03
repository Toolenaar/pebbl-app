import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'dart:math';

import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:rxdart/rxdart.dart';

class SoundscapeManager {
  SoundscapeManager({@required this.presenter});

  final SetsPresenter presenter;
  List<AudioSet> playQueue = [];
  final Random random = Random();

  final BehaviorSubject<AudioSet> activeSetSubject = BehaviorSubject.seeded(null);
  ValueStream<AudioSet> get activeSetStream => activeSetSubject.stream;

  int _activeIndex = 0;

  Function(String) _listener;

  void play() async {
    presenter.setActiveSet(activeSetSubject.value);
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

  void playNext({bool firstPlay = false}) {
    //if last queue next track
    // else just play next
    if (!firstPlay) _activeIndex += 1;
    if (_activeIndex == playQueue.length) {
      queueNextSet();
    }
    activeSetSubject.add(playQueue[_activeIndex]);

    play();
  }

  void playPrevious() {
    _activeIndex -= 1;
    if (_activeIndex == -1) return;
    activeSetSubject.add(playQueue[_activeIndex]);
    play();
  }

  void queueNextSet() {
    // only one set active so we cant randomize
    final sets = presenter.setsInCategory;
    if (sets.length == 1) {
      addSetToQueue(sets.first);
      return;
    }
    //get random set except the previous one
    final potententials = sets.where((e) => e.id != activeSetSubject.value.id).toList();
    int randomNumber = random.nextInt(potententials.length);
    addSetToQueue(potententials[randomNumber]);
  }

  void dispose() {
    removeStateListener();
    _activeIndex = 0;
    playQueue = [];
  }
}
