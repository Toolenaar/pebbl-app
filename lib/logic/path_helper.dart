import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathHelper {
  static Future<String> createFolderIfNotExist(String name) async {
    var path = (await _findLocalPath()) + Platform.pathSeparator + name;

    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return path;
  }

  static Future<String> _findLocalPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return appDocPath;
  }
}
