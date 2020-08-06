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
  static Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }
}
