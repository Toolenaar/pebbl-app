import 'dart:async';

import 'package:flutter/services.dart';

class AudioPlugin {
  static const MethodChannel _channel = const MethodChannel('pebbl_plugin/audio');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> initSet(String setName) async {
    final bool succes = await _channel.invokeMethod('initSet', {'name': setName});
    return succes;
  }

  static Future<bool> playSet(String setName) async {
    final bool succes = await _channel.invokeMethod('playSet', {'name': setName});
    return succes;
  }
}
