import 'dart:convert';

import 'package:pebbl/model/timer_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageHelper {
  static Future<String> getDownloadUrl(String storageUrl, FirebaseStorage storage) async {
    final ref = await storage.getReferenceFromUrl(storageUrl);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
}

class LocalStorage {
  static const String TOUR_KEY = 'TOUR_KEY';
  static const String AUTO_BREAK_TIMER_KEY = 'AUTO_BREAK_TIMER_KEY';
  static const String NIGHT_THEME_KEY = 'NIGHT_THEME_KEY';
  static const String DAY_THEME_KEY = 'DAY_THEME_KEY';
  static const String NIGHTMODE_ENABLED = 'NIGHTMODE_ENABLED';
  static Future saveTimerData(TimerData data) async {
    if (data == null) {
      await setString('TIMER_DATA', null);
      return;
    }

    final json = data.toJson();
    final String encoded = jsonEncode(json);
    await setString('TIMER_DATA', encoded);
  }

  static Future<TimerData> loadTimerData() async {
    final String encoded = await getString('TIMER_DATA');
    if (encoded == null) return null;
    final json = jsonDecode(encoded);
    return TimerData.fromJson(json);
  }

  static Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  static Future setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> getbool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(key);
  }
}
