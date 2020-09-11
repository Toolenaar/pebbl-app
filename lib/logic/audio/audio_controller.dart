import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:rxdart/rxdart.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);
//List<MediaItem> queue;
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

/// Encapsulate all the different data we're interested in into a single
/// stream so we don't have to nest StreamBuilders.

class AudioController {
  AudioController() {
    AudioPlayer.setIosCategory(IosCategory.playback);
  }

  final BehaviorSubject<AudioSet> activeTrackSubject = BehaviorSubject.seeded(null);
  ValueStream<AudioSet> get activeTrackStream => activeTrackSubject.stream;

  static FirebaseStorage storage = FirebaseStorage();

  StreamSubscription<ScreenState> _screenStateSub;
  Stream<ScreenState> get screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) => ScreenState(queue, mediaItem, playbackState));

  List<AudioSet> _currentPlaylist = [];

  AudioSet setForMediaItem(MediaItem item) {
    final audioSet = _currentPlaylist.where((element) => item.id == element.playbackUrl);
    if (audioSet.isEmpty) return null;
    return audioSet.first;
  }

  AudioSet _setActiveTrack(MediaItem item) {
    var item = AudioService.currentMediaItem;
    if (item == null) return null;
    return setForMediaItem(item);
  }

  void init() {
    if (_screenStateSub == null) {
      _screenStateSub = screenStateStream.listen((event) {
        final mediaItem = event?.mediaItem;
        if (mediaItem != null) {
          activeTrackSubject.add(_setActiveTrack((mediaItem)));
        }
      });
    }
  }

  void dispose() {
    _screenStateSub.cancel();
    _screenStateSub = null;
  }

  void startPlaylistAtIndex(List<AudioSet> sets, int index) {
    _currentPlaylist = sets;
    _startPlaylist(index: index);
  }

  void shuffleStartPlaylist(List<AudioSet> sets, {bool startPlaying}) {
    final copy = sets.map((s) => s.copyWith()).toList();
    copy.shuffle();
    _currentPlaylist = copy;
    _startPlaylist();
  }

  Future<List<Map<String, dynamic>>> _playlistToMediaItems() async {
    List<Map<String, dynamic>> newQueue = [];
    for (AudioSet item in _currentPlaylist) {
      final url = await StorageHelper.getDownloadUrl(item.trackUrl, storage);
      item.playbackUrl = url;
      newQueue.add(MediaItem(
              id: url,
              title: item.name,
              artist: item.artist.name,
              album: item.category?.name ?? 'Pebbl',
              duration: Duration(seconds: item.duration))
          .toJson());
    }

    return newQueue.toList();
  }

  void _startPlaylist({int index}) async {
    await AudioService.stop();

    final trackQueue = await _playlistToMediaItems();

    final result = await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Pebbl',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,

      params: {'queue': trackQueue},
    );
    if (index != null) {
      final mediaId = trackQueue[index]['id'];
      AudioService.skipToQueueItem(mediaId);
    }
    // AudioService.play();
    //AudioService.addQueueItems(trackQueue);
  }

  void skipPrevious() {
    AudioService.skipToPrevious();
  }

  void pause() {
    AudioService.pause();
  }

  void play() {
    AudioService.play();
  }

  void skipNext() {
    AudioService.skipToNext();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> _queue;
  // var _queue = <MediaItem>[
  //   MediaItem(
  //     id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
  //     album: "Science Friday",
  //     title: "A Salute To Head-Scratching Science",
  //     artist: "Science Friday and WNYC Studios",
  //     duration: Duration(milliseconds: 5739820),
  //     artUri: "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  //   ),
  //   MediaItem(
  //     id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
  //     album: "Science Friday",
  //     title: "From Cat Rheology To Operatic Incompetence",
  //     artist: "Science Friday and WNYC Studios",
  //     duration: Duration(milliseconds: 2856950),
  //     artUri: "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  //   ),
  // ];
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  AudioProcessingState _skipState;
  bool _playing;
  bool _interrupted = false;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  void onStart(Map<String, dynamic> params) {
    final json = params['queue'];
    _queue = List<MediaItem>.from(json.map((i) => MediaItem.fromJson(i)));
    _playerStateSubscription =
        _audioPlayer.playbackStateStream.where((state) => state == AudioPlaybackState.completed).listen((state) {
      _handlePlaybackCompleted();
    });
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final bufferingState = event.buffering ? AudioProcessingState.buffering : null;
      switch (event.state) {
        case AudioPlaybackState.paused:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.playing:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.connecting:
          _setState(
            processingState: _skipState ?? AudioProcessingState.connecting,
            position: event.position,
          );
          break;
        default:
          break;
      }
    });

    AudioServiceBackground.setQueue(_queue);
    onSkipToNext();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.playing)
      onPause();
    else
      onPlay();
  }

  @override
  void onSkipToQueueItem(String mediaId) async {
    final item = _queue.where((i) => i.id == mediaId);
    if (item.isNotEmpty) {
      _queueIndex = _queue.indexOf(item.first);
      AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.setUrl(mediaItem.id);
      if (_playing) {
        onPlay();
      } else {
        _setState(processingState: AudioProcessingState.ready);
      }
    }
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    var newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) {
      if (newPos >= _queue.length) {
        newPos = 0;
      } else if (newPos < 0) {
        newPos = _queue.length - 1;
      }
    }
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0 ? AudioProcessingState.skippingToNext : AudioProcessingState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(processingState: AudioProcessingState.ready);
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
      AudioServiceBackground.sendCustomEvent('just played');
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  Future<void> onFastForward() async {
    await _seekRelative(fastForwardInterval);
  }

  @override
  Future<void> onRewind() async {
    await _seekRelative(-rewindInterval);
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _audioPlayer.playbackEvent.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    await _audioPlayer.seek(newPosition);
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _playing = false;
    _playerStateSubscription.cancel();
    _eventSubscription.cancel();
    await _setState(processingState: AudioProcessingState.stopped);
    // Shut down this task
    await super.onStop();
  }

  /* Handling Audio Focus */
  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    if (_playing) _interrupted = true;
    switch (interruption) {
      case AudioInterruption.pause:
      case AudioInterruption.temporaryPause:
      case AudioInterruption.unknownPause:
        onPause();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(0.5);
        break;
    }
  }

  @override
  void onAudioFocusGained(AudioInterruption interruption) {
    switch (interruption) {
      case AudioInterruption.temporaryPause:
        if (!_playing && _interrupted) onPlay();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(1.0);
        break;
      default:
        break;
    }
    _interrupted = false;
  }

  @override
  void onAudioBecomingNoisy() {
    onPause();
  }

  Future<void> _setState({
    AudioProcessingState processingState,
    Duration position,
    Duration bufferedPosition,
  }) async {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position;
    }
    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.pause,
        MediaAction.pause,
        MediaAction.seekTo
      ],
      processingState: processingState ?? AudioServiceBackground.state.processingState,
      playing: _playing,
      position: position,
      bufferedPosition: bufferedPosition ?? position,
      speed: _audioPlayer.speed,
    );
  }

  List<MediaControl> getControls() {
    if (_playing) {
      return [skipToPreviousControl, pauseControl, stopControl, skipToNextControl];
    } else {
      return [skipToPreviousControl, playControl, stopControl, skipToNextControl];
    }
  }
}
