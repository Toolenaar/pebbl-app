import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:rxdart/rxdart.dart';

import '../../main.dart';

class AudioManager {
  AudioManager() {
    AudioPlayer.setIosCategory(IosCategory.playback);
    stateSub = AudioService.playbackStateStream.listen(_onStateChanged);
  }

  static FirebaseStorage storage = FirebaseStorage();
  List<AudioSet> activePlaylist;

  final BehaviorSubject<AudioSet> activeTrackSubject = BehaviorSubject.seeded(null);
  ValueStream<AudioSet> get activeTrackStream => activeTrackSubject.stream;
  AudioSet get activeTrack => activeTrackSubject.value;

  int _activeIndex = 0;
  StreamSubscription<PlaybackState> stateSub;

  PlaybackState _currentState;

  int get activeIndex {
    return _activeIndex;
    // final item = AudioService.currentMediaItem;
    // else return _audioManager.activePlaylist.indexOf(_audioManager.activeTrack);
  }

  void _onStateChanged(PlaybackState state) {
    _currentState = state;
    print(state.processingState.toString());

    if (state.processingState == AudioProcessingState.completed) {
      next();
    }
  }

  Future startPlaylist(List<AudioSet> playlist) async {
    //activeTrackSubject.add(audioSet);
    final mediaItems =
        playlist.map((a) => MediaItem(id: a.id, title: a.name, artist: a.artist.name, album: a.category.name)).toList();

    AudioService.addQueueItems(mediaItems);

    //var playbackUrl = await StorageHelper.getDownloadUrl(audioSet.trackUrl, storage);
    AudioService.pause();
    await AudioService.connect();
    AudioService.start(
        //  backgroundTaskEntrypoint: _myEntrypoint,
        // androidNotificationIcon: 'mipmap/ic_launcher',
        // params: {'url': playbackUrl},
        );
    AudioService.play();
  }

  void startPlayingAtIndex(List<AudioSet> audioSets, int index, {bool startPlaying = false}) {
    final copy = audioSets.map((s) => s.copyWith()).toList();
    activePlaylist = copy;
    _activeIndex = index;
    if (startPlaying) {
      //  playNew(activePlaylist[_activeIndex]);
    }
  }

  void shuffleStartPlaylist(List<AudioSet> audioSets, {bool startPlaying = false}) {
    final copy = audioSets.map((s) => s.copyWith()).toList();
    copy.shuffle();
    activePlaylist = copy;
    _activeIndex = 0;
    if (startPlaying) {
      //playNew(activePlaylist[_activeIndex]);
    }
  }

  Future play() async {
    AudioService.play();
  }

  Future pause() async {
    AudioService.pause();
  }

  void next() {
    _activeIndex += 1;
    if (_activeIndex == activePlaylist.length) {
      _activeIndex = 0;
    }
    // playNew(activePlaylist[_activeIndex]);
  }

  void previous() {
    _activeIndex -= 1;
    if (_activeIndex < 0) {
      _activeIndex = activePlaylist.length - 1;
    }
    // playNew(activePlaylist[_activeIndex]);
  }

  void dispose() async {
    await AudioService.disconnect();
    stateSub.cancel();
    AudioService.stop();
  }
}

//void _myEntrypoint() => AudioServiceBackground.run(() => AudioPlayerTask());

// class AudioPlayerTask extends BackgroundAudioTask {
//   //https://github.com/ryanheise/audio_service/wiki/Tutorial
//   //https://github.com/mohammadne/Audio_Service_Example

//   final _audioPlayer = AudioPlayer();

//   @override
//   Future<void> onStart(Map<String, dynamic> params) async {
//     // Broadcast that we're connecting, and what controls are available.
//     AudioServiceBackground.setState(
//         controls: [pauseControl, stopControl], playing: true, processingState: AudioProcessingState.connecting);
//     // Connect to the URL
//     await _audioPlayer.setUrl(params['url']);

//     // Now we're ready to play
//     _audioPlayer.play();
//     // Broadcast that we're playing, and what controls are available.
//     AudioServiceBackground.setState(
//         controls: [pauseControl, stopControl], playing: true, processingState: AudioProcessingState.ready);
//   }

//   @override
//   Future<void> onStop() async {
//     // Stop playing audio.
//     _audioPlayer.stop();
//     // Broadcast that we've stopped.
//     await AudioServiceBackground.setState(controls: [], playing: false, processingState: AudioProcessingState.stopped);
//     // Shut down this background task
//     await super.onStop();
//   }

//   @override
//   void onPlay() {
//     // Broadcast that we're playing, and what controls are available.
//     AudioServiceBackground.setState(
//         controls: [pauseControl, stopControl], playing: true, processingState: AudioProcessingState.ready);
//     // Start playing audio.
//     _audioPlayer.play();
//   }

//   @override
//   void onPause() {
//     // Broadcast that we're paused, and what controls are available.
//     AudioServiceBackground.setState(
//         controls: [playControl, stopControl], playing: false, processingState: AudioProcessingState.ready);
//     // Pause the audio.
//     _audioPlayer.pause();
//   }
// }
