import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/download_manager.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/model/services/audio_service.dart';
import 'package:pebbl/model/services/category_service.dart';

class SetsPresenter with ChangeNotifier {
  static AudioService _service = AudioService();
  static CategoryService _categoryService = CategoryService();
  // static DownloadManager _downloadManager = DownloadManager();

  CategoryColorTheme activeColorTheme;
  Category activeCategory;
  AudioSet activeSet;
  List<AudioSet> loadedSets;
  List<GroupedByCategory> setCategories = [];
  List<Category> _categories = [];
  StreamSubscription<List<AudioSet>> setsSubscription;
  bool isInitialized = false;

  List<AudioSet> get setsInCategory {
    if (activeSet == null) return [];
    return loadedSets.where((e) => e.categoryId == activeSet.categoryId).toList();
  }

  Map<String, double> currentDownloadProgress = {};

  bool isPlaying = false;

  void init() async {
    if (isInitialized) return;
    activeColorTheme = AppColors.colorTheme;
    _categories = await _categoryService.fetchCategories();
    fetchSets();
    // await _downloadManager.init();

    notifyListeners();
  }

  @override
  void dispose() {
    setsSubscription.cancel();
    super.dispose();
  }

  void setActiveCategory(Category category) {
    activeCategory = category;
    activeColorTheme = category.colorTheme;
    notifyListeners();
  }
  // Future _loadDownloadedSets() async {
  //   await _downloadManager.loadDownloadedSets(loadedSets);
  //   notifyListeners();
  // }

  fetchSets() {
    setsSubscription = _service.fetchSetsStream().listen((sets) async {
      loadedSets = sets;
      //for each set pair a category
      _attachCategory();
      //categories grouped
      setCategories = GroupedByCategory.fromAudioSetList(sets);
      isInitialized = setCategories.length > 0;
      notifyListeners();
      //await _loadDownloadedSets();
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

  // Future downloadSet(AudioSet audioSet) async {
  //   try {
  //     AudioSetDownloadTask task = await _downloadManager.downloadSet(audioSet);
  //     StreamSubscription<double> downloadSub;

  //     task.onComplete = () async {
  //       audioSet.downloadedSet = DownloadedSet.fromJsonString(await LocalStorage.getString(audioSet.id));
  //       currentDownloadProgress[audioSet.id] = null;
  //       currentDownloadProgress = Map.from(currentDownloadProgress); //create a new to trigger listeners
  //       downloadSub.cancel();
  //       notifyListeners();
  //     };

  //     downloadSub = task.downloadProgressStream.listen((event) {
  //       currentDownloadProgress[audioSet.id] = event;
  //       currentDownloadProgress = Map.from(currentDownloadProgress); //create a new to trigger listeners
  //       notifyListeners();
  //     });
  //     //remove the download task
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
