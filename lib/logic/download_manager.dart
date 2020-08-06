// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:pebbl/logic/local_storage.dart';
// import 'package:pebbl/logic/path_helper.dart';

// import 'package:pebbl/model/audio_set.dart';
// import 'package:pebbl/model/stem.dart';
// import 'package:rxdart/rxdart.dart';

// class DownloadedSet {
//   final String setId;
//   final List<Stem> downloadedStems;
//   DownloadedSet({this.setId, this.downloadedStems});

//   Map toJson() {
//     return {'setId': setId, 'downloadedStems': downloadedStems.map((e) => e.toJson()).toList()};
//   }

//   static DownloadedSet fromJson(Map data) {
//     return DownloadedSet(setId: data['setId'], downloadedStems: Stem.fromJsonList(data['downloadedStems']));
//   }

//   DownloadedSet copyWith() {
//     return DownloadedSet(setId: setId, downloadedStems: downloadedStems.map((e) => e.copyWith()).toList());
//   }

//   String toJsonString() {
//     final json = toJson();
//     return jsonEncode(json);
//   }

//   static DownloadedSet fromJsonString(String jsonString) {
//     final json = jsonDecode(jsonString);
//     return fromJson(json);
//   }

//   bool get isFullyDownloaded {
//     final count = downloadedStems.length;
//     final downloadedCount = downloadedStems.where((s) => s.filePath != null)?.length ?? 0;
//     return count == downloadedCount;
//   }
// }

// class DownloadManager {
//   ReceivePort _port = ReceivePort();
//   bool isInitialized = false;
//   List<DownloadedSet> downloadedSets;
//   List<AudioSetDownloadTask> _tasks = [];
//   String _downloadPath;
//   StreamSubscription<dynamic> _downloadSub;

//   Future init() async {
//     await FlutterDownloader.initialize(debug: false); //TODO: set false for production
//     _downloadPath = await PathHelper.createFolderIfNotExist('Download');

//     final savedDir = Directory(_downloadPath);
//     bool hasExisted = await savedDir.exists();
//     if (!hasExisted) {
//       savedDir.create();
//     }

//     this.isInitialized = true;
//   }

//   //check downloaded files
//   Future loadDownloadedSets(List<AudioSet> sets) async {
//     downloadedSets = [];
//     for (var audioSet in sets) {
//       final jsonString = await LocalStorage.getString(audioSet.id);
//       if (jsonString != null) {
//         final downloadedSet = DownloadedSet.fromJsonString(jsonString);
//         downloadedSet.downloadedStems.forEach((element) {
//           print(element.filePath);
//         });
//         downloadedSets.add(downloadedSet);
//         // _continueDownload(downloadedSet);
//         audioSet.downloadedSet = downloadedSet;
//       }
//     }
//   }

//   // void _continueDownload(DownloadedSet downloadedSet) {
//   //   if (!downloadedSet.isFullyDownloaded) {
//   //     _createTask(downloadedSet);
//   //   }
//   // }
//   //TODO: check if device has enough storage

//   //setup audiosets with downloaded data

//   //download a new set
//   Future<AudioSetDownloadTask> downloadSet(AudioSet audioSet) async {
//     DownloadedSet downloadedSet = audioSet.downloadedSet ??
//         DownloadedSet(
//           setId: audioSet.id,
//           downloadedStems: audioSet.stems.map((s) => s.copyWith()).toList(),
//         );

//     final task = await _createTask(downloadedSet);

//     return task;
//   }

//   Future<AudioSetDownloadTask> _createTask(DownloadedSet downloadedSet) async {
//     //if no taks make sure to clear pending downloads

//     _setupProgressListener();
//     var task = AudioSetDownloadTask(downloadedSet);
//     _tasks.add(task);

//     await task.startDownload();
//     return task;
//   }

//   //update on percentage
//   void _setupProgressListener() {
//     IsolateNameServer.registerPortWithName(_port.sendPort, 'download_port');
//     if (_downloadSub == null) {
//       _downloadSub = _port.listen((dynamic data) {
//         _calculateProgress(data[0], data[2]);
//         _handleComplete(data[0], data[1]);
//       });
//     }

//     FlutterDownloader.registerCallback(downloadCallback);
//   }

