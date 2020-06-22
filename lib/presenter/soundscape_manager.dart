import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'dart:math';

class SoundscapeManager {
  SoundscapeManager({@required this.audioSets}) {
    activeSet = addSetToQueue(audioSets.first);
  }

  final List<AudioSet> audioSets;
  List<AudioSet> playQueue = [];
  final Random random = Random();
  AudioSet activeSet;

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
