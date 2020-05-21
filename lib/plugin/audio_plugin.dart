import 'dart:async';

import 'package:flutter/services.dart';

class AudioPlugin {
  static const MethodChannel _channel = const MethodChannel('pebbl_plugin/audio');

  bool _isInitialized = false;

  Future<bool> initSet(String setName) async {
    if (_isInitialized) return true;
    _isInitialized = await _channel.invokeMethod('initSet', {'name': setName});
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
