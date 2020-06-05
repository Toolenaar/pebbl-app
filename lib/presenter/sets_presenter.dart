import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebbl/logic/download_manager.dart';
import 'package:pebbl/logic/local_storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/audio_service.dart';
import 'package:pebbl/plugin/audio_plugin.dart';

class SetsPresenter with ChangeNotifier {
  static AudioService _service = AudioService();
  static AudioPlugin _plugin = AudioPlugin();
  static DownloadManager _downloadManager = DownloadManager();
  AudioSet activeSet;
  List<AudioSet> loadedSets;
  List<SetCategory> setCategories = [];
  StreamSubscription<List<AudioSet>> setsSubscription;
  bool get isInitialized {
    return _downloadManager.isInitialized && setCategories.length > 0;
  }

  Map<String, double> currentDownloadProgress = {};

  bool isPlaying = false;

  void init() async {
    fetchSets();
    await _downloadManager.init();
    notifyListeners();
  }

  @override
  void dispose() {
    setsSubscription.cancel();
    super.dispose();
  }

  void setActiveSet(AudioSet audioSet) {
    activeSet = audioSet;
    notifyListeners();
  }

  void changeStemVolume(String fileName, double volume) {
    //get downloaded stem

    _plugin.changeStemVolume(fileName, volume);
  }

  void playActiveSet() async {
    var result = await _plugin.initSet(activeSet.fileName, activeSet.downloadedStemPaths);
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

  Future _loadDownloadedSets() async {
    await _downloadManager.loadDownloadedSets(loadedSets);
    notifyListeners();
  }

  fetchSets() {
    setsSubscription = _service.fetchSetsStream().listen((sets) async {
      loadedSets = sets;
      setCategories = SetCategory.fromAudioSetList(sets);
      if (activeSet == null) activeSet = setCategories.first.sets.first;
      await _loadDownloadedSets();
    });
  }

  void downloadSet(AudioSet audioSet) async {
    AudioSetDownloadTask task = _downloadManager.downloadSet(audioSet);
    StreamSubscription<double> downloadSub;

    task.onComplete = () async {
      audioSet.downloadedSet = DownloadedSet.fromJsonString(await LocalStorage.getString(audioSet.id));
      currentDownloadProgress[audioSet.id] = null;
      currentDownloadProgress = Map.from(currentDownloadProgress); //create a new to trigger listeners
      downloadSub.cancel();
      notifyListeners();
    };

    downloadSub = task.downloadProgressStream.listen((event) {
      currentDownloadProgress[audioSet.id] = event;
      currentDownloadProgress = Map.from(currentDownloadProgress); //create a new to trigger listeners
      notifyListeners();
    });
    //remove the download task
  }
}