//   void _handleComplete(String id, DownloadTaskStatus status) async {
//     // set complete on active download
//     var _completedTask;
//     for (var task in _tasks) {
//       if (task.hasActiveTask(id)) {
//         if (status.value == DownloadTaskStatus.complete.value) {
//           bool isCompleted = await task.handleComplete(id, status);
//           if (isCompleted) _completedTask = task;
//         }
//       }
//     }
//     //remove active downloads
//     if (_completedTask != null) {
//       _tasks.remove(_completedTask);
//     }

//     // if no active downloads close port
//     if (_tasks.length == 0) {}
//   }

//   void dispose() {
//     _downloadSub.cancel();
//     _port.close();
//     IsolateNameServer.removePortNameMapping('download_port');
//   }

//   void _calculateProgress(String id, int progress) {
//     //set progress on active download
//     for (var task in _tasks) {
//       if (task.hasActiveTask(id)) {
//         task.calculateProgress(id, progress);
//       }
//     }
//   }

//   static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
//     final SendPort send = IsolateNameServer.lookupPortByName('download_port');
//     send.send([id, status, progress]);
//   }
// }

// class AudioSetDownloadTask {
//   static FirebaseStorage storage = FirebaseStorage();
//   final DownloadedSet downloadedSet;
//   String _path;
//   Function onComplete;
//   int _completedCount = 0;

//   Map<String, int> progressMap = {};

//   final BehaviorSubject<double> downloadProgressSubject = BehaviorSubject.seeded(0);
//   ValueStream<double> get downloadProgressStream => downloadProgressSubject.stream;

//   bool hasActiveTask(String taskId) {
//     for (var stem in downloadedSet.downloadedStems) {
//       if (stem.downloadTaskId == taskId) return true;
//     }
//     return false;
//   }

//   AudioSetDownloadTask(this.downloadedSet);

//   Future startDownload() async {
//     //check if folder exists if not create it
//     final pathName = 'Download' + Platform.pathSeparator + downloadedSet.setId;
//     await PathHelper.deleteFolderIfExists(pathName); //clear data first
//     _path = await PathHelper.createFolderIfNotExist(pathName);

//     for (var stem in downloadedSet.downloadedStems) {
//       //create a new download task and update download set
//       stem.downloadTaskId = await _enqueueDownload(await _getDownloadUrl(stem), stem.id);

//       await _updateDownloadedSetLocalStorage();
//     }
//   }

//   Future _updateDownloadedSetLocalStorage() async {
//     final jsonString = downloadedSet.toJsonString();
//     await LocalStorage.setString(downloadedSet.setId, jsonString);
//   }

//   Future<String> _getDownloadUrl(Stem stem) async {
//     final ref = await storage.getReferenceFromUrl(stem.downloadUrl);
//     final downloadUrl = await ref.getDownloadURL();
//     return downloadUrl;
//   }

//   Future<String> _enqueueDownload(String url, String fileName) async {
//     final taskId = await FlutterDownloader.enqueue(
//       url: url,
//       fileName: fileName,
//       savedDir: _path,
//       showNotification: true, // show download progress in status bar (for Android)
//       openFileFromNotification: false, // click on notification to open downloaded file (for Android)
//     );
//     return taskId;
//   }

//   Future<bool> handleComplete(String id, DownloadTaskStatus status) async {
//     _completedCount += 1;
//     print('completed download $_completedCount');
//     final stem = downloadedSet.downloadedStems.where((e) => e.downloadTaskId == id).first;
//     stem.filePath =
//         'Download${Platform.pathSeparator}${downloadedSet.setId}${Platform.pathSeparator}${stem.id}';
//     print(stem.filePath);
//     await _updateDownloadedSetLocalStorage();

//     if (onComplete != null && _completedCount == downloadedSet.downloadedStems.length) {
//       onComplete();
//       return true;
//     }
//     return false;
//   }

//   void calculateProgress(String id, int progress) {
//     progressMap[id] = progress;
//     int total = 0;
//     progressMap.forEach((key, value) {
//       total += value;
//     });
//     var stemDonwloadProgress =
//         total / downloadedSet.downloadedStems.length; //devide by total to stay between 0 and 100
//     print('Progress $stemDonwloadProgress');
//     downloadProgressSubject.add(stemDonwloadProgress);
//   }
// }
