import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:pebbl/logic/local_storage.dart';
import 'package:pebbl/logic/path_helper.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/stem.dart';
import 'package:rxdart/rxdart.dart';

class DownloadedSet {
  final String setId;
  final List<Stem> downloadedStems;
  DownloadedSet({this.setId, this.downloadedStems});

  Map toJson() {
    return {'setId': setId, 'downloadedStems': downloadedStems.map((e) => e.toJson()).toList()};
  }

  static DownloadedSet fromJson(Map data) {
    return DownloadedSet(setId: data['setId'], downloadedStems: Stem.fromJsonList(data['downloadedStems']));
  }

  String toJsonString() {
    final json = toJson();
    return jsonEncode(json);
  }

  static DownloadedSet fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return fromJson(json);
  }

  bool get isFullyDownloaded {
    final count = downloadedStems.length;
    final downloadedCount = downloadedStems.where((s) => s.filePath != null)?.length ?? 0;
    return count == downloadedCount;
  }
}

class DownloadManager {
  bool isInitialized = false;
  List<DownloadedSet> downloadedSets;
  String _downloadPath;

  Future init() async {
    await FlutterDownloader.initialize(debug: false);
    _downloadPath = await PathHelper.createFolderIfNotExist('Download');

    final savedDir = Directory(_downloadPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    this.isInitialized = true;
  }

  //check downloaded files
  Future loadDownloadedSets(List<AudioSet> sets) async {
    downloadedSets = [];
    for (var audioSet in sets) {
      final jsonString = await LocalStorage.getString(audioSet.id);
      if (jsonString != null) {
        final downloadedSet = DownloadedSet.fromJsonString(jsonString);
        downloadedSet.downloadedStems.forEach((element) {
          print(element.filePath);
        });
        downloadedSets.add(downloadedSet);
        _continueDownload(downloadedSet);
        audioSet.downloadedSet = downloadedSet;
      }
    }
  }

  void _continueDownload(DownloadedSet downloadedSet) {
    if (!downloadedSet.isFullyDownloaded) {
      AudioSetDownloadTask(downloadedSet, _downloadPath)..startDownload();
    }
  }
  //TODO: check if device has enough storage

  //setup audiosets with downloaded data

  //download a new set
  AudioSetDownloadTask downloadSet(AudioSet audioSet) {
    DownloadedSet downloadedSet = audioSet.downloadedSet ??
        DownloadedSet(
          setId: audioSet.id,
          downloadedStems: audioSet.stems.map((s) => s.copyWith()).toList(),
        );

    final task = AudioSetDownloadTask(
        downloadedSet, _downloadPath + '${Platform.pathSeparator}${downloadedSet.setId}');
    task.startDownload();
    return task;
  }
  //update on percentage

}

class AudioSetDownloadTask {
  static FirebaseStorage storage = FirebaseStorage();
  final DownloadedSet downloadedSet;
  final String path;
  Function onComplete;
  int _completedCount = 0;
  ReceivePort _port = ReceivePort();

  Map<String, int> progressMap = {};

  final BehaviorSubject<double> downloadProgressSubject = BehaviorSubject.seeded(0);
  ValueStream<double> get downloadProgressStream => downloadProgressSubject.stream;

  AudioSetDownloadTask(this.downloadedSet, this.path);

  Future startDownload() async {
    //check if folder exists if not create it
    await PathHelper.createFolderIfNotExist('Download' + Platform.pathSeparator + downloadedSet.setId);

    _setupProgressListener();
    for (var stem in downloadedSet.downloadedStems) {
      //check if download already started
      if (stem.downloadTaskId != null && stem.filePath == null) {
        stem.downloadTaskId = await FlutterDownloader.resume(taskId: stem.downloadTaskId);
      } else {
        //create a new download task and update download set
        stem.downloadTaskId = await _enqueueDownload(await _getDownloadUrl(stem), stem.id);
      }
      await _updateDownloadedSetLocalStorage();
    }
  }

  void _setupProgressListener() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      _calculateProgress(data[0], data[2]);
      _handleComplete(data[0], data[1]);
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _handleComplete(String id, DownloadTaskStatus status) async {
    if (status.value == DownloadTaskStatus.complete.value) {
      _completedCount += 1;
      print('completed download $_completedCount');
      final stem = downloadedSet.downloadedStems.where((e) => e.downloadTaskId == id).first;
      stem.filePath =
          'Download${Platform.pathSeparator}${downloadedSet.setId}${Platform.pathSeparator}${stem.id}';
      print(stem.filePath);
      await _updateDownloadedSetLocalStorage();
      if (onComplete != null && _completedCount == downloadedSet.downloadedStems.length) onComplete();
    }
  }

  void _calculateProgress(String id, int progress) {
    progressMap[id] = progress;
    int total = 0;
    progressMap.forEach((key, value) {
      total += value;
    });
    var stemDonwloadProgress =
        total / downloadedSet.downloadedStems.length; //devide by total to stay between 0 and 100
    print('Progress $stemDonwloadProgress');
    downloadProgressSubject.add(stemDonwloadProgress);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future _updateDownloadedSetLocalStorage() async {
    final jsonString = downloadedSet.toJsonString();
    await LocalStorage.setString(downloadedSet.setId, jsonString);
  }

  Future<String> _getDownloadUrl(Stem stem) async {
    final ref = await storage.getReferenceFromUrl(stem.downloadUrl);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _enqueueDownload(String url, String fileName) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: fileName,
      savedDir: path,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );
    return taskId;
  }
}
