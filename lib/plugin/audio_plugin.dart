import 'dart:async';

import 'package:flutter/services.dart';

class AudioPlugin {
  static const MethodChannel _channel = const MethodChannel('pebbl_plugin/audio');
  static const EventChannel _playbackEventchannel = const EventChannel('pebbl_plugin/playback');
  bool _isInitialized = false;

  void initEventChannel(Function(Object) onEvent, Function(Object) onError) {
    _playbackEventchannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  Future<bool> initSet(String setName, List<String> paths) async {
    if (_isInitialized) return true;
    _isInitialized = await _channel.invokeMethod('initSet', {'name': setName, 'paths': paths});
    return _isInitialized;
  }

  Future<bool> playSet(String setName) async {
    final bool succes = await _channel.invokeMethod('playSet', {'name': setName});
    return succes;
  }

  Future<bool> pauseSet(String setName) async {
    final bool succes = await _channel.invokeMethod('pauseSet', {'name': setName});
    return succes;
  }

  Future<bool> changeStemVolume(String stemName, double volume) async {
    final bool succes = await _channel.invokeMethod('changeStemVolume', {'name': stemName, 'volume': volume});
    return succes;
  }
}
