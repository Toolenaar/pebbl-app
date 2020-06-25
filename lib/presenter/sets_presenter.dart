import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/download_manager.dart';
import 'package:pebbl/logic/local_storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/model/services/audio_service.dart';
import 'package:pebbl/model/services/category_service.dart';
import 'package:pebbl/plugin/audio_plugin.dart';
import 'package:pebbl/presenter/soundscape_manager.dart';

class SetsPresenter with ChangeNotifier {
  static AudioService _service = AudioService();
  static CategoryService _categoryService = CategoryService();
  static AudioPlugin _plugin = AudioPlugin();
  static DownloadManager _downloadManager = DownloadManager();

  CategoryColorTheme get activeColorTheme => activeSet?.category?.colorTheme ?? AppColors.colorTheme;

  SoundscapeManager soundscapeManager;
  AudioSet activeSet;
  List<AudioSet> loadedSets;
  List<GroupedByCategory> setCategories = [];
  List<Category> _categories = [];
  StreamSubscription<List<AudioSet>> setsSubscription;
  bool get isInitialized {
    return _downloadManager.isInitialized && setCategories.length > 0;
  }

  Map<String, double> currentDownloadProgress = {};

  bool isPlaying = false;

  void init() async {
    if (isInitialized) return;
    _categories = await _categoryService.fetchCategories();
    fetchSets();
    await _downloadManager.init();
    _plugin.initEventChannel(_audioPlayerStateChanged, _audioPlayerStateError);
    notifyListeners();
  }

  @override
  void dispose() {
    setsSubscription.cancel();
    super.dispose();
  }

  void _audioPlayerStateChanged(Object object) {
  
    if (soundscapeManager != null) {
      soundscapeManager.notifyPlayerStateChange(object);
    }
  }

  void _audioPlayerStateError(Object object) {
    print(object);
  }

  void setActiveSet(AudioSet audioSet) {
    activeSet = audioSet;

    notifyListeners();
  }

  void setSoundscapeManager() {
    final setsInCategory = loadedSets.where((e) => e.categoryId == activeSet.categoryId).toList();
    soundscapeManager = SoundscapeManager(audioSets: setsInCategory,presenter: this);
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
      //for each set pair a category
      _attachCategory();
      //categories grouped
      setCategories = GroupedByCategory.fromAudioSetList(sets);
      if (activeSet == null) {
        activeSet = setCategories.first.sets.first;
        setSoundscapeManager();
      }
      await _loadDownloadedSets();
    });
  }

  void _attachCategory() {
    for (var audioSet in loadedSets) {
      final cat = _categories.where((c) => c.id == audioSet.categoryId);
      if (cat.isNotEmpty) {
        audioSet.category = cat.first;
      }
    }
  }

  Future downloadSet(AudioSet audioSet) async {
    try {
      AudioSetDownloadTask task = await _downloadManager.downloadSet(audioSet);
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
    } catch (e) {
      print(e);
    }
  }
}
